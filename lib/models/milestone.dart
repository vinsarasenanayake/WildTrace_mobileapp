// milestone model
class Milestone {
  final String id;
  final String year;
  final String title;
  final String description;

  Milestone({
    required this.id,
    required this.year,
    required this.title,
    required this.description,
  });

  // from json
  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'].toString(),
      year: json['year']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
