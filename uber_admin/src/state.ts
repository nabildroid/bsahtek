"use client";

import { User } from "firebase/auth";
import { atom } from "jotai";

export const realTimeAtom = atom(false);

export const userAtom = atom<User | null>(null);

export const userAtomAsync = atom(
  async (get) =>
    await new Promise<User>((res) => {
      const timer = setInterval(() => {
        const val = get(userAtom);
        if (val) {
          clearInterval(timer);
          res(val);
        }
      }, 10);
    })
);
