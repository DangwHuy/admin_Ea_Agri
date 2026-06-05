import 'package:flutter/material.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../widgets/voucher_dialog.dart';
import '../../../core/widgets/common/glass_container.dart';

// Theme-aware color constants are resolved inside the build method or as getters

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  String _searchQuery = '';

  void _showVoucherDialog({String? voucherId, Map<String, dynamic>? data}) {
    showDialog(
      context: context,
      builder: (_) => VoucherDialog(voucherId: voucherId, initialData: data),
    );
  }

  void _confirmSoftDelete(String voucherId, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Deactivate Voucher', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        content: Text('Are you sure you want to deactivate voucher "$code"?\nThis will prevent future uses but keep historical data intact.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('vouchers').doc(voucherId).update({'isActive': false});
              if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voucher "$code" deactivated safely.')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text('Deactivate', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => context.pop(),
                      tooltip: 'Quay lại Dashboard',
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khuyến mãi & Mã giảm giá',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textHeading),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tạo và quản lý mã giảm giá cho các chiến dịch khách hàng.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showVoucherDialog(),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: Text('Tạo Mã giảm giá', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Data Container
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Action Bar
                   Padding(
                     padding: const EdgeInsets.all(24.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text('Active Campaigns', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                         SizedBox(
                           width: 250,
                           height: 40,
                           child: TextField(
                              decoration: InputDecoration(
                                 hintText: 'Search code...',
                                 hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                                 prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
                                 contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                                 enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                              ),
                              onChanged: (val) {
                                 setState(() {
                                    _searchQuery = val.trim().toLowerCase();
                                 });
                              },
                           )
                         ),
                       ]
                     )
                   ),
                   Divider(height: 1, color: Theme.of(context).dividerColor),
                   // StreamBuilder
                   StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('vouchers').orderBy('createdAt', descending: true).snapshots(),
                      builder: (context, snapshot) {
                         if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(padding: EdgeInsets.all(48.0), child: Center(child: CircularProgressIndicator()));
                         }
                         if (snapshot.hasError) {
                            return Padding(padding: const EdgeInsets.all(48.0), child: Center(child: Text("Error fetching vouchers: ${snapshot.error}", style: const TextStyle(color: Colors.red))));
                         }
                         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Padding(padding: EdgeInsets.all(48.0), child: Center(child: Text("No vouchers found.")));
                         }

                         var docs = snapshot.data!.docs;
                         
                         if (_searchQuery.isNotEmpty) {
                            docs = docs.where((doc) {
                               final data = doc.data() as Map<String, dynamic>;
                               final code = (data['code'] ?? '').toString().toLowerCase();
                               return code.contains(_searchQuery);
                            }).toList();
                         }

                         if (docs.isEmpty) {
                            return const Padding(padding: EdgeInsets.all(48.0), child: Center(child: Text("No vouchers match your search.")));
                         }

                         return DataTable(
                            headingRowColor: WidgetStateProperty.all(Theme.of(context).brightness == Brightness.dark ? Colors.white12 : const Color(0xFFF5F7FA)),
                            dataRowMinHeight: 70,
                            dataRowMaxHeight: 70,
                            columns: [
                               _buildDataColumn('Code'),
                               _buildDataColumn('Type & Value'),
                               _buildDataColumn('Min Order'),
                               _buildDataColumn('Usage'),
                               _buildDataColumn('Expiry Date'),
                               _buildDataColumn('Status'),
                               _buildDataColumn('Actions'),
                            ],
                            rows: docs.map((doc) {
                               final data = doc.data() as Map<String, dynamic>;
                               final String code = data['code'] ?? '';
                               final String type = data['discountType'] ?? 'Percentage';
                               final num value = data['value'] ?? 0;
                               final num minOrder = data['minOrderValue'] ?? 0;
                               final int usageCount = data['usageCount'] ?? 0;
                               final int limit = data['usageLimit'] ?? 0;
                               final bool isActive = data['isActive'] ?? true;
                               final DateTime? expiry = data['expiryDate'] != null ? (data['expiryDate'] as Timestamp).toDate() : null;
                               final String expiryString = expiry != null ? "${expiry.day}/${expiry.month}/${expiry.year}" : "";

                               // Hybrid state logic
                               bool isSystemExpired = false;
                               if (expiry != null && DateTime.now().isAfter(expiry)) {
                                  isSystemExpired = true;
                               }
                               if (limit > 0 && usageCount >= limit) {
                                  isSystemExpired = true;
                               }

                               return DataRow(
                                  cells: [
                                     DataCell(Text(code.toUpperCase(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))),
                                     DataCell(Text(type == 'Percentage' ? '${value.toStringAsFixed(0)}%' : '${value.toStringAsFixed(0)} đ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                                     DataCell(Text(minOrder > 0 ? '${minOrder.toStringAsFixed(0)} đ' : 'None', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color))),
                                     DataCell(Text('$usageCount / $limit', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: (usageCount >= limit) ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface))),
                                     DataCell(Text(expiryString, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isSystemExpired ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodySmall?.color))),
                                     DataCell(_buildStatusBadge(isActive, isSystemExpired)),
                                     DataCell(
                                        Row(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                              IconButton(
                                                 icon: Icon(Icons.edit_outlined, color: Theme.of(context).textTheme.bodySmall?.color),
                                                 tooltip: 'Edit',
                                                 onPressed: () => _showVoucherDialog(voucherId: doc.id, data: data),
                                              ),
                                              if (isActive)
                                                IconButton(
                                                   icon: Icon(Icons.block, color: Theme.of(context).colorScheme.error),
                                                   tooltip: 'Deactivate',
                                                   onPressed: () => _confirmSoftDelete(doc.id, code),
                                                ),
                                           ]
                                        )
                                     )
                                  ]
                               );
                            }).toList()
                         );
                      }
                   )
                ]
              )
            )
          ]
        )
      )
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isSystemExpired) {
    if (!isActive) {
      return _badge('Inactive', Theme.of(context).textTheme.bodySmall!.color!, Theme.of(context).brightness == Brightness.dark ? Colors.white12 : const Color(0xFFF5F7FA));
    }
    if (isSystemExpired) {
      return _badge('Expired', Theme.of(context).colorScheme.error, Theme.of(context).colorScheme.error.withOpacity(0.1));
    }
    return _badge('Active', Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.1));
  }

  Widget _badge(String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
