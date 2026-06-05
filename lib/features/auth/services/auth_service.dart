import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm đăng nhập dành riêng cho Admin
  Future<String?> loginAdmin({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kiểm tra quyền (role) trong Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String? role = userDoc.get('role');
        if (role == 'admin') {
          return null; // Đăng nhập thành công
        } else {
          await _auth.signOut(); // Không phải admin -> Ép đăng xuất
          return 'Tài khoản không có quyền truy cập quản trị.';
        }
      } else {
        await _auth.signOut();
        return 'Không tìm thấy dữ liệu người dùng.';
      }
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sai tài khoản hoặc mật khẩu.';
    } catch (e) {
      return 'Lỗi hệ thống: $e';
    }
  }

  // Hàm đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
  }
}