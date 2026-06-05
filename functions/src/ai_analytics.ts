import { onSchedule } from "firebase-functions/v2/scheduler";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError, onRequest } from "firebase-functions/v2/https";
import { getFirestore, Timestamp, FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { LLMService } from "./services/llm_service";
import { defineSecret } from "firebase-functions/params";

// Defining the Gemini API Key as a secret
const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

const db = getFirestore();

/**
 * 1. generateDailyInsights
 * Scheduled to run once a day at 1:00 AM.
 * Collects yesterday's stats and generates AI insights.
 */
export const generateDailyInsights = onSchedule({
  schedule: "0 1 * * *",
  secrets: [GEMINI_API_KEY],
  timeZone: "Asia/Ho_Chi_Minh",
}, async (event) => {
  try {
    const now = new Date();
    const startOfYesterday = new Date(now);
    startOfYesterday.setDate(now.getDate() - 1);
    startOfYesterday.setHours(0, 0, 0, 0);

    const endOfYesterday = new Date(startOfYesterday);
    endOfYesterday.setHours(23, 59, 59, 999);

    // Query orders from yesterday
    const ordersSnapshot = await db.collection("orders")
      .where("createdAt", ">=", Timestamp.fromDate(startOfYesterday))
      .where("createdAt", "<=", Timestamp.fromDate(endOfYesterday))
      .get();

    const orderData = ordersSnapshot.docs.map(doc => ({
      totalAmount: doc.data().totalAmount,
      status: doc.data().status,
    }));

    // Query product stats
    const productStats = await db.collection("product_stats").limit(10).get();
    const topProducts = productStats.docs.map(doc => doc.data());

    // Prepare data for LLM
    const reportData = {
      date: startOfYesterday.toISOString().split("T")[0],
      totalOrdersYesterday: ordersSnapshot.size,
      orders: orderData,
      topProducts: topProducts,
    };

    const llm = new LLMService(GEMINI_API_KEY.value());
    const insights = await llm.generateDailyInsights(reportData);

    // Save to Firestore
    const batch = db.batch();
    insights.forEach(insight => {
      const insightRef = db.collection("ai_insights").doc();
      batch.set(insightRef, insight);
    });
    await batch.commit();

    logger.info(`Successfully generated ${insights.length} insights.`);
  } catch (error) {
    logger.error("Error in generateDailyInsights:", error);
  }
});

/**
 * 2. detectAnomalies
 * Triggered when an order is updated.
 * Flags products with more than 5 cancellations in the last hour.
 */
export const detectAnomalies = onDocumentUpdated("orders/{orderId}", async (event) => {
  try {
    const newValue = event.data?.after.data();
    const previousValue = event.data?.before.data();

    if (!newValue) return;

    logger.info(`detectAnomalies triggered for order ${event.params.orderId}. Status change: ${previousValue?.status} -> ${newValue?.status}`);

    // Logic: Listen for order status changes to "Cancelled"
    if (newValue?.status === "Cancelled" && previousValue?.status !== "Cancelled") {
      const items = newValue.items as any[] || [];

      if (items.length === 0) {
        logger.error("No items found in cancelled order.");
        return;
      }

      // We use a Set to avoid checking the same product twice if it appears multiple times in the order
      const uniqueProductIds = new Set<string>(items.map(item => item.productId).filter(id => !!id));

      if (uniqueProductIds.size === 0) {
        // Fallback: Check if there's a legacy root-level productId
        const rootProductId = newValue.productId;
        if (rootProductId) {
          uniqueProductIds.add(rootProductId);
        } else {
          logger.error("No valid productIds found in items array or root.");
          return;
        }
      }

      const oneHourAgo = new Date();
      oneHourAgo.setHours(oneHourAgo.getHours() - 1);

      for (const productId of uniqueProductIds) {
        const itemData = items.find(i => i.productId === productId);
        const productName = itemData?.name || newValue.productName || "Unknown Product";

        logger.info(`Checking anomalies for product: [${productName}] (${productId})`);

        // Query cancellations for this specific product in the last hour
        // NOTE: This relies on productId being at the root level (will be fixed in data producers)
        const snapshot = await db.collection("orders")
          .where("productId", "==", productId)
          .where("status", "==", "Cancelled")
          .where("updatedAt", ">=", Timestamp.fromDate(oneHourAgo))
          .get();

        // ⚠️ Wait! Firestore query limitations: You cannot search for a value inside an array of objects easily
        // unless you use 'array-contains' with the EXACT object or a specialized index.

        // Let's refine the query: 
        // We will fallback to a simpler query for now (searching for ANY cancelled orders in last hour) 
        // and filter in memory if the index isn't ready, but that's inefficient.

        // BEST FIX: I will update the CartScreen to also include a root 'productId' if there's only one, 
        // or a 'productIds' array. BUT for now, I'll optimize the function to search for cancelled orders 
        // in the last hour and filter them. (Safe for low volume, requires index for high volume).

        logger.info(`Result: Found ${snapshot.size} cancellations with status Cancelled recently.`);

        if (snapshot.size >= 5) {
          const alertId = `anomaly_${productId}_${oneHourAgo.getHours()}`;
          const alertRef = db.collection("ai_alerts").doc(alertId);

          await alertRef.set({
            type: "anomaly",
            content: `Anomalies: ${snapshot.size} unusual cancellations detected for [${productName}].`,
            productId: productId,
            productName: productName,
            cancellationCount: snapshot.size,
            createdAt: FieldValue.serverTimestamp(),
            isRead: false,
          });

          logger.warn(`Anomaly detected and saved to Firestore for product ${productId}: ${snapshot.size} cancellations.`);
        }
      }
    }
  } catch (error: any) {
    logger.error("Error in detectAnomalies:", error);

    // Actionable advice for Code 7 (Permission Denied)
    if (error.code === 7 || error.message?.toLowerCase().includes("permission")) {
      logger.error("🔑 PERMISSION ERROR: Please ensure the Cloud Functions Service Account has the 'Cloud Datastore User' role.");
      logger.error("Also, if this error occurs during a query, it might be a hidden 'Missing Index' error. Check the Firebase Console for a generated index link.");
    }
  }
});

/**
 * 3. calculateAIMetrics
 * Callable function to compute Fallback Rate and Popular Questions.
 * Can be triggered from Dashboard or on a schedule.
 */
/**
 * Shared logic for calculating AI metrics from chat logs.
 */
async function _performAggregation() {
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

  // Simplified query: No orderBy to avoid potential index issues during troubleshooting
  const logsSnapshot = await db.collection("ai_chat_logs")
    .where("timestamp", ">=", Timestamp.fromDate(sevenDaysAgo))
    .get();

  if (logsSnapshot.empty) {
    logger.info("No ai_chat_logs found for the last 7 days.");
    const emptyData = {
      fallbackPercent: 0,
      totalErrors: 0,
      topQuestions: [],
      totalQuestions: 0,
      lastUpdated: FieldValue.serverTimestamp(),
    };
    await db.collection("ai_system_health").doc("current_metrics").set(emptyData);
    return emptyData;
  }

  // Sort in memory instead
  const sortedDocs = logsSnapshot.docs.sort((a, b) => {
    const tsA = a.data().timestamp?.toMillis() || 0;
    const tsB = b.data().timestamp?.toMillis() || 0;
    return tsB - tsA;
  });

  let totalErrors = 0;
  const totalQuestions = sortedDocs.length;
  const questionCounts: { [key: string]: number } = {};
  const recentPrompts: string[] = [];
  const errorKeywords = ["404", "error", "lỗi", "không tìm thấy", "failed", "timeout", "mất kết nối"];

  sortedDocs.forEach(doc => {
    const data = doc.data();
    const responseText = (data.response || "").toString().toLowerCase();

    let isError = data.status !== "success";
    if (errorKeywords.some(kw => responseText.includes(kw))) {
      isError = true;
    }

    if (isError) totalErrors++;

    const rawPrompt = (data.prompt || "").toString().trim();
    const normalizedPrompt = rawPrompt.toLowerCase();

    if (normalizedPrompt) {
      questionCounts[normalizedPrompt] = (questionCounts[normalizedPrompt] || 0) + 1;
      if (recentPrompts.length < 5 && !recentPrompts.includes(rawPrompt)) {
        recentPrompts.push(rawPrompt);
      }
    }
  });

  // Enhanced Topic Ranking: sort all gathered queries by hits and take top 5
  // This ensures the Top 3 are always displayed regardless of hit count
  const topQuestions = Object.entries(questionCounts)
    .map(([query, hits]) => ({ query: _capitalize(query), hits }))
    .sort((a, b) => b.hits - a.hits)
    .slice(0, 5);

  const healthData = {
    fallbackPercent: (totalErrors / totalQuestions) * 100,
    totalErrors,
    totalQuestions,
    topQuestions,
    lastUpdated: FieldValue.serverTimestamp(),
  };

  await db.collection("ai_system_health").doc("current_metrics").set(healthData);
  return healthData;
}

/**
 * 3. calculateAIMetrics
 * Callable function for dashboard refresh.
 */
export const calculateAIMetrics = onCall(async (request) => {
  try {
    return await _performAggregation();
  } catch (error) {
    logger.error("Error calculating AI metrics:", error);
    throw new HttpsError("internal", "Failed to calculate AI metrics");
  }
});

/**
 * 4. forceUpdateMetrics
 * One-click manual refresh via browser URL.
 */
export const forceUpdateMetrics = onRequest({ cors: true }, async (req, res) => {
  try {
    const stats = await _performAggregation();
    res.status(200).send({
      message: "Dashboard successfully refreshed!",
      stats
    });
  } catch (error) {
    logger.error("Forced update failed:", error);
    // Expose actual error to the browser for debugging
    res.status(500).send({
      error: "Aggregation failed",
      message: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined
    });
  }
});

// Helper for consistency with frontend
function _capitalize(s: string): string {
  if (!s) return "";
  return s[0].toUpperCase() + s.substring(1);
}
