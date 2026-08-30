create table public.checkin_record (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  event_id bigint not null references public.event(id) on delete cascade,
  event_guest_id bigint not null references public.event_guest(id) on delete cascade,
  checkin_session_id bigint references public.checkin_session(id) on delete set null,
  checked_in_at timestamptz not null default now(),
  checked_in_by_user_id bigint references public.user_profile(id) on delete set null,
  source text not null,
  idempotency_key text,
  status text not null default 'CHECKED_IN',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, event_guest_id)
);