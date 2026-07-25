import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/upgrade_request_model.dart';
import '../../logs/services/audit_service.dart';
import '../../logs/models/audit_log_model.dart';

class UpgradeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<UpgradeRequestModel>> getAllRequests() {
    return _db
        .collection('upgrade_requests')
        .snapshots()
        .map((snapshot) {
          var requests = snapshot.docs
              .map((doc) => UpgradeRequestModel.fromFirestore(doc))
              .where((req) {
                if (req.status == 'expired') return false;
                if (req.status == 'pending' && DateTime.now().difference(req.createdAt).inMinutes > 10) {
                  return false;
                }
                return true;
              })
              .toList();
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  Future<void> approveRequest(UpgradeRequestModel request, {String? adminMessage}) async {
    final batch = _db.batch();

    // 1. Update upgrade request status
    final requestRef = _db.collection('upgrade_requests').doc(request.id);
    
    final updateData = <String, dynamic>{
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    };
    if (adminMessage != null && adminMessage.isNotEmpty) {
      updateData['adminMessage'] = adminMessage;
    }
    
    batch.update(requestRef, updateData);

    // 2. Update user subscription
    int maxAi = 3;
    if (request.requestedTier == 'EXPERT') maxAi = 15;
    if (request.requestedTier == 'PRO') maxAi = 40;
    
    final subscriptionRef = _db
        .collection('users')
        .doc(request.userId)
        .collection('subscription')
        .doc('info');

    final now = DateTime.now();
    final oneMonthLater = DateTime(now.year, now.month + 1, now.day, now.hour, now.minute, now.second);

    batch.set(subscriptionRef, {
      'membership_tier': request.requestedTier,
      'ai_usage_left': maxAi,
      'last_reset_time': FieldValue.serverTimestamp(),
      'subscription_start_date': FieldValue.serverTimestamp(),
      'subscription_end_date': Timestamp.fromDate(oneMonthLater),
    }, SetOptions(merge: true));

    // 3. Update daily revenue
    final today = DateTime.now();
    final dayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    batch.set(_db.collection('daily_stats').doc(dayString), {
      'revenue': FieldValue.increment(request.amount),
      'orders': FieldValue.increment(1), 
    }, SetOptions(merge: true));

    await batch.commit();

    await AuditService.logAction(
      type: AuditActionType.update,
      module: AuditModule.finance,
      description: "Duyệt nâng cấp gói ${request.requestedTier} cho ${request.userDisplayName ?? request.userId}",
      details: {
        'requestId': request.id,
        'userId': request.userId,
        'tier': request.requestedTier,
        'amount': request.amount,
      },
    );
  }

  Future<void> rejectRequest(String requestId, {String? adminMessage}) async {
    final updateData = <String, dynamic>{
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    };
    if (adminMessage != null && adminMessage.isNotEmpty) {
      updateData['adminMessage'] = adminMessage;
    }
    
    await _db.collection('upgrade_requests').doc(requestId).update(updateData);

    await AuditService.logAction(
      type: AuditActionType.update,
      module: AuditModule.finance,
      description: "Từ chối yêu cầu nâng cấp gói (ID: $requestId)",
      details: {
        'requestId': requestId,
        'adminMessage': adminMessage ?? '',
      },
    );
  }
}
