import { NextResponse } from "next/server";
import * as Schema from "@/db/schema";
import db from "../repository/db";
import { firestore } from "../repository/firebase";

export async function POST(request: Request) {
  const res = await request.json();

  await db
    .insert(Schema.foodTable)
    .values({
      latitude: res.latitude,
      longitude: res.longitude,
      zoomScale: 155,
      rating: 155,
      category: "test",
      county: "test",
      description: "test",
      foodPhoto: "test",
      name: "test",
      sellerAddress: "test",
      sellerName: "test",
      sellerPhoto: "test",
      tags: "test",
      wilaya: "test",
    })
    .execute();

  await firestore.collection("foods").add({
    latitude: 155,
    longitude: 155,
    zoomScale: 155,
  });

  return NextResponse.json({ res });
}
