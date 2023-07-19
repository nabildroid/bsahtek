"use client";

import { QueryClient, QueryClientProvider } from "react-query";

// this is qick fix for showing instant feedback on the dashboard
// i can't pre-render the dashboard routes because of they need data



const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
    },
  },
});


export default function LayoutMiddleware({
  children,
}: {
  children: React.ReactNode;
}) {
  return <QueryClientProvider client={queryClient}>
    <div className="flex-1">
      {children}
    </div>
  </QueryClientProvider>;
}
