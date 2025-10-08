-- Database Tables
CREATE TABLE public.families (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  family_id UUID REFERENCES families(id) ON DELETE SET NULL,
  email TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger Function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE families ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users  
  FOR UPDATE USING (auth.uid() = id);

-- RLS Policies for families table
CREATE POLICY "Users can view own family" ON families
  FOR SELECT USING (id IN (SELECT family_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can update own family" ON families
  FOR UPDATE USING (id IN (SELECT family_id FROM users WHERE id = auth.uid()));

  
-- Users can view families they belong to
CREATE POLICY "Users can view own family" ON families
  FOR SELECT USING (id IN (SELECT family_id FROM users WHERE id = auth.uid()));

-- Users can update families they belong to
CREATE POLICY "Users can update own family" ON families
  FOR UPDATE USING (id IN (SELECT family_id FROM users WHERE id = auth.uid()));

  -- Function to create new family
CREATE OR REPLACE FUNCTION create_family_for_user(family_name TEXT)
RETURNS UUID AS $$
DECLARE
  new_family_id UUID;
  current_user_id UUID;
BEGIN
  current_user_id := auth.uid();
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Create family
  INSERT INTO families (name) VALUES (family_name) RETURNING id INTO new_family_id;
  
  -- Link user to family
  UPDATE users SET family_id = new_family_id WHERE id = current_user_id;
  
  RETURN new_family_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to join existing family (future)
CREATE OR REPLACE FUNCTION join_existing_family(join_family_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE users SET family_id = join_family_id WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

ALTER TABLE public.users ADD COLUMN display_name TEXT;
UPDATE public.users SET display_name = split_part(email, '@', 1) WHERE display_name IS NULL;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS Policies for families table
CREATE POLICY "Users can view their family" ON families
  FOR SELECT USING (
    id IN (
      SELECT family_id 
      FROM users 
      WHERE id = auth.uid()
    )
  );

CREATE POLICY "Family members can update family" ON families
  FOR UPDATE USING (
    id IN (
      SELECT family_id 
      FROM users 
      WHERE id = auth.uid() 
      AND family_id IS NOT NULL
    )
  );

  -- Updated Function to create new family
CREATE OR REPLACE FUNCTION create_family_for_user(family_name TEXT)
RETURNS UUID AS $$
DECLARE
  new_family_id UUID;
  current_user_id UUID;
BEGIN
  current_user_id := auth.uid();
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Create family
  INSERT INTO families (name) VALUES (family_name) RETURNING id INTO new_family_id;
  
  -- Link user to family
  UPDATE users 
  SET family_id = new_family_id 
  WHERE id = current_user_id;
  
  RETURN new_family_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Updated Function to join existing family
CREATE OR REPLACE FUNCTION join_existing_family(join_family_id UUID)
RETURNS VOID AS $$
DECLARE
  current_user_id UUID;
BEGIN
  current_user_id := auth.uid();
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Verify the family exists
  IF NOT EXISTS (SELECT 1 FROM families WHERE id = join_family_id) THEN
    RAISE EXCEPTION 'Family does not exist';
  END IF;

  -- Join family
  UPDATE users 
  SET family_id = join_family_id 
  WHERE id = current_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



-- Helper function to get all family members
CREATE OR REPLACE FUNCTION get_family_members()
RETURNS TABLE (
  user_id UUID,
  email TEXT,
  display_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
  user_family_id UUID;
BEGIN
  -- Get the current user's family_id
  SELECT family_id INTO user_family_id 
  FROM users 
  WHERE id = auth.uid();

  IF user_family_id IS NULL THEN
    RAISE EXCEPTION 'User is not part of any family';
  END IF;

  -- Return all users in the same family
  RETURN QUERY
  SELECT 
    u.id,
    u.email,
    u.display_name,
    u.created_at
  FROM users u
  WHERE u.family_id = user_family_id
  ORDER BY u.created_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop the old trigger and function
DROP TRIGGER IF EXISTS on_user_deleted ON public.users;
DROP FUNCTION IF EXISTS handle_user_deletion();

-- Fixed trigger function
CREATE OR REPLACE FUNCTION handle_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
  -- Only process if the deleted user had a family
  IF OLD.family_id IS NOT NULL THEN
    -- Check if this was the last member of the family
    -- We need to check BEFORE the user is deleted, so we count remaining users
    -- excluding the one being deleted (OLD.id)
    IF NOT EXISTS (
      SELECT 1 
      FROM users 
      WHERE family_id = OLD.family_id 
      AND id != OLD.id
    ) THEN
      -- This was the last member, delete the family
      DELETE FROM families WHERE id = OLD.family_id;
    END IF;
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
CREATE TRIGGER on_user_deleted
  AFTER DELETE ON public.users
  FOR EACH ROW EXECUTE FUNCTION handle_user_deletion();

  CREATE TABLE public.children (
  id UUID PRIMARY KEY,
  family_id UUID REFERENCES families(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  age INTEGER,
  allowance_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  allowance_frequency TEXT, -- 'weekly' or 'monthly'
  allowance_day INTEGER,
  allowance_enabled BOOLEAN NOT NULL DEFAULT false,
  next_allowance_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
);

ALTER TABLE children ENABLE ROW LEVEL SECURITY;

-- Users can view children in their family
CREATE POLICY "Users can view family children" ON children
  FOR SELECT USING (
    family_id IN (
      SELECT family_id FROM users WHERE id = auth.uid()
    )
  );

-- Users can insert children for their family
CREATE POLICY "Users can create family children" ON children
  FOR INSERT WITH CHECK (
    family_id IN (
      SELECT family_id FROM users WHERE id = auth.uid()
    )
  );

-- Users can update children in their family
CREATE POLICY "Users can update family children" ON children
  FOR UPDATE USING (
    family_id IN (
      SELECT family_id FROM users WHERE id = auth.uid()
    )
  );

-- Users can delete children in their family
CREATE POLICY "Users can delete family children" ON children
  FOR DELETE USING (
    family_id IN (
      SELECT family_id FROM users WHERE id = auth.uid()
    )
  );

CREATE TABLE public.transactions (
  id UUID PRIMARY KEY,
  child_id UUID REFERENCES children(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  description TEXT,
  transaction_type TEXT NOT NULL, -- 'credit', 'debit', or 'allowance'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on transactions table
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view transactions for children in their family
CREATE POLICY "Users can view family transactions" ON transactions
  FOR SELECT USING (
    child_id IN (
      SELECT c.id FROM children c
      JOIN users u ON c.family_id = u.family_id
      WHERE u.id = auth.uid()
    )
  );

-- Policy: Users can insert transactions for children in their family
CREATE POLICY "Users can create family transactions" ON transactions
  FOR INSERT WITH CHECK (
    child_id IN (
      SELECT c.id FROM children c
      JOIN users u ON c.family_id = u.family_id
      WHERE u.id = auth.uid()
    )
  );

-- Policy: Users can update transactions for children in their family
CREATE POLICY "Users can update family transactions" ON transactions
  FOR UPDATE USING (
    child_id IN (
      SELECT c.id FROM children c
      JOIN users u ON c.family_id = u.family_id
      WHERE u.id = auth.uid()
    )
  )
  WITH CHECK (
    child_id IN (
      SELECT c.id FROM children c
      JOIN users u ON c.family_id = u.family_id
      WHERE u.id = auth.uid()
    )
  );

-- Policy: Users can delete transactions for children in their family
CREATE POLICY "Users can delete family transactions" ON transactions
  FOR DELETE USING (
    child_id IN (
      SELECT c.id FROM children c
      JOIN users u ON c.family_id = u.family_id
      WHERE u.id = auth.uid()
    )
  );