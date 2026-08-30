create table public.workspace (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  name text not null,
  slug text not null,
  status text not null default 'ACTIVE',
  timezone text,
  currency text,
  locale text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, slug)
);