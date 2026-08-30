-- RLS Policies — Workspace, Wedding, Event, Guest
-- workspace, wedding_profile, couple_person, venue, event, guest, event_guest
-- Per PWS_Authorization_RLS_Specification_v0.1_updated.md §14, §15

-- workspace
alter table public.workspace enable row level security;

create policy "workspace_read"
  on public.workspace for select
  using ( id in (select current_workspace_ids()) );

create policy "workspace_insert"
  on public.workspace for insert
  with check ( organization_id in (select current_organization_ids()) );

create policy "workspace_update"
  on public.workspace for update
  using ( id in (select current_workspace_ids()) )
  with check (
    id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "workspace_delete"
  on public.workspace for delete
  using (
    id in (select current_workspace_ids())
    and has_permission('workspace', 'archive')
  );

-- wedding_profile
alter table public.wedding_profile enable row level security;

create policy "wedding_profile_read"
  on public.wedding_profile for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "wedding_profile_insert"
  on public.wedding_profile for insert
  with check ( workspace_id in (select current_workspace_ids()) );

create policy "wedding_profile_update"
  on public.wedding_profile for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check ( workspace_id in (select current_workspace_ids()) );

-- couple_person
alter table public.couple_person enable row level security;

create policy "couple_person_read"
  on public.couple_person for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "couple_person_insert"
  on public.couple_person for insert
  with check ( workspace_id in (select current_workspace_ids()) );

create policy "couple_person_update"
  on public.couple_person for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check ( workspace_id in (select current_workspace_ids()) );

create policy "couple_person_delete"
  on public.couple_person for delete
  using ( workspace_id in (select current_workspace_ids()) );

-- venue
alter table public.venue enable row level security;

create policy "venue_read"
  on public.venue for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "venue_insert"
  on public.venue for insert
  with check ( workspace_id in (select current_workspace_ids()) );

create policy "venue_update"
  on public.venue for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check ( workspace_id in (select current_workspace_ids()) );

create policy "venue_delete"
  on public.venue for delete
  using ( workspace_id in (select current_workspace_ids()) );

-- event
alter table public.event enable row level security;

create policy "event_read"
  on public.event for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "event_insert"
  on public.event for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "event_update"
  on public.event for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "event_delete"
  on public.event for delete
  using (
    workspace_id in (select current_workspace_ids())
    and has_permission('event', 'delete')
  );

-- guest
alter table public.guest enable row level security;

create policy "guest_read"
  on public.guest for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "guest_insert"
  on public.guest for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "guest_update"
  on public.guest for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "guest_delete"
  on public.guest for delete
  using (
    workspace_id in (select current_workspace_ids())
    and has_permission('guest', 'delete')
  );

-- event_guest
alter table public.event_guest enable row level security;

create policy "event_guest_read"
  on public.event_guest for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "event_guest_insert"
  on public.event_guest for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "event_guest_update"
  on public.event_guest for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "event_guest_delete"
  on public.event_guest for delete
  using ( workspace_id in (select current_workspace_ids()) );
