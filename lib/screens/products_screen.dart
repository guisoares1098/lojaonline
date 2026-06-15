import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/supabase_service.dart';
import '../theme.dart';
import '../utils/formatters.dart';
import '../widgets/cart_badge_button.dart';
import 'product_detail_screen.dart';

/// Lista de produtos buscados do Supabase.
class ProductsScreen extends StatefulWidget {
  static const String routeName = '/products';

  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final SupabaseService _service = SupabaseService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _service.fetchProducts();
  }

  void _reload() {
    setState(() {
      _productsFuture = _service.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: const <Widget>[CartBadgeButton()],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          // Carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Erro de conexão
          if (snapshot.hasError) {
            return _ErrorView(
              message:
                  'Não foi possível carregar os produtos.\nVerifique sua conexão e tente novamente.',
              onRetry: _reload,
            );
          }
          final List<Product> products = snapshot.data ?? <Product>[];
          if (products.isEmpty) {
            return const Center(child: Text('Nenhum produto disponível no momento.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                return _ProductCard(product: products[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ProductImage(url: product.imageUrl, size: 84),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(product.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(
                    formatMoney(product.price),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.hasStock
                        ? 'Estoque: ${product.stock}'
                        : 'Esgotado',
                    style: TextStyle(
                      fontSize: 12,
                      color: product.hasStock ? Colors.black54 : AppColors.warning,
                      fontWeight: product.hasStock ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        ProductDetailScreen.routeName,
                        arguments: product,
                      ),
                      child: const Text('Selecionar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mostra a imagem do produto a partir de uma URL, com placeholder enquanto
/// carrega ou caso a URL falhe/ seja nula.
class ProductImage extends StatelessWidget {
  final String? url;
  final double size;

  const ProductImage({required this.url, required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
      child: Icon(Icons.image_outlined, size: size * 0.5, color: AppColors.primaryDark),
    );

    if (url == null || url!.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.18),
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
          if (progress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off, size: 56, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
