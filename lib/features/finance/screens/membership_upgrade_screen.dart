import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common/custom_admin_table.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';
import '../../../core/widgets/common/custom_admin_badge.dart';
import '../models/upgrade_request_model.dart';
import '../services/upgrade_service.dart';

class MembershipUpgradeScreen extends StatefulWidget {
  const MembershipUpgradeScreen({super.key});

  @override
  State<MembershipUpgradeScreen> createState() => _MembershipUpgradeScreenState();
}

class _MembershipUpgradeScreenState extends State<MembershipUpgradeScreen> {
  final UpgradeService _upgradeService = UpgradeService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: onSurface),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yêu cầu nâng cấp hội viên',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duyệt hoặc từ chối các yêu cầu nâng cấp gói chuyên gia/pro từ người dùng.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Toolbar
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: CustomAdminToolbar(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                children: [
                  Expanded(
                    child: Text(
                      'Danh sách yêu cầu đang chờ xử lý',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Table
            Expanded(
              child: StreamBuilder<List<UpgradeRequestModel>>(
                stream: _upgradeService.getPendingRequests(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final requests = snapshot.data ?? [];

                  if (requests.isEmpty) {
                    return const Center(child: Text('Không có yêu cầu nào đang chờ.'));
                  }

                  return CustomAdminTable(
                    flex: const [3, 2, 2, 2, 3],
                    labels: const ['Người dùng', 'Gói yêu cầu', 'Số tiền', 'Ngày yêu cầu', 'Thao tác'],
                    itemCount: requests.length,
                    rowBuilder: (context, index) {
                      final req = requests[index];
                      return [
                        // User info
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req.userDisplayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(req.userEmail, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        // Requested Tier
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomAdminBadge(
                            text: req.requestedTier,
                            color: req.requestedTier == 'PRO' ? Colors.purple : Colors.blue,
                          ),
                        ),
                        // Amount
                        Text(_currencyFormat.format(req.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                        // Date
                        Text(DateFormat('dd/MM/yyyy HH:mm').format(req.createdAt)),
                        // Actions
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _handleApprove(req),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Duyệt'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => _handleReject(req),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Từ chối'),
                            ),
                          ],
                        ),
                      ];
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleApprove(UpgradeRequestModel request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận duyệt'),
        content: Text('Xác nhận đã nhận tiền và nâng cấp gói ${request.requestedTier} cho ${request.userDisplayName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Duyệt ngay')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _upgradeService.approveRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã duyệt yêu cầu thành công')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  void _handleReject(UpgradeRequestModel request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối yêu cầu'),
        content: Text('Bạn có chắc chắn muốn từ chối yêu cầu của ${request.userDisplayName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _upgradeService.rejectRequest(request.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã từ chối yêu cầu')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }
}
