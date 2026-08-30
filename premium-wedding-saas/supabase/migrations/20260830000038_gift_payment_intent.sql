create table public.gift_payment_intent (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  amount numeric(12,2) not null check (amount > 0),
  currency text not null default 'IDR',
  provider text not null,
  provider_intent_id text,
  status text not null default 'PENDING',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);