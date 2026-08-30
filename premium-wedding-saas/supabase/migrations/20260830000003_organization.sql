create table public.organization (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  status text not null default 'ACTIVE',
  timezone text,
  currency text,
  locale text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
