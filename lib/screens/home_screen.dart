import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../theme.dart';
import 'cart_screen.dart';
import 'products_screen.dart';

/// Tela inicial da loja.
class HomeScreen extends StatelessWidget {
  static const String routeName = '/';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Loja Online')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            const SizedBox(height: 12),
            _Hero(),
            const SizedBox(height: 28),
            Text(
              'Bem-vindo à Loja Online!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Produtos de qualidade com preços justos e entrega rápida.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.shopping_bag_outlined, size: 26),
              label: const Text('Ver Produtos', style: TextStyle(fontSize: 19)),
              onPressed: () => Navigator.pushNamed(context, ProductsScreen.routeName),
            ),
            const SizedBox(height: 16),
            // Botão do carrinho com badge de quantidade.
            Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              offset: const Offset(-12, 8),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.shopping_cart_outlined, size: 26),
                label: const Text('Carrinho', style: TextStyle(fontSize: 19)),
                onPressed: () => Navigator.pushNamed(context, CartScreen.routeName),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.surfaceTint, Colors.white],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(Icons.headphones, size: 56, color: AppColors.primaryDark),
          Icon(Icons.watch, size: 48, color: AppColors.primaryDark),
          Icon(Icons.shopping_bag, size: 52, color: AppColors.primaryDark),
        ],
      ),
    );
  }
}
