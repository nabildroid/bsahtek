import { NextApiRequest } from "next";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export function GET(
  req: Request,
  context: {
    params: { xy: string };
  }
) {

  return NextResponse.json({ params: context.params.xy });
}
