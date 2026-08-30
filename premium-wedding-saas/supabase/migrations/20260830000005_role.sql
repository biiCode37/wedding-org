create table public.role (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint references public.organization(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  is_system boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (
    (is_system = true and organization_id is null)
    or
    (is_system = false and organization_id is not null)
  ),
  unique (code, organization_id)
);
