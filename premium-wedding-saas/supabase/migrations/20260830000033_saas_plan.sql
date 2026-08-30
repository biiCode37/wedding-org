create table public.saas_plan (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  price_amount numeric(12,2) not null default 0,
  currency text not null default 'IDR',
  billing_interval text not null,
  status text not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);