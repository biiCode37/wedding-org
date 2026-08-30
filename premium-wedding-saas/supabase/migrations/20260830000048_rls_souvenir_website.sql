-- RLS Policies — Souvenir, Website, Theme, Media
-- souvenir_entitlement, souvenir_entitlement_override, souvenir_claim,
-- website, website_version, website_section, theme, media_asset
-- Per PWS_Authorization_RLS_Specification_v0.1_updated.md §14, §20

-- souvenir_entitlement
alter table public.souvenir_entitlement enable row level security;

create policy "souvenir_entitlement_read"
  on public.souvenir_entitlement for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "souvenir_entitlement_insert"
  on public.souvenir_entitlement for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "souvenir_entitlement_update"
  on public.souvenir_entitlement for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

-- souvenir_entitlement_override (append-only; insert by authorized staff)
alter table public.souvenir_entitlement_override enable row level security;

create policy "souvenir_entitlement_override_read"
  on public.souvenir_entitlement_override for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "souvenir_entitlement_override_insert"
  on public.souvenir_entitlement_override for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
    and has_permission('souvenir', 'override')
  );

-- souvenir_claim
alter table public.souvenir_claim enable row level security;

create policy "souvenir_claim_read"
  on public.souvenir_claim for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "souvenir_claim_insert"
  on public.souvenir_claim for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

-- website
alter table public.website enable row level security;

create policy "website_read"
  on public.website for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "website_insert"
  on public.website for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "website_update"
  on public.website for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

-- website_version
alter table public.website_version enable row level security;

create policy "website_version_read"
  on public.website_version for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "website_version_insert"
  on public.website_version for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "website_version_update"
  on public.website_version for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

-- website_section
alter table public.website_section enable row level security;

create policy "website_section_read"
  on public.website_section for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "website_section_insert"
  on public.website_section for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "website_section_update"
  on public.website_section for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "website_section_delete"
  on public.website_section for delete
  using ( workspace_id in (select current_workspace_ids()) );

-- theme
alter table public.theme enable row level security;

create policy "theme_read"
  on public.theme for select
  using (
    is_system = true
    or organization_id in (select current_organization_ids())
    or workspace_id in (select current_workspace_ids())
  );

-- media_asset
alter table public.media_asset enable row level security;

create policy "media_asset_read"
  on public.media_asset for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "media_asset_insert"
  on public.media_asset for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "media_asset_update"
  on public.media_asset for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "media_asset_delete"
  on public.media_asset for delete
  using ( workspace_id in (select current_workspace_ids()) );
