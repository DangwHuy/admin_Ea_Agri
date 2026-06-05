const admin = require('firebase-admin');
/**
 * Simple test script to be run from firebase functions:shell
 * Usage: require('./test_trigger.js')
 */
if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: 'daklakagent' });
}

async function run() {
    const db = admin.firestore();
    const tid = "trigger_test_" + Date.now();
    console.log("\n🚀 STARTING TRIGGER TEST...");
    
    // Step 1: Create orders
    console.log("📦 Creating 5 test orders as 'Pending'...");
    for(let i=0; i<5; i++) {
        await db.collection('orders').doc(tid + "_" + i).set({
            productId: "trigger_debug_product",
            status: "Pending",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
    }
    console.log("✅ Orders Created.");

    // Step 2: Update status to trigger the Cloud Function
    console.log("⚠️ Updating status to 'Cancelled' to trigger detectAnomalies...");
    for(let i=0; i<5; i++) {
        await db.collection('orders').doc(tid + "_" + i).update({
            status: "Cancelled",
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
    }
    console.log("🎉 All updates sent! Wait 10-15 seconds and check logs.");
    console.log("Command: firebase functions:log --only detectAnomalies -n 20\n");
}

run().catch(err => {
    console.error("💥 Error during test:", err);
});
