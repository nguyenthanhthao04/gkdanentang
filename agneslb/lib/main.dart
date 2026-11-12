import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/filter_sort_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const AgnesLBApp());
}

class AgnesLBApp extends StatelessWidget {
  const AgnesLBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgnesLB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryNavy,
          primary: AppColors.primaryNavy,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/products': (context) => const ProductListScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/edit-product': (context) => const EditProductScreen(),
        '/product-detail': (context) => const ProductDetailScreen(),
        '/filter-sort': (context) => const FilterSortScreen(),
      },
    );
  }
}
