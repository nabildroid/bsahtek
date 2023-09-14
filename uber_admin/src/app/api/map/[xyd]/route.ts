import { NextApiRequest } from "next";
import { NextResponse } from "next/server";
import db from "../../repository/db";
import * as Schema from "@/db/schema";
import { and, between } from "drizzle-orm";
import {
  reverseCalculateSquareCenter,
  addKilometersToLongitude,
} from "@/utils/coordination";
import { BlocForNot, VerificationError } from "../../repository/firebase";
import secureHash from "../../utils";

import { unstable_cache as cache } from "next/cache";




export async function GET(
  req: Request,
  context: {
    params: { xyd: string };
  }
) {
  if (await BlocForNot("", req)) return VerificationError();

  const [x, y, distance] = context.params.xyd.split(",").map(parseFloat);
  const { x: originalX, y: originalY } = reverseCalculateSquareCenter(
    x,
    y,
    distance
  );

  const boundryX = [
    addKilometersToLongitude(originalX, -distance / 2),
    addKilometersToLongitude(originalX, distance / 2),
  ];
  const boundryY = [
    addKilometersToLongitude(originalY, -distance / 2),
    addKilometersToLongitude(originalY, distance / 2),
  ];


  const zoneID = `foods-zone-${x},${y}`;
  
  console.log("Map zoneID ",zoneID);
  const foods = await cache(() => getFoods(boundryX, boundryY), [zoneID], {
    tags: [zoneID],
  })();

  // todo make it ovious like create a subtype of a computed field in the database!

  const enrishedFoods = await Promise.all(
    foods.map(async (r) => ({
      ...r,
      hash: await secureHash(
        r.windowStart.toString() + r.windowEnd.toString() + r.id
      ),
    }))
  );

  console.log(originalX, originalY, foods.length);
  return NextResponse.json({
    x,
    originalX,
    params: boundryX,
    foods: enrishedFoods, //todo rename it to product!
  });
}

async function getFoods(boundryX: number[], boundryY: number[]) {
  return await db
    .select()
    .from(Schema.bagsTable)
    .where(
      and(
        between(Schema.bagsTable.longitude, boundryX[0], boundryX[1]),
        between(Schema.bagsTable.latitude, boundryY[0], boundryY[1])
      )
    )
    .execute();
}



export const revalidate = 100000;