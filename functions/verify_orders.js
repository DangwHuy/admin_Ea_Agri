const admin = require('firebase-admin');
if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: 'daklakagent' });
}

async function verifyDenormalization() {
    const db = admin.firestore();
    const snapshot = await db.collection('orders').limit(10).get();
    
    console.log(`Checking ${snapshot.size} recent orders...`);
    snapshot.docs.forEach(doc => {
        const data = doc.data();
        console.log(`Order ${doc.id}: productId=${data.productId}, status=${data.status}`);
    });
}

verifyDenormalization().catch(console.error);
