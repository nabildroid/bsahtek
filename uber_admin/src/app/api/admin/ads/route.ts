import { NextResponse } from "next/server";
import firebase, {
  BlocForNot,
  VerificationError,
} from "../../repository/firebase";
import { Ad, IAd } from "@/utils/types";
import { z } from "zod";
import { revalidateTag } from "next/cache";

const ref = firebase.firestore().collection("ads");

export async function GET(request: Request) {
  if (await BlocForNot("admin", request)) return VerificationError();

  const query = await ref.get();
  const ads = query.docs.map((d) => ({ id: d.id, ...d.data() } as IAd));

  return NextResponse.json({ ads });
}

export async function POST(request: Request) {
  if (await BlocForNot("admin", request)) return VerificationError();
  const data = await request.json();
  const ad = Ad.parse(data.ad);

  if (ad.id) {
    await ref.doc(ad.id).set({
      ...ad,
    });
  } else {
    await ref.add({ ...ad });
  }

  revalidateTag("ads");
  revalidateTag("ads");

  return NextResponse.json({});
}

export async function DELETE(request: Request) {
  if (await BlocForNot("admin", request)) return VerificationError();

  const data = await request.json();
  const id = z.string().parse(data.id);
  await ref.doc(id).delete();

  revalidateTag("ads");
  revalidateTag("ads");

  return NextResponse.json({});
}

export const dynamic = "force-dynamic";
