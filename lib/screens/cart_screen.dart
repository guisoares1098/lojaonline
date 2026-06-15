import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../theme.dart';
import '../utils/formatters.dart';
import 'checkout_screen.dart';
import 'products_screen.dart';

/// Carrinho de compras: lista de itens, ajustes e resumo financeiro.
class CartScreen extends StatelessWidget {
  static const String routeName = '/cart';

  const CartScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  Future<void> _confirmCancel(BuildContext context, CartProvider cart) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar pedido'),
          content: const Text('Deseja remover todos os itens do carrinho?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Limpar carrinho'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      cart.clearCart();
      if (context.mounted) {
        _showMessage(context, 'Carrinho esvaziado.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: cart.isEmpty
          ? _EmptyCart()
          : ListView(
              padding: const EdgeInsets.all(14),
              children: <Widget>[
                Text(
                  'Seus itens (${cart.itemCount})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                ),
                const SizedBox(height: 10),
                for (final CartItem item in cart.items)
                  _CartItemCard(item: item),
                const SizedBox(height: 8),
                _SummaryCard(cart: cart),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Finalizar Pedido', style: TextStyle(fontSize: 16)),
                  onPressed: () => Navigator.pushNamed(context, CheckoutScreen.routeName),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: AppColors.warning,
                    side: const BorderSide(color: AppColors.warning),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Cancelar Pedido'),
                  onPressed: () => _confirmCancel(context, cart),
                ),
              ],
            ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = context.read<CartProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ProductImage(url: item.product.imageUrl, size: 60),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('#${item.product.id}  ${item.product.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Unitário: ${formatMoney(item.product.price)}',
                          style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remover item',
                  icon: const Icon(Icons.close, color: AppColors.warning),
                  onPressed: () => cart.removeItem(item.product.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _QuantityControl(
                  quantity: item.quantity,
                  onDecrease: () =>
                      cart.updateQuantity(item.product.id, item.quantity - 1),
                  onIncrease: () {
                    if (item.quantity < item.product.stock) {
                      cart.updateQuantity(item.product.id, item.quantity + 1);
                    } else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                              'Estoque máximo: ${item.product.stock} unidades.'),
                        ),
                      );
                    }
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Text('Subtotal', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    Text(formatMoney(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB9C8E6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: onDecrease,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Icon(Icons.remove, size: 18, color: AppColors.primary),
            ),
          ),
          Container(
            width: 38,
            alignment: Alignment.center,
            child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          InkWell(
            onTap: onIncrease,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Icon(Icons.add, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final CartProvider cart;

  const _SummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    final bool freeShipping = cart.shippingCost == 0;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Resumo da compra',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _SummaryRow(label: 'Subtotal', value: formatMoney(cart.subtotal)),
            _SummaryRow(
              label: 'Frete',
              value: freeShipping ? 'Grátis' : formatMoney(cart.shippingCost),
            ),
            _SummaryRow(label: 'Impostos (8,5%)', value: formatMoney(cart.taxes)),
            const Divider(),
            _SummaryRow(label: 'Total', value: formatMoney(cart.total), highlight: true),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
      fontSize: highlight ? 19 : 15,
      color: highlight ? AppColors.primary : Colors.black87,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: style.copyWith(color: highlight ? AppColors.primary : Colors.black87)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            const Text('Seu carrinho está vazio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            const Text('Adicione produtos para continuar.', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Ir às compras'),
              onPressed: () => Navigator.pushReplacementNamed(context, ProductsScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
