create table public.permission (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  resource text not null,
  action text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (resource, action)
);
