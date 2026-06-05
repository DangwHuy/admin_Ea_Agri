import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

const Color _primaryGreen = Color(0xFF2E7D32);
const Color _textPrimary = Color(0xFF1C2826);
const Color _textSecondary = Color(0xFF6B7280);

class VoucherDialog extends StatefulWidget {
  final String? voucherId;
  final Map<String, dynamic>? initialData;

  const VoucherDialog({super.key, this.voucherId, this.initialData});

  @override
  State<VoucherDialog> createState() => _VoucherDialogState();
}

class _VoucherDialogState extends State<VoucherDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _valueController;
  late TextEditingController _minOrderController;
  late TextEditingController _usageLimitController;
  
  String _discountType = 'Percentage';
  bool _isActive = true;
  DateTime? _expiryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialData?['code'] ?? '');
    _valueController = TextEditingController(text: widget.initialData?['value']?.toString() ?? '');
    _minOrderController = TextEditingController(text: widget.initialData?['minOrderValue']?.toString() ?? '0');
    _usageLimitController = TextEditingController(text: widget.initialData?['usageLimit']?.toString() ?? '');
    
    if (widget.initialData != null) {
      _discountType = widget.initialData!['discountType'] ?? 'Percentage';
      _isActive = widget.initialData!['isActive'] ?? true;
      if (widget.initialData!['expiryDate'] != null) {
        _expiryDate = (widget.initialData!['expiryDate'] as Timestamp).toDate();
      }
    } else {
      _expiryDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  void _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    setState(() {
      _codeController.text = code;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
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
    if (_expiryDate == null) {
      _showToast("Please select an expiry date.");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final code = _codeController.text.trim().toUpperCase();
      final value = double.tryParse(_valueController.text) ?? 0;
      final minOrder = double.tryParse(_minOrderController.text) ?? 0;
      final limit = int.tryParse(_usageLimitController.text) ?? 0;
      
      final data = {
         'code': code,
         'discountType': _discountType,
         'value': value,
         'minOrderValue': minOrder,
         'usageLimit': limit,
         'expiryDate': Timestamp.fromDate(_expiryDate!),
         'isActive': _isActive,
      };

      if (widget.voucherId == null) {
        // Create
        // Verify unique
        final exist = await FirebaseFirestore.instance.collection('vouchers').where('code', isEqualTo: code).get();
        if (exist.docs.isNotEmpty) {
           _showToast('Voucher code already exists!');
           setState(() => _isLoading = false);
           return;
        }
        data['usageCount'] = 0;
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('vouchers').add(data);
        _showToast('Voucher created successfully!');
      } else {
        // Update
        await FirebaseFirestore.instance.collection('vouchers').doc(widget.voucherId).update(data);
        _showToast('Voucher updated successfully!');
      }
      
      if (mounted) Navigator.of(context).pop(true);
    } catch(e) {
      _showToast('Error saving voucher: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(widget.voucherId == null ? 'Create Voucher' : 'Edit Voucher', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: _textPrimary)),
           Switch(
             value: _isActive,
             onChanged: (val) => setState(() => _isActive = val),
             activeColor: _primaryGreen,
           )
        ]
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(labelText: 'Voucher Code', border: OutlineInputBorder()),
                        textCapitalization: TextCapitalization.characters,
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Code required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                       onPressed: _generateCode,
                       style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                       child: const Text('Generate'),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Discount Type', border: OutlineInputBorder()),
                        value: _discountType,
                        items: ['Percentage', 'Fixed Amount'].map((cat) {
                          return DropdownMenuItem<String>(value: cat, child: Text(cat == 'Percentage' ? '% Percentage' : '₫ Fixed Amount'));
                        }).toList(),
                        onChanged: (val) => setState(() => _discountType = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _valueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: _discountType == 'Percentage' ? 'Discount (%)' : 'Discount (đ)', border: const OutlineInputBorder()),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          final numVal = double.tryParse(val) ?? -1;
                          if (numVal < 0) return 'Invalid value';
                          if (_discountType == 'Percentage' && numVal > 100) return 'Max 100%';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _minOrderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minimum Order Value (đ)', border: OutlineInputBorder(), hintText: '0 for no minimum'),
                  validator: (val) => (val != null && double.tryParse(val) == null) ? 'Invalid value' : null,
                ),
                const SizedBox(height: 16),
                Row(
                   children: [
                      Expanded(
                        child: TextFormField(
                          controller: _usageLimitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Usage Limit', border: OutlineInputBorder(), hintText: 'e.g. 100'),
                          validator: (val) => (val == null || val.trim().isEmpty || int.tryParse(val) == null || int.tryParse(val)! <= 0) ? 'Valid limit required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                         child: InkWell(
                            onTap: _pickDate,
                            child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                               decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                               child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                     Text(_expiryDate == null ? 'Select Expiry Date' : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _expiryDate == null ? _textSecondary : _textPrimary)),
                                     const Icon(Icons.calendar_today, size: 18),
                                  ]
                               )
                            )
                         )
                      )
                   ]
                )
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: _textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(widget.voucherId == null ? 'Create Voucher' : 'Save Changes', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
