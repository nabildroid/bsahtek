import { NotAllowed, VerificationError } from "@/app/api/repository/firebase";
import { NextResponse } from "next/server";

// get list of all  (pending-tobe) drivers
export async function GET(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  return NextResponse.json({ success: true });
}
