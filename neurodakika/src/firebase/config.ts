import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY ?? "",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN ?? "",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID ?? "",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET ?? "",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER ?? "",
  appId: import.meta.env.VITE_FIREBASE_APP_ID ?? "",
};

const isConfigValid = Object.values(firebaseConfig).every(
  (value) => typeof value === "string" && value.trim().length > 0
);

const app = isConfigValid ? initializeApp(firebaseConfig) : null;

if (!app) {
  console.warn(
    "Firebase yapılandırması eksik. .env dosyasına VITE_FIREBASE_* değişkenlerini ekleyene kadar auth özellikleri devre dışı."
  );
}

export const auth = app ? getAuth(app) : null;
export const googleProvider = app ? new GoogleAuthProvider() : null;
export const db = app ? getFirestore(app) : null;
export const isFirebaseReady = Boolean(app);

