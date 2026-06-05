import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; 
import 'dart:ui';
import 'package:admin_daklak_web/l10n/app_localizations.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:admin_daklak_web/core/constants/app_spacing.dart';
import 'package:admin_daklak_web/core/providers/theme_provider.dart';
import 'package:admin_daklak_web/core/providers/locale_provider.dart';
import 'package:admin_daklak_web/core/services/analytics_service.dart';
import '../services/auth_service.dart';
import '../utils/email_validator.dart';
import '../utils/firebase_exception_mapper.dart';
import '../presentation/widgets/auth_text_field.dart';
import '../presentation/widgets/auth_button.dart';
import '../presentation/widgets/auth_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_admin_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      if (mounted) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    if (email.isEmpty || password.isEmpty) {
      _showError(l10n.authErrorEmpty);
      return;
    }
    
    if (!EmailValidator.isValid(email)) {
      _showError(l10n.authErrorInvalidEmail);
      return;
    }

    // Track login attempt
    AnalyticsService().trackLoginAttempt(email);

    String? error = await AuthService().loginAdmin(
      email: email,
      password: password,
    );

    if (error == null) {
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_admin_email', email);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_admin_email');
      }

      AnalyticsService().trackLoginSuccess();
      if (mounted) context.go('/dashboard');
    } else {
      AnalyticsService().trackLoginFailure(error);
      // Map potential standard error keys out of the auth service response wrapper
      if (error.contains('[')) {
        final match = RegExp(r'\[([^\]]+)\]').firstMatch(error);
        final code = match != null ? match.group(1)!.split('/').last : error;
        final friendlyErr = FirebaseExceptionMapper.getFriendlyMessage(
          firebase_auth.FirebaseAuthException(code: code, message: error)
        );
        _showError(friendlyErr);
      } else {
        _showError(error);
      }
      // TODO: Analytics.track('login_failure', {'reason': error});
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    
    // We only open dialog if there's no email, or just open it anyway to confirm.
    final resetEmailController = TextEditingController(text: email);

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    await AuthDialog.show(
      context: context,
      title: l10n.forgotPasswordTitle,
      description: l10n.forgotPasswordDesc,
      content: StatefulBuilder(
        builder: (context, setState) {
          return TextFormField(
            controller: resetEmailController,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            ),
          );
        }
      ),
      primaryButtonText: l10n.forgotPasswordSendButton,
      onPrimaryAction: () async {
        final targetEmail = resetEmailController.text.trim();
        if (!EmailValidator.isValid(targetEmail)) {
          _showError(l10n.authErrorInvalidEmail);
          throw Exception('invalid email'); // throw just to prevent dialog close
        }

        try {
          await firebase_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: targetEmail);
          _showSuccess(l10n.authSuccessResetEmail);
          AnalyticsService().trackPasswordResetSent();
        } on firebase_auth.FirebaseAuthException catch (e) {
          _showError(FirebaseExceptionMapper.getFriendlyMessage(e));
          rethrow; // prevent dialog close
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context);

    // If localizations not ready, show a blank or loading state to prevent null errors
    if (l10n == null) return const Scaffold(backgroundColor: Color(0xFF0F172A));

    return Scaffold(
      body: Stack(
        children: [
          // 1. App Background (Asset + Fallback Gradient)
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFCF9F3),
              child: Image.network(
                'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?q=80&w=2940&auto=format&fit=crop',
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.35),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) => const SizedBox(), 
              ),
            ),
          ),
          
          // Header Gradient Frame
          Positioned(
            top: 0, left: 0, right: 0, height: 180,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Footer Gradient Frame
          Positioned(
            bottom: 0, left: 0, right: 0, height: 260,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 2. Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.sm),
                  const Spacer(),
                  Consumer<LocaleProvider>(
                    builder: (context, localeProvider, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.language, color: Colors.white),
                              onPressed: () => localeProvider.toggleLocale(), 
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: IconButton(
                              icon: Icon(
                                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                color: Colors.white,
                              ),
                              onPressed: () => themeProvider.toggleTheme(), 
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 3. Center Content (Login Form)
          Align(
            alignment: const Alignment(0, -0.15), // Offset slightly up from vertical center
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon & Title
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white, // Nền trắng để hòa mình cùng logo
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3), 
                          blurRadius: 30, 
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo2.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.loginTitle,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 380,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 40),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? AppColors.darkCardBg.withValues(alpha: 0.8) 
                            : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark 
                              ? Colors.white.withValues(alpha: 0.1) 
                              : Colors.white.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.loginHeader,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextHeading : AppColors.textHeading,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              width: 48,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primary : const Color(0xFF156b2e),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
    
                            AuthTextField(
                              label: l10n.emailLabel,
                              hintText: l10n.emailHint,
                              prefixIcon: Icons.alternate_email,
                              controller: _emailController,
                              focusNode: _emailFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AuthTextField(
                              label: l10n.passwordLabel,
                              hintText: l10n.passwordHint,
                              prefixIcon: Icons.lock_outline,
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
    
                            // Actions Row (Remember & Forgot PW)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.xs),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _rememberMe ? Icons.check_circle : Icons.radio_button_unchecked,
                                          color: _rememberMe ? AppColors.primary : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                          size: 20,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          l10n.rememberMe,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: isDark ? AppColors.darkTextHeading : AppColors.textHeading,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _handleForgotPassword,
                                  style: TextButton.styleFrom(
                                    foregroundColor: isDark ? AppColors.primaryLight : const Color(0xFF156b2e),
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                  ),
                                  child: Text(
                                    l10n.forgotPassword,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.primaryLight : const Color(0xFF156b2e),
                                      ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
    
                            AuthButton(
                              label: l10n.loginButton,
                              suffixIcon: Icons.arrow_forward_rounded,
                              onPressed: _handleLogin, // Passed directly, concurrency natively managed
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppColors.primary, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '© 2026 EaAgri',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Footer Links
                  _buildFooterLink(l10n.footerPrivacy, '/info/privacy'),
                  const SizedBox(width: AppSpacing.lg),
                  _buildFooterLink(l10n.footerTerms, '/info/terms'),
                  const SizedBox(width: AppSpacing.lg),
                  _buildFooterLink(l10n.footerSupport, '/info/support'),
                  const SizedBox(width: AppSpacing.lg),
                  _buildFooterLink(l10n.footerContact, '/info/contact'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String title, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
