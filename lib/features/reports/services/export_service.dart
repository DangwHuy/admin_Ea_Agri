import 'dart:convert';
import 'dart:typed_data';
import 'package:admin_daklak_web/features/finance/models/expense_model.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import '../../logs/services/audit_service.dart';
import '../../logs/models/audit_log_model.dart';

class ExportService {
  /// Prepend UTF-8 BOM to satisfy Excel's Vietnamese character rendering
  static const List<int> _utf8Bom = [0xEF, 0xBB, 0xBF];

  /// Core logic to trigger a browser download for a CSV file
  void downloadCsv(List<List<dynamic>> rows, String fileName) {
    // 1. Generate CSV string
    final String csvContent = const ListToCsvConverter().convert(rows);
    
    // 2. Convert CSV string to UTF-8 bytes
    final List<int> bytes = utf8.encode(csvContent);
    
    // 3. Combine BOM [0xEF, 0xBB, 0xBF] with CSV bytes into a single Uint8List
    // This ensures raw bytes are passed to the Blob, not a string representation.
    final Uint8List finalBytes = Uint8List.fromList([..._utf8Bom, ...bytes]);
    
    // 4. Create Blob from the combined raw bytes
    final blob = html.Blob([finalBytes], 'text/csv; charset=utf-8');
    
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..style.display = 'none'
      ..setAttribute("download", "$fileName.csv");
    
    html.document.body!.children.add(anchor);
    anchor.click();
    
    // Cleanup with a small delay to ensure browser doesn't cancel the download
    Future.delayed(const Duration(seconds: 1), () {
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    });

    // Log Action for Security Audit
    AuditService.logAction(
      type: AuditActionType.export,
      module: AuditModule.dashboard, // General dashboard export
      description: "Xuất file CSV: $fileName",
      details: {'fileName': fileName, 'rowCount': rows.length},
    );
  }

  /// Maps Order Data to CSV Rows
  /// Since OrderModel implementation might be distributed, we accept a List of Maps 
  /// representing the 'orders' documents.
  void exportOrdersToCsv(List<Map<String, dynamic>> orders) {
    final List<List<dynamic>> rows = [
      ["ID Đơn Hàng", "Ngày Tạo", "Khách Hàng", "SĐT", "Tổng Tiền", "Trạng Thái", "Ghi Chú"],
    ];

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    for (var order in orders) {
      rows.add([
        order['id'] ?? '',
        order['createdAt'] != null ? dateFormat.format(order['createdAt']) : '',
        order['customerName'] ?? order['userName'] ?? 'Khách lẻ',
        order['customerPhone'] ?? order['userPhone'] ?? '',
        order['totalAmount'] ?? 0,
        _translateStatus(order['status'] ?? ''),
        order['note'] ?? '',
      ]);
    }

    downloadCsv(rows, "Danh_Sach_Don_Hang_${DateFormat('yyyyMMdd').format(DateTime.now())}");
  }

  /// Maps ExpenseModel to CSV Rows
  void exportExpensesToCsv(List<ExpenseModel> expenses) {
    final List<List<dynamic>> rows = [
      ["ID", "Ngày", "Danh Mục", "Số Tiền", "Mô Tả"],
    ];

    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var expense in expenses) {
      rows.add([
        expense.id,
        dateFormat.format(expense.date),
        expense.category,
        expense.amount,
        expense.description,
      ]);
    }

    downloadCsv(rows, "Bao_Cao_Chi_Phi_${DateFormat('yyyyMMdd').format(DateTime.now())}");
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Chờ xử lý';
      case 'confirmed': return 'Đã xác nhận';
      case 'shipping': return 'Đang giao';
      case 'completed': return 'Đã hoàn thành';
      case 'cancelled': return 'Đã hủy';
      default: return status;
    }
  }

  /// Maps AI Chat Logs (from Maps) to CSV Rows
  void exportAiChatLogsToCsv(List<Map<String, dynamic>> logs, String fileNamePrefix) {
    final List<List<dynamic>> rows = [
      ["Thời gian", "ID Chat", "User ID", "Chủ đề", "Trạng thái", "Hành động", "Câu hỏi", "Trả lời"],
    ];

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    for (var log in logs) {
      rows.add([
        log['timestamp'] != null ? dateFormat.format(log['timestamp']) : '',
        log['id'] ?? '',
        log['userId'] ?? '',
        log['category_tag'] ?? '',
        log['status'] ?? '',
        log['action_triggered'] ?? '',
        log['prompt'] ?? '',
        log['response'] ?? '',
      ]);
    }

    downloadCsv(rows, "${fileNamePrefix}_${DateFormat('yyyyMMdd').format(DateTime.now())}");
  }

  /// Maps Admin Logs (from Maps) to CSV Rows
  void exportAdminLogsToCsv(List<Map<String, dynamic>> logs) {
    final List<List<dynamic>> rows = [
      ["Thời gian", "Admin", "Hành động", "Mục tiêu / Chi tiết"],
    ];

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    for (var log in logs) {
      rows.add([
        log['timestamp'] != null ? dateFormat.format(log['timestamp']) : '',
        log['adminEmail'] ?? '',
        log['action'] ?? '',
        log['target'] ?? log['details'] ?? '',
      ]);
    }

    downloadCsv(rows, "Nhat_Ky_Admin_${DateFormat('yyyyMMdd').format(DateTime.now())}");
  }
}
