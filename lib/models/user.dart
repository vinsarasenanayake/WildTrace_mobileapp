// ============================================================================
// USER MODEL
// ============================================================================
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? contactNumber;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.contactNumber,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.profileImageUrl,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? contactNumber,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contactNumber': contactNumber,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      contactNumber: json['contactNumber'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}
