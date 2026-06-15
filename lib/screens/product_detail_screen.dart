import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme.dart';
import '../utils/formatters.dart';
import '../widgets/cart_badge_button.dart';
import 'products_screen.dart';

/// Detalhes de um produto, com seletor de quantidade e adição ao carrinho.
class ProductDetailScreen extends StatefulWidget {
  static const String routeName = '/product-detail';

  final Product product;

  const ProductDetailScreen({required this.product, super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  Product get product => widget.product;

  void _decrease() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _increase() {
    if (_quantity < product.stock) {
      setState(() => _quantity++);
    } else {
      _showMessage(
        'Quantidade máxima atingida. Estoque disponível: ${product.stock}.',
      );
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? AppColors.success : null,
        content: Text(message),
      ),
    );
  }

  void _addToCart() {
    context.read<CartProvider>().addItem(product, _quantity);
    _showMessage('Produto adicionado ao carrinho!', success: true);
  }

  @override
  Widget build(BuildContext context) {
    final bool inStock = product.hasStock;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: const <Widget>[CartBadgeButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          Center(child: ProductImage(url: product.imageUrl, size: 180)),
          const SizedBox(height: 18),
          Text(
            product.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
          ),
          const SizedBox(height: 6),
          Text('Código do produto: #${product.id}',
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Text(
            formatMoney(product.price),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Icon(
                inStock ? Icons.check_circle : Icons.cancel,
                color: inStock ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                inStock
                    ? 'Em estoque: ${product.stock} unidades'
                    : 'Produto esgotado',
                style: TextStyle(
                  color: inStock ? Colors.black87 : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 8),
          Text('Descrição',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(product.longDescription, style: const TextStyle(height: 1.45)),
          const SizedBox(height: 24),

          // Seletor de quantidade
          if (inStock) ...<Widget>[
            Row(
              children: <Widget>[
                const Text('Quantidade:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 16),
                _QuantitySelector(
                  quantity: _quantity,
                  onDecrease: _decrease,
                  onIncrease: _increase,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: inStock ? AppColors.primary : Colors.grey,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(
              inStock ? 'Adicionar ao Carrinho' : 'Indisponível',
              style: const TextStyle(fontSize: 16),
            ),
            // Botão desabilitado quando não há estoque.
            onPressed: inStock ? _addToCart : null,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Ver Mais Produtos', style: TextStyle(fontSize: 16)),
            onPressed: () {
              // Volta para a lista de produtos (ou abre, se não houver pilha).
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, ProductsScreen.routeName);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantitySelector({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB9C8E6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove, color: AppColors.primary),
          ),
          Container(
            width: 44,
            alignment: Alignment.center,
            child: Text('$quantity',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
