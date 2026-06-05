import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  // Hàm ghi log hành động của Admin
  static Future<void> logAction({
    required String action,
    required String target
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('admin_logs').add({
        'adminEmail': user.email ?? 'Unknown Admin',
        'adminUid': user.uid,
        'action': action, // Ví dụ: "Đánh dấu lỗi AI", "Xóa lịch sử chat"
        'target': target, // Ví dụ: "Câu hỏi: abc...", "User: xyz@gmail.com"
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi khi ghi log Admin: $e");
    }
  }
}