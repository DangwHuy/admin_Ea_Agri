import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expert_verification_request_model.dart';

class ExpertVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retrieves all expert verification requests.
  Stream<List<ExpertVerificationRequestModel>> getAllRequests() {
    return _firestore
        .collection('expert_requests')
        .snapshots()
        .map((snapshot) {
          final List<ExpertVerificationRequestModel> requests = snapshot.docs
              .map((doc) => ExpertVerificationRequestModel.fromJson(doc.data(), doc.id))
              .toList();
          
          // Client-side sorting: Newest first
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  /// Processes a verification request (Approve or Reject).
  /// Approving will automatically update the user's role to 'expert'.
  Future<void> processRequest({
    required String requestId,
    required String userId,
    required bool isApproved,
  }) async {
    final WriteBatch batch = _firestore.batch();
    
    final requestRef = _firestore.collection('expert_requests').doc(requestId);
    final userRef = _firestore.collection('users').doc(userId);

    // 1. Update request status
    batch.update(requestRef, {
      'status': isApproved ? 'approved' : 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. If approved, upgrade user role to 'expert'
    if (isApproved) {
      batch.update(userRef, {'role': 'expert'});
    }

    await batch.commit();
  }
}
