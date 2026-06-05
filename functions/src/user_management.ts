import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { getAuth } from "firebase-admin/auth";
import { logger } from "firebase-functions";

export const handleUserBanStatusChange = onDocumentUpdated("users/{userId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();

    if (!beforeData || !afterData) return;

    const wasBanned = beforeData.isBanned === true;
    const isBanned = afterData.isBanned === true;

    if (wasBanned !== isBanned) {
        const userId = event.params.userId;
        try {
            await getAuth().updateUser(userId, {
                disabled: isBanned
            });
            
            // Xóa toàn bộ session / token hiện tại để bắt buộc đăng nhập lại
            if (isBanned) {
                await getAuth().revokeRefreshTokens(userId);
                logger.info(`Đã thu hồi token (logout bắt buộc) cho user ${userId}.`);
            }
            
            logger.info(`Đã cập nhật trạng thái Auth cho user ${userId}. Disabled: ${isBanned}`);
        } catch (error) {
            logger.error(`Lỗi khi cập nhật trạng thái Auth cho user ${userId}:`, error);
        }
    }
});
