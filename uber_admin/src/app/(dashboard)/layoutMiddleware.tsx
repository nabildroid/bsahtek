"use client";
// this is qick fix for showing instant feedback on the dashboard
// i can't pre-render the dashboard routes because of they need data


export default function LayoutMiddleware({
  children,
}: {
  children: React.ReactNode;
}) {
  return <div className="flex-1">{children}</div>;
}
