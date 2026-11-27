# Product Requirements Document (PRD) — Ashvin FleetOS (AFOS)
**Integrated Car Rental Information and Sales Operating System**  
*Startup Ashvin Initiative — Yogyakarta, Indonesia*

---

## 1. Product Vision
**Ashvin FleetOS (AFOS)** is a modern, integrated fleet operations and sales management platform designed to automate both retail (**B2C**) and corporate (**B2B**) vehicle rental lifecycles in the Special Region of Yogyakarta and surrounding markets.

AFOS solves foundational challenges in conventional car rental businesses: error-prone manual odometer recording, missed scheduled maintenance, double-booking risks between self-drive and with-driver packages, and leakages in security deposit and cash reconciliation.

---

## 2. Target Users & Personas

### 2.1. Domestic Traveler (Persona: "Rian" — B2C Retail)
- **Profile**: Vacationing family or solo traveler from Jakarta/Surabaya visiting Yogyakarta.
- **Key Needs**: Fast smartphone reservation, transparent service package pricing (Self-Drive vs. With Driver), digital down payment/deposit, and friction-free handover upon arrival.
- **Preferred Language**: Indonesian (`id`).

### 2.2. International Traveler (Persona: "Elena" — B2C Retail)
- **Profile**: Foreign tourist (backpacker or expatriate) exploring Borobudur, Prambanan, and heritage sites.
- **Key Needs**: English interface (with future Japanese/Korean/Mandarin support), passport and International Driving Permit validation, clear deposit terms, and standardized digital agreements.
- **Preferred Language**: English (`en`).

### 2.3. Corporate Client / Event Organizer (Persona: "Denny" — B2B Corporate)
- **Profile**: General Affairs Manager or Event Organizer arranging transportation for a 3-day government conference or corporate delegation in Yogyakarta.
- **Key Needs**: Multi-vehicle bookings under a single Purchase Order (PO/SPK), corporate billing with Terms of Payment (TOP 14/30 days), tax invoicing (PPN 11%, PPh 23), and guaranteed replacement car SLAs in case of vehicle breakdown.
- **Platform**: Desktop / Admin-assisted booking.
- **Language**: Indonesian / English.

### 2.4. Business Owner (Persona: "Mr. Ashvin")
- **Profile**: Founder and proprietor of Ashvin Car Rental.
- **Key Needs**: Real-time fleet utilization visibility, proactive service alerts, guaranteed odometer reading integrity, corporate credit limit enforcement, and an immutable audit trail for every monetary movement.
- **Platform**: Desktop (wide screen for deep analytics and audit logs) and Mobile for on-the-go monitoring.
- **Language**: Indonesian / English.

### 2.5. Administrator & Customer Service (Persona: "Maya")
- **Profile**: Office staff responsible for reviewing online B2C bookings, managing corporate B2B accounts, validating KYC documents, and assigning drivers.
- **Key Needs**: Visual anti-conflict booking calendar, fast reservation status transitions, corporate billing generation, and structured KYC document review workflows.
- **Platform**: Desktop / Office tablet.
- **Language**: Indonesian / English.

### 2.6. Field Staff & Drivers (Persona: "Budi")
- **Profile**: Mobile staff delivering vehicles or professional chauffeurs serving B2C tourists and B2B corporate delegations.
- **Key Needs**: Mobile-optimized checklist for physical vehicle inspections, recording odometer readings and fuel levels, and collecting touch e-signatures on digital delivery receipts.
- **Platform**: Mobile (Android/iOS).
- **Language**: Indonesian.

---

## 3. End-to-End User Journeys

### 3.1. B2C Retail Journey
```
[Customer]             [Admin / CS]            [Field Staff]           [AFOS System]
     │                      │                        │                       │
     ├─ Select Unit & Pkg ──┼────────────────────────┼──────────────────────►│
     ├─ Upload KYC Docs ────┼────────────────────────┼──────────────────────►│
     ├─ Sign Terms & DP ────┼────────────────────────┼──────────────────────►│
     │                      ├─ Verify Documents ─────┼──────────────────────►│ Lock Unit / Driver
     │                      ├─ Confirm Reservation ──┼──────────────────────►│ Status: CONFIRMED
     │  ── Check-Out ──     │                        ├─ Inspect Body & KM ───►│ Status: ON_RENTAL
     │  ── Check-In ──      │                        ├─ Record End KM & Fuel ─►│ Auto Calc Delta KM
     │                      ├─ Settle Deposit ───────┼──────────────────────►│ Atomic Audit Logged
```

### 3.2. B2B Corporate Journey
```
[Corporate PIC]        [Admin / CS]            [Field Staff]           [AFOS System]
     │                      │                        │                       │
     ├─ Register Company ───┼────────────────────────┼──────────────────────►│ Check Credit Limit
     ├─ Issue PO / SPK ─────┼────────────────────────┼──────────────────────►│ Multi-Unit Lock
     │  (e.g., 5 Cars+Driv) │                        │                       │ (Parent + Items)
     │                      ├─ Approve B2B Booking ──┼──────────────────────►│ Status: CONFIRMED
     │  ── Check-Out ──     │                        ├─ Inspect Each Unit ───►│ Items: ON_RENTAL
     │  [Breakdown Alert] ──┼────────────────────────┼─ Dispatch Backup Unit ─►│ SLA: Swap Vehicle
     │  ── Check-In ──      │                        ├─ Return Inspections ──►│ Items: COMPLETED
     │                      ├─ Generate Tax Invoice ─┼──────────────────────►│ TOP 14/30 Days Ledger
```

---

## 4. Key Functional Requirements
1. **Unified Fleet & Package Catalog**: Present physical vehicle units coupled to distinct service options (Self-Drive vs. With Driver, 12h/24h durations, In-Town vs. Out-of-Town).
2. **Multi-Unit B2B Order Scaffolding**: Support parent bookings containing 1 to $N$ vehicle items under a single purchase order or corporate agreement.
3. **Identity & Corporate Verification (KYC/KYB)**: Personal ID for B2C; Tax ID (NPWP) and Business ID (NIB) with designated PIC for B2B.
4. **Mobile-First Staff Check-Out & Check-In**: Digital odometer capture, fuel level tracking, 8-point inspection with photos, and dual touch e-signatures.
5. **Service Level Agreement (SLA) & Maintenance Alerts**: Replacement vehicle swap support during breakdown, milestone tracking for general service (5,000 KM), oil change (10,000 KM), and STNK tax reminders.
6. **Append-Only Financial Ledger & Billing**: Tracking B2C down payments/deposits and B2B corporate receivables (TOP 14/30 days, PPN 11%, PPh 23 withholding tax).
