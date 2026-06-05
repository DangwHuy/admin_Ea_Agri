import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { NotificationService } from "./services/notification_service";

const db = getFirestore();

// --- Cấu hình Ngưỡng (Thresholds) ---
const LOW_VIEWS = 100;
const HIGH_VIEWS = 100;
const LOW_ORDERS = 10;
const GOOD_ORDERS = 10;
const LOW_REVENUE = 5000000; // 5 triệu VND
const MIN_RATING = 4.0;

const VOUCHER_EXPIRY_DAYS = 30;
const DEEP_DISCOUNT_MIN = 0.30;
const DEEP_DISCOUNT_MAX = 0.40;
const UPSELL_DISCOUNT = 0.15;
const UPSELL_MIN_ORDER_VALUE = 500000;

/**
 * 1. scheduledVoucherPipeline
 * Chạy hàng ngày lúc 2h sáng để phân tích người bán và tạo voucher tự động.
 */
export const scheduledVoucherPipeline = onSchedule({
    schedule: "0 2 * * *",
    timeZone: "Asia/Ho_Chi_Minh",
    memory: "512MiB",
}, async (event) => {
    logger.info("Bắt đầu AI Voucher Pipeline...");

    try {
        const now = new Date();
        const thirtyDaysAgo = new Date(now.getTime() - (30 * 24 * 60 * 60 * 1000));

        const sellerData: { [key: string]: any } = {};
        const productSellerMap: { [key: string]: string } = {};

        // 1a. Lấy thông tin sản phẩm và viewCount
        const productsSnap = await db.collection("products").get();
        productsSnap.forEach(doc => {
            const p = doc.data();
            const sid = p.seller?.id || p.sellerId;
            if (sid) {
                productSellerMap[doc.id] = sid;
                if (!sellerData[sid]) {
                    sellerData[sid] = _emptyMetrics();
                }
                sellerData[sid].totalViews += Number(p.viewCount || 0);
            }
        });

        // 1b. Lấy đơn hàng trong 30 ngày qua
        const ordersSnap = await db.collection("orders")
            .where("createdAt", ">=", Timestamp.fromDate(thirtyDaysAgo))
            .get();

        ordersSnap.forEach(doc => {
            const o = doc.data();
            let sid = o.sellerId;

            if (sid === "unknown") return;

            if (!sid) {
                const items = o.items || [];
                const productId = items.length > 0 ? items[0].productId : null;
                if (productId) {
                    sid = productSellerMap[productId];
                }
            }

            if (sid) {
                if (!sellerData[sid]) {
                    sellerData[sid] = _emptyMetrics();
                }
                sellerData[sid].totalOrders += 1;
                sellerData[sid].revenue += Number(o.totalAmount || 0);
            }
        });

        // 1c. Lấy thông tin rating người bán từ bộ sưu tập users
        const usersSnap = await db.collection("users").get();
        usersSnap.forEach(doc => {
            const u = doc.data();
            const sid = u.sellerId || doc.id;
            if (sellerData[sid]) {
                sellerData[sid].rating = Number(u.rating || 0);
                sellerData[sid].sellerName = u.displayName || u.name || "Anonymous Seller";
            }
        });

        // 2. Phân loại và Thực hiện hành động
        let vouchersCreated = 0;
        const batch = db.batch();

        for (const [sid, metrics] of Object.entries(sellerData)) {
            const group = _classifySeller(metrics);
            
            // Cập nhật Tier cho Seller
            const userRef = db.collection("users").doc(sid);
            batch.update(userRef, {
                "sellerTier": group,
                "tierLastUpdatedAt": FieldValue.serverTimestamp(),
                "tierUpdatedBy": "AI_VOUCHER_PIPELINE_SCHEDULER"
            });

            // Logic quyết định tạo voucher
            if ((group === "LOW_CONVERSION" || group === "LOW_REVENUE") && metrics.rating >= MIN_RATING) {
                const voucherType = group === "LOW_CONVERSION" ? "DEEP_DISCOUNT" : "UPSELL";
                
                // Kiểm tra voucher trùng lặp
                const existingVouchers = await db.collection("vouchers")
                    .where("sellerId", "==", sid)
                    .where("type", "==", voucherType)
                    .where("isActive", "==", true)
                    .where("expiryDate", ">", Timestamp.fromDate(now))
                    .limit(1)
                    .get();

                if (existingVouchers.empty) {
                    const discount = voucherType === "DEEP_DISCOUNT" 
                        ? Math.random() * (DEEP_DISCOUNT_MAX - DEEP_DISCOUNT_MIN) + DEEP_DISCOUNT_MIN
                        : UPSELL_DISCOUNT;
                    
                    const minOrderValue = voucherType === "UPSELL" ? UPSELL_MIN_ORDER_VALUE : 0;
                    
                    const voucherRef = db.collection("vouchers").doc();
                    const code = _generateRandomCode(voucherType.substring(0, 2));
                    
                    batch.set(voucherRef, {
                        "sellerId": sid,
                        "sellerName": metrics.sellerName,
                        "type": voucherType,
                        "code": code,
                        "discountType": "Percentage",
                        "value": Math.round(discount * 100),
                        "minOrderValue": minOrderValue,
                        "expiryDate": Timestamp.fromDate(new Date(now.getTime() + (VOUCHER_EXPIRY_DAYS * 24 * 60 * 60 * 1000))),
                        "isActive": true,
                        "usageCount": 0,
                        "usageLimit": 100,
                        "createdAt": FieldValue.serverTimestamp(),
                        "createdBy": "AI_VOUCHER_PIPELINE_SCHEDULER"
                    });
                    vouchersCreated++;
                }
            }
        }

        await batch.commit();
        logger.info(`Pipeline hoàn tất. Đã tạo ${vouchersCreated} voucher mới.`);

        // Bổ sung: Kiểm tra biến động giá để gửi thông báo cho Expert/Nông dân
        await checkPriceFluctuations();

    } catch (error) {
        logger.error("Lỗi trong scheduledVoucherPipeline:", error);
    }
});

