import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String? avata;
  final String? bio;

  const UserProfile({
    required this.uid,
    required this.name,
    this.avata,
    this.bio, required String avatar,
  });

  Map<String, dynamic> toJson(){
    return{
      'name' : name,
      'avata' : avata,
      'bio' : bio
    };
  }

  factory UserProfile.fromJson(
      Map<String, dynamic> json, {
        required String uid,
      }) {
    return UserProfile(
      uid: uid,
      name: json['name'] as String,
      avatar: json['avatar'] as String? ?? 'avatar_01',
      bio: json['bio'] as String? ?? '',
    );
  }
}
