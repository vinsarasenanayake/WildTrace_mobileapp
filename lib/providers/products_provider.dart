// ============================================================================
// PRODUCTS PROVIDER - Product Catalog State Management
// ============================================================================
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  final List<Product> _products = [];
  String _selectedCategory = 'All Collections';
  String _selectedAuthor = 'All Photographers';
  String _sortOption = 'Latest Arrivals';
  String _searchQuery = '';

  List<Product> get products => List.unmodifiable(_products);

  String get selectedCategory => _selectedCategory;
  String get selectedAuthor => _selectedAuthor;
  String get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  // Get filtered products
  List<Product> get filteredProducts {
    var filtered = _products.toList();

    // Filter by category
    if (_selectedCategory != 'All' && _selectedCategory != 'All Collections') {
      filtered = filtered.where((p) => p.category.toUpperCase() == _selectedCategory.toUpperCase()).toList();
    }

    // Filter by author
    if (_selectedAuthor != 'All Photographers') {
      filtered = filtered.where((p) => p.author == _selectedAuthor).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Sort
    switch (_sortOption) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Latest Arrivals':
      default:
        // Assuming the list is initially sorted by latest or we'd need a date field
        // For now, we keep original order (which is reversed in list usually for latest)
        // If we had a date field: filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Set products (for initial load or refresh)
  void setProducts(List<Product> products) {
    _products.clear();
    _products.addAll(products);
    notifyListeners();
  }

  // Add product
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  // Update product
  void updateProduct(String id, Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  // Remove product
  void removeProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Set author filter
  void setAuthor(String author) {
    _selectedAuthor = author;
    notifyListeners();
  }

  // Set sort option
  void setSortOption(String sortOption) {
    _sortOption = sortOption;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = 'All';
    _selectedAuthor = 'All Photographers';
    _sortOption = 'Latest Arrivals';
    _searchQuery = '';
    notifyListeners();
  }

  // Get available categories
  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.insert(0, 'All Collections');
    return cats;
  }

  // Get available authors
  List<String> get authors {
    final list = _products.map((p) => p.author).toSet().toList();
    list.insert(0, 'All Photographers');
    return list;
  }
}
