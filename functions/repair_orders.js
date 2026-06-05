const admin = require('firebase-admin');
if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: 'daklakagent' });
}

async function repairLegacyOrders() {
    const db = admin.firestore();
    const oneHourAgo = new Date();
    oneHourAgo.setHours(oneHourAgo.getHours() - 1);

    console.log("🛠️ Repairing legacy orders for AI test...");
    const snapshot = await db.collection('orders')
        .where('status', '==', 'Cancelled')
        .get();

    if (snapshot.empty) {
        console.log("No cancelled orders found to repair.");
        return;
    }

    let repairedCount = 0;
    for (const doc of snapshot.docs) {
        const data = doc.data();
        if (!data.productId && data.items && data.items.length > 0) {
            const firstItem = data.items[0];
            await doc.ref.update({
                productId: firstItem.productId,
                productName: firstItem.name || firstItem.productName || "Unknown Product"
            });
            console.log(`✅ Repaired Order ${doc.id}: Set productId to ${firstItem.productId}`);
            repairedCount++;
        }
    }
    console.log(`Done! Repaired ${repairedCount} orders.`);
}

repairLegacyOrders().catch(console.error);
