import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/logic/user_provider.dart';
import '../../features/user_management/screens/user_list_screen.dart';
import '../../features/content_management/screens/disease_manager_screen.dart';
import '../../features/content_management/screens/banner_manager_screen.dart';
import '../../features/content_management/screens/community_posts_screen.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../widgets/admin_layout.dart'; // Import layout
import '../../features/expert_management/screens/admin_appointments_screen.dart';
import '../../features/logs/screens/ai_logs_screen.dart';
import '../../features/price_management/screens/agricultural_price.dart';
import '../../features/sales_management/screens/hub_dashboard_screen.dart';
import '../../features/order_management/screens/order_list_screen.dart';
import '../../features/product_warehouse/screens/product_list_screen.dart';
import '../../features/promotions/screens/voucher_management_screen.dart';
import '../../features/finance/screens/finance_screen.dart';
import '../../features/finance/screens/membership_upgrade_screen.dart';
import '../../features/reports/screens/report_screen.dart';
import '../../features/settings/presentation/screens/settings_main_screen.dart';
import '../../features/logs/screens/audit_logs_screen.dart';
import '../../features/expert_management/screens/expert_verification_screen.dart';
import '../../features/system_logs/screens/system_log_screen.dart';
import '../../features/profile/screens/admin_profile_screen.dart';
import '../../features/info/screens/info_screen.dart';


