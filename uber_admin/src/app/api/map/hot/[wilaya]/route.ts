import { NextApiRequest } from "next";
import { NextResponse } from "next/server";
import db from "../../../repository/db";
import * as Schema from "@/db/schema";
import { between } from "drizzle-orm";
import {
  reverseCalculateSquareCenter,
  addKilometersToLongitude,
} from "@/utils/coordination";

export const dynamic = "force-dynamic";

export async function GET(
  req: Request,
  context: {
    params: { wilaya: string };
  }
) {
  const rows = await db.select().from(Schema.foodTable).execute();

  return NextResponse.json({
    wilaya: context.params.wilaya,
    foods: rows,
  });
}
