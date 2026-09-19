-- Supabase Schema for Paws & Claws Charity App

-- 1. Create Animals Table
CREATE TABLE public.animals (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  species text NOT NULL, -- e.g., 'Cat', 'Dog', 'Bird'
  breed text,
  age_months integer,
  description text,
  image_url text,
  is_urgent boolean DEFAULT false,
  adoption_status text DEFAULT 'available', -- 'available', 'pending', 'adopted'
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create Users Table (extends Supabase Auth)
CREATE TABLE public.users (
  id uuid REFERENCES auth.users(id) PRIMARY KEY,
  email text NOT NULL,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create Applications Table
CREATE TABLE public.applications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) NOT NULL,
  animal_id uuid REFERENCES public.animals(id) NOT NULL,
  status text DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  submitted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Create Donations Table
CREATE TABLE public.donations (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES public.users(id) NOT NULL,
  amount numeric(10,2) NOT NULL,
  type text DEFAULT 'one-time', -- 'one-time', 'monthly'
  status text DEFAULT 'completed', -- 'completed', 'failed'
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Create Messages Table (C2C Messaging)
CREATE TABLE public.messages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id uuid REFERENCES auth.users(id) NOT NULL,
  receiver_id uuid REFERENCES auth.users(id) NOT NULL,
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Basic Policies (Can be modified later for tighter security)
-- Public read access for animals
CREATE POLICY "Public profiles are viewable by everyone." ON public.animals FOR SELECT USING (true);
CREATE POLICY "Users can universally insert animals." ON public.animals FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can universally update animals." ON public.animals FOR UPDATE USING (true);

-- Users can read their own profile
CREATE POLICY "Users can view own profile." ON public.users FOR SELECT USING (auth.uid() = id);
-- Users can update their own profile
CREATE POLICY "Users can update own profile." ON public.users FOR UPDATE USING (auth.uid() = id);

-- Users can see their own applications
CREATE POLICY "Users can read own applications." ON public.applications FOR SELECT USING (auth.uid() = user_id);
-- Users can insert their own applications
CREATE POLICY "Users can create applications." ON public.applications FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can see their own donations
CREATE POLICY "Users can read own donations." ON public.donations FOR SELECT USING (auth.uid() = user_id);
-- Users can insert their own donations
CREATE POLICY "Users can create donations." ON public.donations FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Universal P2P Messaging Select Policy (Users can see messages they sent or received)
CREATE POLICY "Users can view active chats" ON public.messages FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
-- Universal P2P Messaging Insert Policy (Users can send messages to anyone openly)
CREATE POLICY "Users can openly insert messages" ON public.messages FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Trigger to automatically create a user record in public.users when a new auth user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
