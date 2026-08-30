create table public.checkin_session (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  event_id bigint not null references public.event(id) on delete cascade,
  started_at timestamptz not null,
  ended_at timestamptz,
  created_by_user_id bigint references public.user_profile(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);