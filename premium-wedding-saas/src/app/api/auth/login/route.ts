import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function POST(request: Request) {
  const { email, password } = await request.json();
  const supabase = await createSupabaseServerClient();

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    return NextResponse.json(
      { error: { code: "UNAUTHENTICATED", message: "Invalid credentials" } },
      { status: 401 }
    );
  }

  return NextResponse.json({
    data: {
      user: { id: data.user.id, email: data.user.email },
      session: data.session,
    },
    meta: { request_id: crypto.randomUUID() },
  });
}
