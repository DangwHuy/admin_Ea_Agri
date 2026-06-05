const admin = require('firebase-admin');
if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: 'daklakagent' });
}

async function auditOrders() {
    const db = admin.firestore();
    const oneHourAgo = new Date();
    oneHourAgo.setHours(oneHourAgo.getHours() - 1);

    console.log("🔍 Auditing recently updated orders...");
    const snapshot = await db.collection('orders')
        .where('updatedAt', '>=', admin.firestore.Timestamp.fromDate(oneHourAgo))
        .get();

    if (snapshot.empty) {
        console.log("❌ No orders found with an 'updatedAt' timestamp in the last hour.");
        
        // Let's check if they were updated but WITHOUT the timestamp field
        const cancelledSnapshot = await db.collection('orders')
            .where('status', '==', 'Cancelled')
            .limit(10)
            .get();
        
        console.log(`ℹ️ Found ${cancelledSnapshot.size} total cancelled orders.`);
        cancelledSnapshot.docs.forEach(doc => {
            const data = doc.data();
            console.log(`- Order ${doc.id}: productId=${data.productId}, updatedAt=${data.updatedAt ? 'EXISTS' : 'MISSING'}`);
        });

    } else {
        console.log(`✅ Found ${snapshot.size} orders updated recently.`);
        const productCounts = {};
        snapshot.docs.forEach(doc => {
            const data = doc.data();
            if (data.status === 'Cancelled') {
                const pid = data.productId || 'NO_PRODUCT_ID';
                productCounts[pid] = (productCounts[pid] || 0) + 1;
            }
        });
        console.log("Cancellation counts per product:", productCounts);
    }
}

auditOrders().catch(console.error);
