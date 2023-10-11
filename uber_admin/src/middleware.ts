import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  if (
    request.nextUrl.pathname != "/landing" &&
    request.nextUrl.pathname != "/login" &&
    request.cookies.get("token") == null
  ) {
    
    return NextResponse.redirect(request.nextUrl);
  }
}

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|privacy|favicon.ico|static).*)"],
};
