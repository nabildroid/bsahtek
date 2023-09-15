import { NextResponse } from "next/server";
import { unstable_cache as cache } from "next/cache";
import { Ad, IAd } from "@/utils/types";
import firebase from "../repository/firebase";

export async function GET(request: Request) {
  const ref = firebase.firestore().collection("ads");

  const query = await cache(() => ref.get(), ["ads"], { tags: ["ads"] })();
  const ads = query.docs.map((d) => ({ id: d.id, ...d.data() } as IAd));

  return NextResponse.json({ ads });
}
