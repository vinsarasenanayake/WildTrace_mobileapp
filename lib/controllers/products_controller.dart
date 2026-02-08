import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api/index.dart';

class ProductsController with ChangeNotifier {
  final ProductApiService _apiService = ProductApiService();
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
  
  List<Product> get topProductsByPrice {
    final list = List<Product>.from(_products);
    list.sort((a, b) => b.price.compareTo(a.price));
    return list.take(5).toList();
  }
  
  void updateToken(String? newToken) {
    if (_token != newToken || _products.isEmpty) {
      _token = newToken;
      fetchProducts(); 
    }
  }

  List<Product> _filteredProducts = [];

  List<Product> get filteredProducts => List.unmodifiable(_filteredProducts);
  
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final fetchedProducts = await _apiService.fetchProducts(token: _token);
      _products.clear();
      _products.addAll(fetchedProducts);
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String get selectedCategory => _selectedCategory;
  String get selectedAuthor => _selectedAuthor;
  String get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  // filter logic for gallery
  void _applyFilters() {
    var filtered = _products.toList();
    if (_selectedCategory != 'All' && _selectedCategory != 'All Collections') {
      filtered = filtered.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }
    if (_selectedAuthor != 'All Photographers') {
      filtered = filtered.where((p) => p.author == _selectedAuthor).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    switch (_sortOption) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Name: A-Z':
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())); 
        break;
      default:
        break;
    }
    _filteredProducts = filtered;
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setAuthor(String author) {
    _selectedAuthor = author;
    _applyFilters();
    notifyListeners();
  }

  void setSortOption(String sortOption) {
    _sortOption = sortOption;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'All Collections';
    _selectedAuthor = 'All Photographers';
    _sortOption = 'Latest Arrivals';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  List<String> get categories {
    final cats = _products.map((p) => 
        p.category.isNotEmpty 
          ? '${p.category[0].toUpperCase()}${p.category.substring(1)}' 
          : p.category
    ).toSet().toList();
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
