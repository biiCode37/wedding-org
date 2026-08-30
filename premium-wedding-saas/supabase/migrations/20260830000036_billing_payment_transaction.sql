create table public.billing_payment_transaction (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  invoice_id bigint not null references public.invoice(id) on delete cascade,
  provider text not null,
  provider_transaction_id text,
  amount numeric(12,2) not null,
  currency text not null default 'IDR',
  status text not null default 'PENDING',
  paid_at timestamptz,
  raw_reference jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);