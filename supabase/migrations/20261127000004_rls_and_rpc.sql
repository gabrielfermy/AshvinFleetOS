-- ============================================================================
-- Migration: 20261127000004_rls_and_rpc.sql
-- System: Ashvin FleetOS (AFOS)
-- Purpose: Universal RLS Policies, Storage Buckets, and Atomic Stored Procedures
-- ============================================================================

-- 1. ENABLE ROW-LEVEL SECURITY UNIVERSALLY
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE corporate_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE rental_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE handovers_checkout ENABLE ROW LEVEL SECURITY;
ALTER TABLE returns_checkin ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- 2. HELPER FUNCTION: GET CURRENT USER ROLE
CREATE OR REPLACE FUNCTION auth_user_role()
RETURNS user_role_enum AS $$
    SELECT role FROM public.user_profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 3. RLS POLICIES FOR USER PROFILES
CREATE POLICY "Profiles viewable by self or admin/owner" ON user_profiles
FOR SELECT USING (auth.uid() = id OR auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Profiles updatable by self or admin/owner" ON user_profiles
FOR UPDATE USING (auth.uid() = id OR auth_user_role() IN ('ADMIN', 'OWNER'));

-- 4. RLS POLICIES FOR FLEET & PACKAGES (Public browse for active)
CREATE POLICY "Vehicles public read" ON vehicles
FOR SELECT USING (is_active = TRUE OR auth_user_role() IN ('ADMIN', 'OWNER', 'FIELD_STAFF'));

CREATE POLICY "Vehicles modify admin/owner" ON vehicles
FOR ALL USING (auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Packages public read" ON rental_packages
FOR SELECT USING (is_active = TRUE OR auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Packages modify admin/owner" ON rental_packages
FOR ALL USING (auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Drivers staff read" ON drivers
FOR SELECT USING (auth_user_role() IN ('ADMIN', 'OWNER', 'FIELD_STAFF'));

CREATE POLICY "Drivers modify admin/owner" ON drivers
FOR ALL USING (auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Corporate accounts read" ON corporate_accounts
FOR SELECT USING (auth_user_role() IN ('ADMIN', 'OWNER') OR pic_user_id = auth.uid());

CREATE POLICY "Corporate accounts modify admin/owner" ON corporate_accounts
FOR ALL USING (auth_user_role() IN ('ADMIN', 'OWNER'));

-- 5. RLS POLICIES FOR BOOKINGS & ITEMS
CREATE POLICY "Bookings viewable by owner, staff, or customer" ON bookings
FOR SELECT USING (
    customer_id = auth.uid() OR auth_user_role() IN ('ADMIN', 'OWNER', 'FIELD_STAFF')
);

CREATE POLICY "Bookings insert by authenticated customers or admin" ON bookings
FOR INSERT WITH CHECK (
    customer_id = auth.uid() OR auth_user_role() IN ('ADMIN', 'OWNER')
);

CREATE POLICY "Bookings update by admin or owner" ON bookings
FOR UPDATE USING (auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Booking items viewable by booking participants" ON booking_items
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM bookings b
        WHERE b.id = booking_items.booking_id
        AND (b.customer_id = auth.uid() OR auth_user_role() IN ('ADMIN', 'OWNER', 'FIELD_STAFF'))
    )
);

CREATE POLICY "Booking items modify by admin or owner" ON booking_items
FOR ALL USING (auth_user_role() IN ('ADMIN', 'OWNER'));

-- 6. RLS FOR HANDOVER & RETURNS (Staff and Admin)
CREATE POLICY "Handovers viewable by participants" ON handovers_checkout
FOR SELECT USING (
    staff_id = auth.uid() OR auth_user_role() IN ('ADMIN', 'OWNER') OR
    EXISTS (
        SELECT 1 FROM booking_items bi
        JOIN bookings b ON b.id = bi.booking_id
        WHERE bi.id = handovers_checkout.booking_item_id AND b.customer_id = auth.uid()
    )
);

CREATE POLICY "Handovers insert by staff or admin" ON handovers_checkout
FOR INSERT WITH CHECK (auth_user_role() IN ('FIELD_STAFF', 'ADMIN', 'OWNER'));

CREATE POLICY "Returns viewable by participants" ON returns_checkin
FOR SELECT USING (
    staff_id = auth.uid() OR auth_user_role() IN ('ADMIN', 'OWNER') OR
    EXISTS (
        SELECT 1 FROM booking_items bi
        JOIN bookings b ON b.id = bi.booking_id
        WHERE bi.id = returns_checkin.booking_item_id AND b.customer_id = auth.uid()
    )
);

CREATE POLICY "Returns insert by staff or admin" ON returns_checkin
FOR INSERT WITH CHECK (auth_user_role() IN ('FIELD_STAFF', 'ADMIN', 'OWNER'));

-- 7. RLS FOR INVOICES, FINANCIAL ENTRIES & AUDIT LOGS
CREATE POLICY "Invoices viewable by customer or admin" ON financial_invoices
FOR SELECT USING (
    auth_user_role() IN ('ADMIN', 'OWNER') OR
    EXISTS (
        SELECT 1 FROM bookings b WHERE b.id = financial_invoices.booking_id AND b.customer_id = auth.uid()
    )
);

CREATE POLICY "Invoices modify by admin or owner" ON financial_invoices
FOR ALL USING (auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Financial entries viewable by admin or owner" ON financial_entries
FOR SELECT USING (auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Financial entries insert by admin or owner" ON financial_entries
FOR INSERT WITH CHECK (auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Audit logs viewable only by owner and admin" ON audit_logs
FOR SELECT USING (auth_user_role() IN ('ADMIN', 'OWNER'));

CREATE POLICY "Audit logs insert by all active roles" ON audit_logs
FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 8. STORAGE BUCKETS INITIALIZATION
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('public-assets', 'public-assets', true),
    ('identity-docs', 'identity-docs', false),
    ('inspection-photos', 'inspection-photos', false),
    ('signatures', 'signatures', false)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS: public assets read
CREATE POLICY "Public Assets Read" ON storage.objects
FOR SELECT USING (bucket_id = 'public-assets');

-- Storage RLS: identity docs restricted
CREATE POLICY "Identity Docs Access" ON storage.objects
FOR ALL USING (
    bucket_id = 'identity-docs' AND (
        auth_user_role() IN ('ADMIN', 'OWNER') OR (storage.foldername(name))[1] = auth.uid()::text
    )
);

-- Storage RLS: inspection photos and signatures for staff & admin
CREATE POLICY "Inspection Photos Access" ON storage.objects
FOR ALL USING (
    bucket_id IN ('inspection-photos', 'signatures') AND auth_user_role() IN ('FIELD_STAFF', 'ADMIN', 'OWNER')
);

-- 9. ATOMIC STORED PROCEDURE: PROCESS RETURN CHECK-IN & ODOMETER
CREATE OR REPLACE FUNCTION rpc_process_checkin_atomic(
    p_booking_item_id UUID,
    p_staff_id UUID,
    p_checkin_odometer_km INT,
    p_checkin_fuel_level SMALLINT,
    p_overtime_hours NUMERIC,
    p_overtime_penalty_fee NUMERIC,
    p_fuel_penalty_fee NUMERIC,
    p_damage_penalty_fee NUMERIC,
    p_body_inspection_json JSONB,
    p_photos_json JSONB,
    p_customer_signature_url TEXT,
    p_staff_signature_url TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_item RECORD;
    v_vehicle RECORD;
    v_checkout RECORD;
    v_delta_km INT;
    v_new_status vehicle_status_enum := 'AVAILABLE';
    v_return_id UUID;
    v_staff_role user_role_enum;
BEGIN
    -- Verify staff role
    SELECT role INTO v_staff_role FROM user_profiles WHERE id = p_staff_id;
    IF v_staff_role NOT IN ('FIELD_STAFF', 'ADMIN', 'OWNER') THEN
        RAISE EXCEPTION 'Unauthorized: Actor must be Field Staff, Admin, or Owner.';
    END IF;

    -- Lock booking item row
    SELECT * INTO v_item FROM booking_items WHERE id = p_booking_item_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking item not found.';
    END IF;

    -- Lock vehicle row
    SELECT * INTO v_vehicle FROM vehicles WHERE id = v_item.vehicle_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Associated vehicle not found.';
    END IF;

    -- Fetch checkout record
    SELECT * INTO v_checkout FROM handovers_checkout WHERE booking_item_id = p_booking_item_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cannot return: Check-out handover record missing.';
    END IF;

    -- Validate odometer
    IF p_checkin_odometer_km < v_checkout.checkout_odometer_km THEN
        RAISE EXCEPTION 'Invalid odometer: End KM (%) cannot be less than Start KM (%).',
            p_checkin_odometer_km, v_checkout.checkout_odometer_km;
    END IF;

    v_delta_km := p_checkin_odometer_km - v_checkout.checkout_odometer_km;

    -- Evaluate service threshold (5,000 KM service or 10,000 KM oil change)
    IF (p_checkin_odometer_km - v_vehicle.last_service_odometer_km >= 5000) OR
       (p_checkin_odometer_km - v_vehicle.last_oil_change_odometer_km >= 10000) OR
       (p_damage_penalty_fee > 0) THEN
        v_new_status := 'MAINTENANCE_REQUIRED';
    END IF;

    -- Insert return check-in record
    INSERT INTO returns_checkin (
        booking_item_id, vehicle_id, staff_id,
        checkin_odometer_km, checkin_fuel_level, distance_traveled_km,
        overtime_hours, overtime_penalty_fee, fuel_penalty_fee, damage_penalty_fee,
        body_inspection_json, photos_json,
        customer_signature_url, staff_signature_url
    ) VALUES (
        p_booking_item_id, v_vehicle.id, p_staff_id,
        p_checkin_odometer_km, p_checkin_fuel_level, v_delta_km,
        p_overtime_hours, p_overtime_penalty_fee, p_fuel_penalty_fee, p_damage_penalty_fee,
        p_body_inspection_json, p_photos_json,
        p_customer_signature_url, p_staff_signature_url
    ) RETURNING id INTO v_return_id;

    -- Update vehicle odometer and trip count
    UPDATE vehicles SET
        current_odometer_km = p_checkin_odometer_km,
        total_trip_count = total_trip_count + 1,
        status = v_new_status,
        updated_at = NOW()
    WHERE id = v_vehicle.id;

    -- Update booking item status
    UPDATE booking_items SET status = 'COMPLETED' WHERE id = p_booking_item_id;

    -- Free assigned driver if present
    IF v_item.driver_id IS NOT NULL THEN
        UPDATE drivers SET status = 'AVAILABLE' WHERE id = v_item.driver_id;
    END IF;

    -- Log atomic audit trail
    INSERT INTO audit_logs (
        entity_name, entity_id, action_type, actor_id, actor_role,
        old_data, new_data, description
    ) VALUES (
        'vehicles', v_vehicle.id, 'CHECKIN_RETURN', p_staff_id, v_staff_role,
        jsonb_build_object('odometer_km', v_vehicle.current_odometer_km, 'status', v_vehicle.status),
        jsonb_build_object('odometer_km', p_checkin_odometer_km, 'status', v_new_status, 'delta_km', v_delta_km),
        format('Return completed for item %s. Mileage increased by %s KM. Vehicle status updated to %s.',
               p_booking_item_id, v_delta_km, v_new_status)
    );

    RETURN jsonb_build_object(
        'success', true,
        'return_id', v_return_id,
        'delta_km', v_delta_km,
        'vehicle_status', v_new_status
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
