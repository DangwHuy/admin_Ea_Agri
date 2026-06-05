import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:cloud_functions/cloud_functions.dart';
import '../../../core/constants/app_colors.dart';
import '../models/expert_verification_request_model.dart';
import '../services/expert_verification_service.dart';

class ExpertRequestDetailDialog extends StatefulWidget {
  final ExpertVerificationRequestModel request;
  final VoidCallback onProcessed;

  const ExpertRequestDetailDialog({
    super.key,
    required this.request,
    required this.onProcessed,
  });

  @override
  State<ExpertRequestDetailDialog> createState() =>
      _ExpertRequestDetailDialogState();
}

class _ExpertRequestDetailDialogState extends State<ExpertRequestDetailDialog> {
  final ExpertVerificationService _service = ExpertVerificationService();
  bool _isProcessing = false;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  Future<void> _handleAction(bool isApproved) async {
    setState(() => _isProcessing = true);
    try {
      await _service.processRequest(
        requestId: widget.request.id,
        userId: widget.request.userId,
        isApproved: isApproved,
      );
      
      if (mounted) {
        _showSuccess(isApproved);
        widget.onProcessed();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccess(bool isApproved) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isApproved ? 'Đã duyệt chuyên gia thành công' : 'Đã từ chối yêu cầu'),
        backgroundColor: isApproved ? Colors.green[700] : Colors.red[700],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi: $message'), backgroundColor: Colors.red),
    );
  }

  void _openUrl(String url) {
    html.window.open(url, '_blank');
  }

