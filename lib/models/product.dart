// ============================================================================
// PRODUCT MODEL
// ============================================================================
class Product {
  final String id;
  final String imageUrl;
  final String category;
  final String title;
  final String author;
  final double price;
  final String? description;
  final String? location;
  final String? year;
  bool isFavorite;

  Product({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.author,
    required this.price,
    this.description,
    this.location,
    this.year,
    this.isFavorite = false,
  });

  Product copyWith({
    String? id,
    String? imageUrl,
    String? category,
    String? title,
    String? author,
    double? price,
    String? description,
    String? location,
    String? year,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      title: title ?? this.title,
      author: author ?? this.author,
      price: price ?? this.price,
      description: description ?? this.description,
      location: location ?? this.location,
      year: year ?? this.year,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'category': category,
      'title': title,
      'author': author,
      'price': price,
      'description': description,
      'location': location,
      'year': year,
      'isFavorite': isFavorite,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      location: json['location'] as String?,
      year: json['year'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
