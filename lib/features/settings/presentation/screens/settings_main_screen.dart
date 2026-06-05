import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/settings_provider.dart';
import '../widgets/forms/global_settings_form.dart';
import '../widgets/forms/ai_settings_form.dart';
import '../widgets/forms/business_settings_form.dart';
import '../widgets/forms/security_settings_form.dart';
import '../widgets/forms/feature_flags_form.dart';
import '../widgets/forms/notification_settings_form.dart';
import '../widgets/forms/localization_settings_form.dart';
import '../widgets/forms/monitoring_settings_form.dart';
import '../widgets/forms/backup_settings_form.dart';
import '../../data/models/settings_group.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

class SettingsMainScreen extends StatefulWidget {
  const SettingsMainScreen({super.key});

  @override
  State<SettingsMainScreen> createState() => _SettingsMainScreenState();
}

class _SettingsMainScreenState extends State<SettingsMainScreen> {
  int _selectedIndex = 0;
  bool _isNavCollapsed = false;

  late final List<SettingsGroup> _groups = [
    SettingsGroup(
      title: 'Hệ thống chung',
      subtitle: 'Quản lý cấu hình cốt lõi và định danh thương hiệu',
      icon: Icons.grid_view_rounded,
      builder: (context) => const GlobalSettingsForm(),
    ),
    SettingsGroup(
      title: 'Cấu hình Kinh doanh',
      subtitle: 'Tùy chỉnh thông số vận hành và chính sách kinh doanh',
      icon: Icons.business_center_rounded,
      builder: (context) => const BusinessSettingsForm(),
    ),
    SettingsGroup(
      title: 'AI & Tích hợp',
      subtitle: 'Cấu hình mô hình ngôn ngữ và các dịch vụ bên thứ ba',
      icon: Icons.psychology_rounded,
      builder: (context) => const AISettingsForm(),
    ),
    SettingsGroup(
      title: 'Bảo mật & Quyền',
      subtitle: 'Cấp phép truy cập và bảo vệ dữ liệu hệ thống',
      icon: Icons.security_rounded,
      builder: (context) => const SecuritySettingsForm(),
    ),
    SettingsGroup(
      title: 'Thông báo',
      subtitle: 'Quản lý kênh liên lạc và thông báo đẩy người dùng',
      icon: Icons.notifications_rounded,
      builder: (context) => const NotificationSettingsForm(),
    ),
    SettingsGroup(
      title: 'Tính năng thử nghiệm',
      subtitle: 'Bật/tắt các chế độ bảo trì và tính năng bản beta',
      icon: Icons.flag_rounded,
      builder: (context) => const FeatureFlagsForm(),
    ),
    SettingsGroup(
      title: 'Định dạng & Ngôn ngữ',
      subtitle: 'Thiết lập vùng miền, ngôn ngữ và hiển thị dữ liệu',
      icon: Icons.language_rounded,
      builder: (context) => const LocalizationSettingsForm(),
    ),
    SettingsGroup(
      title: 'Giám sát & Sức khỏe',
      subtitle: 'Theo dõi hiệu suất và trạng thái hoạt động của server',
      icon: Icons.insights_rounded,
      builder: (context) => const MonitoringSettingsForm(),
    ),
    SettingsGroup(
      title: 'Sao lưu & Dữ liệu',
      subtitle: 'Quản trị cơ sở dữ liệu và lịch trình sao lưu định kỳ',
      icon: Icons.backup_rounded,
      builder: (context) => const BackupSettingsForm(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadAllSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Section (now fully dynamic) ──────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _groups[_selectedIndex].title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 32,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _groups[_selectedIndex].subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Integrated Navigation & Content (Master-Detail) ─────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigation Rail (Master)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isNavCollapsed ? 80 : 260,
                  child: _buildIntegratedNav(),
                ),

                const SizedBox(width: 32),

                // Content Area (Detail)
                Expanded(
                  child: Consumer<SettingsProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.global == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null && provider.global == null) {
                        return Center(
                          child: Text(
                            provider.errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 32),
                        child: _groups[_selectedIndex].builder(context),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegratedNav() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final isSelected = _selectedIndex == index;
              return _SettingsNavChip(
                icon: _groups[index].icon,
                label: _groups[index].title,
                isSelected: isSelected,
                isCollapsed: _isNavCollapsed,
                onTap: () => setState(() => _selectedIndex = index),
              );
            },
          ),
        ),

        // Collapse Toggle
        _buildCollapseToggle(),
      ],
    );
  }

  Widget _buildCollapseToggle() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: () => setState(() => _isNavCollapsed = !_isNavCollapsed),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _isNavCollapsed ? Icons.keyboard_double_arrow_right_rounded : Icons.keyboard_double_arrow_left_rounded,
            size: 20,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}

class _SettingsNavChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SettingsNavChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_SettingsNavChip> createState() => _SettingsNavChipState();
}

class _SettingsNavChipState extends State<_SettingsNavChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.isCollapsed ? widget.label : "",
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : 16, 
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
                  : _isHovered
                      ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected ? activeColor.withValues(alpha: 0.3) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isSelected ? activeColor : Theme.of(context).textTheme.bodySmall?.color,
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                            color: widget.isSelected ? activeColor : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  if (widget.isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
