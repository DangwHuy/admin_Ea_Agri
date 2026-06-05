import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'order_detail_dialog.dart';
import 'package:admin_daklak_web/features/logs/services/bulk_service.dart';
import 'package:admin_daklak_web/features/logs/widgets/bulk_action_bar.dart';
import 'package:admin_daklak_web/features/logs/models/audit_log_model.dart';
import '../../../core/widgets/common/glass_container.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

Color _getBgGray(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5) : const Color(0xFFF5F7FA);
Color _getTextPrimary(BuildContext context) => Theme.of(context).colorScheme.onSurface;
Color _getTextSecondary(BuildContext context) => Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280);
Color _getBorderColor(BuildContext context) => Theme.of(context).dividerColor;
Color _getPrimaryGreen(BuildContext context) => Theme.of(context).primaryColor;
Color _getSuccessGreen(BuildContext context) => Colors.green;
Color _getErrorRed(BuildContext context) => Theme.of(context).colorScheme.error;
Color _getInfoBlue(BuildContext context) => Colors.blue;

void _showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
      backgroundColor: _getTextPrimary(context),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 24, right: 24, left: 24),
    ),
  );
}

class OrdersTableWidget extends StatefulWidget {
  final DateTimeRange? dateRange;
  final bool isDashboard;
  
  const OrdersTableWidget({
    Key? key,
    this.dateRange,
    this.isDashboard = false,
  }) : super(key: key);

  @override
  State<OrdersTableWidget> createState() => OrdersTableWidgetState();
}

class OrdersTableWidgetState extends State<OrdersTableWidget> {
  String _selectedStatus = 'Tất cả trạng thái';
  final Map<String, String> _statusValueMap = {
    'Tất cả trạng thái': 'All Status',
    'Đang chờ': 'Pending',
    'Đang xử lý': 'Processing',
    'Đang giao': 'In Transit',
    'Hoàn thành': 'Completed',
    'Đã hủy': 'Cancelled',
    'Thất bại': 'Failed',
  };
  final Set<String> _selectedIds = {};
  
  bool _isSearchMode = false;
  String _activeSearchId = '';
  String? _firebaseIndexErrorUrl;
  DateTimeRange? _internalDateRange;
  
  List<DocumentSnapshot> _docs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  StreamSubscription? _streamSub;

  DateTimeRange? get _effectiveDateRange => widget.dateRange ?? _internalDateRange;

  @override
  void initState() {
    super.initState();
    _startListeningToOrders();
  }

