import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'viewmodels/expense_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/main_navigation.dart';
import 'views/register_screen.dart'; // THÊM IMPORT TRANG ĐĂNG KÝ MỚI

// --- ĐỊNH NGHĨA 2 BẢNG MÀU CHỦ ĐẠO (SÁNG / TỐI) ---
final kColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.teal,
);

final kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Colors.teal,
);

// --- ĐƯA ĐIỀU HƯỚNG RA NGOÀI ĐỂ KHÔNG BỊ RESET VỀ ĐĂNG NHẬP ---
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    // THÊM ĐOẠN NÀY ĐỂ CHUYỂN SANG TRANG ĐĂNG KÝ
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
  
  // Khởi tạo Cơ sở dữ liệu Hive
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
    // Lắng nghe trạng thái bật/tắt từ công tắc Dark Mode
    final isDarkMode = context.watch<ExpenseViewModel>().isDarkMode;

    return MaterialApp.router(
      title: 'Quản Lý Chi Tiêu',
      debugShowCheckedModeBanner: false,
      
      // --- CẤU HÌNH GIAO DIỆN SÁNG ---
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.primary,
          foregroundColor: kColorScheme.onPrimary,
        ),
        scaffoldBackgroundColor: kColorScheme.surface,
      ),
      
      // --- CẤU HÌNH GIAO DIỆN TỐI (DARK MODE) ---
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kDarkColorScheme.primaryContainer,
          foregroundColor: kDarkColorScheme.onPrimaryContainer,
        ),
        scaffoldBackgroundColor: kDarkColorScheme.surface,
      ),
      
      // --- CÔNG TẮC ĐIỀU KHIỂN TỰ ĐỘNG ---
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      routerConfig: _router,
    );
  }
}