import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/system_log_model.dart';

class SystemLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<SystemLogModel>> getAllLogs() {
    return _firestore
        .collection('audit_logs') // Single Source of Truth
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SystemLogModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
