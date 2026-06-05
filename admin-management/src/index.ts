import {setGlobalOptions} from "firebase-functions/v2";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

// Khởi tạo Firebase Admin
admin.initializeApp();

// Cấu hình vùng (Region) toàn cầu là Singapore
setGlobalOptions({region: "asia-southeast1", maxInstances: 10});

/**
 * Hàm kiểm tra quyền Admin
 */
async function isAdmin(uid: string): Promise<boolean> {
  const userDoc = await admin.firestore().collection("users").doc(uid).get();
  const data = userDoc.data();
  return data?.role === "admin";
}

/**
 * 1. Hàm tạo người dùng hệ thống (Secure)
 */
export const createSystemUser = onCall(async (request) => {
  // A. Kiểm tra xác thực
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bạn phải đăng nhập để thực hiện hành động này.");
  }

  // B. Kiểm tra quyền Admin (RBAC)
  const isUserAdmin = await isAdmin(request.auth.uid);
  if (!isUserAdmin) {
    throw new HttpsError("permission-denied", "Chỉ quản trị viên mới có quyền tạo người dùng.");
  }

  const {email, password, displayName, role, phone, id} = request.data;

  // Kiểm tra dữ liệu đầu vào cơ bản
  if (!email || !password || !displayName) {
    throw new HttpsError("invalid-argument", "Thiếu thông tin bắt buộc (Email, Mật khẩu, Tên).");
  }

  try {
    // C. Tạo tài khoản trong Firebase Auth
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName,
    });

    // D. Đồng bộ thông tin vào Firestore
    const firestorePayload = {
      uid: userRecord.uid,
      displayName,
      email,
      phone: phone || "",
      role: role || "farmer",
      searchName: displayName.toLowerCase(),
      isBanned: false,
      isOnline: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await admin.firestore().collection("users").doc(userRecord.uid).set({
      ...firestorePayload,
      systemId: id || userRecord.uid,
    });

    // E. Ghi nhật ký hệ thống (Audit Log - Centralized)
    const adminDoc = await admin.firestore().collection("users").doc(request.auth.uid).get();
    const adminEmail = adminDoc.data()?.email || "Unknown Admin";

    await admin.firestore().collection("audit_logs").add({
      adminId: request.auth.uid,
      adminEmail: adminEmail,
      actionType: "create",
      module: "users",
      description: `Admin đã tạo tài khoản cho ${email}`,
      targetEmail: email,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      ipAddress: request.rawRequest.ip || "Unknown",
      details: {
        uid: userRecord.uid,
        displayName: displayName,
        role: role || "farmer",
      },
    });

    logger.info(`Admin ${request.auth.uid} created user ${userRecord.uid}`);

    return {
      success: true,
      uid: userRecord.uid,
      message: "Tạo tài khoản thành công",
    };
  } catch (error: any) {
    logger.error("Error creating user:", error);
    throw new HttpsError("internal", error.message || "Lỗi hệ thống khi tạo người dùng.");
  }
});

/**
 * 2. Hàm xóa người dùng hệ thống (Secure)
 */
export const deleteSystemUser = onCall(async (request) => {
  // A. Kiểm tra xác thực
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Bạn phải đăng nhập để xóa người dùng.");
  }

  // B. Kiểm tra quyền Admin
  const isUserAdmin = await isAdmin(request.auth.uid);
  if (!isUserAdmin) {
    throw new HttpsError("permission-denied", "Chỉ quản trị viên mới có quyền xóa người dùng.");
  }

  const {uid} = request.data;
  if (!uid) {
    throw new HttpsError("invalid-argument", "Thiếu UID người dùng cần xóa.");
  }

  try {
    // C. Xóa trong Firebase Auth
    await admin.auth().deleteUser(uid);

    // D. Xóa trong Firestore
    await admin.firestore().collection("users").doc(uid).delete();

    // E. Ghi nhật ký hệ thống (Audit Log - Centralized)
    const adminDoc = await admin.firestore().collection("users").doc(request.auth.uid).get();
    const adminEmail = adminDoc.data()?.email || "Unknown Admin";

    await admin.firestore().collection("audit_logs").add({
      adminId: request.auth.uid,
      adminEmail: adminEmail,
      actionType: "delete",
      module: "users",
      description: `Admin đã xóa người dùng ${uid}`,
      targetEmail: uid, // Lý tưởng là cung cấp email của target từ client gửi lên
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      ipAddress: request.rawRequest.ip || "Unknown",
    });

    logger.info(`Admin ${request.auth.uid} deleted user ${uid}`);

    return {success: true, message: "Xóa người dùng thành công"};
  } catch (error: any) {
    logger.error("Error deleting user:", error);
    throw new HttpsError("internal", error.message || "Lỗi hệ thống khi xóa người dùng.");
  }
});
