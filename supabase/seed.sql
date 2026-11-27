-- ============================================================================
-- Seed: seed.sql
-- System: Ashvin FleetOS (AFOS)
-- Purpose: Realistic Initial Seed Data (B2C, B2B Entities, Full RBAC, Fleet, Orders)
-- ============================================================================

DO $$
DECLARE
    -- Auth & Profile User IDs
    v_owner_id UUID := '00000000-0000-0000-0000-000000000001';
    v_admin_1_id UUID := '00000000-0000-0000-0000-000000000002';
    v_admin_2_id UUID := '00000000-0000-0000-0000-000000000003';
    v_staff_1_id UUID := '00000000-0000-0000-0000-000000000004';
    v_staff_2_id UUID := '00000000-0000-0000-0000-000000000005';
    v_driver_1_user_id UUID := '00000000-0000-0000-0000-000000000006';
    v_driver_2_user_id UUID := '00000000-0000-0000-0000-000000000007';
    v_cust_rian_id UUID := '00000000-0000-0000-0000-000000000008';
    v_cust_elena_id UUID := '00000000-0000-0000-0000-000000000009';
    v_cust_citra_id UUID := '00000000-0000-0000-0000-000000000010';
    v_pic_denny_id UUID := '00000000-0000-0000-0000-000000000011';
    v_pic_bambang_id UUID := '00000000-0000-0000-0000-000000000012';

    -- Corporate Account IDs
    v_corp_jogjawisata_id UUID := '66666666-6666-6666-6666-666666666601';
    v_corp_mataram_id UUID := '66666666-6666-6666-6666-666666666602';
    v_corp_dinas_id UUID := '66666666-6666-6666-6666-666666666603';

    -- Vehicle IDs
    v_avanza_id UUID := '11111111-1111-1111-1111-111111111101';
    v_innova_id UUID := '11111111-1111-1111-1111-111111111102';
    v_brio_id UUID := '11111111-1111-1111-1111-111111111103';
    v_xpander_id UUID := '11111111-1111-1111-1111-111111111104';
    v_hiace_id UUID := '11111111-1111-1111-1111-111111111105';

    -- Driver IDs
    v_driver_sutrisno_id UUID := '55555555-5555-5555-5555-555555555501';
    v_driver_agus_id UUID := '55555555-5555-5555-5555-555555555502';

    -- Package IDs
    v_pkg_avanza_self UUID := '77777777-7777-7777-7777-777777777701';
    v_pkg_avanza_driver UUID := '77777777-7777-7777-7777-777777777702';
    v_pkg_innova_driver UUID := '77777777-7777-7777-7777-777777777703';
    v_pkg_brio_self UUID := '77777777-7777-7777-7777-777777777704';
    v_pkg_hiace_driver UUID := '77777777-7777-7777-7777-777777777705';

    -- Booking IDs
    v_b2c_booking_id UUID := '88888888-8888-8888-8888-888888888801';
    v_b2c_item_id UUID := '99999999-9999-9999-9999-999999999901';
    v_b2b_booking_id UUID := '88888888-8888-8888-8888-888888888802';
    v_b2b_item_1_id UUID := '99999999-9999-9999-9999-999999999902';
    v_b2b_item_2_id UUID := '99999999-9999-9999-9999-999999999903';
