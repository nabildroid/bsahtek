import { NextResponse } from "next/server";
import { AllowOnlyIF, VerificationError } from "../../repository/firebase";
import db from "../../repository/db";
import * as Schema from "@/db/schema";

export const dynamic = "force-dynamic";

// get accepted sellers + todo: filters, search ...
export async function GET(request: Request) {
  if (await AllowOnlyIF("admin", request)) return VerificationError();

  const raws = await db.select().from(Schema.bagsTable);

  return NextResponse.json({ sellers: raws });
}
