// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Digital Agriculture Platform';

  @override
  String get loginSubtitle => 'Ea Agri Management System';

  @override
  String get loginHeader => 'SYSTEM LOGIN';

  @override
  String get emailLabel => 'Admin Email';

  @override
  String get emailHint => 'admin@eaagri.vn';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login Now';

  @override
  String get footerPrivacy => 'PRIVACY POLICY';

  @override
  String get footerTerms => 'TERMS OF SERVICE';

  @override
  String get footerSupport => 'SUPPORT';

  @override
  String get footerContact => 'CONTACT';

  @override
  String get authErrorEmpty => 'Please enter both email and password.';

  @override
  String get authErrorInvalidEmail => 'Invalid email format.';

  @override
  String get authSuccessResetEmail =>
      'Recovery email sent. Please check your inbox.';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordDesc =>
      'Enter your admin email. We will send a link to reset your password.';

  @override
  String get forgotPasswordEmailLabel => 'Admin Email';

  @override
  String get forgotPasswordSendButton => 'SEND LINK';
}
