create table public.souvenir_entitlement_override (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  souvenir_entitlement_id bigint not null references public.souvenir_entitlement(id) on delete cascade,
  previous_quantity int not null,
  new_quantity int not null check (new_quantity >= 0),
  reason text not null check (length(trim(reason)) > 0),
  approved_by_user_id bigint not null references public.user_profile(id) on delete restrict,
  created_at timestamptz not null default now()
);