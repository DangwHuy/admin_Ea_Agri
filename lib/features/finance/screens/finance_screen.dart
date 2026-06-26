import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/common/glass_container.dart';
import '../../../core/widgets/common/custom_admin_table.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/finance_provider.dart';
import '../models/expense_model.dart';
import '../../logs/services/audit_service.dart';
import '../../logs/models/audit_log_model.dart';

  Color _getBgGray(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5) : const Color(0xFFF5F7FA);
  Color _getTextPrimary(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  Color _getTextSecondary(BuildContext context) => Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280);
  Color _getBorderColor(BuildContext context) => Theme.of(context).dividerColor;
  Color _getPrimaryGreen(BuildContext context) => Theme.of(context).primaryColor;
  Color _getWarningRed(BuildContext context) => Theme.of(context).colorScheme.error;
  Color _getInfoBlue(BuildContext context) => Colors.blue;

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    if (financeProvider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)),
      );
    }

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sổ Cái Tài Chính & Đối Soát',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: _getTextPrimary(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tổng quan về dòng tiền, chi phí vận hành và lợi nhuận thực tế.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _getTextSecondary(context)),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddExpenseDialog(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text('Ghi nhận chi phí', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPrimaryGreen(context),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // KPI Row
            Row(
              children: [
                Expanded(child: _buildKPICard(context, 'Tổng Doanh Thu', financeProvider.totalGrossRevenue, _getPrimaryGreen(context), Icons.account_balance_wallet, currencyFormat)),
                const SizedBox(width: 24),
                Expanded(child: _buildKPICard(context, 'Tổng Chi Phí Thực Tế', financeProvider.totalExpenses, _getWarningRed(context), Icons.payments, currencyFormat)),
                const SizedBox(width: 24),
                Expanded(child: _buildKPICard(context, 'Lợi Nhuận Ròng', financeProvider.netProfit, _getInfoBlue(context), Icons.trending_up, currencyFormat, isNet: true)),
              ],
            ),
            const SizedBox(height: 32),

            // Charts
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phân Tích Dòng Tiền Thật', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 350,
                          child: _buildRevenueChart(context, financeProvider),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Biểu đồ Doanh thu (7 ngày)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 350,
                          child: _buildExpensePieChart(context, financeProvider),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Expense Ledger
            _buildExpenseTable(context, financeProvider, currencyFormat),
            const SizedBox(height: 32),
            
            // Revenue Ledger
            _buildRevenueTable(context, financeProvider, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(BuildContext context, String title, double value, Color iconColor, IconData icon, NumberFormat formatter, {bool isNet = false}) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      color: isNet ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant : _getTextPrimary(context)) : null,
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Row(
               children: [
                  Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(color: isNet ? Colors.white.withOpacity(0.1) : iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                     child: Icon(icon, color: isNet ? Colors.white : iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isNet ? Colors.white70 : _getTextSecondary(context), fontWeight: FontWeight.w500)),
               ]
            ),
            const SizedBox(height: 16),
            Text(formatter.format(value), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: isNet ? Colors.white : _getTextPrimary(context))),
         ]
      )
    );
  }

  Widget _buildRevenueChart(BuildContext context, FinanceProvider provider) {
    if (provider.totalGrossRevenue == 0 && provider.totalExpenses == 0) {
      return Center(child: Text('Chưa có dữ liệu giao dịch.', style: Theme.of(context).textTheme.bodyMedium));
    }

    final double maxVal = math.max(provider.totalGrossRevenue, provider.totalExpenses);
    final double minVal = math.min(0.0, provider.netProfit);

    final double padding = 1.4;
    final double chartMaxY = maxVal == 0 ? 1000 : maxVal * padding;
    final double chartMinY = minVal == 0 ? 0 : minVal * padding;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        minY: chartMinY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent, 
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(rod.toY),
                Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: _getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                final style = TextStyle(color: _getTextSecondary(context), fontWeight: FontWeight.bold, fontSize: 13);
                switch (value.toInt()) {
                  case 0: return SideTitleWidget(meta: meta, space: 12, child: Text('Doanh Thu', style: style));
                  case 1: return SideTitleWidget(meta: meta, space: 12, child: Text('Chi Phí', style: style));
                  case 2: return SideTitleWidget(meta: meta, space: 12, child: Text('Lợi Nhuận', style: style));
                  default: return const Text('');
                }
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal > 0 ? maxVal / 5 : 1000,
          getDrawingHorizontalLine: (value) {
            if (value == 0) {
              return FlLine(color: _getTextSecondary(context), strokeWidth: 1);
            }
            return FlLine(color: _getBorderColor(context), strokeWidth: 0.5, dashArray: [5, 5]);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              fromY: 0,
              toY: provider.totalGrossRevenue, 
              color: _getPrimaryGreen(context), 
              width: 60, 
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            )
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
              fromY: 0,
              toY: provider.totalExpenses, 
              color: _getWarningRed(context), 
              width: 60, 
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            )
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(
              fromY: 0,
              toY: provider.netProfit, 
              color: _getInfoBlue(context), 
              width: 60, 
              borderRadius: provider.netProfit >= 0 
                  ? const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
                  : const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            )
          ]),
        ],
      ),
    );
  }

  Widget _buildExpensePieChart(BuildContext context, FinanceProvider provider) {
    final Map<String, double> categories = {};
    for (var exp in provider.expenses) {
      categories[exp.category] = (categories[exp.category] ?? 0) + exp.amount;
    }

    if (categories.isEmpty) return Center(child: Text('Chưa có chi phí ghi nhận.', style: Theme.of(context).textTheme.bodyMedium));

    final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal, Colors.red];

    return PieChart(
      PieChartData(
        sections: categories.entries.map((e) {
          final index = categories.keys.toList().indexOf(e.key) % colors.length;
          return PieChartSectionData(
            value: e.value,
            title: e.key,
            color: colors[index],
            radius: 100,
            titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpenseTable(BuildContext context, FinanceProvider provider, NumberFormat formatter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nhật Ký Chi Phí Thực Tế', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              Text('${provider.expenses.length} bản ghi', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getTextSecondary(context))),
            ],
          ),
        ),

        // CustomAdminTable — golden rule
        SizedBox(
          height: provider.expenses.isEmpty ? 200 : (provider.expenses.length * 72.0 + 80).clamp(200, 600),
          child: CustomAdminTable(
            flex: const [2, 2, 4, 2, 1],
            labels: const ['Ngày', 'Danh mục', 'Mô tả', 'Số tiền', 'Thao tác'],
            itemCount: provider.expenses.length,
            onRowTapWithIndex: (_) {},
            rowBuilder: (context, index) {
              final expense = provider.expenses[index];
              return [
                // Date
                Text(
                  DateFormat('dd/MM/yyyy').format(expense.date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                // Category — Chip
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(expense.category, style: Theme.of(context).textTheme.labelSmall),
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.4),
                    side: BorderSide.none,
                  ),
                ),

                // Description
                Text(
                  expense.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _getTextPrimary(context)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Amount
                Text(
                  formatter.format(expense.amount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getWarningRed(context),
                  ),
                ),

                // Delete action
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: _getWarningRed(context), size: 20),
                    tooltip: 'Xóa',
                    onPressed: () => provider.deleteExpense(expense.id),
                  ),
                ),
              ];
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueTable(BuildContext context, FinanceProvider provider, NumberFormat formatter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nhật Ký Doanh Thu (Tiền vào)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              Text('${provider.revenues.length} bản ghi', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _getTextSecondary(context))),
            ],
          ),
        ),
        SizedBox(
          height: provider.revenues.isEmpty ? 200 : (provider.revenues.length * 72.0 + 80).clamp(200, 600),
          child: CustomAdminTable(
            flex: const [2, 2, 4, 2], // Không cần cột Thao tác
            labels: const ['Ngày', 'Nguồn thu', 'Mô tả', 'Số tiền'],
            itemCount: provider.revenues.length,
            onRowTapWithIndex: (_) {},
            rowBuilder: (context, index) {
              final revenue = provider.revenues[index];
              return [
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(revenue.date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(revenue.source, style: Theme.of(context).textTheme.labelSmall),
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white.withValues(alpha: 0.4),
                    side: BorderSide.none,
                  ),
                ),
                Text(
                  revenue.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _getTextPrimary(context)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatter.format(revenue.amount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getPrimaryGreen(context),
                  ),
                ),
              ];
            },
          ),
        ),
      ],
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddExpenseDialog(),
    );
  }
}

