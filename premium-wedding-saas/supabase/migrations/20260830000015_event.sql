create table public.event (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  venue_id bigint references public.venue(id) on delete set null,
  name text not null,
  event_type text not null,
  starts_at timestamptz not null,
  ends_at timestamptz,
  timezone text not null default 'UTC',
  status text not null default 'DRAFT',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);