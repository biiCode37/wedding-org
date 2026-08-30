-- Authorization Helper Functions for RLS
-- Defined per PWS_Authorization_RLS_Specification_v0.1_updated.md §13

create or replace function public.current_user_profile_id()
returns bigint
language sql
security definer
stable
as $$
  select id from public.user_profile where auth_user_id = auth.uid() limit 1;
$$;

create or replace function public.current_organization_ids()
returns setof bigint
language sql
security definer
stable
as $$
  select organization_id 
  from public.organization_member 
  where user_profile_id = public.current_user_profile_id() 
    and status = 'ACTIVE';
$$;

create or replace function public.current_workspace_ids()
returns setof bigint
language sql
security definer
stable
as $$
  -- Organization owners/admins have access to all workspaces in their organizations,
  -- or via workspace specific membership/roles/client_access.
  select distinct w.id
  from public.workspace w
  join public.organization_member om on om.organization_id = w.organization_id
  where om.user_profile_id = public.current_user_profile_id()
    and om.status = 'ACTIVE'
  union
  select workspace_id
  from public.client_access
  where user_profile_id = public.current_user_profile_id()
    and status = 'ACTIVE';
$$;

create or replace function public.current_event_ids()
returns setof bigint
language sql
security definer
stable
as $$
  select distinct e.id
  from public.event e
  join public.workspace w on w.id = e.workspace_id
  join public.organization_member om on om.organization_id = w.organization_id
  where om.user_profile_id = public.current_user_profile_id()
    and om.status = 'ACTIVE';
$$;

create or replace function public.has_permission(p_resource text, p_action text)
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1
    from public.organization_member om
    join public.member_role mr on mr.organization_member_id = om.id
    join public.role_permission rp on rp.role_id = mr.role_id
    join public.permission p on p.id = rp.permission_id
    where om.user_profile_id = public.current_user_profile_id()
      and om.status = 'ACTIVE'
      and p.resource = p_resource
      and p.action = p_action
  );
$$;
