// Imports
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

// Products Provider
class ProductsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
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
  
  // Update Token
  void updateToken(String? newToken) {
    if (_token != newToken) {
      _token = newToken;
      fetchProducts(); 
    }
  }

  // Fetch Products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    
    Future.microtask(() => notifyListeners());

    try {
      final fetchedProducts = await _apiService.fetchProducts(token: _token);
      _products.clear();
      _products.addAll(fetchedProducts);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching products: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String get selectedCategory => _selectedCategory;
  String get selectedAuthor => _selectedAuthor;
  String get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  // Get Filtered Products
  List<Product> get filteredProducts {
    var filtered = _products.toList();

    if (_selectedCategory != 'All' && _selectedCategory != 'All Collections') {
      filtered = filtered.where((p) => p.category.toUpperCase() == _selectedCategory.toUpperCase()).toList();
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
      case 'Latest Arrivals':
      default:
        break;
    }

    return filtered;
  }

  // Get Product By Id
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Set Products
  void setProducts(List<Product> products) {
    _products.clear();
    _products.addAll(products);
    notifyListeners();
  }

  // Add Product
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  // Update Product
  void updateProduct(String id, Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  // Remove Product
  void removeProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // Set Category
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Set Author
  void setAuthor(String author) {
    _selectedAuthor = author;
    notifyListeners();
  }

  // Set Sort Option
  void setSortOption(String sortOption) {
    _sortOption = sortOption;
    notifyListeners();
  }

  // Set Search Query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear Filters
  void clearFilters() {
    _selectedCategory = 'All Collections';
    _selectedAuthor = 'All Photographers';
    _sortOption = 'Latest Arrivals';
    _searchQuery = '';
    notifyListeners();
  }

  // Get Categories
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

  // Get Authors
  List<String> get authors {
    final list = _products.map((p) => p.author).toSet().toList();
    list.insert(0, 'All Photographers');
    return list;
  }
}
