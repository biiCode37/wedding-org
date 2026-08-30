create table public.subscription (
  id bigint generated always as identity primary key,
  uuid uuid not null unique default gen_random_uuid(),
  organization_id bigint not null references public.organization(id) on delete cascade,
  saas_plan_id bigint not null references public.saas_plan(id) on delete restrict,
  status text not null default 'DRAFT',
  provider text,
  provider_customer_id text,
  provider_subscription_id text,
  starts_at timestamptz,
  ends_at timestamptz,
  current_period_start timestamptz,
  current_period_end timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);