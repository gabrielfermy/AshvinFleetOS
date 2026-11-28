# Brand Guidelines & Design System — Ashvin FleetOS (AFOS)
**Integrated Car Rental Information and Sales Operating System**  
*Official Product of Startup Ashvin — Yogyakarta, Indonesia*

---

## 1. Brand Identity & Positioning

### 1.1. Core Identity
- **Product Name:** Ashvin FleetOS
- **Official Acronym:** **AFOS**
- **Parent Brand:** Startup Ashvin
- **Product Category:** *Fleet & Rental Operating System*
- **Primary Tagline (Global):** *"Smart Fleet Control. Zero Blind Spots."*
- **Operational Tagline (Indonesia):** *"Sistem Operasi Rental Mobil yang Rapi, Aman, dan Terukur."*

### 1.2. Value Pillars
1. **Control & Trust**: Physical vehicle unit separation from commercial service packages, strict KYC verification, digital hand-drawn e-signatures, and mandatory 8-point photo handovers.
2. **Precision & Automation**: Automated odometer difference ($\Delta\text{KM}$) calculation, maintenance & oil change threshold alerts, and anti-double booking concurrency engines.
3. **Atomic Traceability**: Immutable, append-only audit logging for every odometer increment, dispatch checkout/check-in, security deposit deduction, and manager approval.
4. **Guest-Ready Internationalization (i18n)**: High-transparency multi-language experience for tourists (Indonesian & English, architected for Japanese, Korean, and Mandarin) alongside dual-language operational tools for local staff.

---

## 2. Tone of Voice

### 2.1. Customer Portal (B2C Travelers & B2B Guests)
- **Tone**: Warm, welcoming, transparent, and frictionless.
- **Style**: Clear pricing breakdowns (rental base fee, deposit, down payment), zero hidden clauses, simple language accessible across international traveler demographics.

### 2.2. Internal Operations Portal (`Owner`, `Admin`, `Field Staff`, `Driver`)
- **Tone**: Decisive, concise, operational, and unambiguous.
- **Style**: Focus on actionable data points: unit license plate, exact odometer numbers, maintenance alert thresholds, handover signatures, and atomic audit trails.

---

## 3. Official Color Palette & Design Tokens

### 3.1. Primary & Brand Colors
| Token Name | HEX Code | Color Sample | Primary Usage & Semantic Role |
|---|---|---|---|
| **Ashvin Deep Navy** | `#0F2537` | `rgb(15, 37, 55)` | Header, primary navigation, brand identity, authority & security badges. |
| **Jogja Teal / Signal Cyan** | `#0E7C7B` | `rgb(14, 124, 123)` | Primary action buttons, booking CTAs, active states, verified indicators. |
| **Warm Amber** | `#D97706` | `rgb(217, 119, 6)` | Special package highlights, approaching maintenance thresholds (KM/STNK), pending reviews. |

### 3.2. Semantic Status Tokens
| Semantic Role | HEX Code | Background Tint (10%) | Operational Context |
|---|---|---|---|
| **Emerald Verified (Success)** | `#15803D` | `#DCFCE7` | Vehicle `AVAILABLE`, check-in completed, KYC approved, cash deposit refunded. |
| **Crimson Alert (Danger)** | `#B91C1C` | `#FEE2E2` | Odometer discrepancy, overtime penalty, vehicle damage, `MAINTENANCE_REQUIRED`. |
| **Info / Status Blue** | `#0284C7` | `#E0F2FE` | Vehicle `ON_RENTAL`, assigned driver active, B2B contract active. |
| **Neutral Slate (Muted)** | `#64748B` | `#F1F5F9` | `DECOMMISSIONED` vehicle, past audit events, inactive package. |

### 3.3. Surfaces, Canvas & Neutrals
| Token Name | HEX Code | Primary Usage |
|---|---|---|
| **Slate Mist (Canvas)** | `#F8FAFC` | Application body background, subtle card fills, input field fill. |
| **Pure White (Surface)** | `#FFFFFF` | Card backgrounds, dialogs, bottom sheets, dropdown menus. |
| **Border Slate (Subtle)** | `#E2E8F0` | Card borders, table dividers, input field boundaries. |
| **Charcoal Ink (Text Dark)**| `#1E293B` | Primary headings, body copy, technical tabular data. |
| **Muted Slate (Text Muted)**| `#64748B` | Secondary labels, hints, timestamps, metadata. |

---

## 4. Typography System

### 4.1. Primary UI Typeface: Plus Jakarta Sans / Inter
- Clean, highly legible geometric sans-serif engineered for digital screens.
- **Display & Headings**:
  - `Display Large`: 28sp / Bold (700)
  - `Headline Medium`: 20sp / Bold (700)
  - `Title Medium`: 16sp / SemiBold (600)
- **Body & Labels**:
  - `Body Medium`: 14sp / Regular (400)
  - `Label Large`: 14sp / Medium (500)
  - `Caption`: 12sp / Regular (400)

### 4.2. Technical Data & Numbers: JetBrains Mono
- Monospaced font enforcing `tabular-nums` (`FontFeature.tabularFigures()`).
- **Mandatory Usage**:
  - Vehicle License Plates (e.g. `AB 1234 XY`)
  - Odometer Readings (e.g. `45,210 KM`)
  - Monetary Values & Down Payments (e.g. `Rp 350.000`)
  - Booking Reference Codes (e.g. `AFOS-B2C-202611-001`)
  - Audit Log Timestamps & System UUIDs

---

## 5. Brand Mark & Iconography

### 5.1. The AF Monogram
- Combines the silhouette of an open highway/route ribbon with a protective shield geometry, forming the intertwined letters **A** and **F**.
- Represents safe journeys, operational security, and precision fleet tracking.

### 5.2. Rental Domain Iconography (Line & Duotone)
1. **Odometer & Mileage**: Speedometer gauge icon for recording start/end KM.
2. **Key vs. Steering Wheel**: Key icon for *Lepas Kunci* (Self-Drive) vs. Steering Wheel for *Dengan Sopir* (With Driver).
3. **8-Point Inspection**: Vehicle chassis silhouette with camera pinpoints.
4. **Digital Signature**: Quill / Stylus pad icon for contract e-signing.
5. **Audit Log**: Shielded ledger book icon for immutable history.

---

## 6. Contrast & Environment Adaptation Rules

### 6.1. Outdoor Mobile Use (Field Staff in Parking Lot / Garage)
- High-contrast visual ratio ($\ge 4.5:1$ WCAG AA compliant).
- Minimum button touch target: **48x48 dp**.
- Pure white card backgrounds over `#F8FAFC` canvas with distinct `#E2E8F0` borders to ensure visibility under direct sunlight.

### 6.2. Indoor Desktop Use (Management Office & Booking Desk)
- High density information display.
- Subtle row striping in data tables using `#F8FAFC`.
- Interactive hover states using Jogja Teal tint (`#0E7C7B` with 8% opacity).
