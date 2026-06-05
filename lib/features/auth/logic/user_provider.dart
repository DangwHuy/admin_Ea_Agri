import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _role;
  String? get role => _role;

  bool _isSuperAdmin = false;
  bool get isSuperAdmin => _isSuperAdmin;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _displayName;
  String? get displayName => _displayName;

  String? _email;
  String? get email => _email;

  String? _phoneNumber;
  String? get phoneNumber => _phoneNumber;

  String? _photoURL;
  String? get photoURL => _photoURL;

  StreamSubscription? _userSub;
  StreamSubscription? _authSub;

  UserProvider() {
    _init();
  }

  void _init() {
    _authSub = _auth.authStateChanges().listen((user) {
      if (user == null) {
        _role = null;
        _isSuperAdmin = false;
        _displayName = null;
        _email = null;
        _phoneNumber = null;
        _photoURL = null;
        _isLoading = false;
        _userSub?.cancel();
        notifyListeners();
      } else {
        _email = user.email;
        _displayName = user.displayName;
        _photoURL = user.photoURL;
        _listenToUserDoc(user.uid);
      }
    });
  }

  void _listenToUserDoc(String uid) {
    _userSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _userSub = _firestore.collection('users').doc(uid).snapshots().listen((snap) {
      if (snap.exists) {
        final data = snap.data()!;
        _role = data['role'];
        _isSuperAdmin = _role == 'super_admin' || _role == 'admin';
        
        // Prefer Firestore data if available, fallback to Auth data
        _displayName = data['displayName'] ?? _auth.currentUser?.displayName;
        _phoneNumber = data['phoneNumber'];
        _photoURL = data['photoURL'] ?? _auth.currentUser?.photoURL;
        
        debugPrint('UserProvider: Role fetched from Firestore: $_role (isSuperAdmin: $_isSuperAdmin)');
      } else {
        debugPrint('UserProvider: User document NOT found for UID: $uid');
        _role = null;
        _isSuperAdmin = false;
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('UserProvider: Error fetching user doc: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateAdminProfile({String? displayName, String? phoneNumber, String? photoURL}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      // 1. Update Firebase Auth (for Auth features)
      if (displayName != null || photoURL != null) {
        await user.updateProfile(
          displayName: displayName ?? this.displayName,
          photoURL: photoURL ?? this.photoURL,
        );
      }

      // 2. Update Firestore users collection (for app logic)
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['displayName'] = displayName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (photoURL != null) updateData['photoURL'] = photoURL;
      
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception("User not logged in or email is null");

    try {
      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      debugPrint('Error changing password: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }
}
