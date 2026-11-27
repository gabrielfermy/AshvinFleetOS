-- ============================================================================
-- Migration: 20261127000003_audit_and_finance.sql
-- System: Ashvin FleetOS (AFOS)
-- Purpose: Invoicing, Append-Only Financial Ledger, Immutable Audit Trail & Triggers
-- ============================================================================

-- 1. FINANCIAL ENUMS
CREATE TYPE invoice_status_enum AS ENUM ('ISSUED', 'PARTIALLY_PAID', 'PAID', 'OVERDUE');
CREATE TYPE financial_entry_type AS ENUM (
    'INCOME_RENTAL_DP', 'INCOME_RENTAL_SETTLEMENT', 'HOLD_SECURITY_DEPOSIT',
    'RELEASE_SECURITY_DEPOSIT', 'INCOME_PENALTY_OVERTIME', 'INCOME_PENALTY_FUEL',
    'INCOME_PENALTY_DAMAGE', 'INCOME_B2B_INVOICE_SETTLEMENT', 'EXPENSE_MAINTENANCE',
    'EXPENSE_OPERATIONAL'
);

-- 2. FINANCIAL INVOICES (B2C Receipts & B2B Tax Invoicing)
CREATE TABLE financial_invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    corporate_account_id UUID REFERENCES corporate_accounts(id),
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    subtotal_amount NUMERIC(14, 2) NOT NULL CHECK (subtotal_amount >= 0),
    ppn_tax_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (ppn_tax_amount >= 0),
    pph23_tax_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (pph23_tax_amount >= 0),
    total_amount NUMERIC(14, 2) NOT NULL CHECK (total_amount >= 0),
    due_date DATE NOT NULL,
    status invoice_status_enum NOT NULL DEFAULT 'ISSUED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. FINANCIAL CASH LEDGER (Strictly Append-Only)
CREATE TABLE financial_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES bookings(id),
    invoice_id UUID REFERENCES financial_invoices(id),
    vehicle_id UUID REFERENCES vehicles(id),
    entry_type financial_entry_type NOT NULL,
    amount NUMERIC(14, 2) NOT NULL CHECK (amount >= 0),
    recorded_by UUID NOT NULL REFERENCES user_profiles(id),
    approved_by UUID REFERENCES user_profiles(id),
    payment_method VARCHAR(50) NOT NULL DEFAULT 'BANK_TRANSFER',
    payment_proof_url TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. ATOMIC AUDIT TRAIL LOG (Strictly Append-Only)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_name VARCHAR(50) NOT NULL, -- 'vehicles', 'bookings', 'returns_checkin', etc.
    entity_id UUID NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- 'CHECKOUT', 'CHECKIN', 'ODOMETER_CORRECTION', etc.
    actor_id UUID NOT NULL REFERENCES user_profiles(id),
    actor_role user_role_enum NOT NULL,
    old_data JSONB,
    new_data JSONB,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. IMMUTABILITY TRIGGER FUNCTION (Enforces Append-Only)
CREATE OR REPLACE FUNCTION prevent_modification()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Operation not permitted! Target table % is strictly append-only for audit integrity.', TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_immutable_audit_logs
BEFORE UPDATE OR DELETE ON audit_logs
FOR EACH ROW EXECUTE FUNCTION prevent_modification();

CREATE TRIGGER trg_immutable_financial_entries
BEFORE UPDATE OR DELETE ON financial_entries
FOR EACH ROW EXECUTE FUNCTION prevent_modification();

-- 6. PERFORMANCE INDEXES
CREATE INDEX idx_financial_invoices_booking ON financial_invoices(booking_id);
CREATE INDEX idx_financial_invoices_corp ON financial_invoices(corporate_account_id);
CREATE INDEX idx_financial_entries_booking ON financial_entries(booking_id);
CREATE INDEX idx_financial_entries_type ON financial_entries(entry_type);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_name, entity_id);
CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
