import { xxhash64 } from "hash-wasm";

export default async function secureHash(str: string) {
  // todo add nounce!
  const nounce = "";

  return await xxhash64(str + nounce);
}
