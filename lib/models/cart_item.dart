import 'product.dart';

/// Representa um item dentro do carrinho de compras: um produto + a
/// quantidade escolhida pelo usuário.
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Subtotal deste item (preço unitário x quantidade).
  double get subtotal => product.price * quantity;
}
