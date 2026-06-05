const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'daklakagent',
    credential: admin.credential.applicationDefault()
  });
}

const db = admin.firestore();

async function triggerMetrics() {
  console.log("🚀 Starting Smart AI Metrics Aggregation...");
  
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
  
  const Timestamp = admin.firestore.Timestamp;
  const FieldValue = admin.firestore.FieldValue;

  try {
    const logsSnapshot = await db.collection("ai_chat_logs")
      .where("timestamp", ">=", Timestamp.fromDate(sevenDaysAgo))
      .get();

    if (logsSnapshot.empty) {
        console.log("⚠️ No logs found in the last 7 days.");
        return;
    }

    let totalErrors = 0;
    const totalQuestions = logsSnapshot.size;
    const questionCounts = {};
    const recentPrompts = [];
    
    // Semantic Error Keywords
    const errorKeywords = ["404", "error", "lỗi", "không tìm thấy", "failed", "timeout", "mất kết nối"];

    logsSnapshot.docs.forEach(doc => {
      const data = doc.data();
      const responseText = (data.response || "").toString().toLowerCase();
      const prompt = (data.prompt || "").toString().trim();
      const normalizedPrompt = prompt.toLowerCase();

      // 1. Semantic Error Logic
      let isError = data.status !== "success";
      if (errorKeywords.some(kw => responseText.includes(kw))) {
        isError = true;
      }
      if (isError) totalErrors++;

      // 2. Topic Tracking
      if (normalizedPrompt) {
        questionCounts[normalizedPrompt] = (questionCounts[normalizedPrompt] || 0) + 1;
        if (recentPrompts.length < 5 && !recentPrompts.includes(normalizedPrompt)) {
          recentPrompts.push(prompt);
        }
      }
    });

    // 3. Hybrid Top Questions
    let topQuestions = Object.entries(questionCounts)
      .filter(([_, hits]) => hits >= 2)
      .map(([query, hits]) => ({ query: capitalize(query), hits }))
      .sort((a, b) => b.hits - a.hits)
      .slice(0, 5);

    if (topQuestions.length === 0) {
      topQuestions = recentPrompts.map(p => ({ 
        query: capitalize(p), 
        hits: questionCounts[p.toLowerCase()] || 1 
      }));
    }

    const healthData = {
      fallbackPercent: (totalErrors / totalQuestions) * 100,
      totalErrors,
      totalQuestions,
      topQuestions,
      lastUpdated: FieldValue.serverTimestamp(),
    };

    console.log("📊 Final Metrics Calculated:", JSON.stringify(healthData, null, 2));

    await db.collection("ai_system_health").doc("current_metrics").set(healthData);
    console.log("✅ Dashboard data successfully refreshed!");
    process.exit(0);
  } catch (err) {
    console.error("❌ Error during aggregation:", err);
    process.exit(1);
  }
}

function capitalize(s) {
  if (!s) return "";
  return s[0].toUpperCase() + s.substring(1);
}

triggerMetrics();
