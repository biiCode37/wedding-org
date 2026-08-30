create table public.audit_log (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint references public.organization(id) on delete cascade,
  workspace_id bigint references public.workspace(id) on delete cascade,
  actor_user_id bigint references public.user_profile(id),
  actor_type text not null,
  action text not null,
  resource_type text not null,
  resource_id bigint,
  before_snapshot jsonb,
  after_snapshot jsonb,
  request_id text,
  ip_address text,
  user_agent text,
  created_at timestamptz not null default now()
);