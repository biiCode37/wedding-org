create table public.website_section (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  website_version_id bigint not null references public.website_version(id) on delete cascade,
  section_type text not null,
  sort_order int not null,
  config_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);