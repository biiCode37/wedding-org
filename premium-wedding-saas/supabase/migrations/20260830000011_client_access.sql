create table public.client_access (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  user_profile_id bigint not null references public.user_profile(id) on delete cascade,
  access_role text not null default 'COUPLE',
  status text not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workspace_id, user_profile_id)
);