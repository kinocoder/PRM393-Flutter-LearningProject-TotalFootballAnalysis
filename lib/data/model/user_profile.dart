import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String avatarId;
  final String? avatarUrl;
  final String? avatarPublicId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarId = 'ball',
    this.avatarUrl,
    this.avatarPublicId,
    this.createdAt,
    this.updatedAt,
  });
  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    required String uid,
  }) => UserProfile(
    uid: uid,
    email: json['email'] as String? ?? '',
    displayName:
        json['displayName'] as String? ?? json['name'] as String? ?? '',
    avatarId: json['avatarId'] as String? ?? 'ball',
    avatarUrl: json['avatarUrl'] as String?,
    avatarPublicId: json['avatarPublicId'] as String?,
    createdAt: _parseDate(json['createdAt']),
    updatedAt: _parseDate(json['updatedAt']),
  );
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'avatarId': avatarId,
    'avatarUrl': avatarUrl,
    'avatarPublicId': avatarPublicId,
  };
  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
