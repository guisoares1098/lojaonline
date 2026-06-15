import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../services/supabase_service.dart';
import '../theme.dart';
import '../utils/formatters.dart';
import 'order_confirmation_screen.dart';

/// Tela de finalização: formulário de endereços + confirmação do pedido.
class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _billingController = TextEditingController();
  final TextEditingController _shippingController = TextEditingController();
  final SupabaseService _service = SupabaseService();

  bool _sameAddress = true;
  bool _submitting = false;

  @override
  void dispose() {
    _billingController.dispose();
    _shippingController.dispose();
    super.dispose();
  }

  String? _validateAddress(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Campo obrigatório';
    if (text.length < 10) return 'Informe um endereço completo (mín. 10 caracteres)';
    return null;
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.warning : null,
        content: Text(message),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final CartProvider cart = context.read<CartProvider>();

    if (cart.isEmpty) {
      _showMessage('Seu carrinho está vazio.', error: true);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showMessage('Verifique os campos do formulário.', error: true);
      return;
    }

    final String billing = _billingController.text.trim();
    final String shipping =
        _sameAddress ? billing : _shippingController.text.trim();

    setState(() => _submitting = true);
    try {
      final String confirmationNumber = await _service.createOrder(
        items: cart.items,
        billingAddress: billing,
        shippingAddress: shipping,
        subtotal: cart.subtotal,
        shippingCost: cart.shippingCost,
        taxes: cart.taxes,
        total: cart.total,
      );

      final Order order = Order(
        confirmationNumber: confirmationNumber,
        billingAddress: billing,
        shippingAddress: shipping,
        subtotal: cart.subtotal,
        shippingCost: cart.shippingCost,
        taxes: cart.taxes,
        total: cart.total,
      );

      cart.clearCart();

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        OrderConfirmationScreen.routeName,
        arguments: order,
      );
    } catch (error) {
      if (mounted) {
        _showMessage('Não foi possível concluir o pedido: $error', error: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Pedido')),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text('Endereço de cobrança',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _billingController,
                minLines: 2,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Endereço de cobrança',
                  hintText: 'Rua, número, bairro, cidade - UF, CEP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: _validateAddress,
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.white,
                child: CheckboxListTile(
                  value: _sameAddress,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Mesmo endereço para entrega'),
                  onChanged: (bool? value) {
                    setState(() => _sameAddress = value ?? false);
                  },
                ),
              ),
              if (!_sameAddress) ...<Widget>[
                const SizedBox(height: 8),
                Text('Endereço de entrega',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _shippingController,
                  minLines: 2,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Endereço de entrega',
                    hintText: 'Rua, número, bairro, cidade - UF, CEP',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_shipping_outlined),
                  ),
                  validator: (String? value) {
                    if (_sameAddress) return null;
                    return _validateAddress(value);
                  },
                ),
              ],
              const SizedBox(height: 16),
              _OrderSummary(cart: cart),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_submitting ? 'Processando...' : 'Confirmar Pedido',
                    style: const TextStyle(fontSize: 16)),
                onPressed: _submitting ? null : _confirmOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;

  const _OrderSummary({required this.cart});

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
            Text('Resumo do pedido',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _row('Subtotal', formatMoney(cart.subtotal)),
            _row('Frete', freeShipping ? 'Grátis' : formatMoney(cart.shippingCost)),
            _row('Impostos (8,5%)', formatMoney(cart.taxes)),
            const Divider(),
            _row('Total', formatMoney(cart.total), highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
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
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
