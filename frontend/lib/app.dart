import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repo_dummy.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/customer/gold_rate/data/gold_rate_repo_dummy.dart';
import 'features/customer/gold_rate/data/gold_rate_repository.dart';
import 'features/customer/products/data/product_repo_dummy.dart';
import 'features/customer/products/data/product_repository.dart';
import 'features/customer/wishlist/data/wishlist_store.dart';

import 'features/auth/presentation/splash_screen.dart';

class AurixApp extends StatelessWidget {
  const AurixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepoDummy()),
        Provider<GoldRateRepository>(create: (_) => GoldRateRepoDummy()),
        Provider<ProductRepository>(create: (_) => ProductRepoDummy()),
        ChangeNotifierProvider<WishlistStore>(create: (_) => WishlistStore()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aurix',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system, // ✅ follows phone theme
        home: const SplashScreen(),
      ),
    );
  }
}