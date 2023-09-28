import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyAMypMX_KpT-23TSPiEdMlKpI9Bn_MxCGQ",
  authDomain: "arib-api.firebaseapp.com",
  databaseURL:
    "https://arib-api-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "arib-api",
  storageBucket: "arib-api.appspot.com",
  messagingSenderId: "130736475332",
  appId: "1:130736475332:web:1e8230d3bb9302682f4d91",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

export default app;
export const firestore = getFirestore(app);
