import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function GET() {
  const supabase = await createSupabaseServerClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json(
      { error: { code: "UNAUTHENTICATED", message: "Not signed in" } },
      { status: 401 }
    );
  }

  // Resolve user_profile id (used by RLS helpers and domain services).
  const { data: profile } = await supabase
    .from("user_profile")
    .select("id, uuid, display_name, locale, timezone, avatar_url")
    .eq("auth_user_id", user.id)
    .single();

  return NextResponse.json({
    data: {
      auth: { id: user.id, email: user.email },
      profile,
    },
    meta: { request_id: crypto.randomUUID() },
  });
}
