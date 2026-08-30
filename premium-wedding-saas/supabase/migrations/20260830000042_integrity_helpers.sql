-- Integrity trigger functions enforcing same-tenant ownership consistency
-- across security-sensitive relationships defined in PWS_Physical_Database_Schema §23.

create or replace function public.assert_workspace_organization_match()
returns trigger
language plpgsql
as $$
declare
  ws_org bigint;
begin
  select organization_id into ws_org
    from public.workspace
    where id = new.workspace_id;
  if ws_org is null then
    raise exception 'workspace % does not exist', new.workspace_id;
  end if;
  if new.organization_id <> ws_org then
    raise exception 'organization_id (%) does not match workspace organization_id (%)', new.organization_id, ws_org;
  end if;
  return new;
end;
$$;

create or replace function public.assert_event_workspace_organization_match()
returns trigger
language plpgsql
as $$
declare
  ev_ws bigint;
  ws_org bigint;
begin
  select workspace_id into ev_ws from public.event where id = new.event_id;
  if ev_ws is null then
    raise exception 'event % does not exist', new.event_id;
  end if;
  if new.workspace_id <> ev_ws then
    raise exception 'workspace_id (%) does not match event.workspace_id (%)', new.workspace_id, ev_ws;
  end if;
  select organization_id into ws_org from public.workspace where id = new.workspace_id;
  if ws_org is null then
    raise exception 'workspace % does not exist', new.workspace_id;
  end if;
  if new.organization_id <> ws_org then
    raise exception 'organization_id (%) does not match workspace organization_id (%)', new.organization_id, ws_org;
  end if;
  return new;
end;
$$;

create or replace function public.assert_invitation_party_workspace_organization_match()
returns trigger
language plpgsql
as $$
declare
  ws_org bigint;
  ws_for_guest bigint;
  guest_org bigint;
begin
  select organization_id, workspace_id into ws_org, ws_for_guest
    from public.workspace
    where id = new.workspace_id;
  if ws_org is null then
    raise exception 'workspace % does not exist', new.workspace_id;
  end if;
  if new.organization_id <> ws_org then
    raise exception 'organization_id (%) does not match workspace organization_id (%)', new.organization_id, ws_org;
  end if;
  select organization_id, workspace_id into guest_org, ws_for_guest
    from public.guest
    where id = new.primary_guest_id;
  if guest_org is null then
    raise exception 'guest % does not exist', new.primary_guest_id;
  end if;
  if guest_org <> new.organization_id or ws_for_guest <> new.workspace_id then
    raise exception 'primary_guest_id % is not in same workspace/organization', new.primary_guest_id;
  end if;
  return new;
end;
$$;

create or replace function public.assert_souvenir_entitlement_match()
returns trigger
language plpgsql
as $$
declare
  ws_org bigint;
  party_ws bigint;
  party_org bigint;
begin
  select organization_id, workspace_id into ws_org, party_ws
    from public.invitation_party
    where id = new.invitation_party_id;
  if ws_org is null then
    raise exception 'invitation_party % does not exist', new.invitation_party_id;
  end if;
  if new.organization_id <> ws_org then
    raise exception 'organization_id (%) does not match invitation_party.organization_id (%)', new.organization_id, ws_org;
  end if;
  if new.workspace_id <> party_ws then
    raise exception 'workspace_id (%) does not match invitation_party.workspace_id (%)', new.workspace_id, party_ws;
  end if;
  return new;
end;
$$;

create or replace function public.assert_souvenir_claim_match()
returns trigger
language plpgsql
as $$
declare
  ent_ws bigint;
  ent_org bigint;
begin
  select organization_id, workspace_id into ent_org, ent_ws
    from public.souvenir_entitlement
    where id = new.souvenir_entitlement_id;
  if ent_org is null then
    raise exception 'souvenir_entitlement % does not exist', new.souvenir_entitlement_id;
  end if;
  if new.organization_id <> ent_org then
    raise exception 'organization_id (%) does not match souvenir_entitlement.organization_id (%)', new.organization_id, ent_org;
  end if;
  if new.workspace_id <> ent_ws then
    raise exception 'workspace_id (%) does not match souvenir_entitlement.workspace_id (%)', new.workspace_id, ent_ws;
  end if;
  return new;
end;
$$;

create trigger trg_event_assert_ownership
  before insert or update on public.event
  for each row execute function public.assert_event_workspace_organization_match();

create trigger trg_event_guest_assert_ownership
  before insert or update on public.event_guest
  for each row execute function public.assert_event_workspace_organization_match();

create trigger trg_checkin_session_assert_ownership
  before insert or update on public.checkin_session
  for each row execute function public.assert_event_workspace_organization_match();

create trigger trg_checkin_record_assert_ownership
  before insert or update on public.checkin_record
  for each row execute function public.assert_event_workspace_organization_match();

create trigger trg_rsvp_assert_ownership
  before insert or update on public.rsvp
  for each row execute function public.assert_workspace_organization_match();

create trigger trg_rsvp_history_assert_ownership
  before insert or update on public.rsvp_response_history
  for each row execute function public.assert_workspace_organization_match();

create trigger trg_invitation_assert_ownership
  before insert or update on public.invitation
  for each row execute function public.assert_workspace_organization_match();

create trigger trg_invitation_token_assert_ownership
  before insert or update on public.invitation_token
  for each row execute function public.assert_workspace_organization_match();

create trigger trg_invitation_party_assert_ownership
  before insert or update on public.invitation_party
  for each row execute function public.assert_invitation_party_workspace_organization_match();

create trigger trg_souvenir_entitlement_assert_ownership
  before insert or update on public.souvenir_entitlement
  for each row execute function public.assert_souvenir_entitlement_match();

create trigger trg_souvenir_entitlement_override_assert_ownership
  before insert or update on public.souvenir_entitlement_override
  for each row execute function public.assert_workspace_organization_match();

create trigger trg_souvenir_claim_assert_ownership
  before insert or update on public.souvenir_claim
  for each row execute function public.assert_souvenir_claim_match();

create trigger trg_guest_assert_ownership
  before insert or update on public.guest
  for each row execute function public.assert_workspace_organization_match();

create trigger trg_client_access_assert_ownership
  before insert or update on public.client_access
  for each row execute function public.assert_workspace_organization_match();
