create table public.invitation_party (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  primary_guest_id bigint not null references public.guest(id) on delete cascade,
  display_label text not null,
  invited_person_count int not null default 1 check (invited_person_count >= 1),
  actual_attendee_count int not null default 0 check (actual_attendee_count >= 0),
  status text not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (actual_attendee_count <= invited_person_count)
);