class _AddExpenseDialog extends StatefulWidget {
  const _AddExpenseDialog();

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Vận chuyển';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  Future<void> _handleSave() async {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText) ?? 0;
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Vui lòng nhập số tiền hợp lệ (> 0 đ)'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final expense = ExpenseModel(
        id: '',
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        description: _descController.text.trim(),
      );

      await context.read<FinanceProvider>().addExpense(expense);
      
      // Log Action for Security Audit
      await AuditService.logAction(
        type: AuditActionType.create,
        module: AuditModule.finance,
        description: "Ghi nhận chi phí mới: ${expense.category} - ${NumberFormat('#,###').format(expense.amount)} đ",
        details: {
          'category': expense.category,
          'amount': expense.amount,
          'description': expense.description,
          'date': expense.date.toIso8601String(),
        },
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Đã lưu ghi nhận chi phí thành công'), backgroundColor: Theme.of(context).primaryColor),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Lỗi hệ thống'),
            content: Text('Không thể lưu dữ liệu: $e.\nVui lòng kiểm tra kết nối mạng hoặc quyền truy cập Firestore.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Vận chuyển', 'Chuyên gia', 'Kho bãi', 'Marketing', 'Khác'];

    return AlertDialog(
      title: Text('Ghi nhận chi phí mới', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số tiền (đ)', 
                border: OutlineInputBorder(),
                hintText: 'Ví dụ: 500000',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: _isSaving ? null : (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _isSaving ? null : () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Ngày chi', border: OutlineInputBorder()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    Icon(Icons.calendar_today, size: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              enabled: !_isSaving,
              decoration: const InputDecoration(labelText: 'Mô tả / Ghi chú', border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context), 
          child: Text('Hủy', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            minimumSize: const Size(120, 45),
          ),
          child: _isSaving 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('Lưu ghi nhận', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
