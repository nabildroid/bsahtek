import { NextResponse } from "next/server";
import { NotAllowed, VerificationError } from "../../repository/firebase";

export const dynamic = "force-dynamic";

// get accepted sellers + todo: filters, search ...
export async function GET(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  return NextResponse.json({ success: true });
}
