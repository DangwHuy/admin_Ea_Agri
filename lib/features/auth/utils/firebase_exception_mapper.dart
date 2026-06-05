import 'package:firebase_auth/firebase_auth.dart';

class FirebaseExceptionMapper {
  static String getFriendlyMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Email không hợp lệ. Vui lòng kiểm tra lại.';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hóa.';
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này.';
        case 'wrong-password':
          return 'Sai mật khẩu. Vui lòng thử lại.';
        case 'invalid-credential':
          return 'Thông tin đăng nhập không chính xác.';
        case 'too-many-requests':
          return 'Tài khoản tạm khóa do bạn thử sai quá nhiều lần. Vui lòng thử lại sau.';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại internet.';
        default:
          return 'Đã xảy ra lỗi thực thi xác thực: ${e.message}';
      }
    }
    return 'Lỗi hệ thống: ${e.toString()}';
  }
}
