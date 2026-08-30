-- RLS Policies — Tenant & RBAC tables
-- user_profile, organization, organization_settings, organization_member,
-- role, permission, role_permission, member_role, client_access
-- Per PWS_Authorization_RLS_Specification_v0.1_updated.md §14, §15, §16

-- user_profile
alter table public.user_profile enable row level security;

create policy "user_profile_select_self"
  on public.user_profile for select
  using (auth.uid() = auth_user_id);

-- Organization
alter table public.organization enable row level security;

create policy "organization_read_members"
  on public.organization for select
  using ( id in (select current_organization_ids()) );

create policy "organization_update_owner_admin"
  on public.organization for update
  using ( id in (select current_organization_ids()) )
  with check ( id in (select current_organization_ids()) );

-- organization_settings
alter table public.organization_settings enable row level security;

create policy "org_settings_read_members"
  on public.organization_settings for select
  using ( organization_id in (select current_organization_ids()) );

-- organization_member
alter table public.organization_member enable row level security;

create policy "org_member_read_same_org"
  on public.organization_member for select
  using ( organization_id in (select current_organization_ids()) );

create policy "org_member_insert_manage"
  on public.organization_member for insert
  with check (
    organization_id in (select current_organization_ids())
    and has_permission('organization', 'members.manage')
  );

create policy "org_member_update_manage"
  on public.organization_member for update
  using ( organization_id in (select current_organization_ids()) )
  with check ( organization_id in (select current_organization_ids()) );

create policy "org_member_delete_manage"
  on public.organization_member for delete
  using ( organization_id in (select current_organization_ids()) );

-- role
alter table public.role enable row level security;

create policy "role_read_same_org"
  on public.role for select
  using ( organization_id is null or organization_id in (select current_organization_ids()) );

-- permission
alter table public.permission enable row level security;

create policy "permission_read_same_org"
  on public.permission for select
  using ( true );

-- role_permission
alter table public.role_permission enable row level security;

create policy "role_permission_read_same_org"
  on public.role_permission for select
  using (
    exists (
      select 1 from public.role r
      where r.id = role_id
        and (r.organization_id is null or r.organization_id in (select current_organization_ids()))
    )
  );

-- member_role
alter table public.member_role enable row level security;

create policy "member_role_read_same_org"
  on public.member_role for select
  using (
    exists (
      select 1 from public.organization_member om
      where om.id = organization_member_id
        and om.organization_id in (select current_organization_ids())
    )
  );

create policy "member_role_insert_roles_manage"
  on public.member_role for insert
  with check (
    exists (
      select 1 from public.organization_member om
      where om.id = organization_member_id
        and om.organization_id in (select current_organization_ids())
    )
    and has_permission('organization', 'roles.manage')
  );

create policy "member_role_update_roles_manage"
  on public.member_role for update
  using ( true )
  with check (
    exists (
      select 1 from public.organization_member om
      where om.id = organization_member_id
        and om.organization_id in (select current_organization_ids())
    )
    and has_permission('organization', 'roles.manage')
  );

create policy "member_role_delete_roles_manage"
  on public.member_role for delete
  using (
    exists (
      select 1 from public.organization_member om
      where om.id = organization_member_id
        and om.organization_id in (select current_organization_ids())
    )
    and has_permission('organization', 'roles.manage')
  );

-- client_access
alter table public.client_access enable row level security;

create policy "client_access_read_self_workspace"
  on public.client_access for select
  using ( user_profile_id = public.current_user_profile_id() or workspace_id in (select current_workspace_ids()) );
