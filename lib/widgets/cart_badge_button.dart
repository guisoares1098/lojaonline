import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';

/// Ícone de carrinho com um badge mostrando a quantidade de itens.
/// Reaproveitado nas AppBars das telas.
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final int count = context.watch<CartProvider>().itemCount;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Badge(
        label: Text('$count'),
        isLabelVisible: count > 0,
        child: IconButton(
          tooltip: 'Carrinho',
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pushNamed(context, CartScreen.routeName),
        ),
      ),
    );
  }
}
