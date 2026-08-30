create table public.rsvp (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  event_guest_id bigint not null unique references public.event_guest(id) on delete cascade,
  response_status text not null default 'PENDING',
  guest_count int,
  responded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (guest_count is null or guest_count >= 0)
);