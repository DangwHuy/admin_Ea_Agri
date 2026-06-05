import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common/glass_container.dart';
import '../../../core/widgets/common/custom_admin_table.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';
import '../models/audit_log_model.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<AuditLogModel> _logs = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  AuditModule? _selectedModule;
  DateTimeRange? _selectedDateRange;
  final TextEditingController _adminSearchController = TextEditingController();

  // Pagination
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  @override
  void dispose() {
    _adminSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Query query = _firestore.collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(50);

      if (_selectedModule != null) {
        query = query.where('module', isEqualTo: _selectedModule!.name);
      }

      if (_selectedDateRange != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: _selectedDateRange!.start);
        query = query.where('timestamp', isLessThanOrEqualTo: _selectedDateRange!.end.add(const Duration(days: 1)));
      }

      final snapshot = await query.get();
      
      List<AuditLogModel> fetchedLogs = snapshot.docs
          .map((doc) => AuditLogModel.fromFirestore(doc))
          .toList();

      if (_adminSearchController.text.isNotEmpty) {
        String search = _adminSearchController.text.toLowerCase();
        fetchedLogs = fetchedLogs.where((log) => 
          log.adminEmail.toLowerCase().contains(search) || 
          log.adminId.toLowerCase().contains(search)
        ).toList();
      }

      setState(() {
        _logs = fetchedLogs;
        _isLoading = false;
        _currentPage = 0;
      });
    } catch (e) {
      setState(() {
        _error = "Lỗi khi tải nhật ký: $e";
        _isLoading = false;
      });
    }
  }

  void _showDetailDialog(AuditLogModel log) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Chi tiết thao tác", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 24),
                  _detailRow("ID Nhật ký", log.id),
                  _detailRow("Thời gian", DateFormat('dd/MM/yyyy HH:mm:ss').format(log.timestamp)),
                  _detailRow("Quản trị viên", log.adminEmail),
                  _detailRow("ID Quản trị", log.adminId),
                  _detailRow("Địa chỉ IP", log.ipAddress),
                  Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]),
                  _detailRow("Tính năng", log.module.label),
                  _detailRow("Hành động", log.actionType.label),
                  _detailRow("Mô tả", log.description),
                  const SizedBox(height: 16),
                  Text("Dữ liệu chi tiết (JSON):", style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: SelectableText(
                      log.details != null ? const JsonEncoder.withIndent('  ').convert(log.details) : "Không có dữ liệu chi tiết.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.blueGrey[200] : Colors.blueGrey[800]),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Đóng", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text("$label:", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13))),
        ],
      ),
    );
  }

  Color _getActionColor(AuditActionType type) {
    switch (type) {
      case AuditActionType.create: return Colors.green;
      case AuditActionType.update: return Colors.blue;
      case AuditActionType.delete: return Theme.of(context).colorScheme.error;
      case AuditActionType.login: return Colors.teal;
      case AuditActionType.export: return Colors.orange;
      case AuditActionType.security: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nhật ký hệ thống", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text("Theo dõi hoạt động bảo mật và thay đổi dữ liệu.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _fetchLogs,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Làm mới", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Toolbar
            CustomAdminToolbar(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: _adminSearchController,
                    onSubmitted: (_) => _fetchLogs(),
                    decoration: InputDecoration(
                      hintText: 'Tìm Quản trị viên (Email/ID)...',
                      prefixIcon: Icon(Icons.person_search, color: Theme.of(context).textTheme.bodySmall?.color),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<AuditModule?>(
                    initialValue: _selectedModule,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.filter_alt, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    items: [
                      DropdownMenuItem<AuditModule?>(value: null, child: Text("Tất cả tính năng", style: Theme.of(context).textTheme.bodySmall)),
                      ...AuditModule.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label, style: Theme.of(context).textTheme.bodySmall))),
                    ],
                    onChanged: (val) => setState(() => _selectedModule = val),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: _selectedDateRange != null ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.calendar_month, color: _selectedDateRange == null ? Theme.of(context).textTheme.bodySmall?.color : AppColors.primary),
                        onPressed: () async {
                          final picked = await showDateRangePicker(context: context, firstDate: DateTime(2023), lastDate: DateTime.now());
                          if (picked != null) {
                            setState(() => _selectedDateRange = picked);
                          }
                        },
                      ),
                      if (_selectedDateRange != null)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 18),
                          onPressed: () => setState(() => _selectedDateRange = null),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _fetchLogs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text("Áp dụng", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table Content
            if (_isLoading)
              const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              _buildErrorState()
            else if (_logs.isEmpty)
              _buildEmptyState()
            else
              _buildLogTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTable() {
    int totalItems = _logs.length;
    int totalPages = (totalItems / _rowsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
    if (_currentPage >= totalPages) _currentPage = totalPages - 1;

    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = (startIndex + _rowsPerPage).clamp(0, totalItems);
    var pagedLogs = _logs.sublist(startIndex, endIndex);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: (pagedLogs.length * 80).clamp(400, 900) + 70.0,
          child: CustomAdminTable(
            flex: const [2, 3, 2, 2, 3, 1, 1],
            labels: const ['THỜI GIAN', 'QUẢN TRỊ VIÊN', 'HÀNH ĐỘNG', 'TÍNH NĂNG', 'MÔ TẢ', 'IP', ''],
            itemCount: pagedLogs.length,
            rowBuilder: (context, index) {
              final log = pagedLogs[index];
              final actionColor = _getActionColor(log.actionType);

              return [
                // Time
                Text(
                  DateFormat('dd/MM/yyyy\nHH:mm').format(log.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.4),
                ),
                // Admin
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        log.adminEmail.isNotEmpty ? log.adminEmail[0].toUpperCase() : 'A',
                        style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(log.adminEmail, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary), overflow: TextOverflow.ellipsis),
                          Text("ID: ${log.adminId.length > 6 ? log.adminId.substring(0, 6) : log.adminId}...", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: isDark ? AppColors.darkTextMuted : Colors.grey), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                // Action Badge
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? actionColor.withValues(alpha: 0.2) : actionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (log.module == AuditModule.users)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.admin_panel_settings, size: 10, color: AppColors.primary),
                          ),
                        Flexible(
                          child: Text(log.actionType.label, style: TextStyle(color: isDark ? actionColor.withValues(alpha: 0.8) : actionColor, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ),
                // Module
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: log.module == AuditModule.users ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.05) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.module.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: log.module == AuditModule.users ? FontWeight.bold : FontWeight.normal,
                        color: log.module == AuditModule.users ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                // Description
                Tooltip(
                  message: log.description,
                  child: Text(log.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
                ),
                // IP
                Text(log.ipAddress, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: isDark ? AppColors.darkTextMuted : Colors.grey)),
                // Action
                IconButton(icon: Icon(Icons.info_outline, size: 20, color: isDark ? AppColors.darkTextMuted : Colors.grey), onPressed: () => _showDetailDialog(log)),
              ];
            },
          ),
        ),
        _buildTableFooter(totalItems, totalPages),
      ],
    );
  }

  Widget _buildTableFooter(int total, int totalPages) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Row(
        children: [
          Text(
            'Hiển thị ${total == 0 ? 0 : _currentPage * _rowsPerPage + 1} - ${(_currentPage + 1) * _rowsPerPage > total ? total : (_currentPage + 1) * _rowsPerPage} trong $total kết quả',
            style: TextStyle(color: isDark ? AppColors.darkTextMuted : Colors.grey, fontSize: 13),
          ),
          const Spacer(),
          _pageBox(Icons.chevron_left, enabled: _currentPage > 0, onTap: () => setState(() => _currentPage--)),
          ...List.generate(totalPages, (index) {
            if (totalPages > 5 && (index > _currentPage + 1 || index < _currentPage - 1) && index != 0 && index != totalPages - 1) {
              if (index == 1 || index == totalPages - 2) {
                return const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('...'));
              }
              return const SizedBox();
            }
            return _pageBox('${index + 1}', active: _currentPage == index, onTap: () => setState(() => _currentPage = index));
          }),
          _pageBox(Icons.chevron_right, enabled: _currentPage < totalPages - 1, onTap: () => setState(() => _currentPage++)),
        ],
      ),
    );
  }

  Widget _pageBox(dynamic content, {bool active = false, bool enabled = true, VoidCallback? onTap}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: active ? AppColors.primary : Theme.of(context).dividerColor),
        ),
        child: Center(
          child: content is IconData
              ? Icon(content, size: 18, color: enabled ? (active ? Colors.white : Theme.of(context).textTheme.bodySmall?.color) : Colors.grey)
              : Text(content.toString(), style: TextStyle(color: active ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text("Không tìm thấy nhật ký nào phù hợp.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text("Vui lòng kiểm tra index Firestore hoặc quyền truy cập.", style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
          ],
        ),
      ),
    );
  }
}