  Future<void> _runAIAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final List<String> imageUrls = [];
      if (widget.request.portfolioUrl.isNotEmpty) imageUrls.add(widget.request.portfolioUrl);
      imageUrls.addAll(widget.request.evidenceDocuments);

      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'asia-southeast1')
          .httpsCallable('analyzeExpertRequest');

      final result = await callable.call({
        'requestId': widget.request.id,
        'imageUrls': imageUrls,
        'expertInfo': {
          'fullName': widget.request.fullName,
          'expertise': widget.request.expertise,
          'workplace': widget.request.workplace,
          'bio': widget.request.bio,
        },
      });

      if (mounted) {
        setState(() {
          _analysisResult = result.data['analysis'];
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _showError('Lỗi phân tích AI: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 650,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            const Divider(height: 1),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Thông tin cá nhân'),
                    const SizedBox(height: 16),
                    _buildInfoGrid(),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('Tiểu sử & Kinh nghiệm'),
                    const SizedBox(height: 12),
                    _buildBioCard(),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('Tài liệu minh chứng'),
                    const SizedBox(height: 12),
                    _buildEvidenceGrid(),

                    if (_isAnalyzing || _analysisResult != null) ...[
                      const SizedBox(height: 32),
                      _buildSectionHeader('Báo cáo hỗ trợ từ AI (Trợ lý Gemini)'),
                      const SizedBox(height: 12),
                      _buildAIAnalysisSection(),
                    ],
                  ],
                ),
              ),
            ),
            
            const Divider(height: 1),
            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Hồ sơ xác minh chuyên gia',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              if (!_isAnalyzing && _analysisResult == null)
                TextButton.icon(
                  onPressed: _runAIAnalysis,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('AI PHÂN TÍCH'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.purple[700],
                    backgroundColor: Colors.purple[50],
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Wrap(
      spacing: 40,
      runSpacing: 16,
      children: [
        _buildInfoItem('Họ tên', widget.request.fullName, width: 250),
        _buildInfoItem('Số điện thoại', widget.request.phone, width: 250),
        _buildInfoItem('Chuyên môn', widget.request.expertise, width: 250),
        _buildInfoItem('Cơ quan', widget.request.workplace, width: 250),
        _buildInfoItem('Trình độ', widget.request.education, width: 250),
        _buildInfoItem('Kỹ năng', widget.request.skills, width: 250),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {double? width}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        widget.request.bio.isEmpty ? 'Không có thông tin giới thiệu.' : widget.request.bio,
        style: const TextStyle(height: 1.5, fontSize: 14),
      ),
    );
  }

  Widget _buildEvidenceGrid() {
    // 1. Gom tất cả tài liệu vào 1 list (bao gồm cả portfolioUrl từ Mobile gửi lên)
    List<String> filesToShow = [];

    if (widget.request.portfolioUrl.isNotEmpty) {
      filesToShow.add(widget.request.portfolioUrl);
    }

    if (widget.request.evidenceDocuments.isNotEmpty) {
      filesToShow.addAll(widget.request.evidenceDocuments);
    }

    // 2. Kiểm tra nếu không có file nào
    if (filesToShow.isEmpty) {
      return const Text('Không có tài liệu đính kèm',
          style: TextStyle(fontStyle: FontStyle.italic));
    }

    // 3. Hiển thị danh sách file
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: filesToShow.map((url) => _buildEvidenceCard(url)).toList(),
    );
  }

  // Hàm hỗ trợ nhận diện loại file từ URL Firebase
  String _getFileType(String url) {
    final lowerUrl = url.toLowerCase();
    final cleanUrl = lowerUrl.split('?').first; // Bỏ phần token của Firebase

    if (cleanUrl.contains('.pdf') || lowerUrl.contains('pdf')) return 'pdf';
    if (cleanUrl.contains('.doc') || cleanUrl.contains('.docx')) return 'word';
    if (cleanUrl.contains('.jpg') || cleanUrl.contains('.jpeg') || cleanUrl.contains('.png')) return 'image';

    return 'unknown';
  }

  Widget _buildEvidenceCard(String url) {
    final String fileType = _getFileType(url);
    final bool isImage = fileType == 'image';

    return Tooltip(
      message: 'Nhấn để mở/tải tài liệu',
      child: InkWell(
        onTap: () => _openUrl(url), // Mở link sang tab mới
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: isImage ? 140 : 160,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceVariant
                : Colors.grey[100],
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: isImage
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
            ),
          )
              : _buildDocumentIcon(fileType),
        ),
      ),
    );
  }

  // Giao diện Icon cho file PDF / Word
  Widget _buildDocumentIcon(String fileType) {
    IconData icon = Icons.insert_drive_file;
    Color color = Colors.blueGrey;
    String label = 'Tài liệu';

    if (fileType == 'pdf') {
      icon = Icons.picture_as_pdf;
      color = Colors.red[400]!;
      label = 'File PDF';
    } else if (fileType == 'word') {
      icon = Icons.description;
      color = Colors.blue[600]!;
      label = 'File Word';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 2),
        const Text('Nhấn để xem', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }


  Widget _buildAIAnalysisSection() {
    if (_isAnalyzing) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.purple[50]?.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple[100]!),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
            const SizedBox(height: 16),
            Text('AI Gemini đang đọc tài liệu và phân tích hồ sơ...',
                style: TextStyle(color: Colors.purple[900], fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    final String recommendation = _analysisResult?['recommendation'] ?? 'UNKNOWN';
    double rawConfidence = (_analysisResult?['confidenceScore'] ?? 0.0) is int 
        ? (_analysisResult?['confidenceScore'] as int).toDouble() 
        : (_analysisResult?['confidenceScore'] ?? 0.0);
    
    // Chuyển đổi "Độ tự tin của AI" thành "Độ tin cậy của hồ sơ"
    // Nếu AI rất tự tin (ví dụ 95%) rằng hồ sơ CÓ VẤN ĐỀ (Từ chối / Cảnh báo), thì độ tin cậy của hồ sơ thực tế chỉ là 5%.
    double displayReliability = rawConfidence;
    if (recommendation == 'DE_XUAT_TU_CHOI' || recommendation == 'CAN_KIEM_TRA_LAI') {
      displayReliability = 1.0 - rawConfidence;
      // Đảm bảo không bị âm trong trường hợp ngoại lệ
      if (displayReliability < 0) displayReliability = 0;
    }

    Color statusColor = Colors.grey;
    String statusTitle = 'CHƯA XÁC ĐỊNH';
    IconData statusIcon = Icons.help_outline;

    if (recommendation == 'DE_XUAT_DUYET') {
      statusColor = Colors.green;
      statusTitle = 'GỢI Ý: CHẤP THUẬN';
      statusIcon = Icons.check_circle;
    } else if (recommendation == 'DE_XUAT_TU_CHOI') {
      statusColor = Colors.red;
      statusTitle = 'GỢI Ý: TỪ CHỐI';
      statusIcon = Icons.cancel;
    } else {
      statusColor = Colors.orange;
      statusTitle = 'GỢI Ý: CẦN KIỂM TRA LẠI';
      statusIcon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Text(statusTitle, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Text('Độ tin cậy: ${(displayReliability * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          _buildAIInfoRow('Thông tin trích xuất:', _analysisResult?['fullName'] ?? '--'),
          _buildAIInfoRow('Loại giấy tờ:', _analysisResult?['documentType'] ?? '--'),
          _buildAIInfoRow('Hạn dùng:', _analysisResult?['expiryDate'] ?? 'Không rõ'),
          const Divider(height: 24),
          const Text('LÝ DO PHÂN TÍCH:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(_analysisResult?['reason'] ?? 'Không có giải thích chi tiết.', style: const TextStyle(height: 1.5, fontSize: 13.5)),
        ],
      ),
    );
  }

  Widget _buildAIInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isProcessing ? null : () => _handleAction(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text('TỪ CHỐI DUYỆT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isProcessing ? null : () => _handleAction(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isProcessing
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('CHẤP THUẬN CHUYÊN GIA', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
