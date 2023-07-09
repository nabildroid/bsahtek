// secure the route

import db from "@/app/api/repository/db";
import { and, between, eq } from "drizzle-orm";
import * as Schema from "@/db/schema";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export const GET = async (
  request: Request,
  { params }: { params: { sellerID: string } }
) => {
  const rows = await db
    .select()
    .from(Schema.bagsTable)
    .where(eq(Schema.bagsTable.sellerID, params.sellerID))
    .execute();

  return NextResponse.json({ bags: rows });
};
