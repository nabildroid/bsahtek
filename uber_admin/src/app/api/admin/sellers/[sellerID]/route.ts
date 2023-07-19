import { NotAllowed, VerificationError } from "@/app/api/repository/firebase";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

// get details of a seller
export async function GET(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  return NextResponse.json({ success: true });
}

// accept seller and assign them a bag
export async function POST(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  return NextResponse.json({ success: true });
}

// update seller informations
export async function UPDATE(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  return NextResponse.json({ success: true });
}
