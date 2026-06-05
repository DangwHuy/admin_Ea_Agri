import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions";
import { ExpertAIService } from "./services/expert_ai_service";

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

/**
 * analyzeExpertRequest
 * Callable function triggered by Admin to get AI suggestion for an expert request.
 */
export const analyzeExpertRequest = onCall({
    secrets: [GEMINI_API_KEY],
    region: "asia-southeast1", // Singapore
}, async (request) => {
    // 1. Kiểm tra xác thực & Quyền admin
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Bạn cần đăng nhập để sử dụng tính năng này.");
    }

    // (Tùy chọn) Kiểm tra vai trò admin trong Firestore để tăng tính bảo mật
    
    const { requestId, imageUrls, expertInfo } = request.data;

    if (!requestId || !imageUrls || !expertInfo) {
        throw new HttpsError("invalid-argument", "Thiếu thông tin đầu vào (requestId, imageUrls, expertInfo).");
    }

    try {
        if (!GEMINI_API_KEY.value()) {
            throw new HttpsError("failed-precondition", "Dịch vụ AI chưa được cấu hình (Thiếu API Key).");
        }

        const aiService = new ExpertAIService(GEMINI_API_KEY.value());
        const analysis = await aiService.analyzeDocuments(imageUrls, expertInfo);

        logger.info(`Đã hoàn thành phân tích AI cho yêu cầu ${requestId}. Kết quả: ${analysis.recommendation}`);

        return {
            success: true,
            analysis: analysis,
        };
    } catch (error: any) {
        logger.error(`Lỗi khi phân tích AI cho yêu cầu ${requestId}:`, error);
        
        // Trả về lỗi chi tiết hơn cho Client
        if (error instanceof HttpsError) throw error;
        
        throw new HttpsError(
            "internal", 
            error.message || "Lỗi không xác định khi xử lý AI.",
            error.stack
        );
    }
});
