import '../services/api/base_api_service.dart';

// product model
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

  // copy with
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

    String? authorImage,
    String? profession,
    String? quote,
    String? achievement,
    bool? isFavorite,
    Map<String, dynamic>? options,
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
      authorImage: authorImage ?? this.authorImage,
      profession: profession ?? this.profession,
      quote: quote ?? this.quote,
      achievement: achievement ?? this.achievement,
      isFavorite: isFavorite ?? this.isFavorite,
      options: options ?? this.options,
    );
  }

  // to json
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

      'authorImage': authorImage,
      'profession': profession,
      'quote': quote,
      'achievement': achievement,
      'isFavorite': isFavorite,
      'options': options,
    };
  }

  // from json
  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      String? yearValue;
      if (json['year'] != null) {
        yearValue = json['year'].toString();
      } else if (json['created_at'] != null) {
        try {
          yearValue = DateTime.parse(json['created_at'].toString()).year.toString();
        } catch (_) {
          // extract year
          final match = RegExp(r'\d{4}').firstMatch(json['created_at'].toString());
          yearValue = match?.group(0);
        }
      }

      return Product(
        id: (json['id'] ?? '').toString(),
        imageUrl: BaseApiService.resolveImageUrl((json['imageUrl'] ?? json['image_url'] ?? '').toString()),
        category: (json['category'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        author: (json['author'] ?? 
            (json['photographer'] != null && json['photographer'] is Map ? json['photographer']['name'] : null) ??
            json['photographer_id'] ?? 
            'Unknown').toString(),
        price: (json['price'] != null ? num.tryParse(json['price'].toString())?.toDouble() : 0.0) ?? 0.0,
        description: json['description']?.toString(),
        location: json['location']?.toString(),
        year: yearValue,
        authorImage: BaseApiService.resolveImageUrl((json['photographer'] != null && json['photographer'] is Map ? json['photographer']['image'] : json['author_image'])?.toString()),
        profession: (json['photographer'] != null && json['photographer'] is Map ? json['photographer']['profession'] : null)?.toString(),
        quote: (json['photographer'] != null && json['photographer'] is Map ? json['photographer']['quote'] : null)?.toString(),
        achievement: (json['photographer'] != null && json['photographer'] is Map ? json['photographer']['achievement'] : null)?.toString(),
        isFavorite: (json['isFavorite'] == 1 || json['isFavorite'] == true || json['isFavorite'] == 'true' || json['is_favorite'] == true || json['is_favorite'] == 1),
        options: json['options'] is Map<String, dynamic> ? json['options'] : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}
