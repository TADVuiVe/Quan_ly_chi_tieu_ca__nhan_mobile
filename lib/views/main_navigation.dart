import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // THÊM PROVIDER ĐỂ GỌI BỘ NÃO
import '../viewmodels/expense_viewmodel.dart'; // GỌI FILE VIEWMODEL
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'category_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; // Biến lưu vết xem người dùng đang ở Tab nào

  // Danh sách 4 màn hình của ứng dụng
  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const CategoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Gọi ViewModel để lấy hàm dịch thuật
    final viewModel = context.watch<ExpenseViewModel>();

    return Scaffold(
      body: _screens[_currentIndex], // Hiển thị màn hình tương ứng
      
      // GIAO DIỆN MỚI: Thanh điều hướng chuẩn Material Design 3
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index; // Đổi tab khi bấm
          });
        },
        // ĐÃ BỎ TỪ KHÓA CONST Ở ĐÂY VÌ DỮ LIỆU ĐÃ TRỞ THÀNH ĐỘNG
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined), 
            selectedIcon: const Icon(Icons.home), 
            label: viewModel.getText('nav_home') // TỰ ĐỘNG ĐỔI NGÔN NGỮ
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline), 
            selectedIcon: const Icon(Icons.pie_chart), 
            label: viewModel.getText('nav_stats') // TỰ ĐỘNG ĐỔI NGÔN NGỮ
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined), 
            selectedIcon: const Icon(Icons.category), 
            label: viewModel.getText('nav_category') // TỰ ĐỘNG ĐỔI NGÔN NGỮ
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline), 
            selectedIcon: const Icon(Icons.person), 
            label: viewModel.getText('nav_profile') // TỰ ĐỘNG ĐỔI NGÔN NGỮ
          ),
        ],
      ),
    );
  }
}