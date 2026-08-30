create table public.website_version (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  website_id bigint not null references public.website(id) on delete cascade,
  version_number int not null,
  status text not null default 'DRAFT',
  content_json jsonb not null default '{}'::jsonb,
  published_at timestamptz,
  created_by_user_id bigint references public.user_profile(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (website_id, version_number)
);