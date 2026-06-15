/// Modelo que representa um produto da loja.
///
/// Os dados vêm da tabela `products` no Supabase.
class Product {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String description;
  final String longDescription;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.longDescription,
    this.imageUrl,
  });

  /// Cria um [Product] a partir de um mapa JSON retornado pelo Supabase.
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num).toInt(),
      name: (map['name'] ?? '') as String,
      price: _toDouble(map['price']),
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      description: (map['description'] ?? '') as String,
      longDescription: (map['long_description'] ?? map['description'] ?? '') as String,
      imageUrl: map['image_url'] as String?,
    );
  }

  /// Indica se o produto está disponível para compra.
  bool get hasStock => stock > 0;

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
