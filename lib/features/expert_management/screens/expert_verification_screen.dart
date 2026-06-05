import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common/custom_admin_table.dart';
import '../../../core/widgets/common/custom_admin_badge.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';
import '../../../core/widgets/common/custom_admin_pagination.dart';
import '../models/expert_verification_request_model.dart';
import '../services/expert_verification_service.dart';
import '../widgets/expert_request_detail_dialog.dart';

class ExpertVerificationScreen extends StatefulWidget {
  const ExpertVerificationScreen({super.key});

  @override
  State<ExpertVerificationScreen> createState() =>
      _ExpertVerificationScreenState();
}

class _ExpertVerificationScreenState extends State<ExpertVerificationScreen> {
  final ExpertVerificationService _service = ExpertVerificationService();

  // State variables for filtering and pagination
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<String> _selectedStatus = ValueNotifier<String>(
    'Lọc theo trạng thái',
  );
  final ValueNotifier<DateTimeRange?> _selectedDateRange =
      ValueNotifier<DateTimeRange?>(null);
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(1);
  final int _itemsPerPage = 10;

  @override
  void dispose() {
    _searchQuery.dispose();
    _selectedStatus.dispose();
    _selectedDateRange.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  void _showDetailDialog(ExpertVerificationRequestModel request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExpertRequestDetailDialog(
        request: request,
        onProcessed: () {
          // Stream updates automatically
        },
      ),
    );
  }

