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
export const authApp = initializeApp(firebaseConfig, "login");

const clientFirebaseConfig = {
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
const clientApp = initializeApp(clientFirebaseConfig);
export default clientApp;

export const firestore = getFirestore(clientApp);
