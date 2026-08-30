create table public.souvenir_entitlement (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  invitation_party_id bigint not null references public.invitation_party(id) on delete cascade,
  entitlement_type text not null default 'SOUVENIR',
  default_quantity int not null check (default_quantity >= 0),
  override_quantity int check (override_quantity is null or override_quantity >= 0),
  final_quantity int not null check (final_quantity >= 0),
  claimed_quantity int not null default 0 check (claimed_quantity >= 0),
  status text not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (invitation_party_id, entitlement_type),
  check (claimed_quantity <= final_quantity)
);