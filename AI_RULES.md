# AI_RULES.md — Mandatory AI-Assisted Development Standards
**System:** Ashvin FleetOS (AFOS)  
**Organization:** Startup Ashvin

---

## 1. Fundamental Principles (Documentation-Driven Development)
1. **Mandatory Documentation Verification Before Coding**:
   - The AI agent MUST NOT write, generate, or modify frontend code, backend code, database migrations, or configuration files without verifying the specifications in `docs/01-product/`, `docs/02-architecture/`, and `docs/03-ui-ux/`.
   - If user prompts contradict documented rules, prompt the user for clarification and update the relevant documentation first (*Documentation-First*).
2. **Strict Adherence to MVP Scope**:
   - Never implement features categorized under **Phase 2 / Backlog** in `docs/01-product/MVP_SCOPE.md` (e.g., real-time background GPS tracking of renter mobile phones, automated foreign payment gateways, automated dynamic pricing algorithms, etc.).
3. **Consistent Naming & Terminology**:
   - Official system name: **Ashvin FleetOS**.
   - Official acronym: **AFOS**.
   - Do not invent alternative names (e.g., AFO, FleetAshvin).

---

## 2. Data Integrity & Atomic Transactions
1. **Mandatory Atomic Audit Logging (Zero-Tolerance Bypass)**:
   - Every mutation involving:
     - Vehicle status (`vehicles.status`)
     - Vehicle odometer (`vehicles.current_odometer_km`)
     - Booking status (`bookings.status`)
     - KYC / identity verification (`bookings.identity_verified_by`)
     - Handover check-out (`handovers_checkout`) and return check-in (`returns_checkin`)
     - Financial transactions (down payment, final settlement, deposit hold/refund, penalties)
     **MUST** be recorded into `audit_logs` and/or `financial_entries` within the exact same database transaction (PostgreSQL ACID / Supabase RPC).
   - Audit logs and financial entries are strictly **APPEND-ONLY**. No query, API route, or application code may issue an `UPDATE` or `DELETE` on these tables.
2. **Odometer & Trip Accountability**:
   - Any increase in a vehicle's odometer reading must have a traceable origin:
     - Bound to a completed `returns_checkin` belonging to a `booking_id`.
     - Or an authorized manual correction by the `Owner` with documented justification.
   - The vehicle's `total_trip_count` must increment (+1) automatically upon completion of each `returns_checkin`.
3. **Anti-Double Booking Concurrency Guard**:
   - Unit and driver availability validations must not rely solely on client-side Flutter logic.
   - PostgreSQL transactional locking (`SELECT ... FOR UPDATE`) or exclusion constraints must be enforced at the database layer to prevent schedule overlaps.

---

## 3. Access Control & Storage Security
1. **Universal Row-Level Security (RLS)**:
   - All PostgreSQL tables must have RLS enabled (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`).
   - `Customer`: Restricted to viewing available vehicles, creating personal bookings, and viewing own records (`auth.uid() = user_id`).
   - `Field Staff`: Restricted to assigned handover tasks, recording inspection checklists, and uploading handover photos.
   - `Admin` & `Owner`: Full operational and administrative access as defined by the RBAC matrix.
2. **Private Storage Buckets for Sensitive Assets**:
   - The KYC identity bucket (`identity-docs`: ID cards, passports, driving licenses) is strictly **PRIVATE**. Access is only granted via short-lived Signed URLs (maximum 15 minutes validity).
   - Vehicle inspection photos (`inspection-photos`) and digital signatures (`signatures`) must also be protected behind RLS policies.

---

## 4. Code Standards & File Size Ceilings (< 500 Lines)
1. **Strict File Size Limits**:
   - All source files (Dart/Flutter, SQL scripts, edge functions):
     - Methods/Functions: 5–30 lines (warning threshold > 50 lines).
     - Classes/Components: 100–250 lines.
     - **Hard ceiling strictly under 500 lines per file**.
   - If a file approaches 400 lines, proactively decompose, extract, and refactor it into smaller modules following SRP and SOLID principles.
2. **Modular Architecture & State Management**:
   - Organize Flutter code by feature: `lib/features/<feature_name>/{data, domain, presentation}`.
   - Keep UI components free of business logic. Use Riverpod or Bloc consistently.

---

## 5. Internationalization (i18n) Rules
1. **Zero Hardcoded UI Strings**:
   - All user-facing strings must use localization keys (`AppLocalizations.of(context)!.<key>`).
2. **Tiered Language Scope**:
   - **Customer Portal**: Must support Indonesian (`id`) and English (`en`), with an extensible structure for future languages (`ja`, `ko`, `zh`).
   - **Admin / Staff Interface**: Dual language support in Indonesian (`id`) and English (`en`).

---

## 6. Documentation Synchronization Protocol
- Whenever a database table, column, or relationship changes, the developer/AI **MUST** update `docs/02-architecture/DATABASE_SCHEMA.md`.
- Whenever a business rule or validation formula changes, the developer/AI **MUST** update `docs/01-product/BUSINESS_RULES.md`.
- Outdated documentation is treated as a critical bug.
