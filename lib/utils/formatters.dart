/// Formata um valor numérico como moeda em Real brasileiro: `R$ 1.234,56`.
String formatMoney(double value) {
  final String fixed = value.toStringAsFixed(2); // ex: 1234.56
  final List<String> parts = fixed.split('.');
  final String integerPart = parts[0];
  final String decimalPart = parts[1];

  // Insere o separador de milhar (.)
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < integerPart.length; i++) {
    if (i > 0 && (integerPart.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(integerPart[i]);
  }

  return 'R\$ ${buffer.toString()},$decimalPart';
}
