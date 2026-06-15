import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Camada de acesso ao banco de dados Supabase.
///
/// Concentra todas as consultas e gravações usadas pelo app, deixando as
/// telas livres de detalhes de rede.
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  /// Busca todos os produtos cadastrados, ordenados por id.
  Future<List<Product>> fetchProducts() async {
    final List<dynamic> data = await _client
        .from('products')
        .select()
        .order('id', ascending: true);

    return data
        .map((dynamic item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Busca um único produto pelo seu id. Retorna `null` se não existir.
  Future<Product?> fetchProductById(int id) async {
    final Map<String, dynamic>? data = await _client
        .from('products')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return Product.fromMap(data);
  }

  /// Atualiza o estoque de um produto.
  Future<void> updateStock(int productId, int newStock) async {
    await _client
        .from('products')
        .update(<String, dynamic>{'stock': newStock})
        .eq('id', productId);
  }

  /// Cria um pedido completo:
  /// 1. Gera um número de confirmação único (#LOJA-XXXXXXXX);
  /// 2. Insere a linha em `orders`;
  /// 3. Insere cada item em `order_items`;
  /// 4. Desconta o estoque de cada produto em `products`.
  ///
  /// Retorna o número de confirmação gerado.
  ///
  /// Antes de gravar, revalida o estoque atual no banco para evitar vender
  /// mais do que existe (validação em tempo real na finalização).
  Future<String> createOrder({
    required List<CartItem> items,
    required String billingAddress,
    required String shippingAddress,
    required double subtotal,
    required double shippingCost,
    required double taxes,
    required double total,
  }) async {
    if (items.isEmpty) {
      throw Exception('O carrinho está vazio.');
    }

    // Revalida o estoque atual de cada produto direto no banco.
    for (final CartItem item in items) {
      final Product? current = await fetchProductById(item.product.id);
      if (current == null) {
        throw Exception('Produto "${item.product.name}" não está mais disponível.');
      }
      if (item.quantity > current.stock) {
        throw Exception(
          'Estoque insuficiente para "${current.name}". '
          'Disponível: ${current.stock}, solicitado: ${item.quantity}.',
        );
      }
    }

    // Número de confirmação no formato #LOJA-XXXXXXXX
    final String confirmationNumber =
        '#LOJA-${_uuid.v4().substring(0, 8).toUpperCase()}';

    // 1) Cria o pedido e recupera o id gerado.
    final Map<String, dynamic> inserted = await _client
        .from('orders')
        .insert(<String, dynamic>{
          'confirmation_number': confirmationNumber,
          'billing_address': billingAddress,
          'shipping_address': shippingAddress,
          'subtotal': subtotal,
          'shipping_cost': shippingCost,
          'taxes': taxes,
          'total': total,
          'status': 'confirmed',
        })
        .select()
        .single();

    final int orderId = (inserted['id'] as num).toInt();

    // 2) Insere os itens do pedido.
    final List<Map<String, dynamic>> itemRows = items
        .map((CartItem item) => <String, dynamic>{
              'order_id': orderId,
              'product_id': item.product.id,
              'quantity': item.quantity,
              'unit_price': item.product.price,
              'subtotal': item.subtotal,
            })
        .toList();

    await _client.from('order_items').insert(itemRows);

    // 3) Desconta o estoque de cada produto.
    for (final CartItem item in items) {
      final int newStock = (item.product.stock - item.quantity).clamp(0, 1 << 31).toInt();
      await updateStock(item.product.id, newStock);
    }

    return confirmationNumber;
  }
}
