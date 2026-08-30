create table public.event_guest (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  event_id bigint not null references public.event(id) on delete cascade,
  guest_id bigint not null references public.guest(id) on delete cascade,
  attendance_status text not null default 'PENDING',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, guest_id)
);