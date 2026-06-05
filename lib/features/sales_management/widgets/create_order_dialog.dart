import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _primaryGreen = Color(0xFF2E7D32);

class CreateOrderDialog extends StatefulWidget {
  const CreateOrderDialog({Key? key}) : super(key: key);

  @override
  State<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<CreateOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  
  String? _selectedProductId;
  String? _selectedProductName;
  double _selectedProductPrice = 0;
  String? _selectedProductSellerId;   // ← captured from product's seller.id
  bool _isLoading = false;

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  Future<void> _submitOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedProductId == null) {
      _showToast("Vui lòng chọn sản phẩm");
      return;
    }

    setState(() => _isLoading = true);

    try {
      int quantity = int.tryParse(_quantityController.text) ?? 1;
      double total = _selectedProductPrice * quantity;
      
      final today = DateTime.now();
      final dayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final batch = FirebaseFirestore.instance.batch();
      
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      batch.set(orderRef, {
        'customerName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'items': [
          {
            'productId': _selectedProductId,
            'productName': _selectedProductName,
            'quantity': quantity,
            'price': _selectedProductPrice,
          }
        ],
        'totalAmount': total,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        // sellerId is required by the analytics pipeline.
        if (_selectedProductSellerId != null)
          'sellerId': _selectedProductSellerId,
      });

      batch.set(FirebaseFirestore.instance.collection('daily_stats').doc(dayString), {
        'revenue': FieldValue.increment(total),
        'orders': FieldValue.increment(1),
      }, SetOptions(merge: true));

      batch.set(FirebaseFirestore.instance.collection('product_stats').doc(_selectedProductId), {
        'name': _selectedProductName,
        'quantitySold': FieldValue.increment(quantity),
      }, SetOptions(merge: true));

      await batch.commit();

      _showToast("Đã tạo đơn hàng thành công!");
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showToast("Lỗi khi tạo đơn hàng: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tạo Đơn hàng Thủ công', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên khách hàng', border: OutlineInputBorder()),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Địa chỉ giao hàng', border: OutlineInputBorder()),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 16),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('products').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text("Không thể tải danh sách sản phẩm", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red));
                    }
                    final products = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Sản phẩm', border: OutlineInputBorder()),
                      value: _selectedProductId,
                      items: products.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final rawPrice = data['price'] ?? 0;
                        final price = rawPrice is num ? rawPrice.toDouble() : double.tryParse(rawPrice.toString()) ?? 0.0;
                        final sellerMap = data['seller'] as Map<String, dynamic>?;
                        final sellerId = (sellerMap?['id'] as String?) ?? data['sellerId'] as String?;
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(data['name'] ?? 'Sản phẩm không tên'),
                          onTap: () {
                            _selectedProductName = data['name'] ?? 'Sản phẩm không tên';
                            _selectedProductPrice = price;
                            _selectedProductSellerId = sellerId;
                          },
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedProductId = val),
                      validator: (val) => val == null ? 'Bắt buộc' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số lượng', border: OutlineInputBorder()),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Bắt buộc';
                    if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Số lượng không hợp lệ';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Hủy', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitOrder,
          style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('Tạo mới', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
