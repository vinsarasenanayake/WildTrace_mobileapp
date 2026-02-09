import 'product.dart';

// Shows an item in the shopping cart
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

  double get totalPrice => (price ?? product.price) * quantity;

  // Create a copy of CartItem
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

  // Convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'size': size,
      'price': price,
    };
  }

  // Create a CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString(),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] is int)
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 1,
      size: json['size']?.toString(),
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
    );
  }
}
