const admin = require('firebase-admin');
if (admin.apps.length === 0) {
    admin.initializeApp({ projectId: 'daklakagent' });
}

async function auditChatLogs() {
    const db = admin.firestore();
    console.log("🔍 Auditing ai_chat_logs...");
    const snapshot = await db.collection('ai_chat_logs').limit(10).get();

    if (snapshot.empty) {
        console.log("❌ No chat logs found.");
        return;
    }

    snapshot.docs.forEach(doc => {
        console.log(`Document ${doc.id}:`, doc.data());
    });
}

auditChatLogs().catch(console.error);
