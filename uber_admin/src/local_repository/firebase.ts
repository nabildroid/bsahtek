import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyDO4H7E1RqYRVVd8GwubFb6pbAd-SDldpg",
  authDomain: "ubereat-eb4c7.firebaseapp.com",
  databaseURL:
    "https://ubereat-eb4c7-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "ubereat-eb4c7",
  storageBucket: "ubereat-eb4c7.appspot.com",
  messagingSenderId: "1090457346712",
  appId: "1:1090457346712:web:16c60992fccebe2d0ba6ed",
  measurementId: "G-RD3YDZEZBQ",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

export default app;
export const firestore = getFirestore(app);
