import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final DateTime birthDate;
  final String favoriteUniverse;
  final String mainFaction;
  final String experienceLevel;
  final String paintingSkill;
  final String bio;
  final String avatarUrl;
  final List<String> favorites;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.birthDate,
    required this.favoriteUniverse,
    required this.mainFaction,
    required this.experienceLevel,
    required this.paintingSkill,
    required this.bio,
    required this.avatarUrl,
    required this.favorites,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return User(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      favoriteUniverse: data['favoriteUniverse'] ?? '',
      mainFaction: data['mainFaction'] ?? '',
      experienceLevel: data['experienceLevel'] ?? '',
      paintingSkill: data['paintingSkill'] ?? '',
      bio: data['bio'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      favorites: List<String>.from(data['favorites'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }
}