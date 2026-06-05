import { initializeApp } from "firebase-admin/app";

// Initialize the Firebase Admin SDK once at the root
initializeApp();

// Export functions from modules
export * from "./ai_analytics";
export * from "./automation";
export * from "./assistant";
export * from "./notifications";
