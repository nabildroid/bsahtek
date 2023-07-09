
const API = (x: string) => `/api/${x}`;

export async function add(food: any) {
  // post request with food object
  const response = await fetch(API("addfood"), {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(food),
  });
}

export function update() {}

export function remove() {}
