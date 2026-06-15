import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Gerencia o estado do carrinho de compras usando o pacote `provider`.
///
/// Mantém a lista de itens em memória e expõe os cálculos financeiros
/// (subtotal, frete, impostos e total) usados pelas telas.
class CartProvider extends ChangeNotifier {
  static const double _shippingFee = 15.0;
  static const double _freeShippingThreshold = 200.0;
  static const double _taxRate = 0.085; // 8,5%

  final List<CartItem> _items = <CartItem>[];

  /// Lista imutável dos itens no carrinho.
  List<CartItem> get items => List<CartItem>.unmodifiable(_items);

  /// Quantidade total de unidades no carrinho (soma das quantidades).
  int get itemCount => _items.fold(0, (int total, CartItem item) => total + item.quantity);

  /// Indica se o carrinho está vazio.
  bool get isEmpty => _items.isEmpty;

  /// Soma de (preço x quantidade) de todos os itens.
  double get subtotal =>
      _items.fold(0.0, (double total, CartItem item) => total + item.subtotal);

  /// Frete: R$ 15,00 fixo, grátis se o subtotal ultrapassar R$ 200,00.
  /// Carrinho vazio não tem frete.
  double get shippingCost {
    if (_items.isEmpty) return 0;
    return subtotal > _freeShippingThreshold ? 0 : _shippingFee;
  }

  /// Impostos: 8,5% sobre o subtotal.
  double get taxes => subtotal * _taxRate;

  /// Total final: subtotal + frete + impostos.
  double get total => subtotal + shippingCost + taxes;

  /// Retorna a quantidade de um produto já presente no carrinho (0 se não houver).
  int quantityOf(int productId) {
    for (final CartItem item in _items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  /// Adiciona um produto ao carrinho. Se já existir, soma as quantidades.
  /// A quantidade resultante nunca ultrapassa o estoque disponível.
  void addItem(Product product, int quantity) {
    if (quantity <= 0) return;

    final int index = _items.indexWhere((CartItem i) => i.product.id == product.id);
    if (index >= 0) {
      final int newQuantity =
          (_items[index].quantity + quantity).clamp(1, product.stock).toInt();
      _items[index].quantity = newQuantity;
    } else {
      final int clamped = quantity.clamp(1, product.stock).toInt();
      _items.add(CartItem(product: product, quantity: clamped));
    }
    notifyListeners();
  }

  /// Altera a quantidade de um item já no carrinho.
  /// Quantidade <= 0 remove o item; valores acima do estoque são limitados.
  void updateQuantity(int productId, int quantity) {
    final int index = _items.indexWhere((CartItem i) => i.product.id == productId);
    if (index < 0) return;

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity.clamp(1, _items[index].product.stock).toInt();
    }
    notifyListeners();
  }

  /// Remove um item do carrinho pelo id do produto.
  void removeItem(int productId) {
    _items.removeWhere((CartItem i) => i.product.id == productId);
    notifyListeners();
  }

  /// Esvazia o carrinho.
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
