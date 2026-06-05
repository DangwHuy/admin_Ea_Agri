// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get loginTitle => 'Nền Tảng Nông Nghiệp Số';

  @override
  String get loginSubtitle => 'Hệ thống quản lý Ea Agri';

  @override
  String get loginHeader => 'ĐĂNG NHẬP HỆ THỐNG';

  @override
  String get emailLabel => 'Email Quản Trị';

  @override
  String get emailHint => 'admin@daklakweb.vn';

  @override
  String get passwordLabel => 'Mật Khẩu';

  @override
  String get passwordHint => '••••••••';

  @override
  String get rememberMe => 'Ghi nhớ';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get loginButton => 'Đăng Nhập Ngay';

  @override
  String get footerPrivacy => 'CHÍNH SÁCH BẢO MẬT';

  @override
  String get footerTerms => 'ĐIỀU KHOẢN DỊCH VỤ';

  @override
  String get footerSupport => 'HỖ TRỢ';

  @override
  String get footerContact => 'LIÊN HỆ';

  @override
  String get authErrorEmpty => 'Vui lòng nhập đầy đủ email và mật khẩu.';

  @override
  String get authErrorInvalidEmail => 'Định dạng email không hợp lệ.';

  @override
  String get authSuccessResetEmail =>
      'Email khôi phục đã được gửi. Vui lòng kiểm tra hộp thư.';

  @override
  String get forgotPasswordTitle => 'Quên Mật Khẩu?';

  @override
  String get forgotPasswordDesc =>
      'Nhập email quản trị của bạn. Chúng tôi sẽ gửi một liên kết để thiết lập lại mật khẩu.';

  @override
  String get forgotPasswordEmailLabel => 'Email Quản Trị';

  @override
  String get forgotPasswordSendButton => 'GỬI LIÊN KẾT';
}
