# Roadmap & Task Execution Plan — Ashvin FleetOS (AFOS)
**Integrated Car Rental Information and Sales Operating System**  
*Step-by-Step Phased Execution Plan (Documentation-Driven Development)*

---

## 1. Target Repository Structure

```text
AFOS-app/
├── docs/                               # 3D Documentation (Single Source of Truth)
├── supabase/
│   ├── config.toml                     # Supabase CLI configuration
│   ├── seed.sql                        # Initial master seed data & test fixtures
│   └── migrations/
│       ├── 20261127000001_core_schema.sql         # user_profiles, corporate_accounts, vehicles, packages, drivers
│       ├── 20261127000002_booking_operations.sql  # bookings (parent), booking_items (1:N), handovers, returns
│       ├── 20261127000003_audit_and_finance.sql   # financial_invoices, financial_entries, audit_logs, triggers
│       └── 20261127000004_rls_policies.sql        # RLS policies, storage buckets, & atomic RPC procedures
└── app/
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── core/
        │   ├── config/                 # Environment configuration & theme
        │   ├── localization/           # Multi-language l10n engine (ID, EN, +extensible)
        │   ├── network/                # Supabase client singleton
        │   └── widgets/                # Adaptive layout helpers
        └── features/
            ├── auth/
            ├── fleet/
            ├── corporate/              # B2B corporate accounts and credit terms
            ├── booking/                # Master bookings & booking items (1:N)
            ├── operations/             # Handover, Check-out, Check-in, Odometer, E-Signatures
            ├── finance/                # Cash ledger, B2C deposits, & B2B invoicing
            └── audit/
```

---

## 2. Phased MVP Milestone Plan

### Milestone 1: Local Docker Supabase, Database Schema & Atomic Audit Trail
- **Objective**: Establish the isolated local backend environment via Docker and validate atomic transactional integrity across the unified B2C & B2B schema before writing frontend code.
- **Specific Tasks**:
  1. Initialize local Supabase project (`supabase init`).
  2. Implement migration `20261127000001_core_schema.sql` (master tables: `user_profiles`, `corporate_accounts`, `vehicles`, `rental_packages`, `drivers`).
  3. Implement migration `20261127000002_booking_operations.sql` (`bookings` parent, `booking_items` 1:N, `handovers_checkout`, `returns_checkin`).
  4. Implement migration `20261127000003_audit_and_finance.sql` (`financial_invoices`, `financial_entries`, `audit_logs`, append-only triggers).
  5. Implement migration `20261127000004_rls_policies.sql` (4-tier RBAC policies, storage bucket rules, atomic stored procedures `rpc_create_booking_atomic`, `rpc_process_checkout_atomic`, `rpc_process_checkin_atomic`, and `rpc_swap_vehicle_sla_atomic`).
  6. Populate `seed.sql` with realistic Yogyakarta car rental fixtures (Avanza, Innova Reborn, Brio, Self-Drive and With-Driver packages, sample corporate client PT Jogja Tour, and test users).
- **Verification Criteria**:
  - `supabase db reset` executes cleanly with zero errors.
  - SQL verification confirms that `UPDATE` and `DELETE` on `audit_logs` and `financial_entries` are rejected by database triggers.

---

### Milestone 2: Adaptive Flutter Foundation & i18n Architecture
- **Objective**: Set up the cross-platform Flutter project supporting Mobile and Desktop equally with modular multi-language capabilities.
- **Specific Tasks**:
  1. Initialize Flutter application inside the `app/` directory.
  2. Configure `flutter_localizations` with initial dictionary files `app_id.arb` and `app_en.arb`.
  3. Structure modular feature folders under `core/` and `features/`, adhering to the strict $< 500$ lines per file ceiling.
  4. Implement `ResponsiveLayout` (Compact vs. Expanded) and the AFOS design theme.
  5. Configure `supabase_flutter` connected to the local Docker gateway.

---

### Milestone 3: Authentication & Multi-Language Customer Portal (B2C Focus)
- **Objective**: Enable domestic and international travelers to browse fleet inventory and submit online bookings.
- **Specific Tasks**:
  1. Email/password authentication and user profile management.
  2. Dynamic language switcher (ID $\leftrightarrow$ EN) in the customer portal.
  3. Fleet catalog screen with filtering by service type (Self-Drive vs. With Driver).
  4. Booking & KYC submission form: Secure upload of National ID / Passport / Driver's License to private Supabase Storage.
  5. Single-unit reservation creation backed by the decoupled `bookings` and `booking_items` schema.

---

### Milestone 4: Field Staff Operations Module (Mobile-First Handover)
- **Objective**: Provide mobile field staff with an efficient handover and return workflow per vehicle item.
- **Specific Tasks**:
  1. Daily scheduled task list for field personnel with unit badges for retail vs. corporate dispatches.
  2. Mobile Check-Out form: Starting odometer & fuel slider input, 8-point photo inspection capture, and dual touch e-signature pads.
  3. Mobile Check-In form: Return odometer input, automated $\Delta\text{KM}$ calculation, overtime/fuel penalty computation, and return sign-off.
  4. Atomic invocation of `rpc_process_checkin_atomic`: updates vehicle odometer, increments trip count (+1), evaluates maintenance alerts (5,000 / 10,000 KM), and writes an atomic audit record.

---

### Milestone 5: Management Dashboard & B2B Corporate Scaffolding (Desktop Focus)
- **Objective**: Provide Owner and Admin with fleet schedule visibility, B2B corporate order creation, and financial ledger management.
- **Specific Tasks**:
  1. Fleet KPI overview and interactive vehicle/driver Gantt schedule.
  2. B2B Corporate Account Manager: Register corporate profiles, tax details, and credit limits.
  3. Multi-Vehicle B2B Order Builder: Form allowing Admin to dispatch multiple vehicles and drivers under one PO with Terms of Payment (TOP 14/30).
  4. Preventive maintenance dashboard (5,000 KM service, 10,000 KM oil change) and STNK tax expiration alerts.
  5. Financial ledger & invoicing module: Down payments, deposit holds, and corporate tax invoice generation (PPN 11%, PPh 23).
  6. Atomic audit trail viewer: Searchable event table tracking all status changes, odometer increments, and actor approvals.

---

### Milestone 6: End-to-End Integration, Security Audit & Finalization
- **Objective**: Ensure complete end-to-end system reliability and compliance prior to production release.
- **Specific Tasks**:
  1. Concurrency testing for simultaneous booking attempts on the same vehicle across B2C and B2B orders.
  2. Security audit of private storage buckets and Signed URL expiration.
  3. Code cleanliness verification: Ensure all source files remain strictly under 500 lines and free of hardcoded UI strings.
  4. Compilation of the comprehensive end-user operational manual.
