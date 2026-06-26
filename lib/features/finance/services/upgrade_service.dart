import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/upgrade_request_model.dart';

class UpgradeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<UpgradeRequestModel>> getPendingRequests() {
    return _db
        .collection('upgrade_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => UpgradeRequestModel.fromFirestore(doc))
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
    final int maxAi = (request.requestedTier == 'EXPERT') ? 50 : 200;
    final subscriptionRef = _db
        .collection('users')
        .doc(request.userId)
        .collection('subscription')
        .doc('info');

    batch.set(subscriptionRef, {
      'membership_tier': request.requestedTier,
      'ai_usage_left': maxAi,
      'last_reset_time': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 3. Update daily revenue
    final today = DateTime.now();
    final dayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    batch.set(_db.collection('daily_stats').doc(dayString), {
      'revenue': FieldValue.increment(request.amount),
      'orders': FieldValue.increment(1), 
    }, SetOptions(merge: true));

    await batch.commit();
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
  }
}
