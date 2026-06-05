import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';
import 'common/glass_container.dart';

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  const _MenuItem(this.icon, this.label, this.route);
}

class _MenuGroup {
  final String title;
  final List<_MenuItem> items;
  const _MenuGroup(this.title, this.items);
}

const _menuGroups = [
  _MenuGroup('Tổng quan', [
    _MenuItem(Icons.dashboard_rounded, 'Dashboard', '/dashboard'),
    _MenuItem(Icons.bar_chart_outlined, 'Báo cáo & Thống kê', '/reports'),
  ]),
  _MenuGroup('Tài chính', [
    _MenuItem(Icons.account_balance_wallet_outlined, 'Thu chi', '/finance'),
    _MenuItem(Icons.card_membership_rounded, 'Nâng cấp hội viên', '/finance/upgrades'),
  ]),
  _MenuGroup('Chuyên gia', [
    _MenuItem(
      Icons.verified_user_outlined,
      'Duyệt chuyên gia',
      '/expert-verifications',
    ),
    _MenuItem(Icons.calendar_today_outlined, 'Lịch hẹn', '/appointments'),
  ]),
  _MenuGroup('Vận hành', [
    _MenuItem(Icons.shopping_cart_outlined, 'Đơn hàng', '/sales'),
    _MenuItem(Icons.attach_money_outlined, 'Giá nông sản', '/prices'),
    _MenuItem(Icons.bug_report_outlined, 'Sâu bệnh', '/diseases'),
    _MenuItem(Icons.confirmation_number_outlined, 'Mã giảm giá', '/promotions'),
  ]),
  _MenuGroup('Hệ thống', [
    _MenuItem(Icons.image_outlined, 'Banner', '/banners'),
    _MenuItem(Icons.people_outlined, 'Tài khoản', '/users'),
    _MenuItem(Icons.chat_bubble_outline_rounded, 'AI Chat Logs', '/ai-logs'),
    _MenuItem(Icons.security_outlined, 'Nhật ký hệ thống', '/system-logs'),
    _MenuItem(Icons.settings_outlined, 'Cài đặt', '/settings'),
  ]),
];

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isDrawer = screenWidth <= 768;
    bool showIconsOnly = screenWidth > 768 && screenWidth <= 1024;

    bool providerExpanded = context.watch<MenuProvider>().isExpanded;
    bool isExpanded = isDrawer
        ? true
        : (showIconsOnly ? false : providerExpanded);

    final currentRoute = GoRouterState.of(context).matchedLocation;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return GlassContainer(
      width: isExpanded ? 260 : 88,
      height: MediaQuery.of(context).size.height,
      borderRadius: BorderRadius.circular(32), // Liquid glass rounded
      child: Column(
        children: [
          // ── Logo ─────────────────────────────────────────────
          InkWell(
            onTap: () {
              if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              context.go('/dashboard');
            },
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: isExpanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/images/logo2.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'EaAgri',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1E1E1E),
                                      ),
                                ),
                                const Text(
                                  'SMART FARMING',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF13B26F),
                                    fontSize:
                                        9, // Slightly smaller to match long English word
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuGroups.length,
              itemBuilder: (context, index) {
                return _SidebarGroupWidget(
                  group: _menuGroups[index],
                  isExpanded: isExpanded,
                  currentRoute: currentRoute,
                );
              },
            ),
          ),

          // ── Footer ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                _ThemeToggleBtn(isExpanded: isExpanded),
                const SizedBox(height: 12),
                _CollapseToggle(isExpanded: isExpanded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarGroupWidget extends StatelessWidget {
  final _MenuGroup group;
  final bool isExpanded;
  final String currentRoute;
  const _SidebarGroupWidget({
    required this.group,
    required this.isExpanded,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    int activeIndex = -1;
    int longestMatch = -1;
    for (int i = 0; i < group.items.length; i++) {
      final route = group.items[i].route;
      // Khớp chính xác hoặc khớp có gạch chéo theo sau (VD: /finance/upgrades không bị nhầm với /finance)
      if (currentRoute == route || currentRoute.startsWith('$route/')) {
        if (route.length > longestMatch) {
          longestMatch = route.length;
          activeIndex = i;
        }
      }
    }
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    const itemHeight = 44.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.symmetric(
        vertical: isExpanded ? 12 : 8,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8, right: 8),
              child: Text(
                group.title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ),
          ],

          Stack(
            children: [
              if (activeIndex >= 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  top: activeIndex * itemHeight,
                  left: 0,
                  right: 0,
                  height: itemHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Theme.of(context).primaryColor.withOpacity(0.15)
                          : Theme.of(context).primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),

              Column(
                children: List.generate(group.items.length, (index) {
                  return SizedBox(
                    height: itemHeight,
                    child: _SidebarTile(
                      item: group.items[index],
                      isExpanded: isExpanded,
                      isActive: activeIndex == index,
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final _MenuItem item;
  final bool isExpanded;
  final bool isActive;
  const _SidebarTile({
    required this.item,
    required this.isExpanded,
    required this.isActive,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final inactiveColor =
        Theme.of(context).textTheme.bodySmall?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final activeColor = Theme.of(context).primaryColor;
    final fgColor = active ? activeColor : inactiveColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: () {
          if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
          context.go(widget.item.route);
        },
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered && !active
                ? (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.04))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: widget.isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              if (widget.isExpanded) const SizedBox(width: 16),
              Icon(widget.item.icon, size: 22, color: fgColor),
              if (widget.isExpanded)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 14),
                        Text(
                          widget.item.label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: fgColor,
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleBtn extends StatelessWidget {
  final bool isExpanded;
  const _ThemeToggleBtn({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);
    final fgColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return InkWell(
      onTap: () => themeProvider.toggleTheme(),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 48,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: isExpanded
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (isExpanded)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Text(
                    isDark ? 'Chế độ tối' : 'Chế độ sáng',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                    ),
                  ),
                ),
              ),
            Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 20,
              color: fgColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapseToggle extends StatelessWidget {
  final bool isExpanded;
  const _CollapseToggle({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final bgColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);
    final fgColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return InkWell(
      onTap: () => context.read<MenuProvider>().toggleMenu(),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 48,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: isExpanded
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isExpanded)
              Expanded(
                child: Text(
                  'Thu gọn',
                  style: TextStyle(fontWeight: FontWeight.w600, color: fgColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_left_rounded
                  : Icons.keyboard_arrow_right_rounded,
              size: 20,
              color: fgColor,
            ),
          ],
        ),
      ),
    );
  }
}
