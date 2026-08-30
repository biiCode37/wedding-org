create table public.role_permission (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  role_id bigint not null references public.role(id) on delete cascade,
  permission_id bigint not null references public.permission(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (role_id, permission_id)
);
