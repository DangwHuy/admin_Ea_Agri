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
  bool _isCleaning = false;
  final Set<String> _selectedRequestIds = {};
  Timer? _timer;
  late Stream<List<UpgradeRequestModel>> _requestsStream;

  @override
  void initState() {
    super.initState();
    _requestsStream = _upgradeService.getAllRequests();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // Tự động dọn dẹp các yêu cầu quá hạn khi mở màn hình
    _upgradeService.cleanupExpiredRequests().then((count) {
      if (count > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tự động dọn dẹp $count yêu cầu nâng cấp quá hạn')),
        );
      }
    });
  }

  Future<void> _handleCleanup() async {
    setState(() => _isCleaning = true);
    try {
      final count = await _upgradeService.cleanupExpiredRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              count > 0
                  ? 'Đã dọn dẹp thành công $count yêu cầu quá hạn!'
                  : 'Không có yêu cầu quá hạn nào cần dọn dẹp.',
            ),
            backgroundColor: count > 0 ? Colors.green : Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi dọn dẹp: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCleaning = false);
    }
  }

  Widget _buildBulkActionBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_box_outlined, color: Colors.red.shade400),
          const SizedBox(width: 8),
          Text(
            'Đã chọn ${_selectedRequestIds.length} yêu cầu',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _selectedRequestIds.clear()),
            child: const Text('Bỏ chọn'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _handleBulkDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Xóa lịch sử đã chọn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBulkDelete() async {
    final count = _selectedRequestIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn $count lịch sử yêu cầu nâng cấp đã chọn không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final idsToDelete = _selectedRequestIds.toList();
        await _upgradeService.deleteRequests(idsToDelete);
        if (mounted) {
          setState(() {
            _selectedRequestIds.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa thành công $count yêu cầu'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
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
                  ElevatedButton.icon(
                    onPressed: _isCleaning ? null : _handleCleanup,
                    icon: _isCleaning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cleaning_services_outlined, size: 18),
                    label: const Text('Dọn dẹp YC quá hạn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            if (_selectedRequestIds.isNotEmpty) _buildBulkActionBar(),
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
                    showHeaderCheckbox: true,
                    headerCheckboxValue: requests.isNotEmpty && requests.every((req) => _selectedRequestIds.contains(req.id)),
                    onHeaderCheckboxChanged: (val) {
                      setState(() {
                        if (val == true) {
                          for (var req in requests) {
                            _selectedRequestIds.add(req.id);
                          }
                        } else {
                          _selectedRequestIds.clear();
                        }
                      });
                    },
                    rowBuilder: (context, index) {
                      final req = requests[index];
                      final isSelected = _selectedRequestIds.contains(req.id);
                      return [
                        // User info
                        Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedRequestIds.add(req.id);
                                  } else {
                                    _selectedRequestIds.remove(req.id);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req.userDisplayName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                  Text(req.userEmail, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
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
