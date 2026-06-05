import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'vouchers';

  Future<QuerySnapshot> fetchVouchersPage({
    String? sellerIdSearch,
    DocumentSnapshot? lastDoc,
    int limit = 50,
  }) async {
    Query query = _db.collection(_collection)
        .orderBy('createdAt', descending: true);

    if (sellerIdSearch != null && sellerIdSearch.isNotEmpty) {
      query = query.where('sellerId', isEqualTo: sellerIdSearch);
    }

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return await query.limit(limit).get();
  }

  Future<void> updateVoucherStatus(String id, bool isActive) async {
    await _db.collection(_collection).doc(id).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
