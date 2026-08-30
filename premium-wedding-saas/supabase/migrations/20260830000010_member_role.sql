create table public.member_role (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_member_id bigint not null references public.organization_member(id) on delete cascade,
  role_id bigint not null references public.role(id) on delete cascade,
  workspace_id bigint references public.workspace(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);