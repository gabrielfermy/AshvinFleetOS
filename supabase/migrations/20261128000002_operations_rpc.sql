-- ============================================================================
-- Migration: 20261128000002_operations_rpc.sql
-- System: Ashvin FleetOS (AFOS)
-- Purpose: Atomic Check-Out and Hardened Check-In Stored Procedures
-- ============================================================================

-- 1. ATOMIC STORED PROCEDURE: PROCESS CHECK-OUT HANDOVER
CREATE OR REPLACE FUNCTION public.rpc_process_checkout_atomic(
    p_booking_item_id UUID,
    p_staff_id UUID,
    p_checkout_odometer_km INT,
    p_checkout_fuel_level SMALLINT,
    p_body_inspection_json JSONB,
    p_photos_json JSONB,
    p_customer_signature_url TEXT,
    p_staff_signature_url TEXT,
    p_checkout_notes TEXT DEFAULT ''
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_item RECORD;
    v_vehicle RECORD;
    v_checkout_id UUID;
    v_staff_role public.user_role_enum;
BEGIN
    -- Verify staff role
    SELECT role INTO v_staff_role FROM public.user_profiles WHERE id = p_staff_id;
    IF v_staff_role NOT IN ('FIELD_STAFF', 'ADMIN', 'OWNER') THEN
        RAISE EXCEPTION 'Unauthorized: Actor must be Field Staff, Admin, or Owner.';
    END IF;

    -- Lock booking item row
    SELECT * INTO v_item FROM public.booking_items WHERE id = p_booking_item_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking item not found.';
    END IF;

    -- Lock vehicle row
    SELECT * INTO v_vehicle FROM public.vehicles WHERE id = v_item.vehicle_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Associated vehicle not found.';
    END IF;

    -- Validate odometer >= vehicle current odometer
    IF p_checkout_odometer_km < v_vehicle.current_odometer_km THEN
        RAISE EXCEPTION 'Invalid start odometer: Checkout KM (%) cannot be less than current vehicle KM (%).',
            p_checkout_odometer_km, v_vehicle.current_odometer_km;
    END IF;

    -- Insert checkout handover
    INSERT INTO public.handovers_checkout (
        booking_item_id, vehicle_id, staff_id,
        checkout_odometer_km, checkout_fuel_level,
        body_inspection_json, photos_json,
        customer_signature_url, staff_signature_url,
        checkout_notes, checkout_timestamp
    ) VALUES (
        p_booking_item_id, v_vehicle.id, p_staff_id,
        p_checkout_odometer_km, p_checkout_fuel_level,
        p_body_inspection_json, p_photos_json,
        p_customer_signature_url, p_staff_signature_url,
        p_checkout_notes, NOW()
    ) RETURNING id INTO v_checkout_id;

    -- Update vehicle status to ON_RENTAL
    UPDATE public.vehicles SET
        status = 'ON_RENTAL',
        current_odometer_km = p_checkout_odometer_km,
        updated_at = NOW()
    WHERE id = v_vehicle.id;

    -- Update booking item status to ON_RENTAL
    UPDATE public.booking_items SET
        status = 'ON_RENTAL'
    WHERE id = p_booking_item_id;

    -- Update parent booking status to ON_RENTAL
    UPDATE public.bookings SET
        status = 'ON_RENTAL',
        updated_at = NOW()
    WHERE id = v_item.booking_id;

    -- If driver is assigned, set driver to ASSIGNED
    IF v_item.driver_id IS NOT NULL THEN
        UPDATE public.drivers SET status = 'ASSIGNED' WHERE id = v_item.driver_id;
    END IF;

    -- Log atomic audit trail
    INSERT INTO public.audit_logs (
        entity_name, entity_id, action_type, actor_id, actor_role,
        old_data, new_data, description
    ) VALUES (
        'vehicles', v_vehicle.id, 'CHECKOUT_HANDOVER', p_staff_id, v_staff_role,
        jsonb_build_object('odometer_km', v_vehicle.current_odometer_km, 'status', v_vehicle.status),
        jsonb_build_object('odometer_km', p_checkout_odometer_km, 'status', 'ON_RENTAL', 'checkout_id', v_checkout_id),
        format('Handover check-out completed for booking item %s. Vehicle status updated to ON_RENTAL.', p_booking_item_id)
    );

    RETURN jsonb_build_object(
        'success', true,
        'checkout_id', v_checkout_id,
        'vehicle_status', 'ON_RENTAL',
        'checkout_odometer_km', p_checkout_odometer_km
    );
END;
$$;

-- 2. HARDENED ATOMIC STORED PROCEDURE: PROCESS RETURN CHECK-IN & ODOMETER
CREATE OR REPLACE FUNCTION public.rpc_process_checkin_atomic(
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
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_item RECORD;
    v_vehicle RECORD;
    v_checkout RECORD;
    v_delta_km INT;
    v_new_status public.vehicle_status_enum := 'AVAILABLE';
    v_return_id UUID;
    v_staff_role public.user_role_enum;
BEGIN
    -- Verify staff role
    SELECT role INTO v_staff_role FROM public.user_profiles WHERE id = p_staff_id;
    IF v_staff_role NOT IN ('FIELD_STAFF', 'ADMIN', 'OWNER') THEN
        RAISE EXCEPTION 'Unauthorized: Actor must be Field Staff, Admin, or Owner.';
    END IF;

    -- Lock booking item row
    SELECT * INTO v_item FROM public.booking_items WHERE id = p_booking_item_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking item not found.';
    END IF;

    -- Lock vehicle row
    SELECT * INTO v_vehicle FROM public.vehicles WHERE id = v_item.vehicle_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Associated vehicle not found.';
    END IF;

    -- Fetch checkout record
    SELECT * INTO v_checkout FROM public.handovers_checkout WHERE booking_item_id = p_booking_item_id;
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
    INSERT INTO public.returns_checkin (
        booking_item_id, vehicle_id, staff_id,
        checkin_odometer_km, checkin_fuel_level, distance_traveled_km,
        overtime_hours, overtime_penalty_fee, fuel_penalty_fee, damage_penalty_fee,
        body_inspection_json, photos_json,
        customer_signature_url, staff_signature_url, checkin_timestamp
    ) VALUES (
        p_booking_item_id, v_vehicle.id, p_staff_id,
        p_checkin_odometer_km, p_checkin_fuel_level, v_delta_km,
        p_overtime_hours, p_overtime_penalty_fee, p_fuel_penalty_fee, p_damage_penalty_fee,
        p_body_inspection_json, p_photos_json,
        p_customer_signature_url, p_staff_signature_url, NOW()
    ) RETURNING id INTO v_return_id;

    -- Update vehicle odometer and trip count
    UPDATE public.vehicles SET
        current_odometer_km = p_checkin_odometer_km,
        total_trip_count = total_trip_count + 1,
        status = v_new_status,
        updated_at = NOW()
    WHERE id = v_vehicle.id;

    -- Update booking item status
    UPDATE public.booking_items SET status = 'COMPLETED' WHERE id = p_booking_item_id;

    -- If all items in the booking are completed, mark booking COMPLETED
    IF NOT EXISTS (
        SELECT 1 FROM public.booking_items
        WHERE booking_id = v_item.booking_id AND status <> 'COMPLETED'
    ) THEN
        UPDATE public.bookings SET status = 'COMPLETED', updated_at = NOW() WHERE id = v_item.booking_id;
    END IF;

    -- Free assigned driver if present
    IF v_item.driver_id IS NOT NULL THEN
        UPDATE public.drivers SET status = 'AVAILABLE' WHERE id = v_item.driver_id;
    END IF;

    -- Log atomic audit trail
    INSERT INTO public.audit_logs (
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
$$;