/**
 * 2. monthlyDataCleanup
 * Chạy định kỳ vào ngày 1 hàng tháng lúc 3h sáng để dọn dẹp đơn hàng lỗi.
 */
export const monthlyDataCleanup = onSchedule({
    schedule: "0 3 1 * *",
    timeZone: "Asia/Ho_Chi_Minh",
    memory: "256MiB",
}, async (event) => {
    logger.info("Bắt đầu dọn dẹp dữ liệu đơn hàng lỗi...");

    try {
        const query = db.collection("orders").where("sellerId", "==", "unknown");
        const snapshot = await query.get();

        if (snapshot.empty) {
            logger.info("Không tìm thấy đơn hàng lỗi cần dọn dẹp.");
            return;
        }

        const batchSize = 500;
        let count = 0;
        
        for (let i = 0; i < snapshot.size; i += batchSize) {
            const batch = db.batch();
            const chunk = snapshot.docs.slice(i, i + batchSize);
            chunk.forEach(doc => batch.delete(doc.ref));
            await batch.commit();
            count += chunk.length;
        }

        logger.info(`Đã dọn dẹp thành công ${count} đơn hàng lỗi.`);
    } catch (error) {
        logger.error("Lỗi trong monthlyDataCleanup:", error);
    }
});

// --- Helper Functions ---

function _emptyMetrics() {
    return {
        totalViews: 0,
        totalOrders: 0,
        revenue: 0,
        rating: 0,
        sellerName: "Anonymous Seller"
    };
}

function _classifySeller(metrics: any): string {
    const views = metrics.totalViews;
    const orders = metrics.totalOrders;
    const revenue = metrics.revenue;

    const lowViews = views < LOW_VIEWS;
    const highViews = views >= HIGH_VIEWS;
    const lowOrders = orders < LOW_ORDERS;
    const goodOrders = orders >= GOOD_ORDERS;
    const lowRevenue = revenue < LOW_REVENUE;

    if (lowViews && lowOrders && lowRevenue) return "DEAD_SELLER";
    if (lowViews && lowOrders) return "LOW_TRAFFIC";
    if (highViews && lowOrders) return "LOW_CONVERSION";
    if (goodOrders && lowRevenue) return "LOW_REVENUE";

    return "HEALTHY";
}

function _generateRandomCode(prefix: string): string {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let result = prefix + "-";
    for (let i = 0; i < 6; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

/**
 * Báo cáo lỗi kỹ thuật khẩn cấp cho Admin
 */
export async function reportSystemError(title: string, message: string, urgent: boolean = true) {
    logger.error(`[SYSTEM_ERROR] ${title}: ${message}`);
    await NotificationService.sendToAdmin({
        title: title,
        body: message,
        type: "system",
        targetRoute: "/system-logs"
    }, urgent);
}

/**
 * Kiểm tra biến động giá và gửi thông báo nếu phát hiện đột biến
 */
export async function checkPriceFluctuations() {
    const crops = ["Coffee", "Pepper", "Durian"];
    const names: { [key: string]: string } = { "Coffee": "Cà Phê", "Pepper": "Hồ Tiêu", "Durian": "Sầu Riêng" };

    for (const crop of crops) {
        try {
            const cropDoc = await db.collection("Price").doc(crop).get();
            const data = cropDoc.data();
            if (!data) continue;

            const latestPrice = _parsePrice(data.latest_data?.[0]?.price);
            
            // Lấy giá hôm qua từ lịch sử
            const historySnap = await db.collection("Price").doc(crop).collection("History")
                .orderBy("__name__", "desc")
                .limit(2)
                .get();

            if (historySnap.docs.length >= 2) {
                const prevData = historySnap.docs[1].data();
                const yesterdayPrice = _parsePrice(prevData.data?.[0]?.price);

                if (yesterdayPrice > 0) {
                    const changePercent = ((latestPrice - yesterdayPrice) / yesterdayPrice) * 100;

                    if (Math.abs(changePercent) >= 5) {
                        const trend = changePercent > 0 ? "Tăng" : "Giảm";
                        await NotificationService.broadcastToAllUsers({
                            title: `Biến động giá ${names[crop]}`,
                            body: `Giá ${names[crop]} vừa ${trend.toLowerCase()} ${Math.abs(changePercent).toFixed(1)}%. Xem ngay bảng giá mới nhất!`,
                            type: "market",
                            targetRoute: "/prices"
                        });
                    }
                }
            }
        } catch (error) {
            logger.error(`Lỗi khi kiểm tra biến động giá ${crop}:`, error);
        }
    }
}

function _parsePrice(priceRaw: any): number {
    if (!priceRaw) return 0;
    const clean = priceRaw.toString().replace(/[^0-9]/g, "");
    return parseInt(clean) || 0;
}
