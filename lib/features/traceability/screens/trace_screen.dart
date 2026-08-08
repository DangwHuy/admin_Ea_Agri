import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TraceScreen extends StatefulWidget {
  final String harvestId;

  const TraceScreen({Key? key, required this.harvestId}) : super(key: key);

  @override
  State<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  bool _isLoading = true;
  String _error = '';
  
  Map<String, dynamic>? _harvestData;
  Map<String, dynamic>? _treeData;
  Map<String, dynamic>? _farmData;
  List<Map<String, dynamic>> _diaryEntries = [];

  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _lightGreen = const Color(0xFFE8F5E9);
  final Color _bgColor = const Color(0xFFF4F9F4);
  final Color _textColor = const Color(0xFF1E293B);
  final Color _subTextColor = const Color(0xFF64748B);

  // Default language
  String _currentLang = 'vi';

  // Local translations
  final Map<String, Map<String, String>> _dict = {
    'vi': {
      'title': 'Truy Xuất Nguồn Gốc',
      'invalid_code': 'Mã truy xuất không hợp lệ.',
      'not_found': 'Không tìm thấy thông tin lô hàng.',
      'durian': 'SẦU RIÊNG SẠCH',
      'code': 'Mã: ',
      'verified': 'Đã xác thực',
      'data_by': 'Dữ liệu nguồn gốc được ghi nhận bởi Ea Agri',
      'weight': 'Khối lượng',
      'harvest_date': 'Ngày thu hoạch',
      'tree_origin': 'Nguồn cây',
      'plant_year': 'Năm trồng',
      'batch_info': 'Thông Tin Lô Hàng',
      'cut_date': 'Ngày cắt',
      'harvester': 'Người cắt',
      'facility': 'Cơ sở ĐG',
      'farm_origin': 'Nguồn Gốc Nông Trại',
      'area_code': 'Mã vùng trồng:',
      'journey': 'Hành Trình Sản Phẩm',
      'step_plant': 'Trồng cây',
      'step_care': 'Chăm sóc',
      'step_harvest': 'Thu hoạch',
      'step_pack': 'Đóng gói',
      'step_verify': 'Xác thực',
      'diary': 'Nhật ký chăm sóc từ nông trại',
      'no_diary': 'Chưa có dữ liệu chăm sóc',
      'latest': 'Gần nhất: ',
      'harvester_label': 'Người cắt: ',
      'facility_label': 'Cơ sở: ',
      'verified_desc': 'Đã xác thực nguồn gốc trên nền tảng Ea Agri',
      'trust_title': 'Ea Agri - Minh Bạch & An Toàn',
      'trust_desc': 'Sản phẩm được xác thực nguồn gốc trên nền tảng số. Dữ liệu được ghi nhận minh bạch từ nông trại đến tay người tiêu dùng.',
      'activities': 'hoạt động',
      'unknown': 'Không rõ',
      'unnamed_farm': 'Vườn Không Tên',
    },
    'en': {
      'title': 'Traceability',
      'invalid_code': 'Invalid trace code.',
      'not_found': 'Batch information not found.',
      'durian': 'PREMIUM DURIAN',
      'code': 'Code: ',
      'verified': 'Verified',
      'data_by': 'Origin data recorded by Ea Agri',
      'weight': 'Weight',
      'harvest_date': 'Harvest Date',
      'tree_origin': 'Tree Origin',
      'plant_year': 'Planted Year',
      'batch_info': 'Batch Information',
      'cut_date': 'Cut Date',
      'harvester': 'Harvester',
      'facility': 'Packing House',
      'farm_origin': 'Farm Origin',
      'area_code': 'Planting Area Code:',
      'journey': 'Product Journey',
      'step_plant': 'Planting',
      'step_care': 'Care',
      'step_harvest': 'Harvesting',
      'step_pack': 'Packaging',
      'step_verify': 'Verification',
      'diary': 'Farm care diary',
      'no_diary': 'No care data yet',
      'latest': 'Latest: ',
      'harvester_label': 'Harvester: ',
      'facility_label': 'Facility: ',
      'verified_desc': 'Origin verified on the Ea Agri platform',
      'trust_title': 'Ea Agri - Transparent & Safe',
      'trust_desc': 'Product origin is digitally verified. Data is transparently recorded from the farm to the consumer.',
      'activities': 'activities',
      'unknown': 'Unknown',
      'unnamed_farm': 'Unnamed Farm',
    },
    'zh': {
      'title': '产品追溯',
      'invalid_code': '无效的追溯码。',
      'not_found': '未找到批次信息。',
      'durian': '纯净榴莲',
      'code': '编码：',
      'verified': '已认证',
      'data_by': '追溯数据由 Ea Agri 记录',
      'weight': '重量',
      'harvest_date': '采收日期',
      'tree_origin': '树源',
      'plant_year': '种植年份',
      'batch_info': '批次信息',
      'cut_date': '采摘日期',
      'harvester': '采摘人',
      'facility': '包装设施',
      'farm_origin': '农场来源',
      'area_code': '种植区代码：',
      'journey': '产品历程',
      'step_plant': '种植',
      'step_care': '护理',
      'step_harvest': '采收',
      'step_pack': '包装',
      'step_verify': '认证',
      'diary': '农场护理日记',
      'no_diary': '暂无护理数据',
      'latest': '最新：',
      'harvester_label': '采摘人：',
      'facility_label': '设施：',
      'verified_desc': '已在 Ea Agri 平台认证溯源',
      'trust_title': 'Ea Agri - 透明与安全',
      'trust_desc': '产品来源在数字平台认证。数据从农场到消费者透明记录。',
      'activities': '项活动',
      'unknown': '未知',
      'unnamed_farm': '未命名农场',
    }
  };

  String t(String key) {
    return _dict[_currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    if (widget.harvestId.isEmpty) {
      _error = 'invalid_code';
      _isLoading = false;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final db = FirebaseFirestore.instance;
      
      final harvestDoc = await db.collection('harvests').doc(widget.harvestId).get();
      if (!harvestDoc.exists) throw 'not_found';
      _harvestData = harvestDoc.data();
      
      if (_harvestData != null && _harvestData!['treeId'] != null) {
        final treeDoc = await db.collection('trees').doc(_harvestData!['treeId']).get();
        if (treeDoc.exists) _treeData = treeDoc.data();
      }

      if (_harvestData != null && _harvestData!['farmId'] != null) {
        final farmDoc = await db.collection('farms').doc(_harvestData!['farmId']).get();
        if (farmDoc.exists) {
          _farmData = farmDoc.data();
          
          if (_farmData != null && _farmData!['ownerId'] != null) {
             final diaryQuery = await db.collection('users')
                 .doc(_farmData!['ownerId'])
                 .collection('farms')
                 .doc(_harvestData!['farmId'])
                 .collection('diary')
                 .orderBy('date', descending: true)
                 .get();
             _diaryEntries = diaryQuery.docs.map((doc) => doc.data()).toList();
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(dynamic timestamp, {bool includeTime = true}) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return DateFormat(includeTime ? 'dd/MM/yyyy • HH:mm' : 'dd/MM/yyyy').format(timestamp.toDate());
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _primaryGreen)),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red.shade400, size: 64),
              const SizedBox(height: 16),
              Text(t(_error), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            color: _bgColor,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 16),
                        _buildQuickStats(),
                        const SizedBox(height: 24),
                        _buildBatchInfo(),
                        const SizedBox(height: 24),
                        _buildFarmOrigin(),
                        const SizedBox(height: 24),
                        _buildProductJourney(),
                        const SizedBox(height: 32),
                        _buildTrustFooter(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: _primaryGreen,
      pinned: true,
      elevation: 4,
      shadowColor: Colors.black26,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        t('title'),
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.language, color: Colors.white),
          onSelected: (String lang) {
            setState(() {
              _currentLang = lang;
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'vi',
              child: Text('🇻🇳 Tiếng Việt'),
            ),
            const PopupMenuItem<String>(
              value: 'en',
              child: Text('🇬🇧 English'),
            ),
            const PopupMenuItem<String>(
              value: 'zh',
              child: Text('🇨🇳 中文'),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: _lightGreen,
              image: _harvestData?['imageUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(_harvestData!['imageUrl']),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/images/nensauriengsach.png'), 
                      fit: BoxFit.cover,
                    ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                  stops: const [0.4, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              child: Text(
                t('durian'),
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t('code')}${widget.harvestId.length > 8 ? widget.harvestId.substring(0, 8) : widget.harvestId}',
                      style: TextStyle(color: _subTextColor, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.qr_code, size: 24, color: Colors.black54),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (_harvestData?['quality'] != null)
                      _buildBadge(_harvestData!['quality'], _primaryGreen, _lightGreen),
                    if (_farmData?['certifications'] != null && _farmData!['certifications'].isNotEmpty)
                      ...(_farmData!['certifications'] as List).map((c) => _buildBadge(c.toString(), const Color(0xFFE65100), const Color(0xFFFFF3E0))),
                    _buildBadge(t('verified'), _primaryGreen, _lightGreen, icon: Icons.check_circle),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, size: 20, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t('data_by'),
                          style: TextStyle(color: Colors.blue.shade800, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16, color: textColor), const SizedBox(width: 6)],
          Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.1,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(Icons.scale, t('weight'), '${_harvestData?['weight'] ?? 0} kg'),
        _buildStatCard(Icons.event, t('harvest_date'), _formatDate(_harvestData?['harvestDate'], includeTime: false)),
        _buildStatCard(Icons.eco, t('tree_origin'), _treeData?['name'] ?? 'N/A'),
        _buildStatCard(Icons.calendar_month, t('plant_year'), '${_treeData?['plantedYear'] ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _lightGreen, shape: BoxShape.circle),
            child: Icon(icon, color: _primaryGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(color: _textColor, fontWeight: FontWeight.w800, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(color: _subTextColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBatchInfo() {
    return _buildSectionContainer(
      title: t('batch_info'),
      icon: Icons.inventory,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 20) / 2;
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              SizedBox(width: width, child: _buildInfoRowCompact(Icons.event_note, t('cut_date'), _formatDate(_harvestData?['harvestDate']))),
              SizedBox(width: width, child: _buildInfoRowCompact(Icons.person, t('harvester'), _harvestData?['workerName'] ?? t('unknown'))),
              SizedBox(width: width, child: _buildInfoRowCompact(Icons.scale, t('weight'), '${_harvestData?['weight'] ?? 0} kg')),
              SizedBox(width: width, child: _buildInfoRowCompact(Icons.domain, t('facility'), _harvestData?['packingHouseCode'] ?? 'N/A')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRowCompact(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _primaryGreen.withOpacity(0.8)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: _subTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFarmOrigin() {
    return _buildSectionContainer(
      title: t('farm_origin'),
      icon: Icons.location_on,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.map, color: Color(0xFF2E7D32), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_farmData?['name'] ?? t('unnamed_farm'), style: TextStyle(color: _textColor, fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: _subTextColor),
                        const SizedBox(width: 6),
                        Expanded(child: Text(_farmData?['address'] ?? 'N/A', style: TextStyle(color: _subTextColor, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          if (_farmData?['plantingAreaCode'] != null && _farmData!['plantingAreaCode'].toString().isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              children: [
                Icon(Icons.map, size: 20, color: _primaryGreen.withOpacity(0.8)),
                const SizedBox(width: 10),
                Text(t('area_code'), style: TextStyle(color: _subTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(_farmData!['plantingAreaCode'], style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            )
          ],
        ],
      ),
    );
  }

  Widget _buildProductJourney() {
    return _buildSectionContainer(
      title: t('journey'),
      icon: Icons.route,
      child: Column(
        children: [
          _buildTimelineNode(
            isFirst: true,
            isCompleted: true,
            icon: Icons.eco,
            title: t('step_plant'),
            subtitle: '${t('plant_year')}: ${_treeData?['plantedYear'] ?? 'N/A'}',
          ),
          _buildTimelineNode(
            isCompleted: _diaryEntries.isNotEmpty,
            icon: Icons.local_florist,
            title: t('step_care'),
            subtitle: _diaryEntries.isNotEmpty 
                ? '${t('diary')} (${_diaryEntries.length} ${t('activities')})'
                : t('no_diary'),
            content: _diaryEntries.isNotEmpty ? _buildMiniDiary() : null,
          ),
          _buildTimelineNode(
            isCompleted: true,
            icon: Icons.cut,
            title: t('step_harvest'),
            subtitle: '${_formatDate(_harvestData?['harvestDate'])} • ${t('harvester_label')}${_harvestData?['workerName'] ?? t('unknown')}',
          ),
          _buildTimelineNode(
            isCompleted: true,
            icon: Icons.inventory,
            title: t('step_pack'),
            subtitle: '${t('weight')}: ${_harvestData?['weight'] ?? 0} kg • ${t('facility_label')}${_harvestData?['packingHouseCode'] ?? 'N/A'}',
          ),
          _buildTimelineNode(
            isLast: true,
            isCompleted: true,
            icon: Icons.verified_user,
            title: t('step_verify'),
            subtitle: t('verified_desc'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode({
    bool isFirst = false,
    bool isLast = false,
    required bool isCompleted,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? content,
  }) {
    final color = isCompleted ? _primaryGreen : Colors.grey.shade400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              margin: EdgeInsets.only(top: isFirst ? 0 : 8),
              decoration: BoxDecoration(
                color: isCompleted ? color : Colors.white,
                border: Border.all(color: color, width: 2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isCompleted ? Colors.white : color, size: 18),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: content != null ? 90 : 45,
                color: color.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 4 : 12, bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textColor)),
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.schedule,
                      color: isCompleted ? _primaryGreen : Colors.orange,
                      size: 18,
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(fontSize: 14, color: _subTextColor, height: 1.4)),
                if (content != null) ...[
                  const SizedBox(height: 12),
                  content,
                ]
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMiniDiary() {
    final latestEntry = _diaryEntries.first;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _lightGreen.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryGreen.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 14, color: _primaryGreen),
              const SizedBox(width: 6),
              Text('${t('latest')}${_formatDate(latestEntry['date'], includeTime: false)}', style: TextStyle(fontSize: 12, color: _primaryGreen, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${latestEntry['category'] ?? ''} - ${latestEntry['note'] ?? ''}',
            style: TextStyle(fontSize: 13, color: _textColor, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.security, color: Colors.blue.shade600, size: 48),
          const SizedBox(height: 16),
          Text(
            t('trust_title'),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(
            t('trust_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue.shade700, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primaryGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _textColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
