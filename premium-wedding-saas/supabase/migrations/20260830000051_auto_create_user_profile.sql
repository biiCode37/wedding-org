-- Auto-create user_profile on Supabase Auth signup
-- This trigger fires when a new user signs up via Supabase Auth

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.user_profile (auth_user_id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', new.email, new.phone, 'User')
  )
  on conflict (auth_user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();