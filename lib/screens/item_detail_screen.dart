import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:warhammer/screens/review_screen.dart';
import '../models/miniature_set.dart';
import '../services/miniature_service.dart';

class ItemDetailScreen extends StatefulWidget {
  final String setId;
  const ItemDetailScreen({super.key, required this.setId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MiniatureService _miniatureService = MiniatureService();
  late Future<MiniatureSet> _setFuture;
  bool _isFavorite = false;
  int _currentPage = 0;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _setFuture = _firestore
        .collection('objects')
        .doc(widget.setId)
        .get()
        .then((doc) => MiniatureSet.fromFirestore(doc));

    _checkIfFavorite();
    _fetchAverageRating();
  }

  void _checkIfFavorite() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      String userId = user.uid;
      bool favoriteStatus = await _miniatureService.isFavorite(userId, widget.setId);
      setState(() {
        _isFavorite = favoriteStatus;
      });
    }
  }

  void _fetchAverageRating() async {
    DocumentSnapshot doc = await _firestore.collection('objects').doc(widget.setId).get();
    if (doc.exists) {
      setState(() {
        _averageRating = (doc.data() as Map<String, dynamic>)['averageRating'] ?? 0.0;
      });
    }
  }

  void _toggleFavorite() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to favorite items.')),
      );
      return;
    }

    String userId = user.uid;
    try {
      if (_isFavorite) {
        await _miniatureService.removeFromFavorites(userId, widget.setId);
      } else {
        await _miniatureService.addToFavorites(userId, widget.setId);
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<MiniatureSet>(
        future: _setFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final set = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildImageGallery(set),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        set.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${set.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                setId: set.id,
                                onReviewSubmitted: () {
                                  _fetchAverageRating();
                                },
                              ),
                            ),
                          );
                        },
                        child: _buildRatingStars(_averageRating),
                      ),
                      const SizedBox(height: 16),
                      _buildTags(set),
                      const SizedBox(height: 8),
                      Text(
                        set.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageGallery(MiniatureSet set) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: set.images.isNotEmpty ? set.images.length : 1,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              String imageUrl = set.images.isNotEmpty ? set.images[index] : '';

              return imageUrl.isNotEmpty
                  ? Image(
                image: ResizeImage.resizeIfNeeded(
                  null,
                  null,
                  NetworkImageWithRetry(
                    imageUrl,
                    fetchStrategy: FetchStrategyBuilder(
                      timeout: const Duration(seconds: 10),
                    ).build(),
                  ),
                ),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, size: 100),
                  );
                },
              )
                  : const Center(
                child: Icon(Icons.error, size: 100),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _buildPageIndicator(set.images.length),
      ],
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildTags(MiniatureSet set) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildTag(set.releaseYear.toString(), Colors.purple.shade300),
        const SizedBox(height: 8),
        _buildTag(set.category, Colors.blue.shade300),
        const SizedBox(height: 8),
        _buildTag(set.universe, Colors.orange.shade300),
        const SizedBox(height: 8),
        Row(
          children: [
            ...set.faction.map((faction) => _buildTag(faction, Colors.green.shade300)).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildRatingStars(double averageRating) {
    int fullStars = averageRating.floor();
    bool hasHalfStar = (averageRating - fullStars) >= 0.5;

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber);
        }
      }),
    );
  }
}