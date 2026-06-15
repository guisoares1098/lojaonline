/// Modelo que representa um pedido finalizado.
///
/// Espelha a tabela `orders` no Supabase. É usado principalmente para
/// transportar os dados do pedido confirmado até a tela de confirmação.
class Order {
  final int? id;
  final String confirmationNumber;
  final String billingAddress;
  final String shippingAddress;
  final double subtotal;
  final double shippingCost;
  final double taxes;
  final double total;
  final String status;

  const Order({
    this.id,
    required this.confirmationNumber,
    required this.billingAddress,
    required this.shippingAddress,
    required this.subtotal,
    required this.shippingCost,
    required this.taxes,
    required this.total,
    this.status = 'confirmed',
  });

  /// Converte o pedido em um mapa pronto para inserir no Supabase.
  Map<String, dynamic> toInsertMap() {
    return <String, dynamic>{
      'confirmation_number': confirmationNumber,
      'billing_address': billingAddress,
      'shipping_address': shippingAddress,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'taxes': taxes,
      'total': total,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: (map['id'] as num?)?.toInt(),
      confirmationNumber: (map['confirmation_number'] ?? '') as String,
      billingAddress: (map['billing_address'] ?? '') as String,
      shippingAddress: (map['shipping_address'] ?? '') as String,
      subtotal: _toDouble(map['subtotal']),
      shippingCost: _toDouble(map['shipping_cost']),
      taxes: _toDouble(map['taxes']),
      total: _toDouble(map['total']),
      status: (map['status'] ?? 'pending') as String,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
