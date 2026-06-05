import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { NotificationService } from "./services/notification_service";

/**
 * 1. onExpertRequestCreated
 * Notify Admin when a new expert request is submitted.
 */
export const onExpertRequestCreated = onDocumentCreated("expert_requests/{requestId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const data = snapshot.data();

    await NotificationService.sendToAdmin({
        title: "Yêu cầu Chuyên gia mới",
        body: `Người dùng ${data.expertInfo?.fullName || "vô danh"} đã gửi hồ sơ đăng ký chuyên gia.`,
        type: "verification",
        targetRoute: "/expert-verifications",
        metadata: { requestId: event.params.requestId }
    }, true); // Urgent: Yes
});

/**
 * 2. onExpertRequestStatusChanged
 * Notify User when their expert request is approved/rejected.
 */
export const onExpertRequestStatusChanged = onDocumentUpdated("expert_requests/{requestId}", async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    if (!beforeData || !afterData) return;

    // Chỉ gửi nếu status thay đổi
    if (beforeData.status !== afterData.status) {
        const uid = afterData.userId;
        const status = afterData.status; // e.g., "approved", "rejected"
        
        let title = "Trạng thái hồ sơ chuyên gia";
        let body = "";

        if (status === "approved" || status === "active") {
            title = "Chúc mừng! Hồ sơ đã được duyệt";
            body = "Bạn đã chính thức trở thành chuyên gia trên hệ thống Ea Agri.";
        } else if (status === "rejected") {
            title = "Hồ sơ chuyên gia không được duyệt";
            body = `Lý do: ${afterData.reason || "Hồ sơ chưa đạt yêu cầu của hệ thống."}`;
        }

        if (body) {
            await NotificationService.sendToUser(uid, {
                title: title,
                body: body,
                type: "verification",
                targetRoute: "/profile"
            });
        }
    }
});

/**
 * 3. onOrderIssue
 * Notify Admin if an order status becomes unknown or failed.
 */
export const onOrderIssue = onDocumentUpdated("orders/{orderId}", async (event) => {
    const afterData = event.data?.after.data();
    if (!afterData) return;

    if (afterData.status === "unknown" || afterData.status === "failed") {
        await NotificationService.sendToAdmin({
            title: "Cảnh báo Đơn hàng",
            body: `Đơn hàng ${event.params.orderId} đang ở trạng thái lỗi (${afterData.status}).`,
            type: "order",
            targetRoute: "/orders",
            metadata: { orderId: event.params.orderId }
        }, true);
    }
});

/**
 * 4. onWithdrawalRequest
 * Notify Admin when a new withdrawal is requested.
 */
export const onWithdrawalRequest = onDocumentCreated("withdrawals/{withdrawalId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const data = snapshot.data();

    await NotificationService.sendToAdmin({
        title: "Yêu cầu rút tiền mới",
        body: `${data.userName || "Người dùng"} yêu cầu rút ${data.amount?.toLocaleString() || 0} VNĐ.`,
        type: "finance",
        targetRoute: "/finance",
        metadata: { withdrawalId: event.params.withdrawalId }
    }, true);
});

/**
 * 5. onPestReport
 * Notify Admin when multiple pest reports occur (Disease Outbreak Detection).
 */
export const onPestReport = onDocumentCreated("pest_diseases/{reportId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const data = snapshot.data();
    
    // Logic đơn giản: Mỗi báo cáo mới đều báo Admin (V1)
    // V2: Query Firestore đếm số báo cáo cùng loại/vùng
    await NotificationService.sendToAdmin({
        title: "Có báo cáo sâu bệnh mới",
        body: `Phát hiện ${data.pestName || "sâu bệnh"} tại khu vực ${data.location || "Đắk Lắk"}.`,
        type: "alert",
        targetRoute: "/diseases",
    }, false);
});

/**
 * 6. onLowStock
 * Notify Admin when product stock is low (< 10).
 */
export const onLowStock = onDocumentUpdated("products/{productId}", async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    if (!beforeData || !afterData) return;

    // Check if quantity just dropped below 10 (Nested in inventory)
    const beforeQty = beforeData.inventory?.quantity ?? 0;
    const afterQty = afterData.inventory?.quantity ?? 0;
    // Lấy name từ top-level (đồng hạng với inventory) theo yêu cầu của user
    const productName = afterData.name || afterData.inventory?.name || "Nông sản";

    if (afterQty < 10 && beforeQty >= 10) {
        await NotificationService.sendToAdmin({
            title: "Cảnh báo Hết kho",
            body: `Sản phẩm ${productName} chỉ còn ${afterQty} sản phẩm.`,
            type: "lowStock",
            targetRoute: "/products",
            metadata: { productId: event.params.productId }
        }, false);
    }
});
