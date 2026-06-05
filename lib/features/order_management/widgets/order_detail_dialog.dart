import 'package:flutter/material.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

class OrderDetailDialog extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final Function(String docId, String newStatus) onStatusChange;

  const OrderDetailDialog({
    Key? key,
    required this.orderId,
    required this.orderData,
    required this.onStatusChange,
  }) : super(key: key);

  Color _getTextPrimary(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  Color _getTextSecondary(BuildContext context) => Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280);
  Color _getBorderColor(BuildContext context) => Theme.of(context).dividerColor;
  Color _getBgGray(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant : const Color(0xFFF5F7FA);
  final Color _primaryGreen = const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final customerName = orderData['customerName'] ?? 'Không có tên';
    final phone = orderData['phone'] ?? 'Không có';
    final address = orderData['address'] ?? 'Không có';
    final status = orderData['status'] ?? 'Pending';
    final amount = (orderData['totalAmount'] ?? 0) is num ? (orderData['totalAmount'] as num).toDouble() : double.tryParse((orderData['totalAmount']).toString()) ?? 0;
    
    final itemsRaw = orderData['items'];
    List<dynamic> items = [];
    if (itemsRaw is List) {
       items = itemsRaw;
    }

    return Dialog(
       backgroundColor: Theme.of(context).dialogBackgroundColor,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       child: SizedBox(
          width: 600,
          child: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                // Header
                Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: _getBorderColor(context))),
                   ),
                   child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                Text('Chi tiết Đơn hàng', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: _getTextPrimary(context))),
                                const SizedBox(height: 4),
                                Text('#${orderId.toUpperCase()}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getTextSecondary(context))),
                             ]
                         ),
                         IconButton(
                            icon: Icon(Icons.close, color: _getTextSecondary(context)),
                            onPressed: () => Navigator.of(context).pop(),
                         )
                      ]
                   )
                ),
                Flexible(
                   child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                             // User Info Section
                            Text('Thông tin Khách hàng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: _getTextPrimary(context))),
                            const SizedBox(height: 16),
                            Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(color: _getBgGray(context), borderRadius: BorderRadius.circular(12)),
                               child: Column(
                                  children: [
                                     _buildInfoRow(Icons.person_outline, 'Tên', customerName, context),
                                     const SizedBox(height: 12),
                                     _buildInfoRow(Icons.phone_outlined, 'Điện thoại', phone, context),
                                     const SizedBox(height: 12),
                                     _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ', address, context),
                                  ]
                               )
                            ),
                             const SizedBox(height: 32),
                            // Products Table
                            Text('Danh sách sản phẩm', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: _getTextPrimary(context))),
                            const SizedBox(height: 16),
                            Container(
                               decoration: BoxDecoration(
                                  border: Border.all(color: _getBorderColor(context)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                               child: Column(
                                  children: [
                                     Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(color: _getBgGray(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                                         child: Row(
                                            children: [
                                               Expanded(flex: 3, child: Text('Tên sản phẩm', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: _getTextSecondary(context)))),
                                               Expanded(flex: 1, child: Text('SL', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: _getTextSecondary(context)))),
                                               Expanded(flex: 2, child: Text('Đơn giá', textAlign: TextAlign.right, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: _getTextSecondary(context)))),
                                               Expanded(flex: 2, child: Text('Thành tiền', textAlign: TextAlign.right, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: _getTextSecondary(context)))),
                                            ]
                                         )
                                     ),
                                     ...items.map((item) {
                                         final itemName = item['productName'] ?? 'Không rõ';
                                         final qty = item['quantity'] ?? 1;
                                         final price = (item['price'] ?? 0) is num ? (item['price'] as num).toDouble() : double.tryParse(item['price'].toString()) ?? 0;
                                         return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                            decoration: BoxDecoration(border: Border(top: BorderSide(color: _getBorderColor(context)))),
                                             child: Row(
                                                children: [
                                                   Expanded(flex: 3, child: Text(itemName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _getTextPrimary(context), fontWeight: FontWeight.w500))),
                                                   Expanded(flex: 1, child: Text('x$qty', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _getTextSecondary(context)))),
                                                   Expanded(flex: 2, child: Text('${price.toStringAsFixed(0)} đ', textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _getTextSecondary(context)))),
                                                   Expanded(flex: 2, child: Text('${(price * qty).toStringAsFixed(0)} đ', textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _getTextPrimary(context), fontWeight: FontWeight.w600))),
                                                ]
                                             )
                                         );
                                     }).toList(),
                                  ]
                               )
                            ),
                            const SizedBox(height: 24),
                            // Total Section
                            Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                   Text('Tổng cộng:', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _getTextSecondary(context))),
                                   const SizedBox(width: 16),
                                   Text('${amount.toStringAsFixed(0)} đ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: _primaryGreen)),
                                ]
                            )
                         ]
                      )
                   )
                ),
                // Footer (Status Actions)
                Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                      color: _getBgGray(context),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                   ),
                   child: SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text('Chuyển trạng thái:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: _getTextPrimary(context))),
                           const SizedBox(width: 16),
                           Row(
                              children: [
                                 _buildStatusButton('Pending', 'Đang chờ', Colors.orange, status, context),
                                 const SizedBox(width: 8),
                                 _buildStatusButton('Processing', 'Đang xử lý', Colors.blue, status, context),
                                 const SizedBox(width: 8),
                                 _buildStatusButton('In Transit', 'Đang giao', const Color(0xFF6366F1), status, context),
                                 const SizedBox(width: 8),
                                 _buildStatusButton('Completed', 'Hoàn thành', Colors.green, status, context),
                                 const SizedBox(width: 8),
                                 _buildStatusButton('Cancelled', 'Đã hủy', Colors.red, status, context),
                              ]
                           )
                        ]
                     ),
                   )
                )
             ]
          )
       )
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
      return Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Icon(icon, size: 20, color: _getTextSecondary(context)),
            const SizedBox(width: 12),
             SizedBox(
                width: 80,
                child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getTextSecondary(context))),
             ),
             Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _getTextPrimary(context), fontWeight: FontWeight.w500))),
         ]
      );
  }

  Widget _buildStatusButton(String targetStatus, String displayLabel, Color color, String currentStatus, BuildContext context) {
      final isCurrent = currentStatus == targetStatus;
      return InkWell(
         onTap: () {
            if (!isCurrent) {
               onStatusChange(orderId, targetStatus);
               Navigator.of(context).pop();
            }
         },
         borderRadius: BorderRadius.circular(8),
         child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
               color: isCurrent ? color : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfacePrimary.withValues(alpha: 0.1) : Colors.white),
               border: Border.all(color: isCurrent ? color : _getBorderColor(context)),
               borderRadius: BorderRadius.circular(8),
            ),
             child: Text(
                displayLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                   color: isCurrent ? Colors.white : _getTextSecondary(context),
                   fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                )
             )
         )
      );
  }
}
