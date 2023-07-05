type Order = {
  id: number;
  client: string;
  bag: string;
  quantity: number;
  location: {
    latitude: number;
    longitude: number;
  };
  seller: string;
};

export async function POST(request: Request) {
  const order = (await request.json()) as Order;

  console.log(order);

  return new Response(JSON.stringify(order));
}
