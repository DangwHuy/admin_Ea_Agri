const admin = require('firebase-admin');
if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: 'daklakagent' });
}

async function checkSpecificDoc() {
    const db = admin.firestore();
    console.log("🔍 Checking specific chat log found in screenshot...");
    
    // Check specific doc from screenshot
    const docRef = db.collection('ai_chat_logs').doc('3fFxN2EgYCf8TMaK9pvN');
    const doc = await docRef.get();

    if (doc.exists) {
        console.log("✅ FOUND! I am in the correct project.");
        console.log("Data:", doc.data());
        
        const allLogs = await db.collection('ai_chat_logs').get();
        console.log(`Total logs in collection: ${allLogs.size}`);
    } else {
        console.log("❌ NOT FOUND. I might be looking at the wrong project or database instance.");
        
        // Let's list all collections to see where we are
        const collections = await db.listCollections();
        console.log("Available collections in this project:");
        collections.forEach(c => console.log("- " + c.id));
    }
}

checkSpecificDoc().catch(console.error);
