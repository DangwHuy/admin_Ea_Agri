import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_daklak_web/features/logs/services/bulk_service.dart';
import 'package:admin_daklak_web/features/logs/widgets/bulk_action_bar.dart';
import 'package:admin_daklak_web/features/logs/models/audit_log_model.dart';
import '../../../core/constants/app_colors.dart';
import 'package:admin_daklak_web/core/constants/app_text_styles.dart';
import '../../../core/widgets/common/glass_container.dart';
import '../../../core/widgets/common/custom_admin_table.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';
import '../../../core/widgets/common/custom_admin_badge.dart';

class DiseaseManagerScreen extends StatefulWidget {
  const DiseaseManagerScreen({super.key});

  @override
  State<DiseaseManagerScreen> createState() => _DiseaseManagerScreenState();
}

class _DiseaseManagerScreenState extends State<DiseaseManagerScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  final Set<String> _selectedIds = {};

  // Variables cho Search, Filter, View State và Pagination
  String _searchQuery = '';
  Timer? _debounce;
  String _selectedFilterType = 'Tất cả';
  String _sortBy = 'Mới nhất';
  bool _isViewingPending = false;

  // Variables cho Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 8; // Số item hiển thị trên 1 trang giống thiết kế

  static const List<String> _types = [
    'Tất cả',
    'Côn trùng',
    'Nấm',
    'Vi-rút',
    'Khác',
  ];
  static const List<String> _sortOptions = ['Mới nhất', 'Mức độ nguy hiểm'];

  List<String> _stringToList(String input) {
    if (input.isEmpty) return [];
    return input
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        _currentPage = 1; // Reset về trang 1 khi search
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // =========================================================================
  // LOGIC THÊM/SỬA SÂU BỆNH
  // =========================================================================
  void _showDiseaseFormDialog({DocumentSnapshot? existingDoc}) {
    final bool isEditing = existingDoc != null;
    final data = isEditing ? existingDoc.data() as Map<String, dynamic> : {};

    final nameController = TextEditingController(text: data['name'] ?? '');
    final seasonController = TextEditingController(text: data['season'] ?? '');
    final emergencyController = TextEditingController(
      text: data['emergency_level'] ?? '',
    );
    final affectedPartsController = TextEditingController(
      text: (data['affected_parts'] as List? ?? []).join(', '),
    );
    final symptomsController = TextEditingController(
      text: (data['symptoms'] as List? ?? []).join('\n'),
    );
    final treatmentController = TextEditingController(
      text: (data['treatment'] as List? ?? []).join('\n'),
    );
    final preventionController = TextEditingController(
      text: (data['prevention'] as List? ?? []).join('\n'),
    );
    final tagsController = TextEditingController(
      text: (data['tags'] as List? ?? []).join(', '),
    );

    String selectedType = data['type'] ?? 'Nấm';
    if (!_types.contains(selectedType) && selectedType != 'Tất cả') {
      selectedType = 'Khác';
    }

    bool isActive = data['isActive'] ?? true;

    String? existingImageUrl = data['imageUrl'];
    Uint8List? newImageBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          InputDecoration glassInputDecoration(String label) {
            return InputDecoration(
              labelText: label,
              labelStyle: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 13),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            );
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: GlassContainer(
              padding: const EdgeInsets.all(32),
              child: SizedBox(
                width: 700,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing
                            ? 'Chỉnh sửa: ${data['name']}'
                            : 'Thêm Sâu bệnh Mới',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () async {
                          final XFile? image = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setStateDialog(() => newImageBytes = bytes);
                          }
                        },
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: newImageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.memory(
                                    newImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (existingImageUrl != null &&
                                        existingImageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          existingImageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                      )),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: glassInputDecoration('Tên bệnh'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Switch(
                                value: isActive,
                                onChanged: (val) =>
                                    setStateDialog(() => isActive = val),
                                activeTrackColor: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isActive
                                    ? "Đã duyệt (Đang hiển thị)"
                                    : "Chờ xử lý (Đang ẩn)",
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: isActive
                                          ? AppColors.primary
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedType,
                              decoration: glassInputDecoration('Loại'),
                              items: ['Côn trùng', 'Nấm', 'Vi-rút', 'Khác']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setStateDialog(() => selectedType = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: seasonController,
                              decoration: glassInputDecoration(
                                'Mùa vụ (VD: Mùa mưa)',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: emergencyController,
                              decoration: glassInputDecoration(
                                'Mức độ khẩn cấp',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: affectedPartsController,
                              decoration: glassInputDecoration(
                                'Bộ phận bị hại (cách bởi dấu phẩy)',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: symptomsController,
                        maxLines: 4,
                        decoration: glassInputDecoration(
                          'Triệu chứng (mỗi dòng 1 ý)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: treatmentController,
                        maxLines: 4,
                        decoration: glassInputDecoration(
                          'Cách điều trị (mỗi dòng 1 ý)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: preventionController,
                        maxLines: 4,
                        decoration: glassInputDecoration(
                          'Cách phòng ngừa (mỗi dòng 1 ý)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: tagsController,
                        decoration: glassInputDecoration(
                          'Tags từ khóa (cách bởi dấu phẩy)',
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Hủy',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setStateDialog(() => _isLoading = true);
                                    try {
                                      String finalImageUrl =
                                          existingImageUrl ?? '';
                                      if (newImageBytes != null) {
                                        String fileName =
                                            'pest_diseases/${DateTime.now().millisecondsSinceEpoch}.png';
                                        TaskSnapshot snapshot =
                                            await FirebaseStorage.instance
                                                .ref(fileName)
                                                .putData(newImageBytes!);
                                        finalImageUrl = await snapshot.ref
                                            .getDownloadURL();
                                      }

                                      Map<String, dynamic> diseaseData = {
                                        'name': nameController.text.trim(),
                                        'type': selectedType,
                                        'season': seasonController.text.trim(),
                                        'emergency_level': emergencyController
                                            .text
                                            .trim(),
                                        'isActive': isActive,
                                        'affected_parts': _stringToList(
                                          affectedPartsController.text,
                                        ),
                                        'symptoms': _stringToList(
                                          symptomsController.text,
                                        ),
                                        'treatment': _stringToList(
                                          treatmentController.text,
                                        ),
                                        'prevention': _stringToList(
                                          preventionController.text,
                                        ),
                                        'tags': _stringToList(
                                          tagsController.text,
                                        ),
                                        'imageUrl': finalImageUrl,
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      };

                                      if (isEditing) {
                                        await existingDoc.reference.update(
                                          diseaseData,
                                        );
                                      } else {
                                        diseaseData['createdAt'] =
                                            FieldValue.serverTimestamp();
                                        await _firestore
                                            .collection('pest_diseases')
                                            .add(diseaseData);
                                      }

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } finally {
                                      setStateDialog(() => _isLoading = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Lưu dữ liệu',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // LOGIC XÓA SÂU BỆNH
  // =========================================================================
  Future<void> _deleteDisease(DocumentSnapshot doc) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${doc['name']}" không? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Xóa vĩnh viễn',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _isLoading = true);
        final data = doc.data() as Map<String, dynamic>;

        if (data['imageUrl'] != null &&
            data['imageUrl'].toString().contains('firebase')) {
          try {
            await FirebaseStorage.instance
                .refFromURL(data['imageUrl'])
                .delete();
          } catch (e) {
            debugPrint("Lỗi khi xóa ảnh: $e");
          }
        }
        await doc.reference.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa dữ liệu thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // =========================================================================
  // GIAO DIỆN CHÍNH
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('pest_diseases').snapshots(),
          builder: (context, pestSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('ai_chat_logs').snapshots(),
              builder: (context, aiSnapshot) {
                if (!pestSnapshot.hasData || !aiSnapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }

                final pestDocs = pestSnapshot.data!.docs;
                final aiDocs = aiSnapshot.data!.docs;

                // ====================================================================
                // 1. TÍNH TOÁN DỮ LIỆU THẬT
                // ====================================================================

                final now = DateTime.now();
                final sevenDaysAgo = now.subtract(const Duration(days: 7));

                int totalPests = pestDocs.length;
                int newIn7Days = 0;
                int treatableCount = 0;
                int untreatableCount = 0;

                for (var doc in pestDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['createdAt'] != null) {
                    final createdAtDate = (data['createdAt'] as Timestamp)
                        .toDate();
                    if (createdAtDate.isAfter(sevenDaysAgo)) newIn7Days++;
                  }
                  final treatment = data['treatment'] as List?;
                  if (treatment != null && treatment.isNotEmpty) {
                    treatableCount++;
                  } else {
                    untreatableCount++;
                  }
                }

                double treatableRate = totalPests == 0
                    ? 0
                    : (treatableCount / totalPests * 100);
                double untreatableRate = totalPests == 0
                    ? 0
                    : (untreatableCount / totalPests * 100);

                // --- Dữ liệu Hàng Phân Tích ---
                Map<String, int> typeCounts = {
                  'Côn trùng': 0,
                  'Nấm': 0,
                  'Vi-rút': 0,
                  'Vi khuẩn': 0,
                  'Khác': 0,
                };
                for (var doc in pestDocs) {
                  String type =
                      (doc.data() as Map<String, dynamic>)['type'] ?? 'Khác';
                  if (type.toLowerCase().contains('côn trùng')) {
                    type = 'Côn trùng';
                  } else if (type.toLowerCase().contains('nấm')) {
                    type = 'Nấm';
                  } else if (type.toLowerCase().contains('vi-rút') ||
                      type.toLowerCase().contains('virus')) {
                    type = 'Vi-rút';
                  } else if (type.toLowerCase().contains('vi khuẩn')) {
                    type = 'Vi khuẩn';
                  } else {
                    type = 'Khác';
                  }

                  typeCounts[type] = (typeCounts[type] ?? 0) + 1;
                }
                int maxTypeCount = typeCounts.isEmpty
                    ? 1
                    : typeCounts.values.reduce((a, b) => a > b ? a : b);
                if (maxTypeCount == 0) maxTypeCount = 1;

                Map<String, int> topCategories = {};
                for (var doc in aiDocs) {
                  final cat = (doc.data() as Map)['category_tag']?.toString();
                  if (cat != null && cat.isNotEmpty) {
                    topCategories[cat] = (topCategories[cat] ?? 0) + 1;
                  }
                }
                var sortedTop = topCategories.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                int totalAILogs = aiDocs.length;

                var pendingPestsList = pestDocs
                    .where(
                      (doc) =>
                          (doc.data() as Map<String, dynamic>)['isActive'] ==
                          false,
                    )
                    .toList();
                int pendingCount = pendingPestsList.length;

                // --- Dữ liệu cho Bảng (Table) kèm Lọc thông minh ---
                var filteredDocs = pestDocs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  // Lọc theo Search
                  bool matchesSearch = (data['name'] ?? '')
                      .toLowerCase()
                      .contains(_searchQuery);

                  // Lọc theo Tab Type linh hoạt hơn (dùng contains để bao quát dữ liệu đa dạng)
                  bool matchesType = false;
                  if (_selectedFilterType == 'Tất cả') {
                    matchesType = true;
                  } else {
                    String docType = (data['type'] ?? '')
                        .toString()
                        .toLowerCase();
                    String targetType = _selectedFilterType.toLowerCase();
                    if (docType.contains(targetType)) {
                      matchesType = true;
                    } else if (targetType == 'khác' &&
                        !docType.contains('côn trùng') &&
                        !docType.contains('nấm') &&
                        !docType.contains('vi-rút') &&
                        !docType.contains('vi khuẩn')) {
                      matchesType = true;
                    }
                  }

                  // Lọc theo Trạng thái (Pending View)
                  bool matchesStatus = _isViewingPending
                      ? (data['isActive'] == false)
                      : (data['isActive'] == true);

                  return matchesSearch && matchesType && matchesStatus;
                }).toList();

                // Sort
                filteredDocs.sort((a, b) {
                  var dataA = a.data() as Map<String, dynamic>;
                  var dataB = b.data() as Map<String, dynamic>;
                  if (_sortBy == 'Mức độ nguy hiểm') {
                    return (dataB['emergency_level'] ?? '').compareTo(
                      dataA['emergency_level'] ?? '',
                    );
                  } else {
                    Timestamp tA = dataA['createdAt'] ?? Timestamp.now();
                    Timestamp tB = dataB['createdAt'] ?? Timestamp.now();
                    return tB.compareTo(tA);
                  }
                });

                // ====================================================================
                // XỬ LÝ PHÂN TRANG (PAGINATION)
                // ====================================================================
                int totalFilteredItems = filteredDocs.length;
                int totalPages = (totalFilteredItems / _itemsPerPage).ceil();

                // Đảm bảo trang hiện tại không vượt quá tổng số trang
                if (_currentPage > totalPages && totalPages > 0) {
                  _currentPage = totalPages;
                }

                // Cắt danh sách data theo trang hiện tại
                var paginatedDocs = filteredDocs
                    .skip((_currentPage - 1) * _itemsPerPage)
                    .take(_itemsPerPage)
                    .toList();

                // ====================================================================
                // 2. VẼ GIAO DIỆN
                // ====================================================================
                return SingleChildScrollView(
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
                              Row(
                                children: [
                                  if (_isViewingPending)
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        size: 28,
                                      ),
                                      onPressed: () => setState(() {
                                        _isViewingPending = false;
                                        _currentPage = 1;
                                      }),
                                    ),
                                  Text(
                                    _isViewingPending
                                        ? "Danh sách Chờ Duyệt"
                                        : "Thư viện Sâu Bệnh",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Quản lý danh lục sâu bệnh, triệu chứng và giải pháp điều trị.",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_selectedIds.isNotEmpty)
                        BulkActionBar(
                          selectedCount: _selectedIds.length,
                          onClearSelection: () =>
                              setState(() => _selectedIds.clear()),
                          actions: [
                            ElevatedButton.icon(
                              onPressed: _handleBulkDeleteDiseases,
                              icon: const Icon(
                                Icons.delete_sweep,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: Text(
                                "Xóa hàng loạt",
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 32),

                      // Chỉ hiển thị KPI và Chart nếu KHÔNG ở màn hình Pending
                      if (!_isViewingPending) ...[
                        // (A) HÀNG KPI CHÍNH
                        Row(
                          children: [
                            Expanded(
                              child: _buildKPICardUI(
                                "Tổng sâu bệnh",
                                "$totalPests",
                                "Tổng cộng",
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildKPICardUI(
                                "Thêm mới (7 ngày)",
                                "+$newIn7Days",
                                "Mục mới",
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildKPICardUI(
                                "Tỷ lệ có giải pháp",
                                "${treatableRate.toStringAsFixed(1)}%",
                                null,
                                Colors.green,
                                iconTail: Icons.trending_up,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildKPICardUI(
                                "Chưa có giải pháp",
                                "${untreatableRate.toStringAsFixed(1)}%",
                                "Cần cập nhật",
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // (B) HÀNG PHÂN TÍCH
                        SizedBox(
                          height: 430,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Thẻ 1: Biểu đồ
                              Expanded(
                                flex: 2,
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Tỷ trọng Phân loại trong Thư viện",
                                                style: AppTextStyles.heading3
                                                    .copyWith(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Phân bổ dữ liệu theo nhóm sinh học",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.color,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              "CẬP NHẬT: TH04/2024",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                            ),
                                          ),
                                          // Cột cập nhật
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      // Biểu đồ cột
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children:
                                              [
                                                'Côn trùng',
                                                'Nấm',
                                                'Vi-rút',
                                                'Vi khuẩn',
                                                'Khác',
                                              ].map((key) {
                                                double heightRatio =
                                                    (typeCounts[key] ?? 0) /
                                                    maxTypeCount;
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    if ((typeCounts[key] ?? 0) >
                                                        0)
                                                      Text(
                                                        "${typeCounts[key]}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodySmall
                                                                      ?.color,
                                                            ),
                                                      ),
                                                    const SizedBox(height: 8),
                                                    Container(
                                                      width: 35,
                                                      height:
                                                          heightRatio * 150 + 5,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                        borderRadius:
                                                            const BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    6,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      key.toUpperCase(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelSmall
                                                          ?.copyWith(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .bodySmall
                                                                    ?.color,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Cột phải
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    // Thẻ Top AI
                                    GlassContainer(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "TOP CHỦ ĐỀ HỎI AI",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  letterSpacing: 1.2,
                                                ),
                                          ),
                                          const SizedBox(height: 20),
                                          if (sortedTop.isEmpty)
                                            Text(
                                              "Chưa có dữ liệu AI",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                                  ),
                                            ),
                                          ...List.generate(
                                            sortedTop.length > 3
                                                ? 3
                                                : sortedTop.length,
                                            (index) {
                                              double pct = totalAILogs == 0
                                                  ? 0
                                                  : (sortedTop[index].value /
                                                            totalAILogs) *
                                                        100;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondaryContainer,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        "0${index + 1}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .onSecondaryContainer,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        sortedTop[index].key,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onSurface,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${pct.toStringAsFixed(1)}%",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelMedium
                                                          ?.copyWith(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .secondary,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      Icons.trending_up,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                                      size: 16,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Thẻ CẦN DUYỆT GẤP (MÀU XANH ĐẬM)
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Colors.redAccent,
                                                          shape: BoxShape.circle,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "CẦN XỬ LÝ NGAY",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: Colors.white70,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 1.5,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                "Cần duyệt gấp",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "$pendingCount mục mới đang chờ xử lý",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.white70,
                                                    ),
                                              ),
                                              const SizedBox(height: 16),
                                              SizedBox(
                                              width: 120,
                                              child: ElevatedButton(
                                                onPressed: () => setState(() {
                                                  _isViewingPending = true;
                                                  _currentPage = 1;
                                                }),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Xử lý ngay",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ], // End of Dashboard Top Section
                      // (C) KHU VỰC BẢNG DỮ LIỆU CHÍNH
                      CustomAdminToolbar(
                        height: 56,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 6,
                        ),
                        children: [
                          Expanded(
                            flex: 6,
                            child: TextField(
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm sâu bệnh...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
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
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedFilterType,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.filter_list_rounded,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
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
                              items: _types
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() {
                                _selectedFilterType = v!;
                                _currentPage = 1;
                              }),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _sortBy,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.sort,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
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
                              items: _sortOptions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() {
                                _sortBy = v!;
                                _currentPage = 1;
                              }),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () => _showDiseaseFormDialog(),
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Thêm Sâu Bệnh',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
                      ),
                      const SizedBox(height: 24),

                      // TABLE KHUNG TRẮNG
                      SizedBox(
                        height:
                            (paginatedDocs.length * 90) +
                            100, // Dynamic height based on items
                        child: CustomAdminTable(
                          flex: const [4, 2, 2, 2, 1],
                          labels: const [
                            "SÂU BỆNH",
                            "PHÂN LOẠI",
                            "MỨC ĐỘ",
                            "TRẠNG THÁI",
                            "THAO TÁC",
                          ],
                          showHeaderCheckbox: true,
                          headerCheckboxValue:
                              paginatedDocs.isNotEmpty &&
                              paginatedDocs.every(
                                (doc) => _selectedIds.contains(doc.id),
                              ),
                          onHeaderCheckboxChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedIds.addAll(
                                  paginatedDocs.map((e) => e.id),
                                );
                              } else {
                                for (var doc in paginatedDocs) {
                                  _selectedIds.remove(doc.id);
                                }
                              }
                            });
                          },
                          itemCount: paginatedDocs.length,
                          rowBuilder: (context, index) {
                            var doc = paginatedDocs[index];
                            var data = doc.data() as Map<String, dynamic>;
                            bool isActive = data['isActive'] ?? true;

                            return [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _selectedIds.contains(doc.id),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedIds.add(doc.id);
                                        } else {
                                          _selectedIds.remove(doc.id);
                                        }
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  const SizedBox(width: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        data['imageUrl'] != null &&
                                            data['imageUrl']
                                                .toString()
                                                .isNotEmpty
                                        ? Image.network(
                                            data['imageUrl'],
                                            width: 60,
                                            height: 45,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 60,
                                            height: 45,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white12
                                                : Colors.black87,
                                            child: const Icon(
                                              Icons.bug_report,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          data['name'] ?? 'Không tên',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "MÙA VỤ: ${(data['season'] ?? 'Không rõ').toString().toUpperCase()}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _buildBadge(data['type'] ?? 'Khác'),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _buildSeverityBadge(
                                  data['emergency_level'] ?? 'Bình thường',
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: CustomAdminBadge(
                                  text: isActive ? "Đã duyệt" : "Chờ duyệt",
                                  color: isActive
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                      size: 18,
                                    ),
                                    onPressed: () => _showDiseaseFormDialog(
                                      existingDoc: doc,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    onPressed: () => _deleteDisease(doc),
                                  ),
                                ],
                              ),
                            ];
                          },
                        ),
                      ),
                      const Divider(height: 1),

                      // Giao diện Phân Trang (Pagination)
                      if (totalPages > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Hiển thị ${(_currentPage - 1) * _itemsPerPage + 1} - ${((_currentPage * _itemsPerPage) > totalFilteredItems) ? totalFilteredItems : (_currentPage * _itemsPerPage)} trong $totalFilteredItems sâu bệnh",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              Row(
                                children: [
                                  _buildPageButton(
                                    icon: Icons.chevron_left,
                                    onPressed: _currentPage > 1
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  ...List.generate(totalPages, (index) {
                                    int page = index + 1;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildPageButton(
                                        text: "$page",
                                        isActive: _currentPage == page,
                                        onPressed: () =>
                                            setState(() => _currentPage = page),
                                      ),
                                    );
                                  }),
                                  _buildPageButton(
                                    icon: Icons.chevron_right,
                                    onPressed: _currentPage < totalPages
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGET HELPERS T?O UI GI?NG ?NH
  // =========================================================================
  Widget _buildPageButton({
    String? text,
    IconData? icon,
    bool isActive = false,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
          ),
        ),
        alignment: Alignment.center,
        child: text != null
            ? Text(
                text,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isActive ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                icon,
                color: onPressed == null
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildKPICardUI(
    String title,
    String value,
    String? subtitle,
    Color valueColor, {
    IconData? iconTail,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (iconTail != null) Icon(iconTail, color: valueColor, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.shade100;
    Color text = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    if (type.toLowerCase().contains('c�n tr�ng')) {
      bg = Colors.orange.withValues(alpha: 0.1);
      text = Colors.orange;
    } else if (type.toLowerCase().contains('n?m')) {
      bg = AppColors.primary.withValues(alpha: 0.1);
      text = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: text,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String level) {
    Color color = Colors.grey;
    if (level.toLowerCase().contains('r?t cao') ||
        level.toLowerCase().contains('nguy hi?m')) {
      color = AppColors.statusDanger;
    } else if (level.toLowerCase().contains('cao')) {
      color = Colors.orange;
    } else if (level.toLowerCase().contains('trung b�nh')) {
      color = Colors.amber;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          level,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _handleBulkDeleteDiseases() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('X�c nh?n x�a h�ng lo?t'),
        content: Text('B?n c� ch?c ch?n mu?n x�a  m?c s�u b?nh d� ch?n kh�ng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('H?y'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _executeBulkDeleteDiseases();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'X�a t?t c?',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeBulkDeleteDiseases() async {
    setState(() => _isLoading = true);
    try {
      await BulkService.deleteDocuments(
        collection: 'pest_diseases',
        docIds: _selectedIds.toList(),
        module: AuditModule.aichat,
        actionDescription: 'X�a h�ng lo?t s�u b?nh kh?i thu vi?n',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('�� x�a d? li?u th�nh c�ng!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedIds.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('L?i khi x�a h�ng lo?t: '),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
