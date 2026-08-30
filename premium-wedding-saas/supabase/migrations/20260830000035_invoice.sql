create table public.invoice (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  subscription_id bigint not null references public.subscription(id) on delete cascade,
  invoice_number text not null unique,
  status text not null default 'DRAFT',
  amount numeric(12,2) not null,
  currency text not null default 'IDR',
  due_at timestamptz,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);