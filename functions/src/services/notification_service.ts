import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions";

const db = getFirestore();
const messaging = getMessaging();

export interface NotificationPayload {
  title: string;
  body: string;
  type: string;
  targetRoute?: string;
  metadata?: any;
}

export class NotificationService {
  /**
   * Gửi thông báo cho Admin (In-app và Push Topic)
   */
  static async sendToAdmin(payload: NotificationPayload, urgent: boolean = false) {
    try {
      // 1. In-app Notification (Lưu vào Firestore)
      await db.collection("admin_notifications").add({
        title: payload.title,
        message: payload.body,
        type: payload.type,
        isRead: false,
        timestamp: FieldValue.serverTimestamp(),
        targetRoute: payload.targetRoute || null,
        metadata: payload.metadata || null,
      });

      // 2. Push Notification (Gửi qua Topic nếu khẩn cấp)
      if (urgent) {
        const message = {
          notification: {
            title: payload.title,
            body: payload.body,
          },
          data: {
            type: payload.type,
            targetRoute: payload.targetRoute || "",
            ...payload.metadata,
          },
          topic: "admin_urgent_alerts",
        };
        await messaging.send(message);
        logger.info(`Đã gửi Push Notification đến topic admin_urgent_alerts: ${payload.title}`);
      }
    } catch (error) {
      logger.error("Lỗi khi gửi thông báo Admin:", error);
    }
  }

  /**
   * Gửi thông báo cho một người dùng cụ thể (In-app và Push Token)
   */
  static async sendToUser(uid: string, payload: NotificationPayload) {
    try {
      // 1. In-app Notification (Sub-collection của User)
      await db.collection("users").doc(uid).collection("notifications").add({
        title: payload.title,
        message: payload.body,
        type: payload.type,
        isRead: false,
        timestamp: FieldValue.serverTimestamp(),
        targetRoute: payload.targetRoute || null,
        metadata: payload.metadata || null,
      });

      // 2. Lấy FCM Token của User
      const userDoc = await db.collection("users").doc(uid).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (fcmToken) {
        const message = {
          notification: {
            title: payload.title,
            body: payload.body,
          },
          data: {
            type: payload.type,
            targetRoute: payload.targetRoute || "",
          },
          token: fcmToken,
        };
        await messaging.send(message);
        logger.info(`Đã gửi Push Notification cho user ${uid}: ${payload.title}`);
      } else {
        logger.warn(`User ${uid} không có fcmToken, chỉ lưu in-app notification.`);
      }
    } catch (error) {
      logger.error(`Lỗi khi gửi thông báo cho user ${uid}:`, error);
    }
  }

  /**
   * Gửi thông báo cho toàn bộ người dùng (Biến động giá)
   */
  static async broadcastToAllUsers(payload: NotificationPayload) {
    try {
      // Vì gửi cho toàn bộ người dùng có thể tốn tài nguyên, 
      // ta nên khuyến khích dùng Topic "all_users" ở phía client.
      // Dưới đây là cách gửi qua Topic:
      const message = {
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: {
          type: payload.type,
          targetRoute: payload.targetRoute || "",
        },
        topic: "all_users",
      };
      await messaging.send(message);
      
      // Ghi log vào admin_notifications để Admin biết đã phát đi thông báo
      await this.sendToAdmin({
          ...payload,
          title: `[BROADCAST] ${payload.title}`,
      }, false);
      
      logger.info(`Đã phát thông báo toàn cục: ${payload.title}`);
    } catch (error) {
      logger.error("Lỗi khi phát thông báo toàn cục:", error);
    }
  }
}
