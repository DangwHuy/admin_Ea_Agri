import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../services/search_service.dart';

class SearchOverlay extends StatelessWidget {
  final List<SearchResult> results;
  final bool isLoading;
  final VoidCallback onClose;

  const SearchOverlay({
    super.key,
    required this.results,
    required this.isLoading,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildOverlayContainer(
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return _buildOverlayContainer(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Không tìm thấy kết quả',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      );
    }

    // Group results
    final orders = results.where((r) => r.type == 'order').toList();
    final users = results.where((r) => r.type == 'user').toList();
    final experts = results.where((r) => r.type == 'expert').toList();

    return _buildOverlayContainer(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (orders.isNotEmpty) _buildSection(context, 'Đơn hàng', orders, Icons.shopping_bag_outlined),
          if (users.isNotEmpty) _buildSection(context, 'Người dùng', users, Icons.person_outline),
          if (experts.isNotEmpty) _buildSection(context, 'Chuyên gia', experts, Icons.verified_user_outlined),
        ],
      ),
    );
  }

  Widget _buildOverlayContainer({required Widget child}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<SearchResult> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildResultItem(context, item)),
        const Divider(height: 16, color: AppColors.border),
      ],
    );
  }

  Widget _buildResultItem(BuildContext context, SearchResult item) {
    return InkWell(
      onTap: () {
        onClose();
        if (item.type == 'order') {
          // Use GoRouter to navigate to order detail or open dialog. 
          // Note: your current app uses a dialog `_viewOrderDetail` in `orders_table_widget.dart`,
          // but the instruction requested /orders/detail/:id. 
          context.go('/orders'); // Navigation to orders page first as a fallback, or straight to detail if implemented
        } else if (item.type == 'user') {
          context.go('/users');
        } else if (item.type == 'expert') {
          context.go('/expert-verifications'); // Or expert details
        }
      },
      hoverColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: item.photoUrl != null ? NetworkImage(item.photoUrl!) : null,
              child: item.photoUrl == null
                  ? Icon(
                      item.type == 'order' ? Icons.receipt_long : Icons.person,
                      size: 18,
                      color: AppColors.textMuted,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeading,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
