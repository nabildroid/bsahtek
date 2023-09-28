import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyDoROhtYM_umElKN-MykTj1KKusCoP0fP8",
  authDomain: "bsahtek-dashboard.firebaseapp.com",
  projectId: "bsahtek-dashboard",
  storageBucket: "bsahtek-dashboard.appspot.com",
  messagingSenderId: "971263764073",
  appId: "1:971263764073:web:14711c1c0ee959c5a224f8",
  measurementId: "G-XE5L464B1Q",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

export default app;
export const firestore = getFirestore(app);
