import * as admin from 'firebase-admin';

/**
 * Verification script for AI Anomaly Detection
 * This script seeds test data and checks if the Cloud Function correctly generates an alert.
 */

// Initialize with project ID from environment or local config
if (admin.apps.length === 0) {
    admin.initializeApp({
        projectId: 'daklakagent'
    });
}

const db = admin.firestore();

async function runTest() {
    // Generate a unique product ID for this test run to avoid index/data collisions
    const testProductId = `debug_product_${Date.now()}`;
    console.log(`\n🚀 Starting verification for product: ${testProductId}`);

    // 1. Create 5 cancelled orders with correct timestamps
    console.log("📦 Seeding 5 cancelled orders...");
    for (let i = 0; i < 5; i++) {
        const orderId = `debug_order_${testProductId}_${i}`;
        
        // This simulates a status update that triggers onDocumentUpdated
        // We create it first as 'Pending' then update it to 'Cancelled'
        const orderRef = db.collection('orders').doc(orderId);
        
        await orderRef.set({
            productId: testProductId,
            productName: "AI Debug Product",
            status: "Pending",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Small delay to ensure Firestore propagates the creation before we update
        await new Promise(resolve => setTimeout(resolve, 500));

        await orderRef.update({
            status: "Cancelled",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        console.log(`   ✅ Seeded and Cancelled order ${i + 1}/5`);
    }

    console.log("\n⏳ Waiting 15 seconds for Cloud Function to trigger and process logs...");
    await new Promise(resolve => setTimeout(resolve, 15000));

    // 2. Check for the alert in ai_alerts
    console.log("🔍 Checking ai_alerts collection for the new anomaly...");
    const alertsSnippet = await db.collection('ai_alerts')
        .where('productId', '==', testProductId)
        .limit(1)
        .get();

    if (!alertsSnippet.empty) {
        const alertData = alertsSnippet.docs[0].data();
        console.log("\n🎉 SUCCESS! AI Alert detected.");
        console.log("-----------------------------------------");
        console.log(`Alert Type: ${alertData.type}`);
        console.log(`Content:    ${alertData.content}`);
        console.log(`Found Count: ${alertData.cancellationCount}`);
        console.log("-----------------------------------------");
    } else {
        console.log("\n❌ FAILURE: No alert found for this product.");
        console.log("Possible reasons:");
        console.log("1. The Cloud Function trigger failed (check `firebase functions:log`).");
        console.log("2. The query in the Cloud Function is missing a composite index.");
        console.log("3. The environment variables/API keys for Gemini are missing (if used elsewhere).");
        
        console.log("\n💡 Pro-tip: Check logs for this specific product ID to see matching query results:");
        console.log(`   firebase functions:log --only detectAnomalies | grep ${testProductId}`);
    }

    process.exit(0);
}

runTest().catch(err => {
    console.error("💥 Test failed with error:", err);
    process.exit(1);
});
