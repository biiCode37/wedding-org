create table public.verified_gift_transaction (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  workspace_id bigint not null references public.workspace(id) on delete cascade,
  gift_payment_intent_id bigint not null references public.gift_payment_intent(id) on delete cascade,
  provider text not null,
  provider_transaction_id text not null,
  amount numeric(12,2) not null,
  currency text not null default 'IDR',
  status text not null default 'VERIFIED',
  verified_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);