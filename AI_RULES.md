# AI_RULES.md — Mandatory AI-Assisted Development Standards
**System:** Ashvin FleetOS (AFOS)  
**Organization:** Startup Ashvin

---

## 1. Fundamental Principles (Documentation-Driven Development)
1. **Mandatory Documentation Verification Before Coding**:
   - The AI agent MUST NOT write, generate, or modify frontend code, backend code, database migrations, or configuration files without verifying the specifications in `docs/01-product/`, `docs/02-architecture/`, and `docs/03-ui-ux/`.
   - If user prompts contradict documented rules, prompt the user for clarification and update the relevant documentation first (*Documentation-First*).
2. **Decision Tracking & Rule Synchronization Mandate (Zero Hallucination)**:
   - Any architectural, UX, database, or workflow decision worth documenting **MUST** be documented immediately in the corresponding files in `docs/`.
   - Any decision that modifies, refines, or introduces operational rules **MUST** update `AI_RULES.md` and `docs/01-product/BUSINESS_RULES.md` in the exact same turn/commit.
   - Leaving architectural or design decisions as undocumented "implicit code-only knowledge" is strictly forbidden to prevent context drift and AI hallucinations in subsequent turns or sessions.
3. **Strict Adherence to MVP Scope**:
   - Never implement features categorized under **Phase 2 / Backlog** in `docs/01-product/MVP_SCOPE.md` (e.g., real-time background GPS tracking of renter mobile phones, automated foreign payment gateways, automated dynamic pricing algorithms, etc.).
4. **Consistent Naming & Terminology**:
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
1. **Zero-Tolerance for God Files & Hard 500-Line Ceiling**:
   - **Strict Hard Ceiling**: 500 lines per file maximum. Any file exceeding this limit is treated as a critical code smell ("God file") requiring immediate extraction.
   - **Warning Threshold**: Approaching 400 lines triggers mandatory refactoring before any new feature additions.
   - **Granular Line Count Thresholds**:
     - Methods / Functions: 5–20 lines (warning threshold > 30 lines).
     - Classes / Components: 100–250 lines (warning threshold > 300 lines).
     - Entire File: 100–300 lines ideal (**hard ceiling strictly under 500 lines**).
2. **Clean Code, SRP, and DRY Protocol**:
   - Strictly respect the **Single Responsibility Principle (SRP)**: every class, module, or component must own exactly one cohesive responsibility.
   - Strictly respect **DRY (Don't Repeat Yourself)**: centralize shared styles, decorators, converters, and validations.
   - **Structured & Tidy Extraction**: When decomposing an oversized file, place extracted subcomponents into tidy, dedicated sub-directories (`presentation/widgets/`, `domain/`, `data/`). Never create ad-hoc loose files.
3. **Modular Architecture & State Management**:
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
- Whenever an architectural or design decision is made (e.g., auth workflows, OTP simulation, name splitting, WAHA integration, E.164 phone formats), the decision **MUST** be recorded in the Decision Log of `docs/01-product/BUSINESS_RULES.md` and synced into `AI_RULES.md`.
- Outdated documentation is treated as a critical bug and a primary source of AI hallucination.

---

## 7. Multi-Tier Git Branching & Release Governance
1. **Branch Tier Hierarchy**:
   - `main` (**Production**): Represents battle-tested, deployed production software.
   - `staging` (**Pre-Production Integration**): Integration branch where completed features are assembled, tested against Docker Supabase and mock seed data, and reviewed for QA.
   - `feat/*`, `fix/*`, `chore/*`, `docs/*` (**Working Branches**): Dedicated branches for discrete tasks or milestone items.
2. **Strict Direct Push Prohibition**:
   - **DIRECT PUSH TO `staging` OR `main` IS STRICTLY FORBIDDEN.**
   - All code enters `staging` and `main` exclusively through Pull Requests (PRs).
3. **Pull Request Routing Rules**:
   - Working branches (`feat/*`, `fix/*`) **MUST** PR into `staging`. **NEVER directly into `main`**.
   - Promotion to production occurs exclusively via a verified PR from `staging` $\rightarrow$ `main`.
4. **Branch Creation Origin**:
   - Every working branch must branch off from the latest updated branch—either latest `staging` or an active dependency branch when chaining dependent milestones.
5. **Hotfix Workflow**:
   - Critical production patches branch from `main` as `hotfix/*`, PR into `main`, and must immediately be back-merged into `staging` to prevent regression.
6. **Commit Standard**:
   - Enforce Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
7. **No Force Push**:
   - Force pushing (`git push -f`) to `staging` or `main` is strictly prohibited.
