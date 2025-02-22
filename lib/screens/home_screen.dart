import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/miniature_set.dart';
import '../services/miniature_service.dart';
import 'favorites_screen.dart';
import 'filters.dart';
import 'profile_screen.dart';
import 'filtered_miniature_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MiniatureService _service = MiniatureService();
  int _selectedIndex = 0;

  FilterParams _filterParams = FilterParams();
  List<String> categories = [];
  List<String> factions = [];
  List<String> universes = [];

  @override
  void initState() {
    super.initState();
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    await _service.loadAllMiniatureSets();
    categories = await _service.getCategories();
    factions = await _service.getFactions();
    universes = await _service.getUniverses();
    setState(() {});
  }

  Future<void> _showFiltersDialog(BuildContext context) async {
    final newParams = await showDialog<FilterParams>(
      context: context,
      builder: (context) => FilterDialog(
        initialParams: _filterParams,
        categories: categories,
        factions: factions,
        universes: universes,
      ),
    );

    if (newParams != null) {
      Navigator.pushNamed(
        context,
        '/filtered',
        arguments: newParams,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        automaticallyImplyLeading: false,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFiltersDialog(context),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _buildAllMiniatureSets(),
        const FavoritesScreen(),
        const ProfileScreen(),
      ],
    );
  }

  Widget _buildAllMiniatureSets() {
    return FutureBuilder<void>(
      future: _service.loadAllMiniatureSets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyLarge),
          );
        }

        final sets = _service.getFilteredMiniatureSets(_filterParams);

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: sets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildSetItem(sets[index]),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'All Miniature Sets';
      case 1:
        return 'Favorite Sets';
      case 2:
        return 'User Profile';
      default:
        return 'Miniatures App';
    }
  }

  Widget _buildSetItem(MiniatureSet set) {
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

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}