-- ============================================================================
-- Migration: 20261128000001_auth_profile_trigger.sql
-- System: Ashvin FleetOS (AFOS)
-- Purpose: Automatic profile creation trigger on auth.users and INSERT RLS policy
-- ============================================================================

-- 1. Helper Function: Get Current User Role (Safe Search Path & Explicit Type)
CREATE OR REPLACE FUNCTION public.auth_user_role()
RETURNS public.user_role_enum
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT role FROM public.user_profiles WHERE id = auth.uid();
$$;

-- 2. Add INSERT policy for user_profiles so authenticated users can upsert their own profile
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'user_profiles' AND policyname = 'Profiles insertable by self or admin/owner'
    ) THEN
        CREATE POLICY "Profiles insertable by self or admin/owner" ON public.user_profiles
        FOR INSERT WITH CHECK (auth.uid() = id OR public.auth_user_role() IN ('ADMIN', 'OWNER'));
    END IF;
END $$;

-- 3. Trigger Function: automatically create or update user_profiles upon signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.user_profiles (
    id,
    role,
    full_name,
    phone_number,
    nationality,
    preferred_locale
  )
  VALUES (
    new.id,
    COALESCE(
      CASE 
        WHEN new.raw_user_meta_data->>'role' = 'ADMIN' THEN 'ADMIN'::public.user_role_enum
        WHEN new.raw_user_meta_data->>'role' = 'OWNER' THEN 'OWNER'::public.user_role_enum
        WHEN new.raw_user_meta_data->>'role' = 'FIELD_STAFF' THEN 'FIELD_STAFF'::public.user_role_enum
        ELSE 'CUSTOMER'::public.user_role_enum
      END,
      'CUSTOMER'::public.user_role_enum
    ),
    COALESCE(NULLIF(new.raw_user_meta_data->>'full_name', ''), split_part(new.email, '@', 1)),
    COALESCE(new.raw_user_meta_data->>'phone_number', ''),
    COALESCE(new.raw_user_meta_data->>'nationality', 'ID'),
    COALESCE(new.raw_user_meta_data->>'preferred_locale', 'id')
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    phone_number = CASE WHEN EXCLUDED.phone_number <> '' THEN EXCLUDED.phone_number ELSE user_profiles.phone_number END,
    updated_at = NOW();

  RETURN new;
END;
$$;

-- 3. Attach trigger to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Backfill any existing users who lack a user_profile
INSERT INTO public.user_profiles (id, role, full_name, phone_number, nationality, preferred_locale)
SELECT 
    id,
    COALESCE(
      CASE 
        WHEN raw_user_meta_data->>'role' = 'ADMIN' THEN 'ADMIN'::user_role_enum
        WHEN raw_user_meta_data->>'role' = 'OWNER' THEN 'OWNER'::user_role_enum
        WHEN raw_user_meta_data->>'role' = 'FIELD_STAFF' THEN 'FIELD_STAFF'::user_role_enum
        ELSE 'CUSTOMER'::user_role_enum
      END,
      'CUSTOMER'::user_role_enum
    ),
    COALESCE(NULLIF(raw_user_meta_data->>'full_name', ''), split_part(email, '@', 1)),
    COALESCE(raw_user_meta_data->>'phone_number', ''),
    COALESCE(raw_user_meta_data->>'nationality', 'ID'),
    COALESCE(raw_user_meta_data->>'preferred_locale', 'id')
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.user_profiles p WHERE p.id = u.id)
ON CONFLICT (id) DO NOTHING;
