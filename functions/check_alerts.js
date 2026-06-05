const admin = require('firebase-admin');
if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: 'daklakagent' });
}

async function checkAlerts() {
    const db = admin.firestore();
    console.log("🔍 Fetching latest alerts from 'ai_alerts'...");
    const snapshot = await db.collection('ai_alerts').orderBy('createdAt', 'desc').limit(5).get();
    
    if (snapshot.empty) {
        console.log("❌ No alerts found in the 'ai_alerts' collection.");
    } else {
        console.log(`✅ Found ${snapshot.size} alerts:`);
        snapshot.docs.forEach(doc => {
            const data = doc.data();
            console.log("-----------------------------------------");
            console.log(`DOC_ID: ${doc.id}`);
            console.log(`TYPE:   ${data.type}`);
            console.log(`TEXT:   ${data.content}`);
            console.log(`COUNT:  ${data.cancellationCount}`);
            console.log(`TIME:   ${data.createdAt?.toDate ? data.createdAt.toDate().toLocaleString() : 'N/A'}`);
        });
    }
}

checkAlerts().catch(console.error);
