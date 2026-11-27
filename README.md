# Ashvin FleetOS (AFOS)
**Integrated Car Rental Information and Sales Operating System**  
*Official Product of Startup Ashvin — Yogyakarta, Indonesia*

---

## 1. About Ashvin FleetOS (AFOS)
**Ashvin FleetOS (AFOS)** is an integrated fleet operations and sales management platform specifically engineered to meet the operational rigor of the car rental industry in Indonesia, with its primary operational launch in the Special Region of Yogyakarta.

AFOS bridges field operational workflows (handover, physical inspection, odometer audit tracking, scheduled preventive maintenance, and driver dispatch) with a multi-language online reservation portal tailored for both domestic and international travelers.

---

## 2. Core Principles & Key Architecture Values
1. **Documentation-Driven Development (3D)**: All architectural decisions, database schemas, and business rules are formally specified in the `docs/` directory prior to any application code implementation. Documentation serves as the *Single Source of Truth*.
2. **Physical Units vs. Service Packages Separation**: A single physical vehicle unit (license plate, VIN, engine number) can be marketed across multiple service packages (*Self-Drive* vs. *With Driver*, 12h/24h durations, in-town/out-of-town coverage) without compromising physical fleet availability.
3. **Atomic Audit Trail & Financial Ledger**: Every status transition, vehicle odometer increment, surcharge/penalty assessment, and management approval is atomically recorded in a single database transaction (*append-only*).
4. **Equal Citizen Flutter Client (Mobile & Desktop)**: A single adaptive Flutter codebase serves the mobility needs of *Field Staff* (camera inspection, touch *e-signature*) and the data-dense demands of *Owner/Admin* management (Gantt calendar, financial ledger, detailed audit logs).
5. **Tiered Internationalization (i18n)**: The *Customer Portal* features multi-language support (Indonesian & English, architected for rapid expansion to Japanese, Korean, and Mandarin), while the *Back-Office (Owner/Admin/Staff)* interface operates in Indonesian and English.

---

## 3. Repository Directory Structure

```text
AFOS-app/
├── README.md                           # Project overview, setup, and navigation
├── AI_RULES.md                         # Strict AI-assisted development guidelines
├── .env.example                        # Environment variable template
├── .gitignore                          # Standard Flutter & Supabase git ignore
├── docs/                               # 3D Documentation (Single Source of Truth)
│   ├── 01-product/
│   │   ├── PRD.md                      # Product vision, personas, & user journeys
│   │   ├── MVP_SCOPE.md                # MVP boundary vs. Phase 2+ Backlog
│   │   └── BUSINESS_RULES.md           # Business logic, validations, & operational formulas
│   ├── 02-architecture/
│   │   ├── SYSTEM_ARCHITECTURE.md      # Flutter client & Supabase stack architecture
│   │   └── DATABASE_SCHEMA.md          # PostgreSQL DDL, RLS, audit logs & ledger
│   ├── 03-ui-ux/
│   │   └── SCREEN_FLOWS.md             # Adaptive screen flows for mobile & desktop
│   └── 04-execution/
│       └── ROADMAP_TASKS.md            # Phased roadmap milestones and execution tasks
├── supabase/                           # Backend & Database Engine
│   ├── config.toml                     # Supabase CLI configuration
│   ├── seed.sql                        # Initial seed data for master entities
│   └── migrations/                     # Ordered SQL migration files
└── app/                                # Frontend Flutter Application (Mobile & Desktop)
    ├── lib/                            # Modular, feature-driven Flutter source code
    └── test/                           # Unit, widget, & integration test suites
```

---

## 4. Development Environment Prerequisites
- **Flutter SDK**: `>= 3.22.0` (Stable Channel)
- **Dart SDK**: `>= 3.4.0`
- **Docker Desktop**: `>= 24.0` (Required to run the local Supabase stack)
- **Supabase CLI**: `>= 1.160.0`
- **Git**: `>= 2.30`

---

## 5. Local Development Quickstart

### Step 1: Clone Repository & Prepare Environment File
```bash
cp .env.example .env
```

### Step 2: Start Local Supabase Stack (Docker)
```bash
supabase start
```
This boots Docker containers for PostgreSQL, Supabase Studio, GoTrue Auth, Storage, and the API Gateway.
- **Supabase Studio URL**: `http://localhost:54323`
- **API URL**: `http://localhost:54321`
- **Database Connection**: `postgresql://postgres:postgres@localhost:54322/postgres`

### Step 3: Run Database Migrations & Seeding
```bash
supabase db reset
```

### Step 4: Launch the Flutter Application
```bash
cd app
flutter pub get
# For desktop development (e.g. Windows):
flutter run -d windows
# For mobile development (e.g. Android emulator):
flutter run -d android
```

---

## 6. Multi-Tier Git Branching & Release Workflow

```
[feat/* or fix/*] ──► Pull Request ──► [staging] ──► Verified Release PR ──► [main (Production)]
                                           ▲
                                           │ (back-merge hotfixes)
[hotfix/*] ─────────► Critical Patch ──────┴───────────────────────────────► [main (Production)]
```

- **`main` (Production)**: Deployable, battle-tested production releases. Direct pushes and direct PRs from feature branches are **strictly forbidden**.
- **`staging` (Pre-Production)**: Active integration branch. All feature work must PR into `staging`.
- **`feat/*`, `fix/*`, `chore/*`**: Isolated working branches branched from the latest updated branch (`staging` or dependency branch).
- **Promotion to Production**: Only merged from `staging` $\rightarrow$ `main` after complete testing and verification.
- **Hotfixes**: `hotfix/*` branches from `main`, patches critical issues, PRs into `main`, and back-merges into `staging`.
- **Commit Standards**: Enforce [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`).

---

## 7. Documentation Navigation
Before proposing or writing application code, read the following specifications:
- Read [AI Development Rules](file:///k:/Personal/AshvinFleetOS/AFOS-app/AI_RULES.md).
- Read [Product Requirements Document (PRD)](file:///k:/Personal/AshvinFleetOS/AFOS-app/docs/01-product/PRD.md).
- Read [MVP Scope vs. Backlog](file:///k:/Personal/AshvinFleetOS/AFOS-app/docs/01-product/MVP_SCOPE.md).
- Read [Business Rules & Validation Logic](file:///k:/Personal/AshvinFleetOS/AFOS-app/docs/01-product/BUSINESS_RULES.md).
- Read [System Architecture Specification](file:///k:/Personal/AshvinFleetOS/AFOS-app/docs/02-architecture/SYSTEM_ARCHITECTURE.md).
- Read [Database Schema & Data Models](file:///k:/Personal/AshvinFleetOS/AFOS-app/docs/02-architecture/DATABASE_SCHEMA.md).
- Read [UI/UX Screen Flows](file:///k:/Personal/AshvinFleetOS/AFOS-app/docs/03-ui-ux/SCREEN_FLOWS.md).
- Read [Execution Roadmap & Milestones](file:///k:/Personal/AshvinFleetOS/AFOS-app/docs/04-execution/ROADMAP_TASKS.md).
