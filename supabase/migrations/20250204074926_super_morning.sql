/*
  # Add email field to profiles table

  1. Changes
    - Add email column to profiles table
    - Create trigger to copy email from auth.users
  
  2. Security
    - Email is readable by authenticated users
*/

-- Add email column to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email text;

-- Update trigger to include email
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (new.id, new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update existing profiles with emails from auth.users
DO $$
BEGIN
  UPDATE profiles p
  SET email = u.email
  FROM auth.users u
  WHERE p.id = u.id AND p.email IS NULL;
END $$;