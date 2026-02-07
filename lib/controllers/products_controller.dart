import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

// manages product catalog
class ProductsController with ChangeNotifier {
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
  
  // returns featured products
  List<Product> get topProductsByPrice {
    final list = List<Product>.from(_products);
    list.sort((a, b) => b.price.compareTo(a.price));
    return list.take(5).toList();
  }
  
  // updates session token
  void updateToken(String? newToken) {
    if (_token != newToken) {
      _token = newToken;
      fetchProducts(); 
    }
  }

  // loads products from server
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String get selectedCategory => _selectedCategory;
  String get selectedAuthor => _selectedAuthor;
  String get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  // applies active filters
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
      default:
        break;
    }
    return filtered;
  }

  // finds product by id
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // sets product list
  void setProducts(List<Product> products) {
    _products.clear();
    _products.addAll(products);
    notifyListeners();
  }

  // adds single product
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  // updates product data
  void updateProduct(String id, Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  // deletes product
  void removeProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // sets filter category
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // sets filter author
  void setAuthor(String author) {
    _selectedAuthor = author;
    notifyListeners();
  }

  // sets sorting method
  void setSortOption(String sortOption) {
    _sortOption = sortOption;
    notifyListeners();
  }

  // updates search text
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // resets all filters
  void clearFilters() {
    _selectedCategory = 'All Collections';
    _selectedAuthor = 'All Photographers';
    _sortOption = 'Latest Arrivals';
    _searchQuery = '';
    notifyListeners();
  }

  // gets unique categories
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

  // gets unique authors
  List<String> get authors {
    final list = _products.map((p) => p.author).toSet().toList();
    list.insert(0, 'All Photographers');
    return list;
  }
}
