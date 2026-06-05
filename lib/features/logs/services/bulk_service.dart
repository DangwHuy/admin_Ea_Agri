import 'package:cloud_firestore/cloud_firestore.dart';
import 'audit_service.dart';
import '../models/audit_log_model.dart';

class BulkService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Updates multiple documents in a collection atomically using WriteBatch.
  /// Handles chunking for lists larger than 500 documents.
  static Future<void> updateDocuments({
    required String collection,
    required List<String> docIds,
    required Map<String, dynamic> data,
    required AuditModule module,
    required String actionDescription,
  }) async {
    if (docIds.isEmpty) return;

    final List<List<String>> chunks = _chunkList(docIds, 500);

    for (final chunk in chunks) {
      final WriteBatch batch = _firestore.batch();
      for (final id in chunk) {
        batch.update(_firestore.collection(collection).doc(id), {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }

    // Log atomic bulk action to Audit Service
    await AuditService.logAction(
      type: AuditActionType.update,
      module: module,
      description: "$actionDescription (Số lượng: ${docIds.length} mục)",
      details: {
        'collection': collection,
        'docCount': docIds.length,
        'updateData': data,
      },
    );
  }

  /// Deletes multiple documents in a collection atomically using WriteBatch.
  /// Handles chunking for lists larger than 500 documents.
  static Future<void> deleteDocuments({
    required String collection,
    required List<String> docIds,
    required AuditModule module,
    required String actionDescription,
  }) async {
    if (docIds.isEmpty) return;

    final List<List<String>> chunks = _chunkList(docIds, 500);

    for (final chunk in chunks) {
      final WriteBatch batch = _firestore.batch();
      for (final id in chunk) {
        batch.delete(_firestore.collection(collection).doc(id));
      }
      await batch.commit();
    }

    // Log atomic bulk action to Audit Service
    await AuditService.logAction(
      type: AuditActionType.delete,
      module: module,
      description: "$actionDescription (Số lượng: ${docIds.length} mục)",
      details: {
        'collection': collection,
        'docCount': docIds.length,
        'deletedIds': docIds,
      },
    );
  }

  /// Helper to split a list into smaller lists of specified size
  static List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}
