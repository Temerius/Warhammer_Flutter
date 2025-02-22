import 'package:cloud_firestore/cloud_firestore.dart';

class MiniatureSet {
  final String id;
  final String title;
  final String description;
  final String universe;
  final List<String> faction;
  final String category;
  final double price;
  final int releaseYear;
  final List<String> images;
  final List<Comment> comments;
  final double? averageRating;

  MiniatureSet({
    required this.id,
    required this.title,
    required this.description,
    required this.universe,
    required this.faction,
    required this.category,
    required this.price,
    required this.releaseYear,
    required this.images,
    required this.comments,
    this.averageRating,
  });

  factory MiniatureSet.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return MiniatureSet(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? '',
      universe: data['universe'] ?? '',
      faction: List<String>.from(data['faction'] ?? []),
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      releaseYear: (data['releaseYear'] ?? 0).toInt(),
      images: List<String>.from(data['images'] ?? []),
      comments: (data['comments'] ?? []).map<Comment>((commentData) => Comment.fromMap(commentData)).toList(),
      averageRating: doc['averageRating']?.toDouble(),
    );
  }
}

class Comment {
  final String userId;
  final String comment;
  final int rating;
  final Timestamp timestamp;

  Comment({
    required this.userId,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      userId: data['userId'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0).toInt(),
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}