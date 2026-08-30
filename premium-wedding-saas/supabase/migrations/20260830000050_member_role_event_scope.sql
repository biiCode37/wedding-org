-- Complete member_role event_id relationship.
-- member_role was created (step 10) before event (step 15), so the FK to event
-- could not be added inline. This migration completes the scope model defined in
-- PWS_Physical_Database_Schema_v0.1.md §6.4:
--   event_id NOT NULL -> workspace_id NOT NULL (event scope must sit in a workspace)

alter table public.member_role
  add column event_id bigint references public.event(id) on delete cascade;

-- Scope invariant: event scope must belong to the same workspace as the role scope.
-- Enforced by checking the referenced event's workspace matches member_role.workspace_id.
create or replace function public.assert_member_role_event_scope()
returns trigger
language plpgsql
as $$
declare
  ev_ws bigint;
begin
  if new.event_id is null then
    -- organization scope (both null) or workspace scope (workspace set, event null)
    return new;
  end if;
  if new.workspace_id is null then
    raise exception 'event scope requires workspace_id';
  end if;
  select workspace_id into ev_ws from public.event where id = new.event_id;
  if ev_ws is null then
    raise exception 'event % does not exist', new.event_id;
  end if;
  if ev_ws <> new.workspace_id then
    raise exception 'event % does not belong to workspace %', new.event_id, new.workspace_id;
  end if;
  return new;
end;
$$;

create trigger trg_member_role_assert_event_scope
  before insert or update on public.member_role
  for each row execute function public.assert_member_role_event_scope();
