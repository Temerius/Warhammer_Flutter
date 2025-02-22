import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/miniature_set.dart';
import '../services/miniature_service.dart';

class FilteredMiniatureScreen extends StatefulWidget {
  final FilterParams filterParams;

  const FilteredMiniatureScreen({super.key, required this.filterParams});

  @override
  State<FilteredMiniatureScreen> createState() => _FilteredMiniatureScreenState();
}

class _FilteredMiniatureScreenState extends State<FilteredMiniatureScreen> {
  final MiniatureService _service = MiniatureService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtered Miniatures'),
      ),
      body: FutureBuilder<void>(
        future: _service.loadAllMiniatureSets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sets = _service.getFilteredMiniatureSets(widget.filterParams);

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: sets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _buildSetItem(sets[index]),
          );
        },
      ),
    );
  }

  Widget _buildSetItem(MiniatureSet set) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/details',
          arguments: set.id,
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(set.images.isNotEmpty ? set.images.first : ''),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    set.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${set.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      height: 200,
      fit: BoxFit.cover,
    );
  }
}