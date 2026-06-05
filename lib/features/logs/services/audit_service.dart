import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/audit_log_model.dart';

class AuditService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch the public IP address of the admin (Web-compatible)
  static Future<String> _getIP() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'] ?? 'Unknown IP';
      }
      return 'Unknown IP';
    } catch (e) {
      debugPrint('AuditService: Error fetching IP: $e');
      return 'Unknown IP';
    }
  }

  /// Core method to log an admin action
  static Future<void> logAction({
    required AuditActionType type,
    required AuditModule module,
    required String description,
    Map<String, dynamic>? details,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      final String ip = await _getIP();

      final logData = {
        'adminId': user.uid,
        'adminEmail': user.email ?? 'Unknown Admin',
        'actionType': type.name,
        'module': module.name,
        'description': description,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': ip,
      };

      await _firestore.collection('audit_logs').add(logData);
      
      // Also log to the legacy collection for temporary compatibility if needed
      // (Optional: remove this once all screens migrate to audit_logs)
      await _firestore.collection('admin_logs').add({
        'adminEmail': user.email ?? 'Unknown Admin',
        'adminUid': user.uid,
        'action': "[$module] $description",
        'target': details?.toString() ?? 'N/A',
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      debugPrint('AuditService: Failed to log action: $e');
    }
  }
}
