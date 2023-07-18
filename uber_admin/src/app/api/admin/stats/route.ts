import { NotAllowed, VerificationError } from "../../repository/firebase";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  console.log("working");
  return NextResponse.json({ success: true });
}
