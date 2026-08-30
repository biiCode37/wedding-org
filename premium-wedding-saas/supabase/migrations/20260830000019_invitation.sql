create table public.invitation (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  invitation_party_id bigint not null references public.invitation_party(id) on delete cascade,
  event_id bigint references public.event(id) on delete set null,
  title text not null,
  status text not null default 'DRAFT',
  sent_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);