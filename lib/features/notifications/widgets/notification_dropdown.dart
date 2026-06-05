import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'notification_tile.dart';

class NotificationDropdown extends StatefulWidget {
  final VoidCallback? onAction;

  const NotificationDropdown({
    super.key,
    this.onAction,
  });

  @override
  State<NotificationDropdown> createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends State<NotificationDropdown> {
  int _limit = 5;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AdminNotification>>(
      stream: NotificationService.getLatestNotificationsStream(limit: _limit),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final isExpanded = _limit > 5;

        return Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          child: Container(
            width: 380,
            constraints: BoxConstraints(
              maxHeight: isExpanded ? 600 : 500,
              minHeight: 100,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thông báo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (notifications.any((n) => !n.isRead))
                        TextButton(
                          onPressed: () async {
                            await NotificationService.markAllAsRead();
                            widget.onAction?.call();
                          },
                          child: const Text(
                            'Đánh dấu tất cả đã đọc',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Notification List
                notifications.isEmpty && snapshot.connectionState == ConnectionState.waiting
                    ? const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : notifications.isEmpty
                        ? Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.notifications_none_rounded, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Không có thông báo mới',
                                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                return NotificationTile(
                                  notification: notifications[index],
                                  onAction: widget.onAction,
                                );
                              },
                            ),
                          ),
                
                // Footer
                if (notifications.isNotEmpty && !isExpanded) ...[
                  const Divider(height: 1),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _limit = 50;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Text(
                        'Xem tất cả thông báo',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
