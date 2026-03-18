-- Enable extension for UUID generation if not already enabled
create extension if not exists pgcrypto;

create table if not exists public.designs (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id),
  user_type text not null check (user_type in ('customer', 'jeweller')),
  prompt text not null,
  style_params jsonb default '{}'::jsonb,
  image_url text not null,
  sketch_url text,
  thumbnail_url text,
  status text default 'completed' check (status in ('generating', 'completed', 'failed')),
  is_favorite boolean default false,
  created_at timestamptz default now()
);

create index if not exists idx_designs_user_id_created_at
  on public.designs (user_id, created_at desc);

-- Optional row-level security policy setup (customize for your auth model)
-- alter table public.designs enable row level security;

-- Storage bucket for generated images/sketches
insert into storage.buckets (id, name, public)
values ('designs', 'designs', true)
on conflict (id) do nothing;
