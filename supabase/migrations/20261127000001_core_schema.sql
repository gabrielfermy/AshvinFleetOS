-- ============================================================================
-- Migration: 20261127000001_core_schema.sql
-- System: Ashvin FleetOS (AFOS)
-- Purpose: Core Enums, User Profiles, Corporate Accounts, Vehicles, Packages, Drivers
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. ENUM DEFINITIONS
CREATE TYPE user_role_enum AS ENUM ('CUSTOMER', 'FIELD_STAFF', 'ADMIN', 'OWNER');
CREATE TYPE payment_terms_enum AS ENUM ('IMMEDIATE', 'TOP_14', 'TOP_30', 'TOP_60');
CREATE TYPE vehicle_status_enum AS ENUM (
    'AVAILABLE', 'BOOKED', 'ON_RENTAL', 'MAINTENANCE_REQUIRED', 'DECOMMISSIONED'
);
CREATE TYPE transmission_enum AS ENUM ('MANUAL', 'AUTOMATIC');
CREATE TYPE service_type_enum AS ENUM ('SELF_DRIVE', 'WITH_DRIVER');
CREATE TYPE service_area_enum AS ENUM ('IN_TOWN', 'OUT_OF_TOWN');
CREATE TYPE driver_status_enum AS ENUM ('AVAILABLE', 'ASSIGNED', 'OFF_DUTY');

-- 2. USER PROFILES TABLE (Tied to Supabase GoTrue Auth)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role_enum NOT NULL DEFAULT 'CUSTOMER',
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(30) NOT NULL,
    id_card_number VARCHAR(50), -- KTP (WNI) or Passport (WNA)
    driver_license_number VARCHAR(50), -- SIM A / IDP
    nationality VARCHAR(50) NOT NULL DEFAULT 'ID',
    emergency_contact_name VARCHAR(150),
    emergency_contact_phone VARCHAR(30),
    preferred_locale VARCHAR(10) NOT NULL DEFAULT 'id',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. CORPORATE ACCOUNTS (B2B Scaffolding)
CREATE TABLE corporate_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL,
    tax_id VARCHAR(50) NOT NULL, -- NPWP
    business_id VARCHAR(50) NOT NULL, -- NIB
    billing_address TEXT NOT NULL,
    pic_user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    pic_name VARCHAR(150) NOT NULL,
    pic_phone VARCHAR(30) NOT NULL,
    pic_email VARCHAR(100) NOT NULL,
    credit_limit NUMERIC(14, 2) NOT NULL DEFAULT 50000000.00,
    payment_terms payment_terms_enum NOT NULL DEFAULT 'TOP_30',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. PHYSICAL VEHICLES (Fleet Master)
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year SMALLINT NOT NULL CHECK (year >= 2000),
    transmission transmission_enum NOT NULL,
    seating_capacity SMALLINT NOT NULL DEFAULT 7 CHECK (seating_capacity > 0),
    current_odometer_km INT NOT NULL DEFAULT 0 CHECK (current_odometer_km >= 0),
    last_service_odometer_km INT NOT NULL DEFAULT 0 CHECK (last_service_odometer_km >= 0),
    last_oil_change_odometer_km INT NOT NULL DEFAULT 0 CHECK (last_oil_change_odometer_km >= 0),
    stnk_tax_due_date DATE NOT NULL,
    total_trip_count INT NOT NULL DEFAULT 0 CHECK (total_trip_count >= 0),
    status vehicle_status_enum NOT NULL DEFAULT 'AVAILABLE',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. RENTAL PACKAGES (Service Variants)
CREATE TABLE rental_packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    service_type service_type_enum NOT NULL,
    service_area service_area_enum NOT NULL,
    duration_hours SMALLINT NOT NULL CHECK (duration_hours IN (12, 24)),
    base_price NUMERIC(12, 2) NOT NULL CHECK (base_price >= 0),
    deposit_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (deposit_amount >= 0),
    includes_fuel BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. DRIVERS
CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(30) NOT NULL,
    license_number VARCHAR(50) NOT NULL,
    status driver_status_enum NOT NULL DEFAULT 'AVAILABLE',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. PERFORMANCE & LOOKUP INDEXES
CREATE INDEX idx_user_profiles_role ON user_profiles(role);
CREATE INDEX idx_corporate_accounts_active ON corporate_accounts(is_active);
CREATE INDEX idx_vehicles_status ON vehicles(status) WHERE is_active = TRUE;
CREATE INDEX idx_vehicles_tax ON vehicles(stnk_tax_due_date);
CREATE INDEX idx_rental_packages_type ON rental_packages(service_type, is_active);
CREATE INDEX idx_drivers_status ON drivers(status) WHERE is_active = TRUE;
