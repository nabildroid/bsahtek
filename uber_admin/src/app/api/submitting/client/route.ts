import { NextResponse } from "next/server";
import { updateStats } from "../../order/route";
import { BlocForNot, VerificationError } from "../../repository/firebase";
export const dynamic = "force-dynamic";

export const POST = async (request: Request) => {
  if (await BlocForNot("", request)) return VerificationError();

  await updateStats({
    newClients: "increment",
  });

  return NextResponse.json({});
};
