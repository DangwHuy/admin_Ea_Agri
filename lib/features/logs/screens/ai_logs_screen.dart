import 'package:flutter/material.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';
import 'package:admin_daklak_web/features/auth/services/admin_service.dart';
import 'package:admin_daklak_web/features/reports/services/export_service.dart';
import '../../../core/widgets/common/glass_container.dart';
import '../../../core/widgets/common/custom_admin_table.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';

Color _getTextGrey(BuildContext context) => Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280);

class AiLogsScreen extends StatefulWidget {
  const AiLogsScreen({super.key});

  @override
  State<AiLogsScreen> createState() => _AiLogsScreenState();
}

class _AiLogsScreenState extends State<AiLogsScreen> {
  final ExportService _exportService = ExportService();
  int _currentTabIndex = 0; // 0: Tất cả, 1: Có lỗi
  String _searchQuery = "";
  DateTimeRange? _selectedDateRange;

  int _currentPage = 0;
  final int _rowsPerPage = 8;
  bool _isExporting = false;

  // Cached data
  List<QueryDocumentSnapshot> _chatDocs = [];
  StreamSubscription? _chatSub;
  String? _chatError;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  void _initStreams() {
    _chatSub = FirebaseFirestore.instance
        .collection('ai_chat_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snap) {
        if (mounted) setState(() { _chatDocs = snap.docs; _chatError = null; });
      },
      onError: (err) {
        if (mounted) setState(() => _chatError = err.toString());
      },
    );
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _currentPage = 0;
      });
    }
  }

  void _handleExport() async {
    List<QueryDocumentSnapshot> sourceDocs = _chatDocs;
    
    List<QueryDocumentSnapshot> filteredDocs;
    
    Map<String, int> promptCounts = {};
    for (var doc in sourceDocs) {
      var d = doc.data() as Map<String, dynamic>? ?? {};
      String key = "${d['userId'] ?? d['userEmail']}_${(d['prompt'] ?? '').toString().trim().toLowerCase()}";
      promptCounts[key] = (promptCounts[key] ?? 0) + 1;
    }
    filteredDocs = _getFilteredChatDocs(sourceDocs, promptCounts);

    if (filteredDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không có dữ liệu để xuất!")));
      return;
    }

    setState(() => _isExporting = true);
    
    try {
      final List<Map<String, dynamic>> exportData = filteredDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return { ...data, 'id': doc.id, 'timestamp': _parseDateTime(data['timestamp']) };
      }).toList();
      
      String fileName = _currentTabIndex == 1 ? "Danh_Sach_Loi_AI" : "Toan_Bo_Chat_AI";
      _exportService.exportAiChatLogsToCsv(exportData, fileName);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang khởi tạo tải xuống...")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi khi chuẩn bị dữ liệu: $e")));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  bool _matchDate(dynamic timestamp) {
    if (_selectedDateRange == null) return true;
    DateTime? time = _parseDateTime(timestamp);
    if (time == null) return false;
    DateTime start = _selectedDateRange!.start;
    DateTime end = _selectedDateRange!.end.add(const Duration(days: 1));
    return time.isAfter(start) && time.isBefore(end);
  }

  void _toggleFlag(String docId, bool currentFlag, String userId, String prompt) {
    FirebaseFirestore.instance.collection('ai_chat_logs').doc(docId).update({
      'isFlagged': !currentFlag
    });

    AdminService.logAction(
        action: !currentFlag ? "Đánh dấu lỗi AI" : "Gỡ đánh dấu lỗi AI",
        target: "User ID: $userId | Câu hỏi: ${prompt.characters.take(30)}..."
    );
  }

  void _showDetailDialog(Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Chi tiết Chat", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text("Hỏi:\n${data['prompt'] ?? '--'}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Text("AI Trả lời:\n${data['response'] ?? '--'}"),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Đóng", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary))
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNameFromEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return "Người dùng";
    String namePart = email.split('@')[0];
    return namePart.substring(0, 1).toUpperCase() + namePart.substring(1);
  }

  DateTime? _parseDateTime(dynamic timestampData) {
    if (timestampData == null) return null;
    if (timestampData is Timestamp) return timestampData.toDate();
    if (timestampData is String) return DateTime.tryParse(timestampData);
    return null;
  }

  List<QueryDocumentSnapshot> _getFilteredChatDocs(List<QueryDocumentSnapshot> allDocs, Map<String, int> promptCounts) {
    return allDocs.where((doc) {
      var data = doc.data() as Map<String, dynamic>? ?? {};

      String userId = (data['userId'] ?? '').toString().toLowerCase();
      String email = (data['userEmail'] ?? '').toString().toLowerCase();
      String docId = doc.id.toLowerCase();
      String category = (data['category_tag'] ?? '').toString().toLowerCase();
      bool matchSearch = userId.contains(_searchQuery) || email.contains(_searchQuery) || docId.contains(_searchQuery) || category.contains(_searchQuery);

      if (!matchSearch || !_matchDate(data['timestamp'])) return false;

      if (_currentTabIndex == 1) {
        String key = "${data['userId'] ?? data['userEmail']}_${(data['prompt'] ?? '').toString().trim().toLowerCase()}";
        bool isError = data['status'] == 'error';
        bool isFlagged = data['isFlagged'] == true;
        bool isRepeated = (promptCounts[key] ?? 0) > 3;
        return isError || isFlagged || isRepeated;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch sử & Theo dõi Hệ thống',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Thống kê và quản lý hoạt động của trợ lý tương tác AI.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
            const SizedBox(height: 32),

            _buildFirestoreStats(),
            const SizedBox(height: 32),

            CustomAdminToolbar(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                        _currentPage = 0;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm theo ID, Email, Hành động...',
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color),
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
                  child: DropdownButtonFormField<int>(
                    initialValue: _currentTabIndex,
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
                      DropdownMenuItem(value: 0, child: Text("Tất cả Chat AI", style: Theme.of(context).textTheme.bodySmall)),
                      DropdownMenuItem(value: 1, child: Text("Câu trả lời cần xem xét (Lỗi)", style: Theme.of(context).textTheme.bodySmall)),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _currentTabIndex = val!;
                        _currentPage = 0;
                      });
                    },
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
                        onPressed: _pickDateRange,
                      ),
                      if (_selectedDateRange != null)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 18),
                          onPressed: () => setState(() {
                            _selectedDateRange = null;
                            _currentPage = 0;
                          }),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: (!_isExporting && _chatDocs.isNotEmpty) ? _handleExport : null,
                      icon: _isExporting 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                      label: Text(
                          _isExporting ? "Đang xử lý..." : "Xuất File CSV",
                          style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildChatTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirestoreStats() {
    if (_chatError != null) return Text("Lỗi tải thống kê: $_chatError", style: const TextStyle(color: Colors.red));
    if (_chatDocs.isEmpty) return const SizedBox(height: 104, child: Center(child: CircularProgressIndicator()));

    var allChatDocs = _chatDocs;
    int totalLogs = allChatDocs.length;

    Map<String, int> userPromptCounts = {};
    for (var doc in allChatDocs) {
      var d = doc.data() as Map<String, dynamic>? ?? {};
      String key = "${d['userId'] ?? d['userEmail']}_${(d['prompt'] ?? '').toString().trim().toLowerCase()}";
      userPromptCounts[key] = (userPromptCounts[key] ?? 0) + 1;
    }

    int failedCount = allChatDocs.where((doc) {
      var d = doc.data() as Map<String, dynamic>? ?? {};
      String key = "${d['userId'] ?? d['userEmail']}_${(d['prompt'] ?? '').toString().trim().toLowerCase()}";
      return d['status'] == 'error' || d['isFlagged'] == true || (userPromptCounts[key] ?? 0) > 3;
    }).length;

    int successCount = totalLogs - failedCount;

    return Row(
      children: [
        Expanded(child: _buildStatCard('Tổng số Log', NumberFormat('#,###').format(totalLogs), Icons.bar_chart, Colors.green.withValues(alpha: 0.1), Colors.green)),
        const SizedBox(width: 24),
        Expanded(child: _buildStatCard('Cần huấn luyện AI', NumberFormat('#,###').format(failedCount), Icons.psychology, Colors.orange.withValues(alpha: 0.1), Colors.orange)),
        const SizedBox(width: 24),
        Expanded(child: _buildStatCard('Log thành công', NumberFormat('#,###').format(successCount), Icons.check_circle, Colors.teal.withValues(alpha: 0.1), Colors.teal)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color bg, Color iconColor) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: iconColor, size: 30)),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getTextGrey(context))),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary)),
          ])
        ],
      ),
    );
  }

  Widget _buildChatTable() {
    if (_chatError != null) return _buildErrorMessage("Lỗi tải Chat: $_chatError");
    if (_chatDocs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));

    var allDocs = _chatDocs;
    Map<String, int> promptCounts = {};
    for (var doc in allDocs) {
      var d = doc.data() as Map<String, dynamic>? ?? {};
      String key = "${d['userId'] ?? d['userEmail']}_${(d['prompt'] ?? '').toString().trim().toLowerCase()}";
      promptCounts[key] = (promptCounts[key] ?? 0) + 1;
    }

    var filteredDocs = _getFilteredChatDocs(allDocs, promptCounts);

    int totalItems = filteredDocs.length;
    int totalPages = (totalItems / _rowsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
    if (_currentPage >= totalPages) _currentPage = max(0, totalPages - 1);

    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = min(startIndex + _rowsPerPage, totalItems);
    var pagedDocs = totalItems == 0 ? <QueryDocumentSnapshot>[] : filteredDocs.sublist(startIndex, endIndex);

    if (totalItems == 0) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0x441E2538) : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06), width: 1.5),
        ),
        child: const Center(child: Text("Không có dữ liệu phù hợp.")),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: (pagedDocs.length * 90).clamp(400, 1000) + 70.0,
          child: CustomAdminTable(
            flex: const [2, 2, 3, 2, 4, 1],
            labels: const ['THỜI GIAN', 'ID CHAT', 'NGƯỜI DÙNG', 'CHỦ ĐỀ', 'NỘI DUNG', 'HÀNH ĐỘNG'],
            itemCount: pagedDocs.length,
            rowBuilder: (context, index) {
              var doc = pagedDocs[index];
              var data = doc.data() as Map<String, dynamic>? ?? {};

              DateTime? time = _parseDateTime(data['timestamp']);
              String timeStr = time != null ? "${DateFormat('HH:mm').format(time)},\n${DateFormat('dd/MM').format(time)}" : "--";

              String chatId = doc.id.substring(0, 8).toUpperCase();
              String email = data['userEmail'] ?? '';
              String displayName = _getNameFromEmail(email);
              String userIdDisplay = data['userId']?.toString() ?? 'UID-${doc.id.substring(0, 5).toUpperCase()}';

              String promptText = (data['prompt'] ?? '').toString().trim();
              String displayPrompt = promptText.isNotEmpty ? '"$promptText"' : '--';

              bool isFlagged = data['isFlagged'] == true;
              final bool isDark = Theme.of(context).brightness == Brightness.dark;

              return [
                Text(timeStr, style: const TextStyle(fontSize: 13, height: 1.4)),
                Text("#$chatId", style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 16, backgroundColor: isDark ? Colors.blueGrey[800] : Colors.blueGrey[100], child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U', style: TextStyle(color: isDark ? Colors.blueGrey[200] : Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 14))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                          Text('ID: $userIdDisplay', style: TextStyle(color: _getTextGrey(context), fontSize: 12), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFFD96B40).withValues(alpha: 0.2) : const Color(0xFFFBE4D7).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                    child: Text(data['category_tag'] ?? 'Khác', style: TextStyle(color: isDark ? Colors.orange[300] : const Color(0xFFD96B40), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                Text(displayPrompt, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontStyle: FontStyle.italic, color: _getTextGrey(context), fontSize: 13)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: Icon(Icons.remove_red_eye, color: _getTextGrey(context), size: 20), onPressed: () => _showDetailDialog(data), padding: const EdgeInsets.all(4), constraints: const BoxConstraints()),
                      IconButton(icon: Icon(isFlagged ? Icons.flag : Icons.flag_outlined, color: isFlagged ? Colors.red : _getTextGrey(context), size: 20), onPressed: () => _toggleFlag(doc.id, data['isFlagged'] == true, userIdDisplay, data['prompt'] ?? ''), padding: const EdgeInsets.all(4), constraints: const BoxConstraints()),
                    ],
                  ),
                ),
              ];
            },
          ),
        ),
        _buildTableFooter(totalItems, totalPages),
      ],
    );
  }

  Widget _buildErrorMessage(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(msg, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text("Vui lòng kiểm tra index Firestore hoặc quyền truy cập.", style: TextStyle(fontSize: 12, color: _getTextGrey(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildTableFooter(int total, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Row(
        children: [
          Text('Hiển thị ${total == 0 ? 0 : _currentPage * _rowsPerPage + 1} - ${min((_currentPage + 1) * _rowsPerPage, total)} trong $total kết quả', style: TextStyle(color: _getTextGrey(context), fontSize: 13)),
          const Spacer(),
          _pageBox(Icons.chevron_left, enabled: _currentPage > 0, onTap: () => setState(() => _currentPage--)),
          ...List.generate(totalPages, (index) {
            if (totalPages > 5 && (index > _currentPage + 1 || index < _currentPage - 1) && index != 0 && index != totalPages - 1) {
              if (index == 1 || index == totalPages - 2) return const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('...'));
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
}