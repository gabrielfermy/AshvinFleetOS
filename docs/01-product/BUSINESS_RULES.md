# Business Rules & Operational Logic — Ashvin FleetOS (AFOS)
**Integrated Car Rental Information and Sales Operating System**  
*Startup Ashvin — Business Logic & Validation Engine*

---

## 1. Physical Units vs. Service Packages Separation

### 1.1. Vehicle and Package Relationship
- **Physical Vehicle Unit (`vehicles`)**: A tangible asset identified by unique registration attributes: License Plate, VIN, Engine Number, Brand, Model, Year, Transmission (Manual/Automatic), Current Odometer (KM), and STNK Tax Due Date.
- **Service Package (`rental_packages`)**: The commercial offering selected by the customer:
  - Steering Mode: `SELF_DRIVE` or `WITH_DRIVER`.
  - Service Area: `IN_TOWN` (Yogyakarta City, Sleman, Bantul) or `OUT_OF_TOWN` (Kulon Progo, Gunungkidul, Solo, Semarang).
  - Duration: 12 Hours or 24 Hours (Per Calendar Day / Clock-to-Clock).
  - Fuel Inclusions: `EXCLUDE_FUEL` (customer refuels) or `INCLUDE_FUEL` (fuel bundled in rental rate).

### 1.2. Resource Locking Rules
1. **Self-Drive Package (`SELF_DRIVE`)**:
   - The system locks **1 physical vehicle unit** per booking item.
   - Requires strict KYC identity verification and a mandatory refundable **Security Deposit** (waived for verified B2B corporate contracts).
2. **With-Driver Package (`WITH_DRIVER`)**:
   - The system simultaneously locks: **1 physical vehicle unit + 1 assigned driver (`drivers`)**.
   - Validates that the assigned driver has no overlapping schedule conflicts.

---

## 2. Order Architecture: Decoupled Master Booking & Items

### 2.1. Structural Cardinality
- **Master Booking (`bookings`)**: Represents the commercial transaction envelope:
  - Order Type: `B2C_RETAIL` or `B2B_CORPORATE`.
  - Account Reference: `customer_id` (individual profile) or `corporate_account_id` (company entity).
  - Billing Mode: `IMMEDIATE_CASH` (B2C) or `TERMS_OF_PAYMENT` (B2B).
- **Booking Items (`booking_items`)**: Represents individual vehicle dispatches:
  - In **B2C**: Exactly 1 item per booking.
  - In **B2B**: 1 to $N$ items per booking (e.g., 5 Avanza + 5 Drivers for a corporate event).
  - Each item maintains its own operational lifecycle (`CONFIRMED`, `ON_RENTAL`, `COMPLETED`), check-out record, and check-in record.

---

## 3. B2B Corporate Policies & Standard Service Level Agreements (SLA)

### 3.1. Corporate Account Scaffolding
- Verified corporate accounts (`corporate_accounts`) must provide: Company Legal Name, Tax ID (NPWP), Business ID (NIB), Billing Address, and Designated Person In Charge (PIC).
- **Payment Terms (TOP)**: Standardized payment windows:
  - `TOP_14`: Net 14 calendar days from invoice receipt.
  - `TOP_30`: Net 30 calendar days (Standard corporate default).
  - `TOP_60`: Net 60 calendar days (Special enterprise/government contracts).
- **Credit Limit & Security Guarantee**: Corporate orders bypass individual cash deposits as long as the aggregate unpaid invoice balance is within the assigned `credit_limit`. Orders exceeding the credit limit require Owner approval.

### 3.2. Replacement Vehicle SLA (Scaffolding Standards)
In the event of a mechanical breakdown, flat tire, or air conditioning failure:
1. **Metropolitan Area (In-Town Yogyakarta)**: AFOS guarantees a replacement vehicle of equal or higher tier dispatched within **2 to 4 hours**.
2. **Regional Area (Out-of-Town)**: Guaranteed replacement vehicle dispatched within **6 to 8 hours**.
3. **Operational Swap Mechanism**: Field staff performs an emergency check-in on the defective unit and initiates a linked check-out on the replacement unit without terminating the parent corporate contract.

### 3.3. Indonesian Corporate Taxation Scaffolding
- **PPN (Value Added Tax)**: 11% tax applied to standard corporate rental invoices.
- **PPh 23 (Withholding Tax)**: 2% corporate withholding tax for car rental services under Indonesian tax regulations. The system records the gross billable amount, PPN, and PPh 23 deductible credit.

