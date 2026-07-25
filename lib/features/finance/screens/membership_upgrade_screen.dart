import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _timer;
  late Stream<List<UpgradeRequestModel>> _requestsStream;

  @override
  void initState() {
    super.initState();
    _requestsStream = _upgradeService.getAllRequests();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _getRemainingTimeText(DateTime createdAt) {
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    final remaining = 600 - elapsed;
    if (remaining <= 0) return 'Hết hạn';
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return 'Hết hạn sau: ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch sử nâng cấp hội viên',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Theo dõi lịch sử giao dịch nâng cấp tự động và xử lý thủ công (nếu cần).',
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
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomAdminToolbar(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                children: [
                  const Expanded(
                    child: Text(
                      'Danh sách toàn bộ giao dịch',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 280,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm theo mã CK (VD: EA 1A2B)',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Table
            Expanded(
              child: StreamBuilder<List<UpgradeRequestModel>>(
                stream: _requestsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var requests = snapshot.data ?? [];

                  if (_searchQuery.isNotEmpty) {
                    requests = requests.where((req) {
                      final code = req.transferCode?.toLowerCase() ?? '';
                      return code.contains(_searchQuery.toLowerCase());
                    }).toList();
                  }

                  if (requests.isEmpty) {
                    return const Center(child: Text('Không có yêu cầu nào đang chờ.'));
                  }

                  return CustomAdminTable(
                    flex: const [3, 2, 2, 2, 2, 3],
                    labels: const ['Người dùng', 'Gói yêu cầu', 'Mã chuyển khoản', 'Số tiền', 'Ngày yêu cầu', 'Trạng thái / Thao tác'],
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
                        // Transfer Code
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              req.transferCode?.toUpperCase() ?? 'KHÔNG RÕ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        // Amount
                        Text(_currencyFormat.format(req.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                        // Date
                        Text(DateFormat('dd/MM/yyyy HH:mm').format(req.createdAt)),
                        // Actions
                        // Actions
                        req.status == 'pending'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                                  const SizedBox(height: 4),
                                  Text(
                                    _getRemainingTimeText(req.createdAt),
                                    style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : req.status == 'approved'
                                ? CustomAdminBadge(
                                    text: 'Đã thanh toán',
                                    color: Colors.green,
                                  )
                                : CustomAdminBadge(
                                    text: 'Đã từ chối',
                                    color: Colors.red,
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
        await _upgradeService.approveRequest(request, adminMessage: 'Giao dịch thành công. Cảm ơn bạn đã nâng cấp hội viên!');
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
    final reasonController = TextEditingController(text: 'Không tìm thấy mã thanh toán hợp lệ. Vui lòng kiểm tra lại.');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối yêu cầu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn từ chối yêu cầu của ${request.userDisplayName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do từ chối (sẽ gửi cho người dùng)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
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
        await _upgradeService.rejectRequest(request.id, adminMessage: reasonController.text.trim());
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
