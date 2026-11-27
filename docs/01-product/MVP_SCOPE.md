# MVP Scope vs. Backlog Roadmap — Ashvin FleetOS (AFOS)
**Integrated Car Rental Information and Sales Operating System**  
*Startup Ashvin — Product Boundary & Phasing Guidelines*

---

## 1. Scope Definition Principles
The development of **Ashvin FleetOS (AFOS)** follows an architecture-first approach:
- **MVP (Phase 1 — Core Operations & Unified B2C/B2B Engine)**: Focuses on core rental operations, anti-double-booking concurrency, odometer tracking accuracy, owner financial protection, mobile vehicle handover/return inspections, atomic audit logging, and a **B2B-ready unified schema** with admin-assisted corporate booking scaffolding.
- **Phase 2+ (Backlog / Future Enhancements)**: Focuses on customer self-service corporate web portals, telemetry tracking, and external payment gateway integrations.

---

## 2. MVP Features (Phase 1 — Mandatory & Fully Tested)

| Module | MVP Feature | Functional Specification |
|---|---|---|
| **Fleet & Catalog** | Physical Unit vs. Service Package | A physical vehicle can be booked under *Self-Drive* or *With Driver*, 12h/24h durations, In-Town or Out-of-Town coverage. |
| **Unified Order Engine** | Parent Booking & Booking Items (1:N) | Decoupled order schema: 1 booking item for B2C retail; 1 to $N$ vehicle items for B2B multi-unit corporate orders. |
| **B2C Online Reservation** | Digital Booking & KYC Submission | Customer booking form, document upload (KTP/Passport, SIM/IDP), emergency contacts, digital terms acceptance. |
| **B2B Corporate Scaffolding** | Corporate Accounts & Admin Dispatch | Management of `corporate_accounts` (NPWP, NIB, credit limits, TOP 14/30) and admin-assisted multi-vehicle corporate bookings. |
| **Concurrency Guard** | Anti-Double Booking Engine | Database-level locking guarantees no overlapping rentals for the same physical unit or driver across B2C and B2B orders. |
| **Field Check-Out** | Mobile Handover Workflow | 8-point inspection checklist, photo uploads of existing scratches, start odometer & fuel level, dual touch e-signatures per unit. |
| **Field Check-In** | Return Workflow & Auto Delta KM | End odometer & fuel input, automated $\Delta\text{KM}$ calculation, overtime/fuel penalty computation, return photos & e-signature. |
| **Fleet Maintenance & SLA** | Service Alerts & Vehicle Replacement | Threshold alerts for routine service (5,000 KM), oil change (10,000 KM), tax due dates, and admin vehicle swap support for breakdowns. |
| **Audit & Integrity** | Atomic Audit Trail | Immutable (*append-only*) log of all status transitions, odometer changes, approvals, and vehicle trip counts. |
| **Financial Ledger** | Cash & Corporate Invoicing Ledger | Tracking retail DP/settlement/deposits and corporate receivables (Terms of Payment, PPN 11%, PPh 23 withholding tax). |
| **Access Control** | 4-Tier RBAC | Role separation for `Customer`, `Field Staff/Driver`, `Admin/CS`, and `Owner`. |
| **Localization (i18n)** | Tiered Multi-Language | Customer Portal: Indonesian (`id`) & English (`en`) (modular for `ja`, `ko`, `zh`). Admin/Staff: `id` & `en`. |

---

## 3. Backlog (Phase 2+ — STRICTLY EXCLUDED from MVP)

> [!WARNING]
> The AI agent MUST NOT implement frontend portals or external third-party API clients for the features below during MVP development.

### 3.1. Corporate Self-Service Web Portal
- **Description**: Dedicated self-service web dashboard for enterprise clients to log in, view available contracted credit limits, self-dispatch multi-car requests, and download e-faktur tax invoices.
- **MVP Workaround**: Admin/CS inputs and manages corporate orders directly on the desktop management dashboard.

### 3.2. Renter Mobile Background Geolocation Tracking
- **Description**: Real-time GPS location tracking using background smartphone permissions of the active renter as an alternative security layer for vehicles lacking hardware OBD-II GPS modules.
- **Rationale for Phase 2 Deferral**: Requires specialized legal consent workflows under personal data protection regulations, complex battery drain mitigation, and offline caching for regional dead zones.

### 3.3. Automated Payment Gateway Integration (Xendit / Midtrans / Doku)
- In the MVP, B2C payments are validated via manual transfer verification, and B2B operates on Terms of Payment (TOP) invoicing. Automated payment gateway integration is deferred to Phase 2.

### 3.4. IoT Hardware Telematics Integration (OBD-II / CAN bus Tracker)
- Direct hardware telematics integration for automatic odometer sync and speed tracking is deferred to Phase 2.

---

## 4. MVP Definition of Done (DoD)
1. Concurrency testing confirms zero possibility of overlapping bookings for the same vehicle unit across B2C and B2B items.
2. Multi-vehicle corporate orders can be created under a single parent booking without database schema modifications.
3. Every odometer increment on a vehicle record has an accountable, traceable event in the audit log.
4. Every handover and return contains digital signatures and time-stamped inspection photos.
5. Invoicing ledger accurately distinguishes B2C cash settlements from B2B accounts receivable with payment terms.
