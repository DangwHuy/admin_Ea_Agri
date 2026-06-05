import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common/custom_admin_table.dart';
import '../../../core/widgets/common/custom_admin_badge.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';
import '../../../core/widgets/common/custom_admin_pagination.dart';
import '../models/system_log_model.dart';
import '../services/system_log_service.dart';

class SystemLogScreen extends StatefulWidget {
  const SystemLogScreen({super.key});

  @override
  State<SystemLogScreen> createState() => _SystemLogScreenState();
}

class _SystemLogScreenState extends State<SystemLogScreen> {
  final SystemLogService _service = SystemLogService();
  
  // State variables for filtering and pagination
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<String> _selectedAction = ValueNotifier<String>('Tất cả');
  final ValueNotifier<String> _selectedStatus = ValueNotifier<String>('Tất cả');
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(1);
  final int _itemsPerPage = 15;

  @override
  void dispose() {
    _searchQuery.dispose();
    _selectedAction.dispose();
    _selectedStatus.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  void _exportToCsv(List<SystemLogModel> data) {
    String csvString = '\uFEFF"Thời gian","Người thực hiện","Hành động","Chi tiết","Trạng thái"\n';
    
    for (var item in data) {
      final String timeText = DateFormat('dd/MM/yyyy HH:mm:ss').format(item.createdAt);
      csvString += '"$timeText","${item.actorName}","${item.action}","${item.details}","${item.status}"\n';
    }

    final bytes = utf8.encode(csvString);
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8;');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", "nhat_ky_he_thong_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Đang tải tệp CSV...'), backgroundColor: Theme.of(context).primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<SystemLogModel>>(
        stream: _service.getAllLogs(),
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
                valueListenable: _selectedAction,
                builder: (context, actionFilter, _) {
                  return ValueListenableBuilder<String>(
                    valueListenable: _selectedStatus,
                    builder: (context, statusFilter, _) {
                      final filteredData = allData.where((item) {
                        final matchesSearch = item.actorName.toLowerCase().contains(query.toLowerCase()) || 
                                             item.details.toLowerCase().contains(query.toLowerCase());
                        
                        bool matchesAction = false;
                        if (actionFilter == 'Tất cả') {
                          matchesAction = true;
                        } else if (actionFilter == 'Thêm') {
                          matchesAction = item.action == 'Thêm' || 
                                         item.action == 'Thêm mới' || 
                                         item.action.toUpperCase().contains('THÊM');
                        } else if (actionFilter == 'Sửa') {
                          matchesAction = item.action == 'Sửa' || 
                                         item.action == 'Cập nhật' || 
                                         item.action.toUpperCase().contains('SỬA');
                        } else {
                          matchesAction = item.action == actionFilter;
                        }

                        final matchesStatus = statusFilter == 'Tất cả' || item.status == statusFilter;
                        
                        return matchesSearch && matchesAction && matchesStatus;
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

  Widget _buildMainContent(List<SystemLogModel> data) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildToolbar(data),
          const SizedBox(height: 24),
          Expanded(child: _buildTable(data)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhật ký hệ thống',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Theo dõi và quản lý các hoạt động trên hệ thống.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      ],
    );
  }

  Widget _buildToolbar(List<SystemLogModel> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    InputDecoration pillDecoration({IconData? icon}) => InputDecoration(
      prefixIcon: icon != null ? Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color) : null,
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );

    return CustomAdminToolbar(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      children: [
        Expanded(
          flex: 5,
          child: TextField(
            onChanged: (val) {
              _searchQuery.value = val;
              _currentPage.value = 1;
            },
            decoration: pillDecoration(icon: Icons.search).copyWith(
              hintText: 'Tìm kiếm người thực hiện hoặc chi tiết...',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<String>(
            valueListenable: _selectedAction,
            builder: (context, current, _) {
              return DropdownButtonFormField<String>(
                initialValue: current,
                decoration: pillDecoration(icon: Icons.touch_app),
                items: ['Tất cả', 'Thêm', 'Sửa', 'Xóa']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: Theme.of(context).textTheme.bodySmall)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    _selectedAction.value = val;
                    _currentPage.value = 1;
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<String>(
            valueListenable: _selectedStatus,
            builder: (context, current, _) {
              return DropdownButtonFormField<String>(
                initialValue: current,
                decoration: pillDecoration(icon: Icons.check_circle_outline),
                items: ['Tất cả', 'Thành công', 'Thất bại']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: Theme.of(context).textTheme.bodySmall)))
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
        ElevatedButton.icon(
          onPressed: () => _exportToCsv(data),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Xuất CSV', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<SystemLogModel> data) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPage,
      builder: (context, page, _) {
        if (data.isEmpty) return _buildEmptyState();

        final startIndex = (page - 1) * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage > data.length ? data.length : startIndex + _itemsPerPage;
        final pageItems = data.sublist(startIndex, endIndex);

        return Column(
          children: [
            Expanded(
              child: CustomAdminTable(
                flex: const [2, 2, 2, 3, 1],
                labels: const ['Thời gian', 'Người thực hiện', 'Hành động', 'Chi tiết', 'Trạng thái'],
                itemCount: pageItems.length,
                rowBuilder: (context, index) {
                  final item = pageItems[index];
                  return [
                    // Time
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // Actor
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                          child: Text(item.actorName.isNotEmpty ? item.actorName[0].toUpperCase() : 'H', 
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            item.actorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    // Action
                    Text(item.action, style: Theme.of(context).textTheme.bodyMedium),
                    // Details
                    Tooltip(
                      message: item.details,
                      decoration: BoxDecoration(
                        color: AppColors.textHeading.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      showDuration: const Duration(seconds: 5),
                      child: Text(
                        item.details,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status
                    CustomAdminBadge(
                      text: item.status,
                      color: item.status == 'Thành công' ? Colors.green : Colors.red,
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
              label: 'bản ghi',
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
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Không có dữ liệu hiển thị', style: Theme.of(context).textTheme.bodyMedium), // color: AppColors.textMuted will be handled by bodyMedium or copyWith
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
          Text('Lỗi: $error', style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
