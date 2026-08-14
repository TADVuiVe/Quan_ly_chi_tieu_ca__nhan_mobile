import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_viewmodel.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'category_screen.dart';
import 'profile_screen.dart';

// Khung điều hướng chính của ứng dụng (Bottom Navigation Bar):
// Quản lý trạng thái chuyển đổi qua lại giữa 4 màn hình cốt lõi: Trang chủ, Thống kê, Danh mục và Cá nhân.
// Áp dụng giao diện chuẩn Material Design 3 và liên kết trực tiếp với ViewModel để tự động dịch thuật tên các tab.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; 

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const CategoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseViewModel>();

    return Scaffold(
      body: _screens[_currentIndex], 
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index; 
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined), 
            selectedIcon: const Icon(Icons.home), 
            label: viewModel.getText('nav_home') 
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline), 
            selectedIcon: const Icon(Icons.pie_chart), 
            label: viewModel.getText('nav_stats') 
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined), 
            selectedIcon: const Icon(Icons.category), 
            label: viewModel.getText('nav_category') 
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline), 
            selectedIcon: const Icon(Icons.person), 
            label: viewModel.getText('nav_profile') 
          ),
        ],
      ),
    );
  }
}