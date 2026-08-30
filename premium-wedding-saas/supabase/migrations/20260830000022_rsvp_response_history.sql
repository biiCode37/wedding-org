create table public.rsvp_response_history (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  rsvp_id bigint not null references public.rsvp(id) on delete cascade,
  previous_status text,
  new_status text not null,
  changed_by_type text not null,
  changed_by_user_id bigint references public.user_profile(id),
  created_at timestamptz not null default now()
);