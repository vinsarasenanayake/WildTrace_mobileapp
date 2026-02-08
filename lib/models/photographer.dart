import '../services/api/base_api_service.dart';

// photographer model
class Photographer {
  final String id;
  final String name;
  final String profession;
  final String achievement;
  final String quote;
  final String? post;
  final String imageUrl;

  Photographer({
    required this.id,
    required this.name,
    required this.profession,
    required this.achievement,
    required this.quote,
    this.post,
    required this.imageUrl,
  });

  // from json
  factory Photographer.fromJson(Map<String, dynamic> json) {
    return Photographer(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      profession: json['profession'] ?? '',
      achievement: json['achievement'] ?? '',
      quote: json['quote'] ?? '',
      post: json['post'],
      imageUrl: BaseApiService.resolveImageUrl((json['image_url'] ?? json['image'] ?? '').toString()),
    );
  }
}
