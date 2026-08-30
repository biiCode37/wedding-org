-- RLS Policies — SaaS Billing, Wedding Gift, Audit
-- saas_plan, subscription, invoice, billing_payment_transaction,
-- gift_configuration, gift_payment_intent, verified_gift_transaction, audit_log
-- Per PWS_Authorization_RLS_Specification_v0.1_updated.md §14, §25, §26

-- saas_plan (public catalog, read by all authenticated users)
alter table public.saas_plan enable row level security;

create policy "saas_plan_read"
  on public.saas_plan for select
  using ( true );

-- subscription (organization-owned)
alter table public.subscription enable row level security;

create policy "subscription_read"
  on public.subscription for select
  using ( organization_id in (select current_organization_ids()) );

create policy "subscription_insert"
  on public.subscription for insert
  with check ( organization_id in (select current_organization_ids()) );

create policy "subscription_update"
  on public.subscription for update
  using ( organization_id in (select current_organization_ids()) )
  with check ( organization_id in (select current_organization_ids()) );

-- invoice (organization-owned)
alter table public.invoice enable row level security;

create policy "invoice_read"
  on public.invoice for select
  using ( organization_id in (select current_organization_ids()) );

create policy "invoice_insert"
  on public.invoice for insert
  with check ( organization_id in (select current_organization_ids()) );

create policy "invoice_update"
  on public.invoice for update
  using ( organization_id in (select current_organization_ids()) )
  with check ( organization_id in (select current_organization_ids()) );

-- billing_payment_transaction (organization-owned)
alter table public.billing_payment_transaction enable row level security;

create policy "billing_payment_transaction_read"
  on public.billing_payment_transaction for select
  using ( organization_id in (select current_organization_ids()) );

create policy "billing_payment_transaction_insert"
  on public.billing_payment_transaction for insert
  with check ( organization_id in (select current_organization_ids()) );

create policy "billing_payment_transaction_update"
  on public.billing_payment_transaction for update
  using ( organization_id in (select current_organization_ids()) )
  with check ( organization_id in (select current_organization_ids()) );

-- gift_configuration (workspace-owned)
alter table public.gift_configuration enable row level security;

create policy "gift_configuration_read"
  on public.gift_configuration for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "gift_configuration_insert"
  on public.gift_configuration for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "gift_configuration_update"
  on public.gift_configuration for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

-- gift_payment_intent (workspace-owned)
alter table public.gift_payment_intent enable row level security;

create policy "gift_payment_intent_read"
  on public.gift_payment_intent for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "gift_payment_intent_insert"
  on public.gift_payment_intent for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "gift_payment_intent_update"
  on public.gift_payment_intent for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

-- verified_gift_transaction (workspace-owned)
alter table public.verified_gift_transaction enable row level security;

create policy "verified_gift_transaction_read"
  on public.verified_gift_transaction for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "verified_gift_transaction_insert"
  on public.verified_gift_transaction for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

-- audit_log (read-only for authorized; write path is system-controlled)
alter table public.audit_log enable row level security;

create policy "audit_log_read"
  on public.audit_log for select
  using ( organization_id in (select current_organization_ids())
          or workspace_id in (select current_workspace_ids()) );
