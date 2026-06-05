import 'dart:async';
import 'package:flutter/material.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/common/custom_admin_table.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';
import '../../../core/widgets/common/custom_admin_badge.dart';
import '../models/voucher_model.dart';
import '../services/voucher_service.dart';

class VoucherManagementScreen extends StatefulWidget {
  const VoucherManagementScreen({super.key});

  @override
  State<VoucherManagementScreen> createState() =>
      _VoucherManagementScreenState();
}

class _VoucherManagementScreenState extends State<VoucherManagementScreen> {
  final VoucherService _voucherService = VoucherService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String _searchSellerId = '';
  String _statusFilter = 'Tất cả trạng thái';

  List<VoucherModel> _vouchers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastFetchedDoc;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchSellerId = value.trim();
        _vouchers.clear();
        _lastFetchedDoc = null;
        _hasMore = true;
      });
      _fetchVouchers();
    });
  }

  Future<void> _fetchVouchers() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final snapshot = await _voucherService.fetchVouchersPage(
        sellerIdSearch: _searchSellerId.isNotEmpty ? _searchSellerId : null,
        limit: 50,
      );

      final newVouchers = snapshot.docs
          .map((doc) => VoucherModel.fromFirestore(doc))
          .toList();

      setState(() {
        _vouchers = newVouchers;
        if (snapshot.docs.isNotEmpty) _lastFetchedDoc = snapshot.docs.last;
        _hasMore = snapshot.docs.length >= 50;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching vouchers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final snapshot = await _voucherService.fetchVouchersPage(
        sellerIdSearch: _searchSellerId.isNotEmpty ? _searchSellerId : null,
        lastDoc: _lastFetchedDoc,
        limit: 50,
      );

      final newVouchers = snapshot.docs
          .map((doc) => VoucherModel.fromFirestore(doc))
          .toList();

      setState(() {
        _vouchers.addAll(newVouchers);
        if (snapshot.docs.isNotEmpty) _lastFetchedDoc = snapshot.docs.last;
        _hasMore = snapshot.docs.length >= 50;
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Error fetching more vouchers: $e');
      setState(() => _isLoadingMore = false);
    }
  }

  List<VoucherModel> get _filteredVouchers {
    if (_statusFilter == 'Tất cả trạng thái') return _vouchers;

    return _vouchers.where((v) {
      final bool isExpired = DateTime.now().isAfter(v.expiryDate);
      switch (_statusFilter) {
        case 'Đang hoạt động':
          return v.isActive && !isExpired;
        case 'Hết hạn':
          return isExpired;
        case 'Vô hiệu':
          return !v.isActive;
        default:
          return true;
      }
    }).toList();
  }

  String _getStatusText(VoucherModel v) {
    final bool isExpired = DateTime.now().isAfter(v.expiryDate);
    if (!v.isActive) return 'Vô hiệu';
    if (isExpired) return 'Hết hạn';
    return 'Hoạt động';
  }

  Color _getStatusColor(VoucherModel v) {
    final bool isExpired = DateTime.now().isAfter(v.expiryDate);
    if (!v.isActive) return Colors.grey;
    if (isExpired) return Colors.red;
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3);
    final filtered = _filteredVouchers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════
            // HEADER
            // ═══════════════════════════════════════
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Quay lại Dashboard',
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hệ thống Quản lý Mã giảm giá',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý và giám sát các mã giảm giá tự động từ AI cho người bán nông sản.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════
            // TOOLBAR PILL — CustomAdminToolbar
            // height: 56, padding: h24/v6, flex 6:2:2
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomAdminToolbar(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                children: [
                  // Search — flex 6
                  Expanded(
                    flex: 6,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo Seller ID...',
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color),
                        filled: true,
                        fillColor: fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Status Filter — flex 2
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _statusFilter,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.filter_list_rounded, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                        filled: true,
                        fillColor: fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      items: ['Tất cả trạng thái', 'Đang hoạt động', 'Hết hạn', 'Vô hiệu']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: Theme.of(context).textTheme.bodySmall))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _statusFilter = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Loading indicator or count
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${filtered.length} mã giảm giá',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // TABLE — CustomAdminTable (golden rule)
            // ═══════════════════════════════════════
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: CustomAdminTable(
                          flex: const [2, 3, 2, 2, 2, 2, 2, 1],
                          labels: const ['Mã Voucher', 'Người bán', 'Loại', 'Giá trị', 'Sử dụng', 'Hết hạn', 'Trạng thái', 'Bật/Tắt'],
                          itemCount: filtered.length,
                          onRowTapWithIndex: (_) {},
                          rowBuilder: (context, index) {
                            final v = filtered[index];
                            return [
                              // Code
                              Text(
                                v.code.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),

                              // Seller
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.sellerName,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    v.sellerId,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ],
                              ),

                              // Type
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Chip(
                                  label: Text(v.type.replaceAll('_', ' '), style: Theme.of(context).textTheme.labelSmall),
                                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.4),
                                  side: BorderSide.none,
                                ),
                              ),

                              // Value
                              Text(
                                v.discountType == 'Percentage'
                                    ? '${v.value.toStringAsFixed(0)}%'
                                    : '${v.value.toStringAsFixed(0)} đ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),

                              // Usage
                              Text(
                                '${v.usageCount} / ${v.usageLimit}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),

                              // Expiry
                              Text(
                                DateFormat('dd/MM/yyyy').format(v.expiryDate),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),

                              // Status badge
                              Align(
                                alignment: Alignment.centerLeft,
                                child: CustomAdminBadge(
                                  text: _getStatusText(v),
                                  color: _getStatusColor(v),
                                ),
                              ),

                              // Toggle
                              Align(
                                alignment: Alignment.centerRight,
                                child: Switch(
                                  value: v.isActive,
                                  activeColor: const Color(0xFF2E7D32),
                                  onChanged: (val) async {
                                    try {
                                      await _voucherService.updateVoucherStatus(v.id, val);
                                      setState(() {
                                        final idx = _vouchers.indexWhere((x) => x.id == v.id);
                                        if (idx != -1) {
                                          _vouchers[idx] = v.copyWith(isActive: val);
                                        }
                                      });
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Lỗi cập nhật: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ];
                          },
                        ),
                      ),

                      // Load more button
                      if (_hasMore && !_isLoadingMore)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: _fetchMore,
                              icon: Icon(Icons.refresh, color: const Color(0xFF2E7D32)),
                              label: Text(
                                'Tải thêm',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
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
