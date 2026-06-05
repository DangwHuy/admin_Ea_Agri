import { GoogleGenerativeAI } from "@google/generative-ai";
import { logger } from "firebase-functions";
import axios from "axios";

export interface ExpertAnalysisResult {
  fullName: string;
  documentType: string;
  expiryDate: string;
  isExpired: boolean;
  confidenceScore: number;
  recommendation: "DE_XUAT_DUYET" | "DE_XUAT_TU_CHOI" | "CAN_KIEM_TRA_LAI";
  reason: string;
}

export class ExpertAIService {
  private genAI: GoogleGenerativeAI;
  private model: any;

  constructor(apiKey: string) {
    this.genAI = new GoogleGenerativeAI(apiKey);
    // Standardizing on Gemini 2.5 Flash as per available model list
    this.model = this.genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
  }

  /**
   * Phân tích tài liệu chuyên gia bằng cách gửi ảnh/PDF trực tiếp.
   */
  async analyzeDocuments(docUrls: string[], expertInfo: any): Promise<ExpertAnalysisResult> {
    logger.info(`Đang tải và phân tích ${docUrls.length} tài liệu cho: ${expertInfo.fullName}`);

    const supportedMimeTypes = ["application/pdf", "image/jpeg", "image/png", "image/webp", "image/heic", "image/heif"];

    try {
      // 1. Tải toàn bộ tài liệu và lọc các loại không hỗ trợ
      const fileParts = (await Promise.all(
        docUrls.map(async (url) => {
          try {
            const response = await axios.get(url, { responseType: "arraybuffer" });
            const contentType = response.headers["content-type"] || "image/jpeg";
            
            // Kiểm tra xem MIME type có được hỗ trợ bởi Gemini không
            const isSupported = supportedMimeTypes.some(type => 
                contentType.startsWith("image/") || contentType === "application/pdf"
            );
            
            if (!isSupported) {
                logger.warn(`Bỏ qua file không hỗ trợ: ${contentType} từ URL: ${url}`);
                return null;
            }

            const base64Data = Buffer.from(response.data, "binary").toString("base64");

            return {
              inlineData: {
                data: base64Data,
                mimeType: contentType,
              },
            };
          } catch (error) {
            logger.error(`Lỗi khi tải tài liệu từ ${url}:`, error);
            return null;
          }
        })
      )).filter(part => part !== null) as any[];

      // 2. Kiểm tra nếu không có file nào hợp lệ
      if (fileParts.length === 0 && docUrls.length > 0) {
          throw new Error("AI hiện tại chỉ hỗ trợ phân tích định dạng Hình ảnh và PDF. Vui lòng chuyển các tệp chuyên gia (Word/Excel) sang PDF để AI có thể đọc nội dung.");
      }

      // 3. Xây dựng Prompt
      const prompt = `
        Bạn là chuyên gia thẩm định hồ sơ chuyên gia nông nghiệp cho hệ thống Ea Agri.
        Đây là thông tin đăng ký của chuyên gia:
        - Họ tên: ${expertInfo.fullName}
        - Chuyên môn: ${expertInfo.expertise}
        - Đơn vị công tác: ${expertInfo.workplace}
        - Giới thiệu: ${expertInfo.bio}

        Nhiệm vụ của bạn:
        1. Phân tích các tài liệu đi kèm (ID Card, Bằng cấp, Chứng chỉ...). Lưu ý: Chỉ phân tích các file Hình ảnh hoặc PDF.
        2. Trích xuất thông tin trên giấy tờ thật cẩn thận để đối chiếu.
        3. Kiểm tra xem tên trên giấy tờ có khớp với họ tên đăng ký (${expertInfo.fullName}) không.
        4. Kiểm tra thời hạn của giấy tờ (isExpired?).
        5. Đưa ra khuyến nghị:
           - 'DE_XUAT_DUYET': Nếu hồ sơ minh bạch, giấy tờ khớp và còn hạn.
           - 'DE_XUAT_TU_CHOI': Nếu phát hiện giấy tờ giả, không khớp thông tin hoặc hết hạn nghiêm trọng.
           - 'CAN_KIEM_TRA_LAI': Nếu ảnh mờ, thiếu thông tin hoặc cần xác minh thêm thủ công.

        Phản hồi duy nhất dưới dạng JSON:
        {
          "fullName": "Họ tên trích xuất từ giấy tờ",
          "documentType": "Loại giấy tờ (ví dụ: CCCD, Bằng kỹ sư...)",
          "expiryDate": "Ngày hết hạn trên giấy tờ (nếu có)",
          "isExpired": boolean,
          "confidenceScore": số từ 0 đến 1,
          "recommendation": "DE_XUAT_DUYET" | "DE_XUAT_TU_CHOI" | "CAN_KIEM_TRA_LAI",
          "reason": "Giải thích chi tiết lý do (bằng tiếng Việt)"
        }
      `;

      // 4. Gọi Gemini với Prompt và Ảnh/PDF (Multimodal)
      const result = await this.model.generateContent([prompt, ...fileParts]);
      const response = await result.response;
      let text = response.text();

      // Làm sạch text nếu AI trả về markdown code blocks
      text = text.replace(/```json/g, "").replace(/```/g, "").trim();

      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
          throw new Error("AI không trả về định dạng JSON hợp lệ: " + text);
      }

      return JSON.parse(jsonMatch[0]);
    } catch (error) {
      logger.error("Expert AIService Analysis Error:", error);
      throw error;
    }
  }
}
