import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/services/miniature_service.dart';
import '/models/miniature_set.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final MiniatureService _service = MiniatureService();
  late Stream<List<MiniatureSet>> _favoritesStream;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String? userId = user?.uid;
    _favoritesStream = _service.getFavoriteMiniaturesStream(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<MiniatureSet>>(
        stream: _favoritesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: favorites.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _buildFavoriteItem(favorites[index]),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteItem(MiniatureSet set) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/details',
        arguments: set.id,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(set.images.isNotEmpty ? set.images.first : ''),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    set.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${set.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Image.network(
      imageUrl,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
    );
  }
}