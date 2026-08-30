create table public.theme (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint references public.organization(id) on delete cascade,
  workspace_id bigint references public.workspace(id) on delete cascade,
  name text not null,
  config_json jsonb not null default '{}'::jsonb,
  is_system boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);