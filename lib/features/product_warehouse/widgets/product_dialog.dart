import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _primaryGreen = Color(0xFF2E7D32);
const Color _textPrimary = Color(0xFF1C2826);
const Color _textSecondary = Color(0xFF6B7280);

class ProductDialog extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? initialData;

  const ProductDialog({Key? key, this.productId, this.initialData}) : super(key: key);

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageController;
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Sầu riêng',
    'Cà phê',
    'Hồ tiêu',
    'Trái cây',
    'Rau củ',
    'Hạt giống',
    'Vật tư nông nghiệp'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _priceController = TextEditingController(text: widget.initialData?['price']?.toString() ?? '');
    _stockController = TextEditingController(text: widget.initialData?['stock']?.toString() ?? '');
    _imageController = TextEditingController(text: widget.initialData?['imageUrl'] ?? '');
    
    // Ensure category is in our list, supporting legacy English values
    if (widget.initialData != null && widget.initialData!['category'] != null) {
      final String cat = widget.initialData!['category'];
      if (_categories.contains(cat)) {
        _selectedCategory = cat;
      } else {
        // Map legacy EN to VN
        final mapping = {
          'Durian': 'Sầu riêng',
          'Coffee': 'Cà phê',
          'Pepper': 'Hồ tiêu',
          'Fruits': 'Trái cây',
          'Vegetables': 'Rau củ',
          'Seeds': 'Hạt giống',
          'Agricultural Supplies': 'Vật tư nông nghiệp'
        };
        _selectedCategory = mapping[cat] ?? cat;
        // If still not in list, fallback to null or first
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = null;
        }
      }
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
      backgroundColor: _textPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory == null) {
      _showToast("Vui lòng chọn danh mục.");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final name = _nameController.text.trim();
      final price = double.tryParse(_priceController.text) ?? 0;
      final stock = int.tryParse(_stockController.text) ?? 0;
      final image = _imageController.text.trim();
      
      if (widget.productId == null) {
        // Create new
        final batch = FirebaseFirestore.instance.batch();
        final prodRef = FirebaseFirestore.instance.collection('products').doc();
        batch.set(prodRef, {
          'name': name,
          'price': price,
          'stock': stock,
          'category': _selectedCategory,
          'imageUrl': image,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Sync with product_stats
        final statRef = FirebaseFirestore.instance.collection('product_stats').doc(prodRef.id);
        batch.set(statRef, {
          'name': name,
          'quantitySold': 0,
        }, SetOptions(merge: true));
        
        await batch.commit();
        _showToast('Đã thêm sản phẩm thành công!');
      } else {
        // Update existing
        // Update purely the name in stats as well to keep consistency
        final batch = FirebaseFirestore.instance.batch();
        batch.update(FirebaseFirestore.instance.collection('products').doc(widget.productId), {
          'name': name,
          'price': price,
          'stock': stock,
          'category': _selectedCategory,
          'imageUrl': image,
        });
        batch.set(FirebaseFirestore.instance.collection('product_stats').doc(widget.productId), {
           'name': name,
        }, SetOptions(merge: true));

        await batch.commit();
        _showToast('Đã cập nhật sản phẩm thành công!');
      }
      
      if (mounted) Navigator.of(context).pop(true);
    } catch(e) {
      _showToast('Lỗi khi lưu sản phẩm: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.productId == null ? 'Thêm Sản phẩm mới' : 'Chỉnh sửa Sản phẩm', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: _textPrimary)),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên sản phẩm',
                    labelStyle: Theme.of(context).textTheme.titleSmall,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Danh mục',
                    labelStyle: Theme.of(context).textTheme.titleSmall,
                    border: const OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (val) => val == null ? 'Vui lòng chọn danh mục' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Giá bán (đ)',
                          labelStyle: Theme.of(context).textTheme.titleSmall,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Bắt buộc';
                          if (double.tryParse(val) == null) return 'Giá không hợp lệ';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Số lượng tồn kho',
                          labelStyle: Theme.of(context).textTheme.titleSmall,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Bắt buộc';
                          if (int.tryParse(val) == null) return 'Số lượng không hợp lệ';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageController,
                  decoration: InputDecoration(
                    labelText: 'URL Hình ảnh (Không bắt buộc)',
                    labelStyle: Theme.of(context).textTheme.titleSmall,
                    border: const OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Hủy', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: _textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(widget.productId == null ? 'Tạo Sản phẩm' : 'Lưu thay đổi', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
