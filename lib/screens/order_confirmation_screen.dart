import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme.dart';
import '../utils/formatters.dart';
import 'home_screen.dart';

/// Tela final de confirmação do pedido.
class OrderConfirmationScreen extends StatelessWidget {
  static const String routeName = '/order-confirmation';

  final Order order;

  const OrderConfirmationScreen({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido Confirmado'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          const SizedBox(height: 12),
          const Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.success,
              child: Icon(Icons.check, color: Colors.white, size: 56),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pedido Confirmado!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Obrigado pela sua compra. Os detalhes do pedido estão abaixo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 28),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _InfoRow(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Número de confirmação',
                    value: order.confirmationNumber,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Endereço de entrega',
                    value: order.shippingAddress,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Total pago',
                    value: formatMoney(order.total),
                    highlight: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Continuar Comprando', style: TextStyle(fontSize: 16)),
            onPressed: () {
              // Volta para a Home limpando toda a pilha de navegação.
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeScreen.routeName,
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: highlight ? 22 : 16,
                  fontWeight: FontWeight.bold,
                  color: highlight ? AppColors.success : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
