import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

import 'package:admin_daklak_web/core/widgets/common/glass_container.dart';
import 'package:admin_daklak_web/core/widgets/common/custom_admin_table.dart';
import 'package:admin_daklak_web/core/widgets/common/custom_admin_toolbar.dart';
import 'package:admin_daklak_web/core/widgets/common/custom_admin_badge.dart';

class BannerManagerScreen extends StatefulWidget {
  const BannerManagerScreen({super.key});

  @override
  State<BannerManagerScreen> createState() => _BannerManagerScreenState();
}

class _BannerManagerScreenState extends State<BannerManagerScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  String _selectedFilter = 'Tất cả';
  String _sortBy = 'order';
  String _searchQuery = '';
  Timer? _debounce;
  final TextEditingController _searchCtrl = TextEditingController();

  // Biến phục vụ phân trang
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  


  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        _currentPage = 1;
      });
    });
  }

  void _showBannerFormDialog({DocumentSnapshot? existingDoc}) {
    final bool isEditing = existingDoc != null;
    final data = isEditing ? existingDoc.data() as Map<String, dynamic> : {};

    final titleCtrl = TextEditingController(text: data['title'] ?? '');
    final descCtrl = TextEditingController(text: data['description'] ?? '');
    final actionUrlCtrl = TextEditingController(text: data['actionUrl'] ?? '');
    final orderCtrl = TextEditingController(text: (data['order'] ?? 0).toString());

    String selectedType = data['type'] ?? 'ads';
    String? existingImageUrl = data['imageUrl'];
    Uint8List? newImageBytes;

    DateTime? startDate = data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : null;
    DateTime? endDate = data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null;
    bool isActive = data['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          InputDecoration glassInputDecoration(String label) {
            return InputDecoration(
              labelText: label,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            );
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: GlassContainer(
              padding: const EdgeInsets.all(32),
              child: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Chỉnh sửa Banner' : 'Thêm Banner Mới',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setStateDialog(() => newImageBytes = bytes);
                          }
                        },
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: newImageBytes != null
                              ? Image.memory(newImageBytes!, fit: BoxFit.cover)
                              : (existingImageUrl != null && existingImageUrl.isNotEmpty
                              ? Image.network(existingImageUrl, fit: BoxFit.cover)
                              : Icon(Icons.add_a_photo, size: 50, color: Theme.of(context).textTheme.bodySmall?.color)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(controller: titleCtrl, decoration: glassInputDecoration('Tiêu đề banner')),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Switch(
                                value: isActive,
                                onChanged: (val) => setStateDialog(() => isActive = val),
                                activeTrackColor: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isActive ? "Đang chạy" : "Tạm dừng",
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: isActive ? AppColors.primary : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(controller: descCtrl, decoration: glassInputDecoration('Mô tả ngắn gọn')),
                      const SizedBox(height: 16),
                      TextField(controller: actionUrlCtrl, decoration: glassInputDecoration('Đường link (Action URL)')),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedType,
                              decoration: glassInputDecoration('Loại điều hướng'),
                              items: const [
                                DropdownMenuItem(value: 'ads', child: Text('Quảng cáo ngoài')),
                                DropdownMenuItem(value: 'product', child: Text('Chi tiết sản phẩm')),
                                DropdownMenuItem(value: 'category', child: Text('Danh mục')),
                                DropdownMenuItem(value: 'warning', child: Text('Cảnh báo khẩn')),
                              ],
                              onChanged: (val) => setStateDialog(() => selectedType = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                                controller: orderCtrl,
                                keyboardType: TextInputType.number,
                                decoration: glassInputDecoration('Thứ tự ưu tiên (VD: 1, 2)')
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(startDate != null ? "${startDate!.day}/${startDate!.month}/${startDate!.year}" : 'Ngày bắt đầu'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                              ),
                              onPressed: () async {
                                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                                if (date != null) setStateDialog(() => startDate = date);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.event_busy, size: 18),
                              label: Text(endDate != null ? "${endDate!.day}/${endDate!.month}/${endDate!.year}" : 'Ngày kết thúc'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                              ),
                              onPressed: () async {
                                final date = await showDatePicker(context: context, initialDate: startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                                if (date != null) setStateDialog(() => endDate = date);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), 
                            child: Text('Hủy', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              if (titleCtrl.text.isEmpty || (newImageBytes == null && existingImageUrl == null)) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tiêu đề và chọn ảnh')));
                                return;
                              }

                              setStateDialog(() => _isLoading = true);

                              try {
                                String finalImageUrl = existingImageUrl ?? '';

                                if (newImageBytes != null) {
                                  String fileName = 'banners/${DateTime.now().millisecondsSinceEpoch}.png';
                                  TaskSnapshot snapshot = await FirebaseStorage.instance.ref(fileName).putData(newImageBytes!);
                                  finalImageUrl = await snapshot.ref.getDownloadURL();

                                  if (isEditing && existingImageUrl != null && existingImageUrl.contains('firebase')) {
                                    try { await FirebaseStorage.instance.refFromURL(existingImageUrl).delete(); } catch (_) {}
                                  }
                                }

                                Map<String, dynamic> bannerData = {
                                  'title': titleCtrl.text,
                                  'description': descCtrl.text,
                                  'actionUrl': actionUrlCtrl.text,
                                  'imageUrl': finalImageUrl,
                                  'type': selectedType,
                                  'order': int.tryParse(orderCtrl.text) ?? 0,
                                  'isActive': isActive,
                                  'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
                                  'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                };

                                if (isEditing) {
                                  await existingDoc.reference.update(bannerData);
                                } else {
                                  bannerData['clicks'] = 0;
                                  bannerData['impressions'] = 0;
                                  bannerData['createdAt'] = FieldValue.serverTimestamp();
                                  await _firestore.collection('home_banners').add(bannerData);
                                }

                                setStateDialog(() => _isLoading = false);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật banner thành công!'), backgroundColor: Color(0xFF3D7E50)));
                                }

                              } catch (e) {
                                setStateDialog(() => _isLoading = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(isEditing ? 'Lưu dữ liệu' : 'Tạo mới', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Future<void> _deleteBanner(DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa banner này vĩnh viễn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text('Xóa', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white))),
        ],
      ),
    );

    if (confirm == true) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['imageUrl'] != null && data['imageUrl'].toString().contains('firebase')) {
        try { await FirebaseStorage.instance.refFromURL(data['imageUrl']).delete(); } catch (e) { debugPrint('Lỗi: $e'); }
      }
      await doc.reference.delete();
      setState(() { _currentPage = 1; });
    }
  }
  
  Widget _buildStatusBadge(bool isActive, bool isExpired) {
    if (isExpired) {
      return const CustomAdminBadge(text: 'Hết hạn', color: Color(0xFFD15F5F));
    }
    if (isActive) {
      return const CustomAdminBadge(text: 'Đang chạy', color: AppColors.primary);
    }
    return const CustomAdminBadge(text: 'Tạm dừng', color: Colors.orange);
  }

  Widget _buildKPICardUI(String title, String value, String? subtitle, Color valueColor, {IconData? iconTail}) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              const SizedBox(width: 8),
              if (subtitle != null) Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: valueColor, fontWeight: FontWeight.bold)),
              if (iconTail != null) Icon(iconTail, color: valueColor, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton({String? text, IconData? icon, bool isActive = false, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
        ),
        alignment: Alignment.center,
        child: text != null
            ? Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold))
            : Icon(icon, color: onPressed == null ? Colors.grey.shade300 : Theme.of(context).colorScheme.onSurface, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('home_banners').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Đã xảy ra lỗi khi tải dữ liệu.'));
            }

            final allDocs = snapshot.data?.docs ?? [];
            int activeCount = 0, expiredCount = 0, totalClicks = 0;
            final now = DateTime.now();
            List<DocumentSnapshot> filteredDocs = [];

            // 1. Tính toán KPI và Lọc dữ liệu Local
            for (var doc in allDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final isActive = data['isActive'] ?? false;
              final isExpired = data['endDate'] != null && (data['endDate'] as Timestamp).toDate().isBefore(now);

              totalClicks += (data['clicks'] ?? 0) as int;
              if (isExpired) {
                expiredCount++;
              } else if (isActive) {
                activeCount++;
              }

              // Lọc
              if (_selectedFilter == 'Đang chạy' && (!isActive || isExpired)) continue;
              if (_selectedFilter == 'Tạm dừng' && (isActive || isExpired)) continue;
              if (_selectedFilter == 'Hết hạn' && !isExpired) continue;
              if (_searchQuery.isNotEmpty) {
                final title = (data['title'] ?? '').toString().toLowerCase();
                if (!title.contains(_searchQuery)) continue;
              }

              filteredDocs.add(doc);
            }

            // 2. Sắp xếp Local
            filteredDocs.sort((a, b) {
              final dataA = a.data() as Map<String, dynamic>;
              final dataB = b.data() as Map<String, dynamic>;
              if (_sortBy == 'Mới nhất') {
                Timestamp? tA = dataA['createdAt'];
                Timestamp? tB = dataB['createdAt'];
                if (tA == null && tB == null) return 0;
                if (tA == null) return 1;
                if (tB == null) return -1;
                return tB.compareTo(tA);
              } else {
                int orderA = dataA['order'] ?? 999;
                int orderB = dataB['order'] ?? 999;
                return orderA.compareTo(orderB);
              }
            });

            // 3. Xử lý Logic Phân trang
            final totalItems = filteredDocs.length;
            final totalPages = (totalItems / _itemsPerPage).ceil();

            if (_currentPage > totalPages && totalPages > 0) {
              _currentPage = totalPages;
            } else if (totalPages == 0) {
              _currentPage = 1;
            }

            final pagedDocs = filteredDocs.skip((_currentPage - 1) * _itemsPerPage).take(_itemsPerPage).toList();

            String clicksText = totalClicks > 999 ? "${(totalClicks / 1000).toStringAsFixed(1)}k" : totalClicks.toString();

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
                          Text('Quản lý Banner', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          Text("Quản lý danh lục banner hiển thị trên ứng dụng.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // KPI CARDS
                  Row(
                    children: [
                      Expanded(child: _buildKPICardUI('Banner đang chạy', activeCount.toString(), "Hoạt động", AppColors.primary, iconTail: Icons.play_circle_fill)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKPICardUI('Đã hết hạn', expiredCount.toString(), "Hết hạn", const Color(0xFFD15F5F), iconTail: Icons.timer_off)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKPICardUI('Tổng lượt click', clicksText, "Lượt nhấp", const Color(0xFFE27C37), iconTail: Icons.ads_click)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // FILTER BAR (TOOLBAR)
                  CustomAdminToolbar(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm banner...',
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3),
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
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_selectedFilter),
                          initialValue: _selectedFilter,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.filter_list_rounded, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          ),
                          items: ['Tất cả', 'Đang chạy', 'Tạm dừng', 'Hết hạn'].map((f) => DropdownMenuItem(value: f, child: Text(f, style: Theme.of(context).textTheme.bodySmall))).toList(),
                          onChanged: (val) => setState(() {
                            _selectedFilter = val!;
                            _currentPage = 1;
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_sortBy),
                          initialValue: _sortBy,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.sort, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          ),
                          items: [
                            DropdownMenuItem(value: 'order', child: Text('Ưu tiên hiển thị', style: Theme.of(context).textTheme.bodySmall)), 
                            DropdownMenuItem(value: 'Mới nhất', child: Text('Mới nhất', style: Theme.of(context).textTheme.bodySmall))
                          ],
                          onChanged: (val) => setState(() {
                            _sortBy = val!;
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
                            onPressed: () => _showBannerFormDialog(),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: const Text('Thêm Banner', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
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
                  ),
                  const SizedBox(height: 24),

                  // LIST BANNER (TABLE TRẮNG / GLASS)
                  SizedBox(
                    height: (pagedDocs.length * 100) + 120, 
                    child: CustomAdminTable(
                      flex: const [4, 2, 2, 3, 2, 1],
                      labels: const ["BANNER", "ĐIỀU HƯỚNG", "ƯU TIÊN", "HIỆU QUẢ", "TRẠNG THÁI", "THAO TÁC"],
                      itemCount: pagedDocs.length,
                      rowBuilder: (context, index) {
                        var doc = pagedDocs[index];
                        var data = doc.data() as Map<String, dynamic>;
                        
                        final isActive = data['isActive'] ?? false;
                        bool isExpired = false;
                        if (data['endDate'] != null) isExpired = (data['endDate'] as Timestamp).toDate().isBefore(DateTime.now());

                        final int order = data['order'] ?? 999;
                        String prioLabel = order <= 1 ? "Cao ($order)" : "Thường ($order)";

                        int views = data['impressions'] ?? 0;
                        int clicks = data['clicks'] ?? 0;
                        double ctr = views > 0 ? (clicks / views * 100) : 0;
                        
                        String bannerType = (data['type'] ?? 'ADS').toString().toUpperCase();

                        return [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                                    ? Image.network(
                                        data['imageUrl'],
                                        width: 100,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        height: 60,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black87,
                                        child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      data['title'] ?? '(Không tiêu đề)',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['description'] ?? '',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16)
                              ),
                              child: Text(bannerType, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(Icons.stars, size: 16, color: order <= 1 ? Colors.orange : Colors.grey),
                                const SizedBox(width: 4),
                                Text(prioLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                              ]
                            )
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Lượt xem: $views', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 2),
                              Text('Lượt click: $clicks', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 2),
                              Text('CTR: ${ctr.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _buildStatusBadge(isActive, isExpired)
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Theme.of(context).primaryColor, size: 18),
                                onPressed: () => _showBannerFormDialog(existingDoc: doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                onPressed: () => _deleteBanner(doc),
                              ),
                            ],
                          ),
                        ];
                      },
                    ),
                  ),

                  // Giao diện Phân Trang
                  if (totalPages > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hiển thị ${(_currentPage - 1) * _itemsPerPage + 1} - ${((_currentPage * _itemsPerPage) > totalItems) ? totalItems : (_currentPage * _itemsPerPage)} trong $totalItems banner",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Row(
                            children: [
                              _buildPageButton(
                                icon: Icons.chevron_left,
                                onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                              ),
                              const SizedBox(width: 8),
                              ...List.generate(totalPages, (index) {
                                int page = index + 1;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildPageButton(
                                    text: "$page",
                                    isActive: _currentPage == page,
                                    onPressed: () => setState(() => _currentPage = page),
                                  ),
                                );
                              }),
                              _buildPageButton(
                                icon: Icons.chevron_right,
                                onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
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
        ),
      ),
    );
  }
}