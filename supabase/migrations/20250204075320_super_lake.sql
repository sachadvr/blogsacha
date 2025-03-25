/*
  # Add themes to posts

  1. New Tables
    - `themes`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `created_at` (timestamp)

  2. Changes
    - Add theme_id to posts table
  
  3. Security
    - Enable RLS on themes table
    - Add policies for themes table
*/

-- Create themes table
CREATE TABLE IF NOT EXISTS themes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Add theme to posts
ALTER TABLE posts ADD COLUMN IF NOT EXISTS theme_id uuid REFERENCES themes(id);

-- Enable RLS
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;

-- Themes policies
CREATE POLICY "Themes are viewable by everyone"
  ON themes FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can create themes"
  ON themes FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Insert default themes
INSERT INTO themes (name) VALUES
  ('Technology'),
  ('Lifestyle'),
  ('Travel'),
  ('Food'),
  ('Programming')
ON CONFLICT (name) DO NOTHING;