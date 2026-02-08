import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../../models/photographer.dart';
import '../../models/milestone.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wild_trace.db');

    return await openDatabase(
      path,
      version: 5,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _dropAllTables(db);
          await _createTables(db);
          return; // V2 was a full reset, no need for further checks
        }
        
        if (oldVersion < 3) {
          // Add table for offline sync
          await _createTables(db); // Will only create new tables due to IF NOT EXISTS
        }
        
        if (oldVersion < 4) {
          // V4: Simplify schema by storing full JSON and removing redundant columns
          await db.execute('DROP TABLE IF EXISTS products');
          await db.execute('DROP TABLE IF EXISTS cart_items');
          await _createTables(db);
        }

        if (oldVersion < 5) {
          // V5: Add display_order column to keep product list order consistent with API
          await db.execute('ALTER TABLE products ADD COLUMN display_order INTEGER');
        }
      },
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _dropAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS products');
    await db.execute('DROP TABLE IF EXISTS cart_items');
    await db.execute('DROP TABLE IF EXISTS orders');
    await db.execute('DROP TABLE IF EXISTS favorites');
    await db.execute('DROP TABLE IF EXISTS photographers');
    await db.execute('DROP TABLE IF EXISTS milestones');
  }

  Future<void> _createTables(Database db) async {
    // Stores full product JSON to ensure all nested data is available offline
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id TEXT PRIMARY KEY,
        isFavorite INTEGER,
        product_json TEXT,
        display_order INTEGER
      )
    ''');

    // Cart items linked to product details via JSON
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cart_items (
        id TEXT PRIMARY KEY,
        product_json TEXT,
        quantity INTEGER,
        size TEXT,
        price REAL
      )
    ''');

    // orders table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        userId TEXT,
        items_json TEXT,
        subtotal REAL,
        tax REAL,
        shipping REAL,
        total REAL,
        status TEXT,
        orderDate TEXT,
        estimatedDeliveryDate TEXT,
        shippingAddress TEXT
      )
    ''');

    // favorites table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        product_id TEXT PRIMARY KEY
      )
    ''');

    // photographers table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS photographers (
        id TEXT PRIMARY KEY,
        name TEXT,
        profession TEXT,
        achievement TEXT,
        quote TEXT,
        post TEXT,
        imageUrl TEXT
      )
    ''');

    // milestones table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS milestones (
        id TEXT PRIMARY KEY,
        year TEXT,
        title TEXT,
        description TEXT
      )
    ''');
    
    // pending actions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_actions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_type TEXT,
        data TEXT,
        created_at TEXT
      )
    ''');
  }

  // Stores actions performed while offline to be synced later
  Future<void> addPendingAction(String type, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('pending_actions', {
      'action_type': type,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingActions() async {
    final db = await database;
    return await db.query('pending_actions', orderBy: 'created_at ASC');
  }

  Future<void> deletePendingAction(int id) async {
    final db = await database;
    await db.delete('pending_actions', where: 'id = ?', whereArgs: [id]);
  }

  // product operations
  Future<void> cacheProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch(); // Batch insert for performance
    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      batch.insert(
        'products',
        {
          'id': product.id,
          'isFavorite': product.isFavorite ? 1 : 0,
          'product_json': jsonEncode(product.toJson()),
          'display_order': i,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Product>> getCachedProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'display_order ASC',
    );
    return maps.map((map) {
      if (map['product_json'] != null) {
        // Hydrate model from the stored JSON string
        final productMap = jsonDecode(map['product_json'] as String);
        return Product.fromJson(productMap);
      }
      throw Exception('Malformed cache entry');
    }).toList();
  }

  // cart operations
  Future<void> cacheCartItems(List<CartItem> items) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('cart_items'); // Refresh cart cache
      for (var item in items) {
        await txn.insert('cart_items', {
          'id': item.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'product_json': jsonEncode(item.product.toJson()),
          'quantity': item.quantity,
          'size': item.size,
          'price': item.price,
        });
      }
    });
  }

  Future<List<CartItem>> getCachedCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');
    return maps.map((map) {
      return CartItem(
        id: map['id'],
        product: Product.fromJson(jsonDecode(map['product_json'])),
        quantity: map['quantity'],
        size: map['size'],
        price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      );
    }).toList();
  }

  // order operations
  Future<void> cacheOrders(List<Order> orders) async {
    final db = await database;
    final batch = db.batch();
    for (var order in orders) {
      batch.insert(
        'orders',
        {
          'id': order.id,
          'userId': order.userId,
          'items_json': jsonEncode(order.items.map((i) => i.toJson()).toList()),
          'subtotal': order.subtotal,
          'tax': order.tax,
          'shipping': order.shipping,
          'total': order.total,
          'status': order.status.toString().split('.').last,
          'orderDate': order.orderDate.toIso8601String(),
          'estimatedDeliveryDate': order.estimatedDeliveryDate?.toIso8601String(),
          'shippingAddress': order.shippingAddress,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Order>> getCachedOrders(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'orderDate DESC',
    );
    return maps.map((map) {
      final items = (jsonDecode(map['items_json']) as List)
          .map((i) => CartItem.fromJson(i))
          .toList();
      return Order(
        id: map['id'],
        userId: map['userId'],
        items: items,
        subtotal: map['subtotal'],
        tax: map['tax'],
        shipping: map['shipping'],
        total: map['total'],
        status: OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == map['status'],
          orElse: () => OrderStatus.pending,
        ),
        orderDate: DateTime.parse(map['orderDate']),
        estimatedDeliveryDate: map['estimatedDeliveryDate'] != null
            ? DateTime.parse(map['estimatedDeliveryDate'])
            : null,
        shippingAddress: map['shippingAddress'],
      );
    }).toList();
  }

  // favorites operations
  Future<void> cacheFavorites(List<String> productIds) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('favorites');
      for (var id in productIds) {
        await txn.insert('favorites', {'product_id': id});
      }
    });
  }

  Future<List<String>> getCachedFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return maps.map((map) => map['product_id'] as String).toList();
  }

  Future<void> toggleFavoriteLocal(String productId, bool isFavorite) async {
    final db = await database;
    if (isFavorite) {
      await db.insert('favorites', {'product_id': productId}, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.delete('favorites', where: 'product_id = ?', whereArgs: [productId]);
    }
    
    // also update products table if exists
    await db.update('products', {'isFavorite': isFavorite ? 1 : 0}, where: 'id = ?', whereArgs: [productId]);
    
    // update product_json if it exists to keep isFavorite in sync
    final productMaps = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (productMaps.isNotEmpty && productMaps.first['product_json'] != null) {
      final productMap = jsonDecode(productMaps.first['product_json'] as String);
      productMap['isFavorite'] = isFavorite;
      await db.update('products', {'product_json': jsonEncode(productMap)}, where: 'id = ?', whereArgs: [productId]);
    }
  }

  // photographers operations
  Future<void> cachePhotographers(List<Photographer> photographers) async {
    final db = await database;
    final batch = db.batch();
    for (var p in photographers) {
      batch.insert(
        'photographers',
        {
          'id': p.id,
          'name': p.name,
          'profession': p.profession,
          'achievement': p.achievement,
          'quote': p.quote,
          'post': p.post,
          'imageUrl': p.imageUrl,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Photographer>> getCachedPhotographers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('photographers');
    return maps.map((map) => Photographer(
      id: map['id'],
      name: map['name'],
      profession: map['profession'],
      achievement: map['achievement'],
      quote: map['quote'],
      post: map['post'],
      imageUrl: map['imageUrl'],
    )).toList();
  }

  // milestones operations
  Future<void> cacheMilestones(List<Milestone> milestones) async {
    final db = await database;
    final batch = db.batch();
    for (var m in milestones) {
      batch.insert(
        'milestones',
        {
          'id': m.id,
          'year': m.year,
          'title': m.title,
          'description': m.description,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Milestone>> getCachedMilestones() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('milestones', orderBy: 'year DESC');
    return maps.map((map) => Milestone(
      id: map['id'],
      year: map['year'],
      title: map['title'],
      description: map['description'],
    )).toList();
  }
}
