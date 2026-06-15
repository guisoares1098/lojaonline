import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'models/order.dart';
import 'models/product.dart';
import 'providers/cart_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/home_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Supabase com as credenciais do projeto.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const LojaOnlineApp());
}

class LojaOnlineApp extends StatelessWidget {
  const LojaOnlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartProvider>(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'Loja Online',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: HomeScreen.routeName,
        routes: <String, WidgetBuilder>{
          HomeScreen.routeName: (_) => const HomeScreen(),
          ProductsScreen.routeName: (_) => const ProductsScreen(),
          CartScreen.routeName: (_) => const CartScreen(),
          CheckoutScreen.routeName: (_) => const CheckoutScreen(),
        },
        // Rotas que recebem argumentos são resolvidas aqui.
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case ProductDetailScreen.routeName:
              final Product product = settings.arguments as Product;
              return MaterialPageRoute<void>(
                builder: (_) => ProductDetailScreen(product: product),
                settings: settings,
              );
            case OrderConfirmationScreen.routeName:
              final Order order = settings.arguments as Order;
              return MaterialPageRoute<void>(
                builder: (_) => OrderConfirmationScreen(order: order),
                settings: settings,
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
