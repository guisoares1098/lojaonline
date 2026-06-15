# Loja Online Simples — Flutter + Supabase

Aplicativo de loja online completo em Flutter, com backend no Supabase
(PostgreSQL). Fluxo: **Home → Produtos → Detalhes → Carrinho → Checkout →
Confirmação**.

Baseado no projeto didático do Prof. Alexandre Garcez Vieira, aprimorado com
persistência em banco de dados via Supabase.

## Arquitetura

```
lib/
  main.dart                      # init do Supabase, Provider e rotas nomeadas
  config/supabase_config.dart    # URL e chave anon do projeto
  theme.dart                     # cores e ThemeData
  utils/formatters.dart          # formatação de moeda (R$ 0,00)
  models/
    product.dart
    cart_item.dart
    order.dart
  services/
    supabase_service.dart        # fetchProducts, fetchProductById, createOrder, updateStock
  providers/
    cart_provider.dart           # estado do carrinho (subtotal, frete, impostos, total)
  widgets/
    cart_badge_button.dart       # ícone de carrinho com badge
  screens/
    home_screen.dart
    products_screen.dart
    product_detail_screen.dart
    cart_screen.dart
    checkout_screen.dart
    order_confirmation_screen.dart
```

## Backend (Supabase)

Projeto: **zaprun-loja-online** (região `sa-east-1`).

Tabelas: `products`, `orders`, `order_items` (com RLS habilitado — leitura
pública de `products`, leitura/escrita de `orders` e `order_items`, e update
de estoque em `products`). A tabela `products` já vem populada com 8 produtos
de exemplo.

As credenciais estão em `lib/config/supabase_config.dart`.

## Regras de negócio

- **Frete:** R$ 15,00 fixo, **grátis** quando o subtotal passa de R$ 200,00.
- **Impostos:** 8,5% sobre o subtotal.
- **Total:** subtotal + frete + impostos.
- **Estoque:** validado ao adicionar ao carrinho, ao ajustar a quantidade e
  novamente no servidor ao finalizar o pedido. Produtos sem estoque ficam com
  o botão "Adicionar ao Carrinho" desabilitado.
- Ao confirmar o pedido: gera `#LOJA-XXXXXXXX`, grava em `orders` +
  `order_items` e desconta o estoque em `products`.

## Como rodar

Pré-requisito: Flutter SDK instalado (`flutter doctor` sem erros).

```bash
cd loja_online_simples_flutter_aprimorado
flutter pub get
flutter run
```

Para Android, a permissão de internet já está declarada em
`android/app/src/main/AndroidManifest.xml`.
