import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function POST(request: Request) {
  const { email, password, display_name } = await request.json();

  const supabase = await createSupabaseServerClient();

  const { data: authData, error: authError } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { display_name: display_name ?? email },
    },
  });

  if (authError) {
    return NextResponse.json(
      { error: { code: "SIGNUP_FAILED", message: authError.message } },
      { status: 400 }
    );
  }

  // If signup returns no user, it may require email confirmation.
  // user_profile auto-created via trigger (on_auth_user_created).
  return NextResponse.json({
    data: {
      user: authData.user
        ? { id: authData.user.id, email: authData.user.email }
        : null,
      session: authData.session,
    },
    meta: { request_id: crypto.randomUUID() },
  });
}
