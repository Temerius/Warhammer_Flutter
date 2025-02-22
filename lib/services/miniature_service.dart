import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/miniature_set.dart';

class MiniatureService {
  final FirebaseFirestore _firestore;

  MiniatureService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  List<MiniatureSet> _allMiniatureSets = [];

  Future<bool> isFavorite(String userId, String setId) async {
    final DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final favorites = data?['favorites'] as List<dynamic>?;

      return favorites?.contains(setId) ?? false;
    }

    return false;
  }

  Future<void> addToFavorites(String userId, String setId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'favorites': FieldValue.arrayUnion([setId]),
      }, SetOptions(merge: true));
    } catch (e) {
      throw e;
    }
  }

  Future<void> removeFromFavorites(String userId, String setId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'favorites': FieldValue.arrayRemove([setId]),
      }, SetOptions(merge: true));
    } catch (e) {
      throw e;
    }
  }

  Stream<List<MiniatureSet>> getFavoriteMiniaturesStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().asyncMap((userDoc) async {
      if (userDoc.exists && userDoc.data()!['favorites'] != null) {
        List<String> favorites = List<String>.from(userDoc.data()!['favorites']);

        final futures = favorites.map((setId) => _firestore.collection('objects').doc(setId).get());
        final setDocs = await Future.wait(futures);

        List<MiniatureSet> miniatureSets = setDocs
            .where((setDoc) => setDoc.exists)
            .map((setDoc) => MiniatureSet.fromFirestore(setDoc))
            .toList();

        int favoriteSetsCount = miniatureSets.length;
        String favoriteUniverse = _determineFavoriteUniverse(miniatureSets);
        String mainFaction = _determineMainFaction(miniatureSets);
        double totalSetsValue = _calculateTotalValue(miniatureSets);

        await _firestore.collection('users').doc(userId).update({
          'favoriteSetsCount': favoriteSetsCount,
          'favoriteUniverse': favoriteUniverse,
          'mainFaction': mainFaction,
          'totalSetsValue': totalSetsValue,
        });

        return miniatureSets;
      }
      return [];
    });
  }

  double _calculateTotalValue(List<MiniatureSet> sets) {
    return sets.fold(0.0, (total, set) => total + set.price);
  }

  String _determineFavoriteUniverse(List<MiniatureSet> sets) {
    if (sets.isEmpty) return 'None';

    final universeCounts = <String, int>{};
    for (var set in sets) {
      universeCounts[set.universe] = (universeCounts[set.universe] ?? 0) + 1;
    }

    final favoriteUniverse = universeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return favoriteUniverse;
  }

  String _determineMainFaction(List<MiniatureSet> sets) {
    if (sets.isEmpty) return 'None';

    final factionCounts = <String, int>{};
    for (var set in sets) {
      for (var faction in set.faction) {
        factionCounts[faction] = (factionCounts[faction] ?? 0) + 1;
      }
    }

    final mainFaction = factionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return mainFaction;
  }

  Future<List<MiniatureSet>> getFavoriteMiniatures(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data()!['favorites'] != null) {
        List<String> favorites = List<String>.from(userDoc.data()!['favorites']);

        final futures = favorites.map((setId) =>
            _firestore.collection('objects').doc(setId).get()
        );

        final setDocs = await Future.wait(futures);
        return setDocs
            .where((setDoc) => setDoc.exists)
            .map((setDoc) => MiniatureSet.fromFirestore(setDoc))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> loadAllMiniatureSets() async {
    final snapshot = await _firestore.collection('objects').get();
    _allMiniatureSets = snapshot.docs
        .map((doc) => MiniatureSet.fromFirestore(doc))
        .toList();
  }

  List<MiniatureSet> getFilteredMiniatureSets(FilterParams params) {
    List<MiniatureSet> filteredSets = List.from(_allMiniatureSets);

    if (params.searchQuery.isNotEmpty) {
      final searchQueryLower = params.searchQuery.toLowerCase();
      filteredSets = filteredSets.where((set) =>
          set.title.toLowerCase().contains(searchQueryLower)).toList();
    }

    if (params.selectedCategories.isNotEmpty) {
      filteredSets = filteredSets
          .where((set) => params.selectedCategories.contains(set.category))
          .toList();
    }
    if (params.selectedFactions.isNotEmpty) {
      filteredSets = filteredSets.where((set) =>
          set.faction.any((faction) => params.selectedFactions.contains(faction)))
          .toList();
    }
    if (params.selectedUniverses.isNotEmpty) {
      filteredSets = filteredSets
          .where((set) => params.selectedUniverses.contains(set.universe))
          .toList();
    }
    if (params.minPrice != null) {
      filteredSets = filteredSets
          .where((set) => set.price >= params.minPrice!)
          .toList();
    }
    if (params.maxPrice != null) {
      filteredSets = filteredSets
          .where((set) => set.price <= params.maxPrice!)
          .toList();
    }
    if (params.minYear != null) {
      filteredSets = filteredSets
          .where((set) => set.releaseYear >= params.minYear!)
          .toList();
    }
    if (params.maxYear != null) {
      filteredSets = filteredSets
          .where((set) => set.releaseYear <= params.maxYear!)
          .toList();
    }

    if (params.sortBy == 'price') {
      filteredSets.sort((a, b) => params.sortDescending
          ? b.price.compareTo(a.price)
          : a.price.compareTo(b.price));
    } else if (params.sortBy == 'rating') {
      filteredSets.sort((a, b) {
        double aRating = a.averageRating ?? 0.0;
        double bRating = b.averageRating ?? 0.0;
        return params.sortDescending ? bRating.compareTo(aRating) : aRating.compareTo(bRating);
      });
    } else if (params.sortBy == 'releaseYear') {
      filteredSets.sort((a, b) => params.sortDescending
          ? b.releaseYear.compareTo(a.releaseYear)
          : a.releaseYear.compareTo(b.releaseYear));
    }

    return filteredSets;
  }

  Future<List<String>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getFactions() async {
    final snapshot = await _firestore.collection('factions').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getUniverses() async {
    final snapshot = await _firestore.collection('universes').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}

class FilterParams {
  final String searchQuery;
  final List<String> selectedCategories;
  final List<String> selectedFactions;
  final List<String> selectedUniverses;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final String sortBy;
  final bool sortDescending;

  FilterParams({
    this.searchQuery = '',
    this.selectedCategories = const [],
    this.selectedFactions = const [],
    this.selectedUniverses = const [],
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.sortBy = 'releaseYear',
    this.sortDescending = false,
  });

  FilterParams copyWith({
    String? searchQuery,
    List<String>? selectedCategories,
    List<String>? selectedFactions,
    List<String>? selectedUniverses,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    String? sortBy,
    bool? sortDescending,
  }) {
    return FilterParams(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedFactions: selectedFactions ?? this.selectedFactions,
      selectedUniverses: selectedUniverses ?? this.selectedUniverses,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}