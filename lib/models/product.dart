// Product Model
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
  final String? authorImage;
  final String? profession;
  final String? quote;
  final String? achievement;
  bool isFavorite;
  final Map<String, dynamic>? options;

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
    this.authorImage,
    this.profession,
    this.quote,
    this.achievement,
    this.isFavorite = false,
    this.options,
  });

  // Factory Method for creating a modified copy of the product
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

  // Convert product object to JSON format
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

  // Create a product object from JSON data
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      author: (json['author'] ?? 
          (json['photographer'] != null && json['photographer'] is Map ? json['photographer']['name'] : null) ??
          json['photographer_id'] ?? 
          'Unknown').toString(),
      price: (json['price'] != null ? num.tryParse(json['price'].toString())?.toDouble() : 0.0) ?? 0.0,
      description: json['description']?.toString(),
      location: json['location']?.toString(),
      year: (json['year'] ?? (json['created_at'] != null ? DateTime.parse(json['created_at'].toString()).year.toString() : null))?.toString(),
      authorImage: (json['photographer'] != null && json['photographer'] is Map ? json['photographer']['image'] : json['author_image'])?.toString(),
      profession: (json['photographer'] != null && json['photographer'] is Map ? json['photographer']['profession'] : null)?.toString(),
      quote: (json['photographer'] != null && json['photographer'] is Map ? json['photographer']['quote'] : null)?.toString(),
      achievement: (json['photographer'] != null && json['photographer'] is Map ? json['photographer']['achievement'] : null)?.toString(),
      isFavorite: (json['isFavorite'] == 1 || json['isFavorite'] == true || json['isFavorite'] == 'true' || json['is_favorite'] == true || json['is_favorite'] == 1),
      options: json['options'] is Map<String, dynamic> ? json['options'] : null,
    );
  }
}
