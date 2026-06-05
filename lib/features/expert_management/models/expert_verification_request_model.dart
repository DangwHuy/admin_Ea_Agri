import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertVerificationRequestModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String education;
  final String workplace;
  final String skills;
  final String expertise;
  final String bio;
  final String portfolioUrl;
  final List<String> evidenceDocuments;
  final String status;
  final DateTime createdAt;
  final double? rating;

  ExpertVerificationRequestModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.education,
    required this.workplace,
    required this.skills,
    required this.expertise,
    required this.bio,
    required this.portfolioUrl,
    required this.evidenceDocuments,
    required this.status,
    required this.createdAt,
    this.rating,
  });

  factory ExpertVerificationRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return ExpertVerificationRequestModel(
      id: id,
      userId: json['userId']?.toString() ?? 'Unknown',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? 'Chưa cập nhật',
      phone: json['phone']?.toString() ?? 'N/A',
      education: json['education']?.toString() ?? 'N/A',
      workplace: json['workplace']?.toString() ?? 'N/A',
      skills: json['skills']?.toString() ?? 'N/A',
      expertise: json['expertise']?.toString() ?? 'Chưa xác định',
      bio: json['bio']?.toString() ?? json['biography']?.toString() ?? '',
      portfolioUrl: json['portfolioUrl']?.toString() ?? '',
      evidenceDocuments: _parseList(json['evidenceDocuments']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: _parseDateTime(json['createdAt']),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  ExpertVerificationRequestModel copyWith({double? rating}) {
    return ExpertVerificationRequestModel(
      id: id,
      userId: userId,
      fullName: fullName,
      phone: phone,
      education: education,
      workplace: workplace,
      skills: skills,
      expertise: expertise,
      bio: bio,
      portfolioUrl: portfolioUrl,
      evidenceDocuments: evidenceDocuments,
      status: status,
      createdAt: createdAt,
      rating: rating ?? this.rating,
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'education': education,
      'workplace': workplace,
      'skills': skills,
      'expertise': expertise,
      'bio': bio,
      'portfolioUrl': portfolioUrl,
      'evidenceDocuments': evidenceDocuments,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
