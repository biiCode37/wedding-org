create table public.organization_member (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  user_profile_id bigint not null references public.user_profile(id) on delete cascade,
  status text not null default 'ACTIVE',
  joined_at timestamptz,
  left_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, user_profile_id)
);
