create table public.venue (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  name text not null,
  address text,
  city text,
  region text,
  postal_code text,
  country text,
  latitude numeric,
  longitude numeric,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);