  void _exportToCsv(List<ExpertVerificationRequestModel> data) {
    String csvString =
        '\uFEFF"Họ tên","Số điện thoại","Chuyên môn","Trạng thái","Ngày gửi"\n';

    for (var item in data) {
      final String statusText = _getStatusText(item.status);
      final String dateText = DateFormat('dd/MM/yyyy').format(item.createdAt);
      final String phoneFormatted = '="""${item.phone}"""';

      csvString +=
          '"${item.fullName}",$phoneFormatted,"${item.expertise}","$statusText","$dateText"\n';
    }

    final bytes = utf8.encode(csvString);
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8;');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute(
        "download",
        "danh_sach_chuyen_gia_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv",
      )
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang tải tệp CSV...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Đã từ chối';
      default:
        return 'Chờ duyệt';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<ExpertVerificationRequestModel>>(
        stream: _service.getAllRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildErrorState(snapshot.error);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allData = snapshot.data ?? [];

          return ValueListenableBuilder<String>(
            valueListenable: _searchQuery,
            builder: (context, query, _) {
              return ValueListenableBuilder<String>(
                valueListenable: _selectedStatus,
                builder: (context, statusFilter, _) {
                  return ValueListenableBuilder<DateTimeRange?>(
                    valueListenable: _selectedDateRange,
                    builder: (context, dateRange, _) {
                      final filteredData = allData.where((item) {
                        final matchesSearch =
                            item.fullName.toLowerCase().contains(
                              query.toLowerCase(),
                            ) ||
                            item.expertise.toLowerCase().contains(
                              query.toLowerCase(),
                            );
                        final matchesStatus =
                            statusFilter == 'Lọc theo trạng thái' ||
                            _getStatusText(item.status) == statusFilter;

                        bool matchesDate = true;
                        if (dateRange != null) {
                          // Lọc bao gồm cả ngày kết thúc (đến 23:59:59)
                          final startDate = DateTime(
                            dateRange.start.year,
                            dateRange.start.month,
                            dateRange.start.day,
                          );
                          final endDate = DateTime(
                            dateRange.end.year,
                            dateRange.end.month,
                            dateRange.end.day,
                            23,
                            59,
                            59,
                          );
                          matchesDate =
                              item.createdAt.isAfter(
                                startDate.subtract(const Duration(seconds: 1)),
                              ) &&
                              item.createdAt.isBefore(
                                endDate.add(const Duration(seconds: 1)),
                              );
                        }

                        return matchesSearch && matchesStatus && matchesDate;
                      }).toList();

                      return _buildMainContent(filteredData);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMainContent(List<ExpertVerificationRequestModel> data) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(data),
          const SizedBox(height: 24),
          _buildToolbar(data),
          const SizedBox(height: 24),
          Expanded(child: _buildTable(data)),
        ],
      ),
    );
  }

  Widget _buildHeader(List<ExpertVerificationRequestModel> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duyệt chuyên gia',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Xem và quản lý các yêu cầu xác minh từ các chuyên gia.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Chọn khoảng thời gian',
      saveText: 'Chọn',
      cancelText: 'Hủy',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _selectedDateRange.value = picked;
      _currentPage.value = 1;
    }
  }

  Widget _buildToolbar(List<ExpertVerificationRequestModel> data) {
    return CustomAdminToolbar(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      children: [
        // Column 1 & 2: Search (Flex 3 + 3 = 6)
        Expanded(
          flex: 6,
          child: TextField(
            onChanged: (val) {
              _searchQuery.value = val;
              _currentPage.value = 1;
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm chuyên gia...',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurfaceVariant
                  : Colors.white.withValues(alpha: 0.3),
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
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Column 3: Status Filter (Flex 2)
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<String>(
            valueListenable: _selectedStatus,
            builder: (context, current, _) {
              return DropdownButtonFormField<String>(
                value: current,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.filter_list_rounded,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurfaceVariant
                      : Colors.white.withValues(alpha: 0.3),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                ),
                items:
                    [
                          'Lọc theo trạng thái',
                          'Chờ duyệt',
                          'Đã duyệt',
                          'Đã từ chối',
                        ]
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    _selectedStatus.value = val;
                    _currentPage.value = 1;
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        // Column 4: Date Filter (Flex 2)
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<DateTimeRange?>(
            valueListenable: _selectedDateRange,
            builder: (context, range, _) {
              return InkWell(
                onTap: _selectDateRange,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurfaceVariant
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          range == null
                              ? 'Lọc theo ngày'
                              : '${DateFormat('dd/MM').format(range.start)} - ${DateFormat('dd/MM').format(range.end)}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (range != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 14),
                          onPressed: () => _selectedDateRange.value = null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        // Column 5: Export Button (Flex 1)
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _exportToCsv(data),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Xuất file'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<ExpertVerificationRequestModel> data) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPage,
      builder: (context, page, _) {
        final startIndex = (page - 1) * _itemsPerPage;
        if (data.isEmpty) return _buildEmptyState();

        final endIndex = startIndex + _itemsPerPage > data.length
            ? data.length
            : startIndex + _itemsPerPage;
        final pageItems = data.sublist(startIndex, endIndex);

        return Column(
          children: [
            Expanded(
              child: CustomAdminTable(
                flex: const [3, 3, 2, 2, 1],
                labels: const [
                  'Họ tên',
                  'Lĩnh vực',
                  'Trạng thái',
                  'Ngày gửi',
                  'Thao tác',
                ],
                itemCount: pageItems.length,
                onRowTapWithIndex: (index) =>
                    _showDetailDialog(pageItems[index]),
                rowBuilder: (context, index) {
                  final item = pageItems[index];
                  return [
                    // Name
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            item.fullName.isNotEmpty
                                ? item.fullName[0].toUpperCase()
                                : '?',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.fullName,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                item.phone,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text(
                          item.expertise,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurfaceVariant
                            : Colors.white.withValues(alpha: 0.4),
                        side: BorderSide.none,
                      ),
                    ),
                    // Status
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomAdminBadge(
                        text: _getStatusText(item.status),
                        color: _getStatusColor(item.status),
                      ),
                    ),
                    // Date
                    Text(
                      DateFormat('dd/MM/yyyy').format(item.createdAt),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // Actions
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.visibility_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: () => _showDetailDialog(item),
                        tooltip: 'Xem chi tiết',
                      ),
                    ),
                  ];
                },
              ),
            ),
            const SizedBox(height: 24),
            CustomAdminPagination(
              totalItems: data.length,
              itemsPerPage: _itemsPerPage,
              currentPage: page,
              onPageChanged: (val) => _currentPage.value = val,
              label: 'yêu cầu',
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy yêu cầu nào',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Lỗi: $error',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
