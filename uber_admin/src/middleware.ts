import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

function dropMiddleware(url: URL) {
  if (url.pathname.includes("/_next")) {
    return true;
  }

  if (url.pathname.startsWith("/api")) {
    return true;
  }
  if (url.pathname.startsWith("/static")) {
    return true;
  }
  if (url.pathname.startsWith("/login")) {
    return true;
  }

  if (url.pathname.includes("/favicon.ico")) {
    return true;
  }

  return false;
}

export function middleware(request: NextRequest) {
  const url = new URL(request.url);
  if (dropMiddleware(url)) return NextResponse.next();

  if (request.cookies.get("token") == null) {
    url.pathname = `landing${url.pathname}`;
    console.log(url.pathname);
    return NextResponse.rewrite(url);
  }
}

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|privacy|favicon.ico|static).*)"],
};