---

## 4. Anti-Double Booking Concurrency Engine

### 4.1. Turnaround Buffer Time
- Every vehicle booking item automatically adds a **60-minute turnaround buffer** after the scheduled return time before the unit becomes available for the next reservation.
- Vehicle occupancy window formula:
  $$\text{Blocked Interval} = [\text{Start Time}, \text{End Time} + 60\text{ minutes}]$$

### 4.2. Schedule Validation Algorithm
A physical vehicle $V$ or driver $D$ is deemed **Available** for interval $[T_{\text{start}}, T_{\text{end}}]$ if and only if:
$$\text{COUNT}(\text{Conflicting Active Booking Items}) = 0$$
where conflict between $[A_{\text{start}}, A_{\text{end}}]$ and $[B_{\text{start}}, B_{\text{end}}]$ occurs when:
$$A_{\text{start}} < B_{\text{end}} \quad \text{AND} \quad A_{\text{end}} > B_{\text{start}}$$

---

## 5. Odometer Logic & Trip Lifecycle

### 5.1. Handover Input Validations
- **Check-Out (Initial Handover)**: Input $\text{KM}_{\text{start}}$ ($\ge \text{current\_odometer\_km}$) and $\text{Fuel}_{\text{start}}$ (scale 1/8 to 8/8).
- **Check-In (Return)**: Input $\text{KM}_{\text{end}}$ ($\ge \text{KM}_{\text{start}}$) and $\text{Fuel}_{\text{end}}$.
- **Distance Calculation**:
  $$\Delta \text{KM} = \text{KM}_{\text{end}} - \text{KM}_{\text{start}}$$
- **Vehicle State Update**:
  - $\text{current\_odometer\_km} = \text{KM}_{\text{end}}$
  - $\text{total\_trip\_count} = \text{total\_trip\_count} + 1$
- **Manual Odometer Correction**: Restricted strictly to the `OWNER` role with mandatory justification notes logged to `audit_logs`.

---

## 6. Preventive Maintenance & Vehicle Tax Thresholds

### 6.1. Routine Service & Oil Change Thresholds
- **General Service Alert**: Triggered when:
  $$(\text{current\_odometer\_km} - \text{last\_service\_odometer\_km}) \ge 5,000\text{ KM}$$
- **Engine Oil Change Alert**: Critical trigger when:
  $$(\text{current\_odometer\_km} - \text{last\_oil\_change_odometer\_km}) \ge 10,000\text{ KM}$$
- When a threshold is met, the vehicle is flagged as `SERVICE_DUE` on management dashboards.

### 6.2. Annual STNK Tax Expiration Reminders
- Alerts based on days remaining until `stnk_tax_due_date`:
  - **H-30 Days**: Warning alert (Yellow badge).
  - **H-7 Days**: Critical alert (Red badge).
  - Expired: Vehicle flagged as `REGISTRATION_EXPIRED` and restricted from out-of-town trips.

---

## 7. Approval Matrix & Penalty Rules

### 7.1. Authorization Matrix
| Operational Action | Permitted Role | Prerequisites & Notes |
|---|---|---|
| B2C Booking Confirmation | Admin, Owner | Verifies down payment proof & unit availability. |
| B2B Corporate Order Approval | Admin, Owner | Verifies corporate credit limit and PO validity. |
| Self-Drive KYC Approval | Admin, Owner | Reviews personal ID, driving license, emergency contacts. |
| Check-Out / Check-In Execution | Field Staff, Admin, Owner | Requires inspection photos & digital e-signatures per item. |
| Replacement Vehicle Swap | Admin, Owner | Authorizes emergency unit substitution under active SLA. |
| Deposit Hold / Refund / Deduction | Admin, Owner | Atomically written to the cash ledger (B2C). |
| Corporate Invoice Settlement | Admin, Owner | Reconciles bank transfer with accounts receivable (B2B). |

### 7.2. Penalty & Overtime Calculations
1. **Late Return (Overtime)**: Grace period up to 30 minutes free. 31–120 minutes charged at $10\%$ of vehicle daily rate per hour. $> 120$ minutes charged as 1 full additional day.
2. **Fuel Shortage**: Missing fuel bars converted to currency plus a Rp25,000 refueling administrative fee.
3. **Physical Damage Claims**: Deducted directly from security deposit (B2C) or billed to consolidated corporate invoice (B2B).
