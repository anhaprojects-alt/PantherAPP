import { initializeApp } from "https://www.gstatic.com/firebasejs/11.10.0/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/11.10.0/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/11.10.0/firebase-firestore.js";
import { getStorage } from "https://www.gstatic.com/firebasejs/11.10.0/firebase-storage.js";

const firebaseConfig = {
  apiKey: "AIzaSyDgyjU9z3XnTT-Eb5EwhGsGnvrP68ylyCA",
  authDomain: "panther-3fc1b.firebaseapp.com",
  projectId: "panther-3fc1b",
  storageBucket: "panther-3fc1b.firebasestorage.app",
  messagingSenderId: "517207033570",
  appId: "1:517207033570:web:76dfda2c1dd45bc74480bb",
  measurementId: "G-N6T7TFYL8P"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
