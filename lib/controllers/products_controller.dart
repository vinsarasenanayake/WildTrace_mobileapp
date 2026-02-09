import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api/index.dart';
import '../services/database/database_service.dart';

class ProductsController with ChangeNotifier {
  // controller to manage products with api and local db
  final ProductApiService _apiService = ProductApiService();
  final DatabaseService _dbService = DatabaseService();
  final List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';
  String? _token;
  String _selectedCategory = 'All Collections';
  String _selectedAuthor = 'All Photographers';
  String _sortOption = 'Latest Arrivals';
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String get error => _error;
  String? get token => _token;
  List<Product> get products => List.unmodifiable(_products);

  // get top 5 most expensive products for featured section
  List<Product> get topProductsByPrice {
    final list = List<Product>.from(_products);
    list.sort((a, b) => b.price.compareTo(a.price));
    return list.take(5).toList();
  }

  // refresh products when token changes
  void updateToken(String? newToken) {
    if (_token != newToken || _products.isEmpty) {
      _token = newToken;
      fetchProducts();
    }
  }

  List<Product> _filteredProducts = [];

  List<Product> get filteredProducts => List.unmodifiable(_filteredProducts);

  // Load product collection from backend and synchronize cache
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // try loading from cache
      final cached = await _dbService.getCachedProducts();
      if (cached.isNotEmpty) {
        _products.clear();
        _products.addAll(cached);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Cache Load Error: $e');
    }

    try {
      // get products data from backend
      final fetchedProducts = await _apiService.fetchProducts(token: _token);
      _products.clear();
      _products.addAll(fetchedProducts);
      _applyFilters();
      _error = '';

      // update cache
      await _dbService.cacheProducts(fetchedProducts);
    } catch (e) {
      if (!e.toString().contains('connect to the internet')) {
        debugPrint('API Fetch Error: $e');
      }
      if (_products.isEmpty) {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String get selectedCategory => _selectedCategory;
  String get selectedAuthor => _selectedAuthor;
  String get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  void _applyFilters() {
    var filtered = _products.toList();
    if (_selectedCategory != 'All' && _selectedCategory != 'All Collections') {
      filtered = filtered
          .where(
            (p) => p.category.toLowerCase() == _selectedCategory.toLowerCase(),
          )
          .toList();
    }
    if (_selectedAuthor != 'All Photographers') {
      filtered = filtered.where((p) => p.author == _selectedAuthor).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.category.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    switch (_sortOption) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Name: A-Z':
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      default:
        break;
    }
    _filteredProducts = filtered;
  }

  // Find a specific product from the local collection
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Update selected category and re-apply filters
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Update selected photographer and re-apply filters
  void setAuthor(String author) {
    _selectedAuthor = author;
    _applyFilters();
    notifyListeners();
  }

  // Update sorting preference and re-apply filters
  void setSortOption(String sortOption) {
    _sortOption = sortOption;
    _applyFilters();
    notifyListeners();
  }

  // Update active search term and re-apply filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Reset all filtering and sorting preferences
  void clearFilters() {
    _selectedCategory = 'All Collections';
    _selectedAuthor = 'All Photographers';
    _sortOption = 'Latest Arrivals';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  List<String> get categories {
    final cats = _products
        .map(
          (p) => p.category.isNotEmpty
              ? '${p.category[0].toUpperCase()}${p.category.substring(1)}'
              : p.category,
        )
        .toSet()
        .toList();
    cats.sort();
    cats.insert(0, 'All Collections');
    return cats;
  }

  List<String> get authors {
    final list = _products.map((p) => p.author).toSet().toList();
    list.insert(0, 'All Photographers');
    return list;
  }
}
