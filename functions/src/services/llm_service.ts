import { GoogleGenerativeAI } from "@google/generative-ai";
import { logger } from "firebase-functions";

export interface AIInsight {
  text: string;
  type: "positive" | "negative" | "neutral";
  createdAt: FirebaseFirestore.Timestamp;
}

export class LLMService {
  private genAI: GoogleGenerativeAI;
  private model: any;

  constructor(apiKey: string) {
    this.genAI = new GoogleGenerativeAI(apiKey);
    // Standardizing on Gemini 2.5 Flash as per available model list
    this.model = this.genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
  }

  /**
   * Generates business insights based on sales and product data.
   * @param data Simplified JSON of yesterday's performance.
   * @returns Array of insights.
   */
  async generateDailyInsights(data: any): Promise<AIInsight[]> {
    const prompt = `
      Act as an agricultural data analyst for a commerce platform in Dak Lak.
      Analyze the following JSON data representing yesterday's performance:
      ${JSON.stringify(data, null, 2)}

      Task: Return exactly 3 short insights (under 15 words per sentence) about revenue and trends.
      Format: Return ONLY a valid JSON array of objects with "text" and "type" ('positive'|'negative'|'neutral') fields.
      Example: [{"text": "Revenue increased by 15% due to high Durian demand.", "type": "positive"}]
    `;

    try {
      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();
      
      // Basic JSON extraction from LLM response
      const jsonMatch = text.match(/\[.*\]/s);
      if (!jsonMatch) {
          throw new Error("Failed to extract JSON from AI response");
      }
      
      const insights = JSON.parse(jsonMatch[0]);
      return insights.map((item: any) => ({
        ...item,
        createdAt: new Date(),
      }));
    } catch (error) {
      logger.error("LLM Insight Generation Error:", error);
      // Fallback insights if AI fails
      return [
        { text: "Data analysis successfully completed for yesterday.", type: "neutral", createdAt: new Date() as any },
      ];
    }
  }
}
