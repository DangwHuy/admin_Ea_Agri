import 'package:cloud_firestore/cloud_firestore.dart';

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String type; // 'user', 'expert', 'order'
  final String? photoUrl;
  final dynamic rawData;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.photoUrl,
    this.rawData,
  });
}

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SearchResult>> searchGlobal(String query) async {
    final str = query.trim();
    if (str.isEmpty) return [];

    final List<SearchResult> results = [];

    try {
      // 1. Search Users and Experts (by displayName prefix)
      // Note: Because Firestore is case-sensitive, this assumes names are capitalized consistently.
      // Often in production, a 'searchKeywords' array is used, but we'll use startAt/endAt for now.
      final userSnapshot = await _firestore
          .collection('users')
          .orderBy('displayName')
          .startAt([str])
          .endAt(['$str\uf8ff'])
          .limit(10)
          .get();

      for (var doc in userSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] ?? 'user';
        final isExpert = role == 'expert';
        
        results.add(SearchResult(
          id: doc.id,
          title: data['displayName'] ?? 'Unknown',
          subtitle: data['email'] ?? data['phoneNumber'] ?? 'No contact',
          type: isExpert ? 'expert' : 'user',
          photoUrl: data['photoURL'],
          rawData: data,
        ));
      }

      // 2. Search Orders (by exact ID or prefix, but exact ID is safer for Firestore doc IDs)
      // Since order IDs are doc IDs, we can't easily perform a startAt() on doc UI unless we use FieldPath.documentId()
      final orderSnapshot = await _firestore
          .collection('orders')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: str)
          .where(FieldPath.documentId, isLessThanOrEqualTo: '$str\uf8ff')
          .limit(5)
          .get();

      for (var doc in orderSnapshot.docs) {
        final data = doc.data();
        final amount = data['totalAmount'] ?? 0;
        final customerName = data['customerName'] ?? 'Unknown Customer';
        
        results.add(SearchResult(
          id: doc.id,
          title: 'Order ${doc.id.toUpperCase()}',
          subtitle: '$customerName - $amount đ',
          type: 'order',
          rawData: data,
        ));
      }
    } catch (e) {
      // ignore: avoid_print
      print('SearchService Error: $e');
    }

    return results;
  }
}
