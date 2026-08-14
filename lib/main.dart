import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/main_navigation.dart';
import 'views/register_screen.dart';

// Điểm bắt đầu (Entry point) của ứng dụng:
// Khởi tạo cơ sở dữ liệu cục bộ (Hive) và hệ thống quản lý trạng thái toàn cục (Provider).
// Cấu hình bộ định tuyến (GoRouter) để điều hướng giữa Đăng nhập, Đăng ký và màn hình chính.
// Thiết lập giao diện tổng thể (ThemeData) hỗ trợ chuyển đổi mượt mà giữa chế độ Sáng và Tối (Dark Mode).
final kColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.teal,
);

final kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Colors.teal,
);

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigation(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('expense_box');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseViewModel()..loadExpenses(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ExpenseViewModel>().isDarkMode;

    return MaterialApp.router(
      title: 'Quản Lý Chi Tiêu',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.primary,
          foregroundColor: kColorScheme.onPrimary,
        ),
        scaffoldBackgroundColor: kColorScheme.surface,
      ),
      
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kDarkColorScheme.primaryContainer,
          foregroundColor: kDarkColorScheme.onPrimaryContainer,
        ),
        scaffoldBackgroundColor: kDarkColorScheme.surface,
      ),
      
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      routerConfig: _router,
    );
  }
}