BEGIN
    -- 1. AUTH USERS (Supabase GoTrue)
    INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data)
    VALUES 
        (v_owner_id, 'owner@ashvin.id', crypt('AshvinOwner2026!', gen_salt('bf')), NOW(), '{"full_name": "Pak Ashvin"}'::jsonb),
        (v_admin_1_id, 'admin@ashvin.id', crypt('AshvinAdmin2026!', gen_salt('bf')), NOW(), '{"full_name": "Maya Admin"}'::jsonb),
        (v_admin_2_id, 'admin.ops@ashvin.id', crypt('AshvinAdmin2026!', gen_salt('bf')), NOW(), '{"full_name": "Hendra Ops Admin"}'::jsonb),
        (v_staff_1_id, 'staff.budi@ashvin.id', crypt('AshvinStaff2026!', gen_salt('bf')), NOW(), '{"full_name": "Budi Lapangan"}'::jsonb),
        (v_staff_2_id, 'staff.joko@ashvin.id', crypt('AshvinStaff2026!', gen_salt('bf')), NOW(), '{"full_name": "Joko Lapangan"}'::jsonb),
        (v_driver_1_user_id, 'driver.sutrisno@ashvin.id', crypt('AshvinDriver2026!', gen_salt('bf')), NOW(), '{"full_name": "Sutrisno Chauffeur"}'::jsonb),
        (v_driver_2_user_id, 'driver.agus@ashvin.id', crypt('AshvinDriver2026!', gen_salt('bf')), NOW(), '{"full_name": "Agus Supir"}'::jsonb),
        (v_cust_rian_id, 'rian.wisata@gmail.com', crypt('AshvinCust2026!', gen_salt('bf')), NOW(), '{"full_name": "Rian Pelanggan"}'::jsonb),
        (v_cust_elena_id, 'elena.travels@outlook.com', crypt('AshvinCust2026!', gen_salt('bf')), NOW(), '{"full_name": "Elena Rostova"}'::jsonb),
        (v_cust_citra_id, 'citra.keluarga@yahoo.co.id', crypt('AshvinCust2026!', gen_salt('bf')), NOW(), '{"full_name": "Citra Lestari"}'::jsonb),
        (v_pic_denny_id, 'denny@jogjawisata.com', crypt('AshvinCorp2026!', gen_salt('bf')), NOW(), '{"full_name": "Denny Corporate PIC"}'::jsonb),
        (v_pic_bambang_id, 'bambang@mataram.co.id', crypt('AshvinCorp2026!', gen_salt('bf')), NOW(), '{"full_name": "Bambang Mataram PIC"}'::jsonb)
    ON CONFLICT (id) DO NOTHING;

    -- 2. USER PROFILES (Full RBAC Coverage)
    INSERT INTO user_profiles (id, role, full_name, phone_number, id_card_number, driver_license_number, nationality, preferred_locale)
    VALUES
        (v_owner_id, 'OWNER', 'Pak Ashvin', '+6281234567801', '3471012304850001', 'SIM-A-1001', 'ID', 'id'),
        (v_admin_1_id, 'ADMIN', 'Maya Admin', '+6281234567802', '3471012304900002', 'SIM-A-1002', 'ID', 'id'),
        (v_admin_2_id, 'ADMIN', 'Hendra Ops Admin', '+6281234567803', '3471012304910003', 'SIM-A-1003', 'ID', 'id'),
        (v_staff_1_id, 'FIELD_STAFF', 'Budi Lapangan', '+6281234567804', '3471012304920004', 'SIM-A-1004', 'ID', 'id'),
        (v_staff_2_id, 'FIELD_STAFF', 'Joko Lapangan', '+6281234567805', '3471012304930005', 'SIM-A-1005', 'ID', 'id'),
        (v_driver_1_user_id, 'FIELD_STAFF', 'Sutrisno Chauffeur', '+6281234567806', '3471012304800006', 'SIM-B1-2001', 'ID', 'id'),
        (v_driver_2_user_id, 'FIELD_STAFF', 'Agus Supir', '+6281234567807', '3471012304820007', 'SIM-B1-2002', 'ID', 'id'),
        -- B2C Retail Customers
        (v_cust_rian_id, 'CUSTOMER', 'Rian Pelanggan', '+6281234567808', '3578012304950008', 'SIM-A-3001', 'ID', 'id'),
        (v_cust_elena_id, 'CUSTOMER', 'Elena Rostova', '+447911123456', 'PASSPORT-GB-9921', 'IDP-INT-4401', 'UK', 'en'),
        (v_cust_citra_id, 'CUSTOMER', 'Citra Lestari', '+6281234567810', '3171012304970010', 'SIM-A-3002', 'ID', 'id'),
        -- B2B Corporate PICs
        (v_pic_denny_id, 'CUSTOMER', 'Denny Corporate PIC', '+6281122334455', '3471012304880011', 'SIM-A-4001', 'ID', 'id'),
        (v_pic_bambang_id, 'CUSTOMER', 'Bambang Mataram PIC', '+6281122334466', '3471012304890012', 'SIM-A-4002', 'ID', 'id')
    ON CONFLICT (id) DO NOTHING;

    -- 3. B2B CORPORATE ACCOUNTS (Corporate Clients)
    INSERT INTO corporate_accounts (
        id, company_name, tax_id, business_id, billing_address,
        pic_user_id, pic_name, pic_phone, pic_email, credit_limit, payment_terms
    ) VALUES 
        (v_corp_jogjawisata_id, 'PT Jogja Wisata Mandiri', '01.234.567.8-541.000', '1234567890123',
         'Jl. Malioboro No. 88, Gedongtengen, Kota Yogyakarta',
         v_pic_denny_id, 'Denny Corporate PIC', '+6281122334455', 'denny@jogjawisata.com',
         75000000.00, 'TOP_30'),
        (v_corp_mataram_id, 'CV Mataram Solusi Teknologi', '02.345.678.9-541.000', '2345678901234',
         'Jl. Kaliurang KM 6, Sleman, DI Yogyakarta',
         v_pic_bambang_id, 'Bambang Mataram PIC', '+6281122334466', 'bambang@mataram.co.id',
         35000000.00, 'TOP_14'),
        (v_corp_dinas_id, 'Dinas Pariwisata DIY (Instansi Pemerintah)', '00.123.456.7-541.000', '3456789012345',
         'Jl. Malioboro No. 56, Kota Yogyakarta',
         v_admin_1_id, 'Maya Admin (Gov Liaison)', '+6281234567802', 'pariwisata@jogjaprov.go.id',
         100000000.00, 'TOP_60')
    ON CONFLICT (id) DO NOTHING;

    -- 4. PHYSICAL VEHICLES (Fleet Master)
    INSERT INTO vehicles (
        id, license_plate, brand, model, year, transmission, seating_capacity,
        current_odometer_km, last_service_odometer_km, last_oil_change_odometer_km,
        stnk_tax_due_date, total_trip_count, status
    ) VALUES 
        (v_avanza_id, 'AB 1420 QK', 'Toyota', 'All New Avanza 1.5 G', 2023, 'AUTOMATIC', 7,
         18500, 15000, 15000, CURRENT_DATE + INTERVAL '120 days', 42, 'ON_RENTAL'),
        (v_innova_id, 'AB 1899 ZT', 'Toyota', 'Innova Reborn 2.4 V Diesel', 2022, 'AUTOMATIC', 7,
         34200, 30000, 30000, CURRENT_DATE + INTERVAL '45 days', 68, 'AVAILABLE'),
        (v_brio_id, 'AB 1102 GA', 'Honda', 'Brio Satya E', 2023, 'MANUAL', 5,
         12100, 10000, 10000, CURRENT_DATE + INTERVAL '210 days', 28, 'AVAILABLE'),
        (v_xpander_id, 'AB 1733 XY', 'Mitsubishi', 'Xpander Ultimate', 2023, 'AUTOMATIC', 7,
         24800, 20000, 20000, CURRENT_DATE + INTERVAL '15 days', 50, 'AVAILABLE'),
        (v_hiace_id, 'AB 7001 CD', 'Toyota', 'HiAce Commuter 16-Seat', 2022, 'MANUAL', 16,
         48000, 45000, 40000, CURRENT_DATE + INTERVAL '90 days', 85, 'AVAILABLE')
    ON CONFLICT (id) DO NOTHING;

    -- 5. DRIVERS (Chauffeurs)
    INSERT INTO drivers (id, user_id, full_name, phone_number, license_number, status)
    VALUES 
        (v_driver_sutrisno_id, v_driver_1_user_id, 'Sutrisno Chauffeur', '+6281234567806', 'SIM-B1-2001', 'AVAILABLE'),
        (v_driver_agus_id, v_driver_2_user_id, 'Agus Supir', '+6281234567807', 'SIM-B1-2002', 'AVAILABLE')
    ON CONFLICT (id) DO NOTHING;

    -- 6. RENTAL PACKAGES
    INSERT INTO rental_packages (
        id, name, service_type, service_area, duration_hours, base_price, deposit_amount, includes_fuel
    ) VALUES 
        (v_pkg_avanza_self, 'Avanza Lepas Kunci 24 Jam (Dalam Kota)', 'SELF_DRIVE', 'IN_TOWN', 24, 350000.00, 500000.00, FALSE),
        (v_pkg_avanza_driver, 'Avanza Dengan Sopir 12 Jam (Dalam Kota)', 'WITH_DRIVER', 'IN_TOWN', 12, 500000.00, 0.00, FALSE),
        (v_pkg_innova_driver, 'Innova Reborn All-In 12 Jam (Wisata Jogja)', 'WITH_DRIVER', 'IN_TOWN', 12, 850000.00, 0.00, TRUE),
        (v_pkg_brio_self, 'Brio Lepas Kunci 24 Jam (Dalam Kota)', 'SELF_DRIVE', 'IN_TOWN', 24, 275000.00, 500000.00, FALSE),
        (v_pkg_hiace_driver, 'HiAce Commuter With Driver 12 Jam (Grup Wisata)', 'WITH_DRIVER', 'IN_TOWN', 12, 1200000.00, 0.00, TRUE)
    ON CONFLICT (id) DO NOTHING;

    -- 7. SAMPLE B2C ACTIVE RESERVATION & CHECKOUT
    INSERT INTO bookings (
        id, booking_code, order_type, customer_id, status, total_amount, security_deposit_amount, down_payment_amount, approved_by, approved_at
    ) VALUES (
        v_b2c_booking_id, 'AFOS-B2C-202611-001', 'B2C_RETAIL', v_cust_rian_id, 'ON_RENTAL', 350000.00, 500000.00, 105000.00, v_admin_1_id, NOW() - INTERVAL '4 hours'
    ) ON CONFLICT (id) DO NOTHING;

    INSERT INTO booking_items (
        id, booking_id, vehicle_id, package_id, start_time, end_time, unit_price, status
    ) VALUES (
        v_b2c_item_id, v_b2c_booking_id, v_avanza_id, v_pkg_avanza_self, NOW() - INTERVAL '4 hours', NOW() + INTERVAL '20 hours', 350000.00, 'ON_RENTAL'
    ) ON CONFLICT (id) DO NOTHING;

    INSERT INTO handovers_checkout (
        booking_item_id, vehicle_id, staff_id, checkout_odometer_km, checkout_fuel_level,
        body_inspection_json, customer_signature_url, staff_signature_url, checkout_notes
    ) VALUES (
        v_b2c_item_id, v_avanza_id, v_staff_1_id, 18500, 8,
        '{"front_bumper": "minor_scratch_left", "tires": "good", "spare_tire": "present"}'::jsonb,
        'https://supabase.local/storage/v1/object/signatures/sig_cust_rian.png',
        'https://supabase.local/storage/v1/object/signatures/sig_staff_budi.png',
        'Serah terima di Stasiun Tugu Yogyakarta. Unit bersih.'
    ) ON CONFLICT (booking_item_id) DO NOTHING;

    -- 8. SAMPLE B2B MULTI-UNIT CONFIRMED ORDER (PT Jogja Wisata Mandiri - 2 Cars)
    INSERT INTO bookings (
        id, booking_code, order_type, customer_id, corporate_account_id, po_number, status, total_amount, security_deposit_amount, approved_by, approved_at
    ) VALUES (
        v_b2b_booking_id, 'AFOS-B2B-202611-002', 'B2B_CORPORATE', v_pic_denny_id, v_corp_jogjawisata_id, 'PO-JWM-2026-X12', 'CONFIRMED', 2050000.00, 0.00, v_owner_id, NOW() - INTERVAL '1 day'
    ) ON CONFLICT (id) DO NOTHING;

    INSERT INTO booking_items (
        id, booking_id, vehicle_id, package_id, driver_id, start_time, end_time, unit_price, status
    ) VALUES 
        (v_b2b_item_1_id, v_b2b_booking_id, v_innova_id, v_pkg_innova_driver, v_driver_sutrisno_id, NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day 12 hours', 850000.00, 'CONFIRMED'),
        (v_b2b_item_2_id, v_b2b_booking_id, v_hiace_id, v_pkg_hiace_driver, v_driver_agus_id, NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day 12 hours', 1200000.00, 'CONFIRMED')
    ON CONFLICT (id) DO NOTHING;

END $$;
