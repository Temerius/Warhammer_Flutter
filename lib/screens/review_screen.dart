import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewScreen extends StatefulWidget {
  final String setId;
  final VoidCallback onReviewSubmitted;

  const ReviewScreen({super.key, required this.setId, required this.onReviewSubmitted});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
  }

  Stream<List<Map<String, dynamic>>> _fetchComments() {
    return _firestore
        .collection('objects')
        .doc(widget.setId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data != null && data['comments'] != null) {
        return List<Map<String, dynamic>>.from(data['comments']);
      }
      return [];
    });
  }

  Future<void> _submitComment() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to leave a comment.')),
      );
      return;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final username = userDoc.data()?['displayName'] ?? 'Anonymous';

    final review = {
      'username': username,
      'rating': _rating,
      'comment': _commentController.text,
      'date': DateTime.now(),
      'userId': user.uid,
    };

    final commentsSnapshot = await _firestore
        .collection('objects')
        .doc(widget.setId)
        .get();

    final comments = commentsSnapshot.data()?['comments'] ?? [];
    final hasReviewed = comments.any((comment) => comment['userId'] == user.uid);

    if (hasReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only leave one review.')),
      );
      return;
    }

    await _firestore.collection('objects').doc(widget.setId).update({
      'comments': FieldValue.arrayUnion([review]),
    });

    final totalRating = comments.fold(0.0, (sum, comment) {
      return sum + (comment['rating'] is double ? comment['rating'] : (comment['rating'] as int).toDouble());
    }) + _rating;

    final newAverageRating = totalRating / (comments.length + 1);

    await _firestore.collection('objects').doc(widget.setId).update({
      'averageRating': newAverageRating,
    });

    _commentController.clear();
    _rating = 0.0;

    widget.onReviewSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leave a rating:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildRatingStars(),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Write your comment...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitComment,
              child: const Text('Submit Comment'),
            ),
            const SizedBox(height: 16),
            Text('Existing Comments:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchComments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final comments = snapshot.data ?? [];

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            _buildRatingStars(comment['rating'] is double ? comment['rating'] : (comment['rating'] as int).toDouble()),
                            const SizedBox(height: 4),
                            Text(comment['comment']),
                            const SizedBox(height: 4),
                            Text(
                              '${(comment['date'] as Timestamp).toDate().toLocal()}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars([double? rating]) {
    double displayRating = rating ?? _rating;

    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1.0;
            });
          },
          child: Icon(
            index < displayRating.floor()
                ? Icons.star
                : index == displayRating.floor() && displayRating - index >= 0.5
                ? Icons.star_half
                : Icons.star_border,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}