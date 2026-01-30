// Imports
import 'product.dart';

// Cart Item Model
class CartItem {
  final String? id;
  final Product product;
  int quantity;
  final String? size;
  final double? price;

  CartItem({
    this.id,
    required this.product,
    this.quantity = 1,
    this.size,
    this.price,
  });

  // Get Total Price
  double get totalPrice => (price ?? product.price) * quantity;

  // Copy With
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? size,
    double? price,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      price: price ?? this.price,
    );
  }

  // To Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'size': size,
      'price': price,
    };
  }

  // From Json
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString(),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] is int) ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1,
      size: json['size']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
    );
  }
}
