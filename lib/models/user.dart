// user profile model
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
  final String? role;

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
    this.role,
  });

  // creates copy with updates
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
    String? role,
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
      role: role ?? this.role,
    );
  }

  // converts to json
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
      'role': role,
    };
  }

  // creates from json
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      contactNumber: (json['contact_number'] ?? json['contactNumber'])?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      postalCode: (json['postal_code'] ?? json['postalCode'])?.toString(),
      country: json['country']?.toString(),
      profileImageUrl: (json['profile_image_url'] ?? json['profileImageUrl'])?.toString(),
      role: json['role']?.toString(),
    );
  }
}
