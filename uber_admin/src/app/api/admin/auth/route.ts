import { NextResponse } from "next/server";
import firebase, {
  BlocForNot,
  VerificationError,
} from "../../repository/firebase";
import { AdminBlocForNot } from "../../repository/admin_firebase";

export async function GET(request: Request) {
  if (await AdminBlocForNot([""], request)) return VerificationError();

  const accessToken = await firebase.auth().createCustomToken("allowed_user", {
    admin: true,
  });
  return NextResponse.json({ accessToken });
}

export const dynamic = "force-dynamic";
