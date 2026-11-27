# System Architecture Specification — Ashvin FleetOS (AFOS)
**Integrated Car Rental Information and Sales Operating System**  
*Unified B2C & B2B Architecture — Flutter Client & Supabase Engine*

---

## 1. High-Level System Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ASHVIN FLEETOS CLIENT                           │
│                      (Single Flutter Codebase)                         │
│                                                                        │
│   ┌──────────────────────────────┐    ┌────────────────────────────┐   │
│   │   Mobile Client (Android/iOS)│    │ Desktop Client (Win/macOS) │   │
│   │   - Handover Check-out/Check-in   │    │ - Fleet Master & Schedule  │   │
│   │   - Camera / Photo Inspections    │    │ - B2B Multi-Unit Dispatch  │   │
│   │   - Touch E-Signature Pad         │    │ - Corporate Invoicing & TOP│   │
│   │   - Customer Online B2C Portal    │    │ - Audit Logs & Cash Ledger │   │
│   └───────────────┬──────────────┘    └─────────────┬──────────────┘   │
└───────────────────┼─────────────────────────────────┼──────────────────┘
                    │ HTTPS / WebSockets              │
                    ▼                                 ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   SUPABASE BACKEND STACK (LOCAL DOCKER)                │
│                                                                        │
│  ┌──────────────────────┐ ┌───────────────────┐ ┌───────────────────┐  │
│  │    GoTrue (Auth)     │ │ Storage Engine    │ │ Realtime Engine   │  │
│  │  - JWT & RBAC Claims │ │ - KYC & KYB Docs  │ │ - Fleet status    │  │
│  │  - B2C Retail Users  │ │ - Damage Photos   │ │ - Schedule sync   │  │
│  │  - Staff / Admin / PO│ │ - E-Signatures    │ │                   │  │
│  └──────────┬───────────┘ └─────────┬─────────┘ └─────────┬─────────┘  │
│             │                       │                     │            │
│  ┌──────────▼───────────────────────▼─────────────────────▼─────────┐  │
│  │                  PostgreSQL 15+ Core Engine                       │  │
│  │  - Unified B2C & B2B Relational Models (Bookings & Items 1:N)     │  │
│  │  - Row-Level Security (RLS) across all operational tables         │  │
│  │  - Stored Procedures / RPC for Atomic Multi-Table Mutations       │  │
│  │  - Append-Only Atomic Audit Trail & Financial Cash/Invoice Ledger │  │
│  │  - Temporal Locking Preventing Double-Booking Race Conditions     │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Flutter Client Architecture (Equal Citizen Mobile & Desktop)

### 2.1. Responsive Multi-Platform Strategy
The Flutter application uses a single unified codebase tailored to both operational mobility and administrative depth:
- **Responsive Breakpoints**:
  - `Compact (Phone)`: Screen width $< 600\text{ dp}$ (Field staff inspections, quick check-out/check-in, B2C customer portal).
  - `Medium (Tablet)`: Screen width $600\text{ dp} - 1024\text{ dp}$ (Office reception, fast booking confirmation).
  - `Expanded (Desktop)`: Screen width $> 1024\text{ dp}$ (Full corporate B2B multi-vehicle builder, interactive Gantt fleet schedule, invoice reconciliation, and detailed audit log tables).

### 2.2. Modular Feature-Driven Project Layout
```
app/lib/
├── core/
│   ├── config/             # Environment variables, themes, and constants
│   ├── localization/       # i18n engine and l10n delegate loaders
│   ├── network/            # Supabase client singleton and error handlers
│   ├── storage/            # Local cache (tokens, preferences)
│   └── widgets/            # Shared adaptive widgets (ResponsiveLayout, AFOSButton)
└── features/
    ├── auth/               # Authentication and RBAC state
    ├── fleet/              # Physical fleet units and maintenance alerts
    ├── packages/           # Commercial service packages (Self-Drive / Driver)
    ├── corporate/          # B2B corporate accounts, contracts, and credit limits
    ├── booking/            # Master bookings, booking items (1:N), and scheduling
    ├── operations/         # Handover, Check-out, Check-in, Odometer, & E-Signatures
    ├── finance/            # Cash ledger, B2C deposits, and B2B invoices (TOP)
    └── audit/              # Atomic audit logs and actor activity tracking
```

---

## 3. Tiered Internationalization (i18n / L10n)
1. **Customer-Facing Portal (Domestic & International Travelers)**:
   - Mandatory Languages: **Indonesian (`id`)** and **English (`en`)**.
   - Architecture modularly extensible to Japanese (`ja`), Korean (`ko`), and Mandarin (`zh`).
2. **Back-Office Interface (Owner, Admin/CS, Field Staff)**:
   - Operational dual-language support: **Indonesian (`id`)** and **English (`en`)**.

---

## 4. Supabase Backend Integration & Security

### 4.1. Row-Level Security (RLS) & RBAC Matrix
User roles are stored in `user_profiles.role` and embedded into Supabase Auth JWT claims:
- `CUSTOMER`: Can read available listings, create personal booking drafts, and manage personal KYC records (`auth.uid() = user_id`).
- `FIELD_STAFF`: Can view assigned unit dispatches, perform check-out and check-in inspections, and upload photos.
- `ADMIN`: Can verify KYC/KYB documents, manage corporate accounts, allocate multi-vehicle dispatches, and issue invoices.
- `OWNER`: Full administrative access, manual odometer corrections, financial ledger reporting, and complete audit log visibility.

### 4.2. Storage Security
| Storage Bucket | Access Type | Visibility & Rules |
|---|---|---|
| `public-assets` | Public (Read) | Vehicle catalog photographs. |
| `identity-docs` | **Private** | Personal KYC and Corporate KYB documents (NIB, NPWP). Signed URLs only (max 15 mins). |
| `inspection-photos`| **Private** | Handover and return inspection photographs. |
| `signatures` | **Private** | Digital e-signatures captured during handover and return. |

---

## 5. Unified B2C & B2B Atomic Data Engine

### 5.1. Decoupled Parent-Child Booking Model
- `bookings` (Parent): Represents the commercial agreement, customer/corporate entity, and billing mode.
- `booking_items` (Child 1:N): Represents individual vehicle and driver allocations. A retail B2C order has exactly 1 child; a corporate B2B order has 1 to $N$ children.

### 5.2. Atomic Stored Procedures (RPC)
- `rpc_create_booking_atomic()`: Locks target vehicles and drivers, verifies schedule collisions for all requested items, and writes parent booking and item records in a single transaction.
- `rpc_process_checkout_atomic()`: Records check-out inspection data per item, sets item to `ON_RENTAL`, and writes audit records atomically.
- `rpc_process_checkin_atomic()`: Records check-in inspection data, computes $\Delta\text{KM}$, updates vehicle odometer and trip count, evaluates maintenance thresholds, calculates penalties, and updates the financial invoice atomically.
- `rpc_swap_vehicle_sla_atomic()`: Handles emergency vehicle breakdown swaps under corporate SLA without terminating the parent agreement.
