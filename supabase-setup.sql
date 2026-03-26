-- ══════════════════════════════════════════════════════
--  TakaTrack — Supabase Database Setup
--  Run this entire file in Supabase → SQL Editor → New Query
-- ══════════════════════════════════════════════════════

-- 1. PROFILES TABLE
create table if not exists public.profiles (
  id          bigint generated always as identity primary key,
  user_id     uuid references auth.users(id) on delete cascade not null unique,
  name        text not null,
  budget      numeric(12,2) not null default 30000,
  month       text not null,           -- e.g. "2025-06"
  avatar      text,                    -- base64 data URL
  created_at  timestamptz default now()
);

-- 2. CATEGORIES TABLE
create table if not exists public.categories (
  id          text primary key,        -- e.g. "rent", "food", "c_123456"
  user_id     uuid references auth.users(id) on delete cascade not null,
  label       text not null,
  icon        text not null default '📦',
  color       text not null default '#adb5bd',
  locked      boolean not null default false,
  created_at  timestamptz default now()
);

-- 3. EXPENSES TABLE
create table if not exists public.expenses (
  id          bigint generated always as identity primary key,
  user_id     uuid references auth.users(id) on delete cascade not null,
  category    text not null,
  amount      numeric(12,2) not null,
  date        date not null,
  month       text not null,           -- e.g. "2025-06"
  comment     text,
  loan_type   text,                    -- "given" | "taken" | null
  created_at  timestamptz default now()
);

-- ══════════════════════════════════════════════════════
--  ROW LEVEL SECURITY — users can only see their own data
-- ══════════════════════════════════════════════════════

alter table public.profiles   enable row level security;
alter table public.categories enable row level security;
alter table public.expenses   enable row level security;

-- PROFILES policies
create policy "Users can view own profile"
  on public.profiles for select using (auth.uid() = user_id);

create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = user_id);

create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = user_id);

create policy "Users can delete own profile"
  on public.profiles for delete using (auth.uid() = user_id);

-- CATEGORIES policies
create policy "Users can view own categories"
  on public.categories for select using (auth.uid() = user_id);

create policy "Users can insert own categories"
  on public.categories for insert with check (auth.uid() = user_id);

create policy "Users can update own categories"
  on public.categories for update using (auth.uid() = user_id);

create policy "Users can delete own categories"
  on public.categories for delete using (auth.uid() = user_id);

-- EXPENSES policies
create policy "Users can view own expenses"
  on public.expenses for select using (auth.uid() = user_id);

create policy "Users can insert own expenses"
  on public.expenses for insert with check (auth.uid() = user_id);

create policy "Users can update own expenses"
  on public.expenses for update using (auth.uid() = user_id);

create policy "Users can delete own expenses"
  on public.expenses for delete using (auth.uid() = user_id);

-- ══════════════════════════════════════════════════════
--  INDEXES for performance
-- ══════════════════════════════════════════════════════
create index if not exists expenses_user_month on public.expenses(user_id, month);
create index if not exists expenses_user_date  on public.expenses(user_id, date);
create index if not exists categories_user     on public.categories(user_id);