  @override
  void didUpdateWidget(covariant OrdersTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dateRange != oldWidget.dateRange) {
      _startListeningToOrders();
    }
  }

  void _startListeningToOrders() {
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _docs.clear();
      _firebaseIndexErrorUrl = null;
    });
    _streamSub?.cancel();

    Query q = FirebaseFirestore.instance.collection('orders');
    final firestoreStatus = _statusValueMap[_selectedStatus] ?? 'All Status';
    if (firestoreStatus != 'All Status') {
      q = q.where('status', isEqualTo: firestoreStatus);
    }
    
    final dateRange = _effectiveDateRange;
    if (dateRange != null) {
      q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
           .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end));
    }

    q = q.orderBy('createdAt', descending: true).limit(50);

    _streamSub = q.snapshots().listen((snapshot) {
      if (!mounted) return;
      setState(() {
         _docs = snapshot.docs;
         _isLoading = false;
         if (snapshot.docs.length < 50) _hasMore = false;
      });
    }, onError: (Object error) {
      if (!mounted) return;
      setState(() {
         _isLoading = false;
         _hasMore = false;
         if (error.toString().contains('requires an index')) {
            final regExp = RegExp(r'https:\/\/console\.firebase\.google\.com[^\s]*');
            final match = regExp.firstMatch(error.toString());
            if (match != null) {
              _firebaseIndexErrorUrl = match.group(0);
            }
         } else {
             _showToast(context, 'Lỗi Firebase: $error');
         }
      });
    });
  }

  Future<void> _fetchMoreOrders() async {
    if (!_hasMore || _isLoadingMore || _docs.isEmpty) return;
    setState(() => _isLoadingMore = true);

    Query q = FirebaseFirestore.instance.collection('orders');
    final firestoreStatus = _statusValueMap[_selectedStatus] ?? 'All Status';
    if (firestoreStatus != 'All Status') q = q.where('status', isEqualTo: firestoreStatus);
    
    final dateRange = _effectiveDateRange;
    if (dateRange != null) {
       q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end));
    }
    
    q = q.orderBy('createdAt', descending: true)
         .startAfterDocument(_docs.last)
         .limit(50);

    try {
        final snapshot = await q.get();
        if (mounted) {
          setState(() {
            if (snapshot.docs.length < 50) _hasMore = false;
            _docs.addAll(snapshot.docs);
            _isLoadingMore = false;
          });
        }
    } catch(error) {
        if (!mounted) return;
        setState(() => _isLoadingMore = false);
        if (error.toString().contains('requires an index')) {
            final regExp = RegExp(r'https:\/\/console\.firebase\.google\.com[^\s]*');
            final match = regExp.firstMatch(error.toString());
            if (match != null) {
              setState(() => _firebaseIndexErrorUrl = match.group(0));
            }
        }
    }
  }

  void _performSearch(String query) {
    final str = query.trim();
    if (str.isEmpty) {
      setState(() { _isSearchMode = false; _activeSearchId = ''; });
      _startListeningToOrders();
      return;
    }
    
    _streamSub?.cancel();
    setState(() {
      _isSearchMode = true;
      _activeSearchId = str;
      _isLoading = false;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final newRange = await showDateRangePicker(
      context: context,
      initialDateRange: _internalDateRange ?? DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
        ),
        child: child!,
      ),
    );
    if (newRange != null) {
      setState(() {
        _internalDateRange = DateTimeRange(
          start: DateTime(newRange.start.year, newRange.start.month, newRange.start.day),
          end: DateTime(newRange.end.year, newRange.end.month, newRange.end.day, 23, 59, 59),
        );
      });
      _startListeningToOrders();
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  void exportToCSV() {
    if (_docs.isEmpty) {
      _showToast(context, 'Không có dữ liệu để xuất.');
      return;
    }

    final List<List<dynamic>> rows = [
      ['Mã đơn hàng', 'Tên khách hàng', 'Tổng tiền']
    ];

    for (var doc in _docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final amount = (data['totalAmount'] ?? 0) is num ? (data['totalAmount'] as num).toDouble() : double.tryParse((data['totalAmount']).toString()) ?? 0;
      final customerName = data['customerName'] ?? 'Không có tên';
      rows.add([doc.id.toUpperCase(), customerName, amount]);
    }

    final String csvData = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'orders_export_${DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '')}.csv';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    _showToast(context, 'Xuất file thành công!');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════════════════════════════════════
        // STANDALONE PILL TOOLBAR
        // ═══════════════════════════════════════════════
        _selectedIds.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: BulkActionBar(
                selectedCount: _selectedIds.length,
                onClearSelection: () => setState(() => _selectedIds.clear()),
                actions: [_buildBulkStatusDropdown()],
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildToolbar(context, isDark),
            ),

        // ═══════════════════════════════════════════════
        // GLASS TABLE CARD
        // ═══════════════════════════════════════════════
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_firebaseIndexErrorUrl != null)
                _buildFirebaseIndexErrorBubble()
              else if (_isSearchMode)
                _buildSearchFutureResult()
              else if (_isLoading)
                const Padding(padding: EdgeInsets.all(48.0), child: Center(child: CircularProgressIndicator()))
              else if (_docs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_rounded, size: 48, color: _getTextSecondary(context)),
                        const SizedBox(height: 12),
                        Text("Không tìm thấy đơn hàng nào.", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _getTextSecondary(context))),
                      ],
                    ),
                  ),
                )
              else
                _buildDataTableBody(_docs),
                
              if (!_isSearchMode && _hasMore && !_isLoading && _firebaseIndexErrorUrl == null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: _isLoadingMore 
                      ? const CircularProgressIndicator() 
                      : TextButton.icon(
                          onPressed: _fetchMoreOrders,
                          icon: Icon(Icons.refresh, color: _getPrimaryGreen(context)),
                          label: Text("Tải thêm đơn hàng", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: _getPrimaryGreen(context), fontWeight: FontWeight.w600)),
                        ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }

  /// Toolbar using CustomAdminToolbar — same specs as Expert Verification
  /// height: 56, padding: h24/v6, flex: 6:2:2:1, borderRadius: 30
  Widget _buildToolbar(BuildContext context, bool isDark) {
    final fillColor = isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3);

    String dateLabel = 'Lọc theo ngày';
    if (_internalDateRange != null) {
      final s = _internalDateRange!.start;
      final e = _internalDateRange!.end;
      dateLabel = '${s.day}/${s.month}/${s.year} - ${e.day}/${e.month}/${e.year}';
    }

    return CustomAdminToolbar(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      children: [
        // Search — flex 6
        Expanded(
          flex: 6,
          child: TextField(
            onChanged: (val) {
              if (val.isEmpty) _performSearch('');
            },
            onSubmitted: (val) => _performSearch(val),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm đơn hàng...',
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
            value: _selectedStatus,
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
            items: <String>['Tất cả trạng thái', 'Đang chờ', 'Đang xử lý', 'Đang giao', 'Hoàn thành', 'Đã hủy', 'Thất bại']
                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: Theme.of(context).textTheme.bodySmall))).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() { _selectedStatus = newValue; });
                if (!_isSearchMode) _startListeningToOrders();
              }
            },
          ),
        ),
        const SizedBox(width: 16),

        // Date Filter — flex 2
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_internalDateRange != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 14),
                      onPressed: () {
                        setState(() => _internalDateRange = null);
                        _startListeningToOrders();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Export Button — flex 1
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: exportToCSV,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Xuất file'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getPrimaryGreen(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirebaseIndexErrorBubble() {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Row(
                   children: [
                       const Icon(Icons.warning_rounded, color: Colors.red),
                       const SizedBox(width: 8),
                       Text("Yêu cầu thiết lập Index Firebase", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
                    ]
                 ),
                 const SizedBox(height: 4),
                 Text("Bộ lọc này yêu cầu một 'Composite Index' trong Firestore để hoạt động.", style: Theme.of(context).textTheme.bodySmall),
                 const SizedBox(height: 8),
                 SelectableText("Vui lòng sao chép và dán liên kết này vào trình duyệt của bạn để tạo index:\n${_firebaseIndexErrorUrl!}", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
             ]
          )
        )
      );
  }

  Widget _buildSearchFutureResult() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('orders').doc(_activeSearchId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Padding(padding: EdgeInsets.all(48.0), child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
           return Padding(
             padding: const EdgeInsets.all(48.0),
             child: Center(
               child: Column(
                 children: [
                   Icon(Icons.search_off_rounded, size: 48, color: _getTextSecondary(context)),
                   const SizedBox(height: 12),
                   Text("Không tìm thấy đơn hàng với mã này.", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _getTextSecondary(context))),
                 ],
               ),
             ),
           );
        }
        return _buildDataTableBody([snapshot.data!]);
      },
    );
  }

  Widget _buildDataTableBody(List<DocumentSnapshot> displayDocs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - (widget.isDashboard ? 100 : 96)),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(_getBgGray(context)),
          showCheckboxColumn: true,
          dataRowMaxHeight: 70,
          dataRowMinHeight: 70,
          onSelectAll: (selected) {
            setState(() {
              if (selected == true) {
                _selectedIds.addAll(displayDocs.map((d) => d.id));
              } else {
                _selectedIds.clear();
              }
            });
          },
          columns: [
            _buildDataColumn('Mã đơn hàng'),
            _buildDataColumn('Khách hàng'),
            _buildDataColumn('Tổng tiền'),
            _buildDataColumn('Trạng thái'),
            _buildDataColumn('Ngày tạo'),
            _buildDataColumn('Thao tác'),
          ],
          rows: displayDocs.map((doc) {
            Map<String, dynamic> data;
            try {
              data = doc.data() as Map<String, dynamic>? ?? {};
            } catch(e) {
              data = {};
            }
            
            final date = (data['createdAt'] as Timestamp?)?.toDate();
            final dateString = date != null ? "${date.day}/${date.month}/${date.year}" : "";
            final amount = (data['totalAmount'] ?? 0) is num ? (data['totalAmount'] as num).toDouble() : double.tryParse((data['totalAmount']).toString()) ?? 0;

            return DataRow(
              selected: _selectedIds.contains(doc.id),
              onSelectChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedIds.add(doc.id);
                  } else {
                    _selectedIds.remove(doc.id);
                  }
                });
              },
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => _viewOrderDetail(doc.id, data),
                    child: Text(doc.id.length > 8 ? doc.id.substring(0, 8).toUpperCase() : doc.id.toUpperCase(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: _getPrimaryGreen(context))),
                  )
                ),
                DataCell(Text(data['customerName'] ?? 'Không có tên', style: Theme.of(context).textTheme.bodyMedium)),
                DataCell(Text('${amount.toStringAsFixed(0)} đ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                DataCell(_buildStatusBadge(data['status'] ?? 'Pending')),
                DataCell(Text(dateString, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getTextSecondary(context)))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Eye icon — view detail
                      IconButton(
                        onPressed: () => _viewOrderDetail(doc.id, data),
                        icon: Icon(Icons.visibility_outlined, size: 20, color: _getPrimaryGreen(context)),
                        tooltip: 'Xem chi tiết',
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: _getTextSecondary(context))),
    );
  }

  /// Map Firestore status → Vietnamese display label
  String _statusToVietnamese(String status) {
    switch (status) {
      case 'Pending': return 'Đang chờ';
      case 'Processing': return 'Đang xử lý';
      case 'In Transit': return 'Đang giao';
      case 'Completed': return 'Hoàn thành';
      case 'Cancelled': return 'Đã hủy';
      case 'Failed': return 'Thất bại';
      default: return status;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    Color statusBg;

    switch (status) {
      case 'Pending':
        statusColor = Colors.orange;
        statusBg = Colors.orange.withValues(alpha: 0.1);
        break;
      case 'Processing':
        statusColor = _getInfoBlue(context);
        statusBg = _getInfoBlue(context).withValues(alpha: 0.1);
        break;
      case 'In Transit':
        statusColor = const Color(0xFF6366F1);
        statusBg = const Color(0xFF6366F1).withValues(alpha: 0.1);
        break;
      case 'Completed':
        statusColor = _getSuccessGreen(context);
        statusBg = _getSuccessGreen(context).withValues(alpha: 0.1);
        break;
      case 'Cancelled':
      case 'Failed':
        statusColor = _getErrorRed(context);
        statusBg = _getErrorRed(context).withValues(alpha: 0.1);
        break;
      default:
        statusColor = _getTextSecondary(context);
        statusBg = _getBgGray(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(50)),
      child: Text(_statusToVietnamese(status), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _updateOrderStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(docId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) _showToast(context, 'Đã cập nhật đơn hàng sang ${_statusToVietnamese(newStatus)}');
    } catch (e) {
      if (mounted) _showToast(context, 'Lỗi cập nhật đơn hàng: $e');
    }
  }

  void _viewOrderDetail(String orderId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailDialog(
        orderId: orderId,
        orderData: data,
        onStatusChange: _updateOrderStatus,
      )
    );
  }

  Widget _buildBulkStatusDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text("Cập nhật trạng thái", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
          items: <String>['Pending', 'Processing', 'In Transit', 'Completed', 'Cancelled']
              .map((value) => DropdownMenuItem(value: value, child: Text(_statusToVietnamese(value)))).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              _confirmBulkUpdate(newValue);
            }
          },
        ),
      ),
    );
  }

  void _confirmBulkUpdate(String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận cập nhật hàng loạt", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn cập nhật trạng thái cho ${_selectedIds.length} đơn hàng sang '${_statusToVietnamese(newStatus)}'?", style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _executeBulkUpdate(newStatus);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _getPrimaryGreen(context)),
            child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeBulkUpdate(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await BulkService.updateDocuments(
        collection: 'orders',
        docIds: _selectedIds.toList(),
        data: {'status': newStatus},
        module: AuditModule.orders,
        actionDescription: "Cập nhật hàng loạt trạng thái đơn hàng sang '${_statusToVietnamese(newStatus)}'",
      );
      if (mounted) {
        _showToast(context, "Đã cập nhật ${_selectedIds.length} đơn hàng thành công.");
        setState(() {
          _selectedIds.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showToast(context, "Lỗi khi cập nhật hàng loạt: $e");
        setState(() => _isLoading = false);
      }
    }
  }
}
