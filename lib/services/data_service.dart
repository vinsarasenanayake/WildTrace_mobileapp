// Imports
import '../models/product.dart';

// Data Service
class DataService {
  // Sample Products
  static List<Product> getSampleProducts() {
    final baseProducts = [
      Product(
        id: '1',
        imageUrl: 'assets/images/product1.jpg',
        category: 'WILDLIFE',
        title: 'Majestic Lion',
        author: 'John Photographer',
        price: 299.99,
        description: 'A stunning portrait of a lion in its natural habitat.',
        location: 'Serengeti, Tanzania',
        year: '2023',
      ),
      Product(
        id: '2',
        imageUrl: 'assets/images/product2.jpg',
        category: 'WILDLIFE',
        title: 'Elephant Herd',
        author: 'Jane Wildlife',
        price: 349.99,
        description: 'A family of elephants crossing the savanna.',
        location: 'Masai Mara, Kenya',
        year: '2023',
      ),
      Product(
        id: '3',
        imageUrl: 'assets/images/product3.jpg',
        category: 'BIRDS',
        title: 'Eagle in Flight',
        author: 'Mike Avian',
        price: 279.99,
        description: 'A golden eagle soaring through the sky.',
        location: 'Rocky Mountains, USA',
        year: '2024',
      ),
      Product(
        id: '4',
        imageUrl: 'assets/images/product4.jpg',
        category: 'WILDLIFE',
        title: 'Tiger Portrait',
        author: 'Sarah Wild',
        price: 399.99,
        description: 'An intense close-up of a Bengal tiger.',
        location: 'Ranthambore, India',
        year: '2023',
      ),
      Product(
        id: '5',
        imageUrl: 'assets/images/product5.jpg',
        category: 'MARINE',
        title: 'Dolphin Pod',
        author: 'Ocean Explorer',
        price: 259.99,
        description: 'Dolphins playing in crystal clear waters.',
        location: 'Great Barrier Reef, Australia',
        year: '2024',
      ),
      Product(
        id: '6',
        imageUrl: 'assets/images/product6.jpg',
        category: 'WILDLIFE',
        title: 'Cheetah Sprint',
        author: 'Speed Shooter',
        price: 329.99,
        description: 'A cheetah in full sprint across the plains.',
        location: 'Serengeti, Tanzania',
        year: '2023',
      ),
    ];

    final List<Product> extendedProducts = [];
    extendedProducts.addAll(baseProducts);
    
    for (int i = 0; i < 2; i++) {
      for (final p in baseProducts) {
         extendedProducts.add(p.copyWith(
           id: '${p.id}_copy_$i',
           title: '${p.title} ${i + 2}'
         ));
      }
    }
    
    return extendedProducts;
  }

  // Featured Items
  static List<Map<String, String>> getFeaturedItems() {
    return [
      {
        'image': 'assets/images/product10.jpg',
        'title': 'Sunset Safari',
        'author': 'Wild Lens',
      },
      {
        'image': 'assets/images/product11.jpg',
        'title': 'Arctic Fox',
        'author': 'Polar Vision',
      },
      {
        'image': 'assets/images/product12.jpg',
        'title': 'Rainforest Canopy',
        'author': 'Jungle Eye',
      },
    ];
  }
}
