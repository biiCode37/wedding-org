create table public.wedding_profile (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  workspace_id bigint not null unique references public.workspace(id) on delete cascade,
  title text not null,
  wedding_date timestamptz,
  status text not null default 'DRAFT',
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);