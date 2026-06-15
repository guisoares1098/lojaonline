// Testes de unidade do CartProvider.
//
// O CartProvider contém a lógica de negócio do carrinho (totais, frete e
// impostos) e é puro Dart, então pode ser testado sem inicializar o Supabase.

import 'package:flutter_test/flutter_test.dart';

import 'package:loja_online_simples_flutter/models/product.dart';
import 'package:loja_online_simples_flutter/providers/cart_provider.dart';

Product _produto({
  int id = 1,
  String name = 'Produto Teste',
  double price = 100.0,
  int stock = 10,
}) {
  return Product(
    id: id,
    name: name,
    price: price,
    stock: stock,
    description: 'curta',
    longDescription: 'longa',
  );
}

void main() {
  group('CartProvider', () {
    test('carrinho começa vazio', () {
      final CartProvider cart = CartProvider();
      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
      expect(cart.subtotal, 0);
      expect(cart.shippingCost, 0);
      expect(cart.total, 0);
    });

    test('addItem soma quantidades do mesmo produto', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_produto(), 2);
      cart.addItem(_produto(), 3);
      expect(cart.itemCount, 5);
      expect(cart.quantityOf(1), 5);
    });

    test('addItem nunca ultrapassa o estoque', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_produto(stock: 4), 10);
      expect(cart.quantityOf(1), 4);
    });

    test('frete é R\$15 abaixo de R\$200 e grátis acima', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_produto(price: 50), 1); // subtotal 50
      expect(cart.shippingCost, 15.0);

      cart.addItem(_produto(price: 50), 3); // subtotal 200 (não passa de 200)
      expect(cart.subtotal, 200.0);
      expect(cart.shippingCost, 15.0);

      final CartProvider cart2 = CartProvider();
      cart2.addItem(_produto(price: 250, stock: 5), 1); // subtotal 250 > 200
      expect(cart2.shippingCost, 0.0);
    });

    test('impostos são 8,5% do subtotal', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_produto(price: 100), 1); // subtotal 100
      expect(cart.taxes, closeTo(8.5, 0.0001));
    });

    test('total = subtotal + frete + impostos', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_produto(price: 100), 1); // subtotal 100, frete 15, imposto 8.5
      expect(cart.total, closeTo(123.5, 0.0001));
    });

    test('updateQuantity para 0 remove o item', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_produto(), 2);
      cart.updateQuantity(1, 0);
      expect(cart.isEmpty, isTrue);
    });

    test('removeItem e clearCart esvaziam o carrinho', () {
      final CartProvider cart = CartProvider();
      cart.addItem(_produto(id: 1), 1);
      cart.addItem(_produto(id: 2), 1);
      cart.removeItem(1);
      expect(cart.itemCount, 1);
      cart.clearCart();
      expect(cart.isEmpty, isTrue);
    });
  });
}
