import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'package:go_router/go_router.dart';

class NotificationTile extends StatelessWidget {
  final AdminNotification notification;
  final VoidCallback? onAction;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onAction,
  });

  /// Helper method to format timestamp into Vietnamese relative time
  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      // Standard format for older notifications: DD/MM/YYYY
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.system:
        return Icons.settings_suggest_rounded;
      case NotificationType.order:
        return Icons.shopping_basket_rounded;
      case NotificationType.alert:
        return Icons.report_problem_rounded;
      case NotificationType.aiError:
        return Icons.psychology_alt_rounded;
      case NotificationType.lowStock:
        return Icons.inventory_2_rounded;
      case NotificationType.verification:
        return Icons.verified_user_rounded;
      case NotificationType.finance:
        return Icons.account_balance_wallet_rounded;
      case NotificationType.market:
        return Icons.trending_up_rounded;
      case NotificationType.moderation:
        return Icons.gavel_rounded;
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.system:
        return Colors.blue;
      case NotificationType.order:
        return Colors.green;
      case NotificationType.alert:
        return Colors.orange;
      case NotificationType.aiError:
        return Colors.red;
      case NotificationType.lowStock:
        return Colors.deepPurple;
      case NotificationType.verification:
        return Colors.teal;
      case NotificationType.finance:
        return Colors.amber.shade700;
      case NotificationType.market:
        return Colors.indigo;
      case NotificationType.moderation:
        return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // 1. Mark as read in Firestore
        await NotificationService.markAsRead(notification.id);
        
        // 2. Execute callback (usually to close dropdown)
        onAction?.call();

        // 3. Navigate if targetRoute exists
        if (notification.targetRoute != null && context.mounted) {
          String route = notification.targetRoute!;
          
          // --- Legacy Route Mapping ---
          // Ensures old notifications in Firestore still work after route refactoring
          final legacyMap = {
            '/expert-management': '/expert-verifications',
            '/order-management': '/orders',
            '/finance-management': '/finance',
            '/pest-management': '/diseases',
            '/warehouse-management': '/products',
            '/agricultural-price': '/prices',
          };

          if (legacyMap.containsKey(route)) {
            route = legacyMap[route]!;
          }
          // ----------------------------

          context.push(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : Colors.blue.withValues(alpha: 0.05),
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatRelativeTime(notification.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
