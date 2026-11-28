# Rule: Clean Code, SOLID/SRP, DRY & Anti-God File Standards

## 1. Zero Tolerance for God Files
- No single file may exceed **500 lines** under any circumstances.
- If a file approaches **400 lines**, it must be proactively decomposed, extracted, and refactored before adding any new code.
- Files must adhere strictly to the **Single Responsibility Principle (SRP)**: one file, one cohesive responsibility.

## 2. Granular Line Count Thresholds
- **Functions / Methods**: Typical range 5–20 lines (warning threshold: > 30 lines).
- **Classes / Components**: Typical range 100–250 lines (warning threshold: > 300 lines).
- **Entire File**: Typical range 100–300 lines (**hard ceiling: strictly < 500 lines**).

## 3. Tidy & Structured Refactoring Protocol
When refactoring oversized components or models:
- **Presentation / UI**: Extract modular sub-widgets into dedicated `presentation/widgets/` directories (e.g. `phone_input_field.dart`, `auth_otp_step.dart`).
- **Business Logic**: Extract state manipulation, network calls, and validations into dedicated `controllers`, `services`, or `validators`.
- **Domain / Models**: Separate serialization (`fromJson`/`toJson`), value objects, and domain logic into cohesive files.
- **DRY Invariant**: Reusable UI patterns, theme styles, and validation rules must be centralized rather than duplicated across files.
