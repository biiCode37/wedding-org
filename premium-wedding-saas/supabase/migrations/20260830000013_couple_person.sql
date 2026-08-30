create table public.couple_person (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  role text not null,
  display_name text not null,
  first_name text,
  last_name text,
  phone text,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);