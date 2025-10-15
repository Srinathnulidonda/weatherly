import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme_manager.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<String> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  
  final List<Map<String, String>> _popularCities = [
    {'name': 'New York', 'country': 'United States'},
    {'name': 'London', 'country': 'United Kingdom'},
    {'name': 'Tokyo', 'country': 'Japan'},
    {'name': 'Paris', 'country': 'France'},
    {'name': 'Sydney', 'country': 'Australia'},
    {'name': 'Dubai', 'country': 'UAE'},
  ];

  final List<Map<String, String>> _allCities = [
    {'name': 'New York', 'country': 'United States', 'region': 'New York'},
    {'name': 'London', 'country': 'United Kingdom', 'region': 'England'},
    {'name': 'Tokyo', 'country': 'Japan', 'region': 'Kanto'},
    {'name': 'Paris', 'country': 'France', 'region': 'Île-de-France'},
    {'name': 'Sydney', 'country': 'Australia', 'region': 'New South Wales'},
    {'name': 'Mumbai', 'country': 'India', 'region': 'Maharashtra'},
    {'name': 'Dubai', 'country': 'UAE', 'region': 'Dubai'},
    {'name': 'Singapore', 'country': 'Singapore', 'region': 'Central'},
    {'name': 'Los Angeles', 'country': 'United States', 'region': 'California'},
    {'name': 'Chicago', 'country': 'United States', 'region': 'Illinois'},
    {'name': 'Toronto', 'country': 'Canada', 'region': 'Ontario'},
    {'name': 'Berlin', 'country': 'Germany', 'region': 'Berlin'},
    {'name': 'Madrid', 'country': 'Spain', 'region': 'Madrid'},
    {'name': 'Rome', 'country': 'Italy', 'region': 'Lazio'},
    {'name': 'Bangkok', 'country': 'Thailand', 'region': 'Bangkok'},
    {'name': 'Seoul', 'country': 'South Korea', 'region': 'Seoul'},
    {'name': 'Delhi', 'country': 'India', 'region': 'Delhi'},
    {'name': 'Shanghai', 'country': 'China', 'region': 'Shanghai'},
    {'name': 'Mexico City', 'country': 'Mexico', 'region': 'Mexico City'},
    {'name': 'Cairo', 'country': 'Egypt', 'region': 'Cairo'},
    {'name': 'Moscow', 'country': 'Russia', 'region': 'Moscow'},
    {'name': 'Jakarta', 'country': 'Indonesia', 'region': 'Jakarta'},
    {'name': 'Istanbul', 'country': 'Turkey', 'region': 'Istanbul'},
    {'name': 'Manila', 'country': 'Philippines', 'region': 'Metro Manila'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String city) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(city);
    _recentSearches.insert(0, city);
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.take(5).toList();
    }
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      final results = _allCities
          .where((city) =>
              city['name']!.toLowerCase().contains(query.toLowerCase()) ||
              city['country']!.toLowerCase().contains(query.toLowerCase()))
          .map((city) => city['name']!)
          .toList();

      setState(() {
        _searchResults = results.take(8).toList();
        _isSearching = false;
      });
    });
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() {
      _recentSearches = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: ThemeManager.getCurrentGradient(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Search input
              _buildSearchInput(),
              
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GlassContainer(
            width: 40,
            height: 40,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            blur: 10,
            borderRadius: BorderRadius.circular(20),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Search Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        width: double.infinity,
        height: 56,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        blur: 10,
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: const TextStyle(
            fontSize: 17,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Search cities worldwide...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
            ),
            prefixIcon: _isSearching
                ? SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ThemeManager.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  )
                : Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.4),
                  ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: _performSearch,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _saveRecentSearch(value);
              Navigator.pop(context, value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_searchController.text.isNotEmpty && _searchResults.isNotEmpty) {
      return _buildSearchResults();
    }

    return _buildDefaultContent();
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        final cityData = _allCities.firstWhere(
          (c) => c['name'] == city,
          orElse: () => {'name': city, 'country': '', 'region': ''},
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _saveRecentSearch(city);
                Navigator.pop(context, city);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ThemeManager.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: ThemeManager.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cityData['name']!,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (cityData['region']!.isNotEmpty)
                            Text(
                              '${cityData['region']}, ${cityData['country']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: 400.ms,
        );
      },
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 16,
                      color: ThemeManager.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RECENT SEARCHES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._recentSearches.map((city) => _buildRecentSearchItem(city)),
            const SizedBox(height: 32),
          ],

          // Popular cities
          Row(
            children: [
              Icon(
                Icons.public,
                size: 16,
                color: ThemeManager.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'POPULAR CITIES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._popularCities.map((city) => _buildCityItem(city)),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String city) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _saveRecentSearch(city);
            Navigator.pop(context, city);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildCityItem(Map<String, String> city) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        width: double.infinity,
        height: 72,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        blur: 10,
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _saveRecentSearch(city['name']!);
              Navigator.pop(context, city['name']);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        city['country']!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn();
  }
}