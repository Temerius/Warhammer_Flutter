import 'package:flutter/material.dart';
import '../services/miniature_service.dart';

class FilterDialog extends StatefulWidget {
  final FilterParams initialParams;
  final List<String> categories;
  final List<String> factions;
  final List<String> universes;

  const FilterDialog({
    super.key,
    required this.initialParams,
    required this.categories,
    required this.factions,
    required this.universes,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterParams _params;
  final int currentYear = DateTime.now().year;

  String? minYearError;
  String? maxYearError;
  String? minPriceError;
  String? maxPriceError;

  bool showCategories = false;
  bool showFactions = false;
  bool showUniverses = false;
  bool showPriceRange = false;
  bool showYearRange = false;
  bool showSortOptions = false;

  @override
  void initState() {
    super.initState();
    _params = widget.initialParams;
  }

  void _validateAndSetMinYear(String value) {
    int? minYear = int.tryParse(value);
    if (minYear != null) {
      setState(() {
        _params = _params.copyWith(minYear: minYear);
        if (minYear > currentYear) {
          minYearError = 'Year cannot be greater than $currentYear';
        } else {
          if (_params.maxYear != null && minYear > _params.maxYear!) {
            minYearError = 'Min year $minYear cannot be greater than max year ${_params.maxYear}';
          } else {
            minYearError = null;
            int? tmp = _params.maxYear;
            if (tmp != null && tmp <= currentYear) {
              maxYearError = null;
            }
          }
        }
      });
    }
  }

  void _validateAndSetMaxYear(String value) {
    int? maxYear = int.tryParse(value);
    if (maxYear != null) {
      setState(() {
        _params = _params.copyWith(maxYear: maxYear);
        if (maxYear > currentYear) {
          maxYearError = 'Year cannot be greater than $currentYear';
        } else {
          if (_params.minYear != null && maxYear < _params.minYear!) {
            maxYearError = 'Max year $maxYear cannot be less than min year ${_params.minYear}';
          } else {
            maxYearError = null;
            int? tmp = _params.minYear;
            if (tmp != null && tmp <= currentYear) {
              minYearError = null;
            }
          }
        }
      });
    }
  }

  void _validateAndSetMinPrice(String value) {
    double? minPrice = double.tryParse(value);
    if (minPrice != null) {
      setState(() {
        _params = _params.copyWith(minPrice: minPrice);
        if (_params.maxPrice != null && minPrice > _params.maxPrice!) {
          double? tmp = _params.maxPrice;
          minPriceError = "Min price $minPrice cannot be greater than max price $tmp";
        } else {
          minPriceError = null;
          maxPriceError = null;
        }
      });
    }
  }

  void _validateAndSetMaxPrice(String value) {
    double? maxPrice = double.tryParse(value);
    if (maxPrice != null) {
      setState(() {
        _params = _params.copyWith(maxPrice: maxPrice);
        if (_params.minPrice != null && maxPrice < _params.minPrice!) {
          double? tmp = _params.minPrice;
          maxPriceError = "Max price $maxPrice cannot be less than min price $tmp";
        } else {
          maxPriceError = null;
          minPriceError = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filters and Sorting'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Search by name'),
              onChanged: (value) {
                setState(() {
                  _params = _params.copyWith(searchQuery: value);
                });
              },
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              title: 'Categories:',
              isExpanded: showCategories,
              onToggle: () {
                setState(() {
                  showCategories = !showCategories;
                });
              },
              children: widget.categories.map((category) => CheckboxListTile(
                title: Text(category),
                value: _params.selectedCategories.contains(category),
                onChanged: (bool? value) {
                  setState(() {
                    _params = _params.copyWith(
                      selectedCategories: value!
                          ? [..._params.selectedCategories, category]
                          : _params.selectedCategories.where((c) => c != category).toList(),
                    );
                  });
                },
              )).toList(),
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              title: 'Factions:',
              isExpanded: showFactions,
              onToggle: () {
                setState(() {
                  showFactions = !showFactions;
                });
              },
              children: widget.factions.map((faction) => CheckboxListTile(
                title: Text(faction),
                value: _params.selectedFactions.contains(faction),
                onChanged: (bool? value) {
                  setState(() {
                    _params = _params.copyWith(
                      selectedFactions: value!
                          ? [..._params.selectedFactions, faction]
                          : _params.selectedFactions.where((f) => f != faction).toList(),
                    );
                  });
                },
              )).toList(),
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              title: 'Universes:',
              isExpanded: showUniverses,
              onToggle: () {
                setState(() {
                  showUniverses = !showUniverses;
                });
              },
              children: widget.universes.map((universe) => CheckboxListTile(
                title: Text(universe),
                value: _params.selectedUniverses.contains(universe),
                onChanged: (bool? value) {
                  setState(() {
                    _params = _params.copyWith(
                      selectedUniverses: value!
                          ? [..._params.selectedUniverses, universe]
                          : _params.selectedUniverses.where((u) => u != universe).toList(),
                    );
                  });
                },
              )).toList(),
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              title: 'Price Range:',
              isExpanded: showPriceRange,
              onToggle: () {
                setState(() {
                  showPriceRange = !showPriceRange;
                });
              },
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Min Price'),
                        keyboardType: TextInputType.number,
                        onChanged: _validateAndSetMinPrice,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Max Price'),
                        keyboardType: TextInputType.number,
                        onChanged: _validateAndSetMaxPrice,
                      ),
                    ),
                  ],
                ),
                if (minPriceError != null) ...[
                  const SizedBox(height: 5),
                  Text(minPriceError!, style: const TextStyle(color: Colors.red)),
                ],
                if (maxPriceError != null) ...[
                  const SizedBox(height: 5),
                  Text(maxPriceError!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              title: 'Release Year Range:',
              isExpanded: showYearRange,
              onToggle: () {
                setState(() {
                  showYearRange = !showYearRange;
                });
              },
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Min Year'),
                        keyboardType: TextInputType.number,
                        onChanged: _validateAndSetMinYear,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Max Year'),
                        keyboardType: TextInputType.number,
                        onChanged: _validateAndSetMaxYear,
                      ),
                    ),
                  ],
                ),
                if (minYearError != null) ...[
                  const SizedBox(height: 5),
                  Text(minYearError!, style: const TextStyle(color: Colors.red)),
                ],
                if (maxYearError != null) ...[
                  const SizedBox(height: 5),
                  Text(maxYearError!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              title: 'Sort By:',
              isExpanded: showSortOptions,
              onToggle: () {
                setState(() {
                  showSortOptions = !showSortOptions;
                });
              },
              children: [
                DropdownButton<String>(
                  value: _params.sortBy,
                  onChanged: (String? newValue) {
                    setState(() {
                      _params = _params.copyWith(sortBy: newValue!);
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'price', child: Text('Price')),
                    DropdownMenuItem(value: 'releaseYear', child: Text('Release Year')),
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Sort Descending'),
                  value: _params.sortDescending,
                  onChanged: (bool value) {
                    setState(() {
                      _params = _params.copyWith(sortDescending: value);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _params),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            ],
          ),
        ),
        if (isExpanded) ...children,
      ],
    );
  }
}