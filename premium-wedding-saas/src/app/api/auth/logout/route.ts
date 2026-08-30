import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function POST() {
  const supabase = await createSupabaseServerClient();
  const { error } = await supabase.auth.signOut();

  if (error) {
    return NextResponse.json(
      { error: { code: "LOGOUT_FAILED", message: error.message } },
      { status: 400 }
    );
  }

  return NextResponse.json({
    data: { result: "ok" },
    meta: { request_id: crypto.randomUUID() },
  });
}
