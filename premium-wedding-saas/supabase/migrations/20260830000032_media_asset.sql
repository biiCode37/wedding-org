create table public.media_asset (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  storage_provider text not null,
  storage_key text not null,
  file_name text not null,
  mime_type text,
  size_bytes bigint,
  width int,
  height int,
  status text not null default 'READY',
  created_by_user_id bigint references public.user_profile(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);