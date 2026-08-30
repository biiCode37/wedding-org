create table public.user_profile (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  auth_user_id uuid not null unique references auth.users(id) on delete cascade,
  display_name text not null default '',
  first_name text,
  last_name text,
  phone text,
  avatar_url text,
  locale text,
  timezone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index user_profile_auth_user_id_idx on public.user_profile (auth_user_id);
