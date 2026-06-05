import 'package:flutter/material.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../widgets/product_dialog.dart';
import 'package:admin_daklak_web/features/logs/services/bulk_service.dart';
import 'package:admin_daklak_web/features/logs/widgets/bulk_action_bar.dart';
import 'package:admin_daklak_web/features/logs/models/audit_log_model.dart';
import '../../../core/widgets/common/custom_admin_table.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả danh mục';
  final Set<String> _selectedIds = {};
  bool _isProcessing = false;
  
  Color get _bgGray => Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant : const Color(0xFFF5F7FA);
  Color get _textPrimary => Theme.of(context).colorScheme.onSurface;
  Color get _textSecondary => Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280);
  Color get _borderColor => Theme.of(context).dividerColor;
  Color get _primaryGreen => const Color(0xFF2E7D32);
  Color get _warningRed => Theme.of(context).colorScheme.error;


  final List<String> _filterCategories = [
    'Tất cả danh mục',
    'Sầu riêng',
    'Cà phê',
    'Hồ tiêu',
    'Trái cây',
    'Rau củ',
    'Hạt giống',
    'Vật tư nông nghiệp'
  ];

  void _showProductDialog({String? productId, Map<String, dynamic>? data}) {
    showDialog(
      context: context,
      builder: (_) => ProductDialog(productId: productId, initialData: data),
    );
  }

  void _confirmDelete(String productId, String productName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xóa sản phẩm', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: _textPrimary)),
        content: Text('Bạn có chắc chắn muốn xóa "$productName"?', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('products').doc(productId).delete();
              if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa "$productName".')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Xóa', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.3);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════
            // HEADER — simplified
            // ═══════════════════════════════════════
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: _textPrimary),
                  onPressed: () => context.pop(),
                  tooltip: 'Quay lại Dashboard',
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý Sản phẩm Nông sản',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý kho hàng, giá biến thể và mức tồn kho.',
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
            // height: 56, padding: h24/v6, flex 6:2:1
            // ═══════════════════════════════════════
            _selectedIds.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: BulkActionBar(
                    selectedCount: _selectedIds.length,
                    onClearSelection: () => setState(() => _selectedIds.clear()),
                    actions: [
                      ElevatedButton.icon(
                        onPressed: _handleBulkDelete,
                        icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 20),
                        label: const Text('Xóa hàng loạt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomAdminToolbar(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    children: [
                      // Search — flex 6
                      Expanded(
                        flex: 6,
                        child: TextField(
                          onChanged: (val) {
                            setState(() => _searchQuery = val.trim().toLowerCase());
                          },
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm sản phẩm...',
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

                      // Category Filter — flex 2
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
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
                          items: _filterCategories
                              .map((s) => DropdownMenuItem(value: s, child: Text(s, style: Theme.of(context).textTheme.bodySmall))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() { _selectedCategory = val; });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Add Product Button — flex 1
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => _showProductDialog(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Thêm SP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryGreen,
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
                ),

            // ═══════════════════════════════════════
            // TABLE — CustomAdminTable (golden rule)
            // flex: [1, 2, 3, 2, 2, 2, 1], glass header, hover rows
            // ═══════════════════════════════════════
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 300,
                    child: Center(child: Text("Lỗi tải sản phẩm: ${snapshot.error}", style: const TextStyle(color: Colors.red))),
                  );
                }

                var docs = snapshot.data?.docs ?? [];

                if (_selectedCategory != 'Tất cả danh mục') {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final classification = data['classification'] as Map<String, dynamic>?;
                    final String? cat = (classification?['categoryId'] as String?) ?? (data['category'] as String?);
                    
                    if (cat == null) return false;
                    
                    // Chấp nhận cả nhãn cũ (Anh) và nhãn mới (Việt) trong khi chờ migration
                    if (cat == _selectedCategory) return true;
                    if (_selectedCategory == 'Sầu riêng' && (cat == 'Durian' || cat == 'sau_rieng_ri6' || cat == 'sau_rieng_thai')) return true;
                    if (_selectedCategory == 'Cà phê' && (cat == 'Coffee' || cat == 'cafe_hat')) return true;
                    if (_selectedCategory == 'Hồ tiêu' && cat == 'Pepper') return true;
                    if (_selectedCategory == 'Trái cây' && cat == 'Fruits') return true;
                    if (_selectedCategory == 'Rau củ' && cat == 'Vegetables') return true;
                    if (_selectedCategory == 'Hạt giống' && cat == 'Seeds') return true;
                    if (_selectedCategory == 'Vật tư nông nghiệp' && (cat == 'Agricultural Supplies' || cat == 'VẬT TƯ - THIẾT BỊ')) return true;
                    return false;
                  }).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height - 260,
                  child: CustomAdminTable(
                    flex: const [1, 2, 3, 2, 2, 2, 1],
                    labels: const ['Ảnh', 'Mã SP', 'Tên sản phẩm', 'Danh mục', 'Giá bán', 'Tồn kho', 'Thao tác'],
                    itemCount: docs.length,
                    onRowTapWithIndex: (index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      _showProductDialog(productId: doc.id, data: data);
                    },
                    rowBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final String name = data['name'] ?? 'Sản phẩm không tên';
                      
                      // Support both flat and nested schema
                      final classification = data['classification'] as Map<String, dynamic>?;
                      final pricing = data['pricing'] as Map<String, dynamic>?;
                      final inventory = data['inventory'] as Map<String, dynamic>?;

                      final String rawCategory = (classification?['categoryId'] as String?) ?? (data['category'] as String?) ?? 'Chưa phân loại';
                      
                      // Map categories to Vietnamese for display if they are English
                      final categoryMapping = {
                        'Durian': 'Sầu riêng',
                        'Coffee': 'Cà phê',
                        'Pepper': 'Hồ tiêu',
                        'Fruits': 'Trái cây',
                        'Vegetables': 'Rau củ',
                        'Seeds': 'Hạt giống',
                        'Agricultural Supplies': 'Vật tư nông nghiệp',
                        'cafe_hat': 'Cà phê',
                        'sau_rieng_ri6': 'Sầu riêng',
                        'sau_rieng_thai': 'Sầu riêng'
                      };
                      final String category = categoryMapping[rawCategory] ?? rawCategory;

                      final num priceNum = (pricing?['retailPrice'] as num?)?.toDouble() ?? (data['price'] as num?)?.toDouble() ?? 0.0;
                      final int stock = (inventory?['quantity'] as int?) ?? (data['stock'] as int?) ?? 0;
                      
                      final String imgUrl = data['imageUrl'] ?? '';
                      final bool isLowStock = stock <= 10;

                      return [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: _bgGray,
                              border: Border.all(color: _borderColor),
                              image: imgUrl.isNotEmpty && imgUrl.startsWith('http')
                                ? DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)
                                : null,
                            ),
                            child: (imgUrl.isEmpty || !imgUrl.startsWith('http'))
                              ? const Icon(Icons.image, color: Colors.grey)
                              : null,
                          ),
                        ),

                        // Product Code
                        Text(
                          doc.id.length > 6 ? doc.id.substring(0, 6).toUpperCase() : doc.id.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: _textSecondary),
                        ),

                        // Name
                        Text(
                          name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: _textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Category — pill badge
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(category, style: Theme.of(context).textTheme.labelSmall),
                            backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.4),
                            side: BorderSide.none,
                          ),
                        ),

                        // Price
                        Text(
                          '${priceNum.toStringAsFixed(0)} đ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),

                        // Stock
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              stock.toString(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLowStock ? _warningRed : _primaryGreen,
                              ),
                            ),
                            if (isLowStock) ...[
                              const SizedBox(width: 8),
                              Tooltip(
                                message: 'Sắp hết hàng',
                                child: Icon(Icons.warning_amber_rounded, color: _warningRed, size: 20),
                              ),
                            ],
                          ],
                        ),

                        // Actions
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility_outlined, color: _primaryGreen, size: 20),
                                tooltip: 'Chỉnh sửa',
                                onPressed: () => _showProductDialog(productId: doc.id, data: data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                tooltip: 'Xóa',
                                onPressed: () => _confirmDelete(doc.id, name),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  void _handleBulkDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xóa hàng loạt', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa ${_selectedIds.length} sản phẩm đã chọn không? Hành động này không thể hoàn tác.', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _executeBulkDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa tất cả', style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  Future<void> _executeBulkDelete() async {
    setState(() => _isProcessing = true);
    try {
      await BulkService.deleteDocuments(
        collection: 'products',
        docIds: _selectedIds.toList(),
        module: AuditModule.products,
        actionDescription: "Xóa hàng loạt sản phẩm khỏi kho",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa ${_selectedIds.length} sản phẩm thành công.')));
        setState(() {
          _selectedIds.clear();
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa hàng loạt: $e'), backgroundColor: Colors.red));
        setState(() => _isProcessing = false);
      }
    }
  }
}