class AppRouter {
  static GoRouter createRouter(UserProvider userProvider) {
    return GoRouter(
      initialLocation: '/dashboard',
      refreshListenable: userProvider,
      redirect: (context, state) {
        final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
        final bool isGoingToLogin = state.matchedLocation == '/login';
        final bool isPublicRoute = state.matchedLocation.startsWith('/info');

        if (!isLoggedIn && !isGoingToLogin && !isPublicRoute) return '/login';
        if (isLoggedIn && isGoingToLogin) return '/dashboard';

        // RBAC Check for Settings
        if (state.matchedLocation == '/settings') {
          // If still loading role from Firestore, don't redirect yet
          if (userProvider.isLoading) return null;

          if (!userProvider.isSuperAdmin) {
            debugPrint('AppRouter: Access denied to /settings. Role detected: ${userProvider.role}');
            return '/dashboard'; // Redirect to dashboard if not super_admin
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/info/:type',
          builder: (context, state) {
            final type = state.pathParameters['type'];
            String title = 'Thông Tin';
            String content = 'Nội dung đang được cập nhật...';
            
            switch (type) {
              case 'privacy':
                title = 'Chính Sách Bảo Mật';
                content = '''
Chính sách bảo mật của Ea Agri cam kết bảo vệ thông tin cá nhân của người dùng một cách tuyệt đối.

1. Thu thập thông tin: Chúng tôi chỉ thu thập các thông tin cần thiết để quản lý tài khoản và cải thiện dịch vụ.
2. Sử dụng thông tin: Thông tin của bạn được sử dụng để xác thực, bảo mật và thông báo các cập nhật quan trọng.
3. Chia sẻ thông tin: Chúng tôi không bao giờ bán hoặc chia sẻ dữ liệu của bạn cho bên thứ ba vì mục đích thương mại.
4. Bảo mật: Dữ liệu được mã hóa và lưu trữ trên hệ thống đám mây bảo mật cao của Google (Firebase).

Nếu bạn có bất kỳ câu hỏi nào, vui lòng liên hệ đội ngũ hỗ trợ của chúng tôi.
                ''';
                break;
              case 'terms':
                title = 'Điều Khoản Dịch Vụ';
                content = '''
Bằng việc truy cập vào hệ thống Ea Agri, bạn đồng ý tuân thủ các điều khoản sau:

1. Trách nhiệm tài khoản: Bạn chịu trách nhiệm bảo mật mật khẩu và mọi hoạt động diễn ra dưới tài khoản của mình.
2. Sử dụng đúng mục đích: Hệ thống chỉ dành cho mục đích quản lý nông nghiệp số chuyên nghiệp.
3. Hành vi nghiêm cấm: Không được phép truy cập trái phép, phá hoại dữ liệu hoặc can thiệp vào hoạt động của hệ thống.
4. Thay đổi điều khoản: Chúng tôi có quyền cập nhật điều khoản này bất cứ lúc nào để phù hợp với quy định pháp luật.

Việc vi phạm các điều khoản trên có thể dẫn đến việc khóa tài khoản vĩnh viễn.
                ''';
                break;
              case 'support':
                title = 'Trung Tâm Hỗ Trợ';
                content = '''
Chào mừng đến với Trung Tâm Hỗ Trợ Ea Agri!

Làm thế nào để chúng tôi có thể giúp bạn?
- Hỗ trợ kỹ thuật: support@eaagri.vn
- Hotline: 1900 xxxx (8:00 - 17:30, Thứ 2 - Thứ 6)
- Zalo hỗ trợ: 09xx xxx xxx

Chúng tôi sẽ phản hồi yêu cầu của bạn trong vòng tối đa 24 giờ làm việc.
                ''';
                break;
              case 'contact':
                title = 'Liên Hệ';
                content = '''
Liên hệ với Ban Quản Trị Hệ Thống Ea Agri:

- Địa chỉ: Thành phố Buôn Ma Thuột, Tỉnh Đắk Lắk.
- Email: contact@eaagri.vn
- Điện thoại: (0262) xxx xxxx
- Website: www.daklakweb.vn

Chúng tôi luôn sẵn sàng lắng nghe ý kiến đóng góp của bạn để hoàn thiện hệ thống hơn mỗi ngày.
                ''';
                break;
            }
            return InfoScreen(title: title, content: content);
          },
        ),
        // SỬ DỤNG SHELL_ROUTE CHO CÁC TRANG QUẢN TRỊ
        ShellRoute(
          builder: (context, state, child) {
            return AdminLayout(child: child); // Bọc nội dung bằng Layout có Sidebar
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const AdminProfileScreen(),
            ),
            GoRoute(
              path: '/users',
              builder: (context, state) => const UserManagementScreen(),
            ),
            GoRoute(
              path: '/diseases',
              builder: (context, state) => const DiseaseManagerScreen(),
            ),
            GoRoute(
              path: '/banners',
              builder: (context, state) => const BannerManagerScreen(),
            ),
            GoRoute(
              path: '/community-posts',
              builder: (context, state) => const CommunityPostsScreen(),
            ),
            GoRoute(
              path: '/appointments',
              builder: (context, state) => const AdminAppointmentsScreen(),
            ),
            GoRoute(
              path: '/ai-logs',
              builder: (context, state) => const AiLogsScreen(),
            ),
            GoRoute(
              path: '/prices',
              builder: (context, state) => const AgriculturalPriceDashboard(),
            ),
            GoRoute(
              path: '/sales',
              builder: (context, state) => const HubDashboardScreen(),
            ),
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrderListScreen(),
            ),
            GoRoute(
              path: '/orders/detail/:id',
              builder: (context, state) => const OrderListScreen(),
            ),
            GoRoute(
              path: '/products',
              builder: (context, state) => const ProductListScreen(),
            ),
            GoRoute(
              path: '/promotions',
              builder: (context, state) => const VoucherManagementScreen(),
            ),
            GoRoute(
              path: '/finance',
              builder: (context, state) => const FinanceScreen(),
            ),
            GoRoute(
              path: '/finance/upgrades',
              builder: (context, state) => const MembershipUpgradeScreen(),
            ),
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsMainScreen(),
            ),
            GoRoute(
              path: '/audit-logs',
              builder: (context, state) => const AuditLogsScreen(),
            ),
            GoRoute(
              path: '/expert-verifications',
              builder: (context, state) => const ExpertVerificationScreen(),
            ),
            GoRoute(
              path: '/system-logs',
              builder: (context, state) => const SystemLogScreen(),
            ),
          ],
        ),
      ],
    );
  }
}