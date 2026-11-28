# UI/UX Screen Flows & Adaptive Layouts — Ashvin FleetOS (AFOS)
**Integrated Car Rental Information and Sales Operating System**  
*Flutter User Interface & Interaction Specifications (Mobile & Desktop)*

---

## 1. UI/UX Design Principles
1. **Design System & Brand Suite Fidelity**: All visual tokens, color swatches, typography (Plus Jakarta Sans/Inter & JetBrains Mono), and status badges MUST strictly conform to `docs/03-ui-ux/BRAND_GUIDELINES.md`.
2. **Adaptive & Responsive First**: Layouts dynamically adjust between smartphones (360–430 dp), tablets (600–900 dp), and desktop workstations (1280–1920 dp).
3. **Mobile Field Efficiency**: Field staff screens feature thumb-friendly touch targets, minimal tap friction, high-contrast outdoor visibility, and immediate camera/signature interactions per vehicle unit.
4. **High Information Density for Desktop**: Administrative interfaces for Owner and Admin prioritize productivity: horizontal Gantt fleet calendars, multi-unit B2B order builders, corporate billing reconciliations, and JSON audit log diff viewers.
5. **Intuitive Multi-Language Switching**: Persistent language selector in the top-right header for customer portals (switching dynamically between Indonesian and English).

---

## 2. Role-Based Navigation Architecture

### 2.1. Customer Portal Navigation (B2C Retail — Mobile & Web View)
- **Fleet Catalog (`/catalog`)**:
  - Filters: Vehicle Brand, Transmission (Manual/Automatic), Seating Capacity, Package Type (Self-Drive / With Driver).
  - Vehicle Cards: High-resolution photo, key specifications, daily base rate, real-time availability badge.
- **Package Details & Booking (`/booking/new`)**:
  - Date & time picker (automatically enforces minimum duration and 60-minute cleaning buffer).
  - Package selection (12h / 24h, In-Town / Out-of-Town, Exclude / Include Fuel).
  - KYC Form: Image upload for National ID / Passport, Driving License / International Driving Permit, emergency contact details.
  - Cost Breakdown: Rental base fee, refundable security deposit, down payment requirement (30%).
- **My Bookings (`/my-bookings`)**:
  - Reservation history, KYC verification status, pickup instructions, and signed handover receipts.

### 2.2. Field Staff Navigation (Mobile-First Handover App)
- **Daily Handover Tasks (`/staff/tasks`)**:
  - Tabs: "Scheduled Check-Outs (Departures)" and "Expected Check-Ins (Returns)". Lists individual vehicle dispatches (booking items) with badges for B2C retail vs. B2B corporate events.
- **Check-Out Handover Flow (`/staff/checkout/:bookingItemId`)**:
  1. *Identity Verification*: Verify customer in-person with uploaded KYC photo or authorized corporate delegate.
  2. *Odometer & Fuel Recording*: Input starting odometer ($\ge \text{current odometer}$) and fuel level slider (1–8 scale).
  3. *8-Point Body Inspection*: Interactive vehicle diagram (Front, Rear, Left, Right, Roof, Interior, Spare Tire, Windows). Photograph pre-existing blemishes.
  4. *Digital Handover & E-Signature*: Recipient and staff draw e-signatures on the mobile touch pad to generate the digital delivery receipt.
- **Check-In Return Flow (`/staff/checkin/:bookingItemId`)**:
  1. *Odometer & Fuel Input*: Record return odometer and fuel level. System instantly calculates $\Delta\text{KM} = \text{KM End} - \text{KM Start}$.
  2. *Post-Rental Inspection*: Re-evaluate the 8-point body diagram. Flag new damages for deposit deductions (B2C) or corporate billing (B2B).
  3. *Instant Fee Calculation*: Automated breakdown of overtime penalties, fuel shortages, and damage claims.
  4. *Return Sign-Off*: Recipient and staff sign the final return and release agreement.

### 2.3. Management Navigation (Owner & Admin — Desktop View)
- **Operations Dashboard (`/admin/dashboard`)**:
  - Metrics Cards: Active Fleet Units, Vehicles On-Rental, Pending KYC Reviews, Today's Gross Revenue, Maintenance Alerts.
  - Interactive Fleet Calendar: Visual Gantt schedule showing real-time unit occupancy and driver dispatches across B2C and B2B orders.
- **B2B Corporate Account Manager (`/admin/corporate`)**:
  - Corporate Directory: Company name, NPWP, NIB, designated PIC, assigned credit limit, and current outstanding invoice balance.
  - Action: "Create Corporate Account", "Adjust Credit Limit", "View Contract History".
- **Multi-Vehicle B2B Order Builder (`/admin/bookings/b2b-builder`)**:
  - Select Corporate Account & enter PO/SPK number.
  - Multi-Unit Picker: Add multiple rows of vehicles + assigned drivers + rental packages under one parent booking envelope.
  - Real-time credit limit validation against existing unpaid balances.
- **Fleet & Maintenance Management (`/admin/fleet`)**:
  - Fleet Table: License plate, model, operational status, current odometer, mileage accumulated since last service.
  - Maintenance Alert Panel: Prominent warning cards for units reaching the 5,000 KM service interval, 10,000 KM oil change, or STNK tax expiration (H-30 / H-7).
  - SLA Emergency Swap Action: Authorizes instant vehicle replacement dispatch during breakdowns.
- **Financial Ledger & Invoicing (`/admin/finance`)**:
  - Tabs: "B2C Cash & Deposits" and "B2B Corporate Invoices".
  - B2B Invoice Actions: "Generate Consolidated Tax Invoice (PPN 11%, PPh 23)", "Record TOP Settlement", "Send Payment Reminder".
- **Atomic Audit Trail Log (`/admin/audit-logs`)**:
  - Interactive audit table: Timestamp, Entity Name, Action Type, Actor (Name + Role), Changes (JSON Diff Viewer), and Justification Notes.
  - License plate filter providing a complete lifetime mileage increment history for each vehicle.

---

## 3. UI Component Adaptability Matrix

| UI Component | Mobile View (< 600 dp) | Desktop View (> 1024 dp) |
|---|---|---|
| **Primary Navigation** | Bottom Navigation Bar (4 primary tabs) | Collapsible Left Sidebar with grouped hierarchical menus |
| **Fleet Catalog** | Single-column vertically scrollable card feed | Responsive 3–4 column grid with persistent left filter drawer |
| **B2B Order Creation** | Read-only order overview | Full multi-unit builder table with driver picker & credit balance |
| **Inspection Workflow** | Step-by-step wizard capturing one inspection angle at a time | Multi-pane view (Vehicle interactive diagram alongside photo gallery) |
| **E-Signature Capture** | Fullscreen touch pad with auto-orientation support | Modal dialog supporting touch screen, mouse, or remote mobile link |
| **Audit Log Viewer** | Simplified chronological event cards per vehicle | Full data table with column sorting, date range filters, & JSON diff view |
