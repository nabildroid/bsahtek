import { NextResponse } from "next/server";

import { Ad, IAd } from "@/utils/types";
import firebase from "../repository/firebase";

const ref = firebase.firestore().collection("ads");

export async function GET(request: Request) {
  const query = await ref.get();
  const ads = query.docs.map((d) => ({ id: d.id, ...d.data() } as IAd));

  return NextResponse.json({ ads });
}

// todo make it use cache but for later!
