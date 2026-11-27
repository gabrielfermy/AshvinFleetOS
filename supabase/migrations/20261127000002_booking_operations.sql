-- ============================================================================
-- Migration: 20261127000002_booking_operations.sql
-- System: Ashvin FleetOS (AFOS)
-- Purpose: Decoupled Master Bookings, Booking Items (1:N), Check-Out, Check-In
-- ============================================================================

-- 1. ORDER & BOOKING STATUS ENUMS
CREATE TYPE order_type_enum AS ENUM ('B2C_RETAIL', 'B2B_CORPORATE');
CREATE TYPE booking_status_enum AS ENUM (
    'DRAFT', 'PENDING_VERIFICATION', 'CONFIRMED', 'ON_RENTAL', 'COMPLETED', 'CANCELLED'
);

-- 2. MASTER BOOKINGS TABLE (Order Envelope)
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_code VARCHAR(30) NOT NULL UNIQUE,
    order_type order_type_enum NOT NULL DEFAULT 'B2C_RETAIL',
    customer_id UUID REFERENCES user_profiles(id),
    corporate_account_id UUID REFERENCES corporate_accounts(id),
    po_number VARCHAR(100),
    status booking_status_enum NOT NULL DEFAULT 'DRAFT',
    total_amount NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    security_deposit_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (security_deposit_amount >= 0),
    down_payment_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (down_payment_amount >= 0),
    approved_by UUID REFERENCES user_profiles(id),
    approved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. BOOKING ITEMS TABLE (Individual Vehicle & Driver Dispatches: 1:N)
CREATE TABLE booking_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id),
    package_id UUID NOT NULL REFERENCES rental_packages(id),
    driver_id UUID REFERENCES drivers(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    status booking_status_enum NOT NULL DEFAULT 'DRAFT',
    is_replacement BOOLEAN NOT NULL DEFAULT FALSE,
    replaced_item_id UUID REFERENCES booking_items(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_booking_time_validity CHECK (end_time > start_time)
);

-- 4. CHECK-OUT HANDOVER TABLE
CREATE TABLE handovers_checkout (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_item_id UUID NOT NULL UNIQUE REFERENCES booking_items(id) ON DELETE RESTRICT,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    staff_id UUID NOT NULL REFERENCES user_profiles(id),
    checkout_odometer_km INT NOT NULL CHECK (checkout_odometer_km >= 0),
    checkout_fuel_level SMALLINT NOT NULL CHECK (checkout_fuel_level BETWEEN 1 AND 8),
    body_inspection_json JSONB NOT NULL DEFAULT '{}',
    photos_json JSONB NOT NULL DEFAULT '[]',
    customer_signature_url TEXT NOT NULL,
    staff_signature_url TEXT NOT NULL,
    checkout_notes TEXT,
    checkout_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. CHECK-IN RETURN TABLE
CREATE TABLE returns_checkin (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_item_id UUID NOT NULL UNIQUE REFERENCES booking_items(id) ON DELETE RESTRICT,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    staff_id UUID NOT NULL REFERENCES user_profiles(id),
    checkin_odometer_km INT NOT NULL CHECK (checkin_odometer_km >= 0),
    checkin_fuel_level SMALLINT NOT NULL CHECK (checkin_fuel_level BETWEEN 1 AND 8),
    distance_traveled_km INT NOT NULL DEFAULT 0 CHECK (distance_traveled_km >= 0),
    overtime_hours NUMERIC(4, 1) NOT NULL DEFAULT 0 CHECK (overtime_hours >= 0),
    overtime_penalty_fee NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (overtime_penalty_fee >= 0),
    fuel_penalty_fee NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (fuel_penalty_fee >= 0),
    damage_penalty_fee NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (damage_penalty_fee >= 0),
    body_inspection_json JSONB NOT NULL DEFAULT '{}',
    photos_json JSONB NOT NULL DEFAULT '[]',
    customer_signature_url TEXT NOT NULL,
    staff_signature_url TEXT NOT NULL,
    checkin_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. INDEXES FOR ANTI-CONFLICT SCHEDULE CHECKS
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_corporate ON bookings(corporate_account_id);
CREATE INDEX idx_booking_items_schedule ON booking_items(vehicle_id, start_time, end_time);
CREATE INDEX idx_booking_items_driver ON booking_items(driver_id, start_time, end_time);
CREATE INDEX idx_booking_items_status ON booking_items(status);
