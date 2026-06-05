import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import '../../../core/widgets/common/glass_container.dart';
import '../../../core/widgets/common/custom_admin_toolbar.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  String _searchQuery = "";
  String _selectedFilter = "Lọc theo trạng thái";
  DateTimeRange? _selectedDateRange;
  final List<String> _filters = [
    "Lọc theo trạng thái",
    "Đang chờ",
    "Đã xác nhận",
    "Hoàn thành",
    "Đã hủy",
  ];

  // Phân trang
  int _currentPage = 1;
  final int _itemsPerPage = 4;

  // Bảng màu
  Color _getPrimaryGreen(BuildContext context) =>
      Theme.of(context).primaryColor;
  Color _getTextDark(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  Color _getTextGrey(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF718096);

  // Khởi tạo Stream 1 lần duy nhất để chống giật/nháy màn hình
  late Stream<QuerySnapshot> _appointmentsStream;

  @override
  void initState() {
    super.initState();
    _appointmentsStream = FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('time', descending: true)
        .snapshots();
  }

  String _mapFilterToStatus(String filter) {
    switch (filter) {
      case "Đang chờ":
        return "pending";
      case "Đã xác nhận":
        return "confirmed";
      case "Hoàn thành":
        return "completed";
      case "Đã hủy":
        return "cancelled";
      default:
        return "";
    }
  }

  // Hàm xóa lịch hẹn
  Future<void> _deleteAppointment(String docId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text(
          "Bạn vẫn muốn xóa cuộc hẹn này chứ? Hành động này không thể hoàn tác.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Đồng ý xóa"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa cuộc hẹn thành công")),
        );
      }
    }
  }

  // Hàm tạo lịch hẹn mới
  void _showCreateAppointmentDialog() {
    final farmerNameCtrl = TextEditingController();
    final farmerIdCtrl = TextEditingController();
    final farmerPhoneCtrl = TextEditingController();
    final expertNameCtrl = TextEditingController();
    final expertIdCtrl = TextEditingController();
    DateTime selectedTime = DateTime.now();

    // Tạo sẵn ID cuộc hẹn tự động từ Firestore
    DocumentReference newDocRef = FirebaseFirestore.instance
        .collection('appointments')
        .doc();
    String generatedId = newDocRef.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Tạo lịch hẹn mới",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _getPrimaryGreen(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trường ID tự động do hệ thống đề xuất
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: TextEditingController(text: generatedId),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Mã lịch hẹn (Tự động tạo)",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                _buildTextField("Tên Nông dân", farmerNameCtrl),
                _buildTextField("ID Nông dân", farmerIdCtrl),
                _buildTextField("SĐT Nông dân", farmerPhoneCtrl),
                const Divider(height: 30),
                _buildTextField("Tên Chuyên gia", expertNameCtrl),
                _buildTextField("ID Chuyên gia", expertIdCtrl),
                const SizedBox(height: 16),

                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return ListTile(
                      title: Text(
                        "Thời gian hẹn:",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(selectedTime),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.calendar_month),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: selectedTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          if (!context.mounted) return;
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Lưu vào Firestore dùng ID đã sinh ra
              await newDocRef.set({
                'farmerName': farmerNameCtrl.text.isEmpty
                    ? "Chưa cung cấp"
                    : farmerNameCtrl.text,
                'farmerId': farmerIdCtrl.text.isEmpty
                    ? "N/A"
                    : farmerIdCtrl.text,
                'farmerPhone': farmerPhoneCtrl.text,
                'expertName': expertNameCtrl.text.isEmpty
                    ? "Chưa phân công"
                    : expertNameCtrl.text,
                'expertId': expertIdCtrl.text.isEmpty
                    ? "N/A"
                    : expertIdCtrl.text,
                'time': Timestamp.fromDate(selectedTime),
                'status': 'pending',
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tạo lịch hẹn thành công!")),
                );
              }
            },
            child: const Text("Lưu cuộc hẹn"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Chọn khoảng thời gian',
      saveText: 'Chọn',
      cancelText: 'Hủy',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _currentPage = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _appointmentsStream, // Gọi stream từ biến đã khởi tạo ở initState
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        int total = docs.length;
        int upcoming = docs
            .where(
              (d) =>
                  (d.data() as Map<String, dynamic>)['status'] == 'confirmed',
            )
            .length;
        int completed = docs
            .where(
              (d) =>
                  (d.data() as Map<String, dynamic>)['status'] == 'completed',
            )
            .length;

        // Xử lý bộ lọc & Tìm kiếm (Tìm theo từng chữ cái)
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';
          final farmerName = (data['farmerName'] ?? '')
              .toString()
              .toLowerCase();
          final expertName = (data['expertName'] ?? '')
              .toString()
              .toLowerCase();
          final docId = doc.id.toLowerCase();
          final DateTime appointmentTime = data['time'] != null
              ? (data['time'] as Timestamp).toDate()
              : DateTime.now();

          bool matchTab =
              _selectedFilter == "Lọc theo trạng thái" ||
              status == _mapFilterToStatus(_selectedFilter);
          bool matchSearch =
              _searchQuery.isEmpty ||
              farmerName.contains(_searchQuery) ||
              expertName.contains(_searchQuery) ||
              docId.contains(_searchQuery);

          bool matchDate = true;
          if (_selectedDateRange != null) {
            final start = DateTime(
              _selectedDateRange!.start.year,
              _selectedDateRange!.start.month,
              _selectedDateRange!.start.day,
            );
            final end = DateTime(
              _selectedDateRange!.end.year,
              _selectedDateRange!.end.month,
              _selectedDateRange!.end.day,
              23,
              59,
              59,
            );
            matchDate =
                appointmentTime.isAfter(
                  start.subtract(const Duration(seconds: 1)),
                ) &&
                appointmentTime.isBefore(end.add(const Duration(seconds: 1)));
          }

          return matchTab && matchSearch && matchDate;
        }).toList();

        // Xử lý logic Phân trang
        int totalPages = (filteredDocs.length / _itemsPerPage).ceil();
        if (totalPages == 0) totalPages = 1;
        if (_currentPage > totalPages) _currentPage = totalPages;

        int startIndex = (_currentPage - 1) * _itemsPerPage;
        int endIndex = startIndex + _itemsPerPage;
        if (endIndex > filteredDocs.length) endIndex = filteredDocs.length;

        List<DocumentSnapshot> paginatedDocs = filteredDocs.sublist(
          startIndex,
          endIndex,
        );

        return Padding(
          padding: const EdgeInsets.all(32.0), // Standardized to dashboard 32px
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quản lý lịch hẹn",
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Quản lý và điều phối các cuộc hẹn giữa chuyên gia và nông dân.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- SUMMARY CARDS ---
              Row(
                children: [
                  _buildStatCard(
                    "Tổng lịch hẹn",
                    total.toString(),
                    Icons.calendar_today,
                    const Color(0xFF4CAF50),
                    const Color(0xFFE8F5E9).withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.2
                          : 1.0,
                    ),
                    _getPrimaryGreen(context),
                  ),
                  const SizedBox(width: 24),
                  _buildStatCard(
                    "Lịch sắp tới",
                    upcoming.toString(),
                    Icons.access_time_filled,
                    const Color(0xFF934B22),
                    const Color(0xFFFDF0E7).withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.2
                          : 1.0,
                    ),
                    _getTextDark(context),
                  ),
                  const SizedBox(width: 24),
                  _buildStatCard(
                    "Đã hoàn thành",
                    completed.toString(),
                    Icons.check_circle,
                    const Color(0xFF4CAF50),
                    const Color(0xFFE8F5E9).withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.2
                          : 1.0,
                    ),
                    _getTextDark(context),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Standardized gap from 32 to 24
              // --- TOOLBAR ---
              CustomAdminToolbar(
                height: 56,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 6,
                ),
                children: [
                  // Ô tìm kiếm (Flex 6 = Khớp với 3 cột đầu: 1 + 2 + 3)
                  Expanded(
                    flex: 6,
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                          _currentPage = 1;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm lịch hẹn...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          size: 20,
                        ),
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurfaceVariant
                            : Colors.white.withValues(alpha: 0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bộ lọc trạng thái (Flex 2 - Khớp với cột TRẠNG THÁI)
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedFilter,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.filter_list_rounded,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurfaceVariant
                            : Colors.white.withValues(alpha: 0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                      items: _filters
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedFilter = val;
                            _currentPage = 1;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bộ lọc ngày (Flex 2 - Khớp với cột THỜI GIAN)
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _selectDateRange,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkSurfaceVariant
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedDateRange == null
                                    ? 'Lọc theo ngày'
                                    : '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedDateRange != null)
                              IconButton(
                                icon: const Icon(Icons.close, size: 14),
                                onPressed: () =>
                                    setState(() => _selectedDateRange = null),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nút tạo mới (Flex 1 - Khớp với cột HÀNH ĐỘNG)
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _showCreateAppointmentDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getPrimaryGreen(context),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, size: 18),
                            SizedBox(width: 4),
                            Text(
                              "Tạo mới",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- DATA TABLE ---
              Expanded(
                child: Builder(
                  builder: (context) {
                    final bool isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final headerGlassColor = isDark
                        ? const Color(0x881E2538)
                        : Colors.white.withValues(alpha: 0.4);
                    final bodyGlassColor = isDark
                        ? const Color(0x441E2538)
                        : Colors.white.withValues(alpha: 0.15);
                    final borderColor = isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.06);

                    final headerTextColor = isDark
                        ? _getTextGrey(context)
                        : Colors.black87;

                    return Container(
                      decoration: BoxDecoration(
                        color: bodyGlassColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: headerGlassColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "MÃ LỊCH HẸN",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: headerTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "NÔNG DÂN",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: headerTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "CHUYÊN GIA",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: headerTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "TRẠNG THÁI",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: headerTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "THỜI GIAN",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: headerTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "HÀNH ĐỘNG",
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: headerTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table Body
                          Expanded(
                            child: paginatedDocs.isEmpty
                                ? const Center(
                                    child: Text("Không có dữ liệu phù hợp"),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    itemCount: paginatedDocs.length,
                                    separatorBuilder: (context, index) =>
                                        Divider(height: 1, color: borderColor),
                                    itemBuilder: (context, index) {
                                      final doc = paginatedDocs[index];
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      return _buildDataRow(doc.id, data);
                                    },
                                  ),
                          ),

                          // Pagination Footer
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: borderColor),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Hiển thị ${filteredDocs.isEmpty ? 0 : startIndex + 1} - $endIndex của ${filteredDocs.length} lịch hẹn",
                                  style: TextStyle(
                                    color: _getTextGrey(context),
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Nút Previous
                                    InkWell(
                                      onTap: _currentPage > 1
                                          ? () => setState(() => _currentPage--)
                                          : null,
                                      child: _buildPageIcon(
                                        Icons.chevron_left,
                                        enabled: _currentPage > 1,
                                      ),
                                    ),

                                    // Hiển thị các nút trang 1, 2, 3
                                    for (int i = 1; i <= totalPages; i++)
                                      if (i == 1 ||
                                          i == totalPages ||
                                          (i >= _currentPage - 1 &&
                                              i <= _currentPage + 1))
                                        InkWell(
                                          onTap: () =>
                                              setState(() => _currentPage = i),
                                          child: _buildPageNumber(
                                            i.toString(),
                                            _currentPage == i,
                                          ),
                                        )
                                      else if (i == 2 && _currentPage > 3 ||
                                          i == totalPages - 1 &&
                                              _currentPage < totalPages - 2)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Text("..."),
                                        ),

                                    // Nút Next
                                    InkWell(
                                      onTap: _currentPage < totalPages
                                          ? () => setState(() => _currentPage++)
                                          : null,
                                      child: _buildPageIcon(
                                        Icons.chevron_right,
                                        enabled: _currentPage < totalPages,
                                      ),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color iconBgColor,
    Color valueColor,
  ) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getTextGrey(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String docId, Map<String, dynamic> data) {
    bool isHovered = false;
    final rowHoverColor = Colors.white.withValues(alpha: 0.03);

    final DateTime time = data['time'] != null
        ? (data['time'] as Timestamp).toDate()
        : DateTime.now();
    final String farmerName = data['farmerName'] ?? "N/A";
    final String farmerId = data['farmerId']?.toString() ?? "Chưa có ID";
    final String expertName = data['expertName'] ?? "N/A";
    final String expertId = data['expertId']?.toString() ?? "Chưa có ID";
    final String status = data['status'] ?? "pending";

    String initials = farmerName.isNotEmpty ? farmerName[0].toUpperCase() : "N";

    return StatefulBuilder(
      builder: (context, setRowState) {
        return MouseRegion(
          onEnter: (_) => setRowState(() => isHovered = true),
          onExit: (_) => setRowState(() => isHovered = false),
          child: Container(
            color: isHovered ? rowHoverColor : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Cột 1: Mã Lịch Hẹn
                Expanded(
                  flex: 1,
                  child: Text(
                    docId.substring(0, 8).toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _getTextGrey(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Cột 2: Nông dân
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurfaceVariant
                            : Colors.grey[200],
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: _getTextDark(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              farmerName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getTextDark(context),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID: $farmerId",
                              style: TextStyle(
                                color: _getTextGrey(context),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Cột 3: Chuyên gia
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF4CAF50),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              expertName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _getTextDark(context),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "ID: $expertId",
                              style: TextStyle(
                                color: _getTextGrey(context),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Cột 4: Trạng thái
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildStatusBadge(status),
                  ),
                ),

                // Cột 5: Thời gian
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(time),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getTextDark(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(time),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getTextGrey(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cột 6: Hành động
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'delete') _deleteAppointment(docId);
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Xóa cuộc hẹn',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
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
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color text;
    String labelText;

    if (status == 'confirmed') {
      bg = isDark
          ? Colors.green[900]!.withValues(alpha: 0.3)
          : const Color(0xFFD4EDDA);
      text = isDark ? Colors.green[200]! : const Color(0xFF155724);
      labelText = "Đã xác nhận";
    } else if (status == 'pending') {
      bg = isDark
          ? Colors.orange[900]!.withValues(alpha: 0.3)
          : const Color(0xFFFDE6D8);
      text = isDark ? Colors.orange[200]! : const Color(0xFFC05621);
      labelText = "Đang chờ";
    } else if (status == 'completed') {
      bg = isDark ? Colors.grey[800]! : Colors.grey[200]!;
      text = isDark ? Colors.grey[300]! : Colors.grey[700]!;
      labelText = "Hoàn thành";
    } else {
      bg = isDark
          ? Colors.red[900]!.withValues(alpha: 0.3)
          : const Color(0xFFF8D7DA);
      text = isDark ? Colors.red[200]! : const Color(0xFF721C24);
      labelText = "Đã hủy";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labelText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: text,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPageNumber(String number, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? _getPrimaryGreen(context) : Colors.transparent,
        shape: BoxShape.circle,
        border: isSelected
            ? null
            : Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : Theme.of(context).dividerColor,
              ),
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isSelected ? Colors.white : _getTextDark(context),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPageIcon(IconData icon, {required bool enabled}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: enabled
              ? (isDark ? Colors.grey[600]! : Colors.grey[400]!)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: enabled
            ? _getTextDark(context)
            : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
    );
  }
}
