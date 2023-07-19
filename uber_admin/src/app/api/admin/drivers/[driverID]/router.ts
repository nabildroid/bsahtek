import { NotAllowed, VerificationError } from "@/app/api/repository/firebase";
import { NextResponse } from "next/server";

// get details of a deliver
export async function GET(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  return NextResponse.json({ success: true });
}

// accept deliver and assign them a bag
export async function POST(request: Request) {
  return NextResponse.json({ success: true });
}

// update deliver informations
export async function UPDATE(request: Request) {
  return NextResponse.json({ success: true });
}
