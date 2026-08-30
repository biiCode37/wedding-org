create table public.souvenir_claim (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  souvenir_entitlement_id bigint not null references public.souvenir_entitlement(id) on delete cascade,
  quantity int not null check (quantity > 0),
  claim_type text not null,
  claimant_name text,
  claimant_guest_id bigint references public.guest(id) on delete set null,
  proxy_for_guest_id bigint references public.guest(id) on delete set null,
  confirmed_by_user_id bigint references public.user_profile(id) on delete set null,
  idempotency_key text not null,
  claimed_at timestamptz not null default now(),
  notes text,
  status text not null default 'COMPLETED',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workspace_id, idempotency_key),
  check (
    (claim_type = 'OWNER')
    or
    (claim_type = 'PROXY' and proxy_for_guest_id is not null and confirmed_by_user_id is not null)
  )
);