-- RLS Policies — Invitation, RSVP, Check-in
-- invitation_party, invitation, invitation_token, rsvp, rsvp_response_history,
-- checkin_session, checkin_record
-- Per PWS_Authorization_RLS_Specification_v0.1_updated.md §14, §17, §19

-- invitation_party
alter table public.invitation_party enable row level security;

create policy "invitation_party_read"
  on public.invitation_party for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "invitation_party_insert"
  on public.invitation_party for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "invitation_party_update"
  on public.invitation_party for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "invitation_party_delete"
  on public.invitation_party for delete
  using ( workspace_id in (select current_workspace_ids()) );

-- invitation
alter table public.invitation enable row level security;

create policy "invitation_read"
  on public.invitation for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "invitation_insert"
  on public.invitation for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "invitation_update"
  on public.invitation for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "invitation_delete"
  on public.invitation for delete
  using ( workspace_id in (select current_workspace_ids()) );

-- invitation_token (highly restricted: staff + token access handled server-side)
alter table public.invitation_token enable row level security;

create policy "invitation_token_read_staff"
  on public.invitation_token for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "invitation_token_insert"
  on public.invitation_token for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "invitation_token_update"
  on public.invitation_token for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "invitation_token_delete"
  on public.invitation_token for delete
  using ( workspace_id in (select current_workspace_ids()) );

-- rsvp
alter table public.rsvp enable row level security;

create policy "rsvp_read"
  on public.rsvp for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "rsvp_insert"
  on public.rsvp for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "rsvp_update"
  on public.rsvp for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

-- rsvp_response_history (append-only)
alter table public.rsvp_response_history enable row level security;

create policy "rsvp_history_read"
  on public.rsvp_response_history for select
  using ( workspace_id in (select current_workspace_ids()) );

-- checkin_session
alter table public.checkin_session enable row level security;

create policy "checkin_session_read"
  on public.checkin_session for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "checkin_session_insert"
  on public.checkin_session for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "checkin_session_update"
  on public.checkin_session for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

-- checkin_record
alter table public.checkin_record enable row level security;

create policy "checkin_record_read"
  on public.checkin_record for select
  using ( workspace_id in (select current_workspace_ids()) );

create policy "checkin_record_insert"
  on public.checkin_record for insert
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );

create policy "checkin_record_update"
  on public.checkin_record for update
  using ( workspace_id in (select current_workspace_ids()) )
  with check (
    workspace_id in (select current_workspace_ids())
    and organization_id in (select current_organization_ids())
  );
