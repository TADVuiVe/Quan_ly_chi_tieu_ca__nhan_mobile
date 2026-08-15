import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // =========================================================
          // 1. LỚP NỀN (BACKGROUND)
          // =========================================================
          // Ở đây mình dùng dải màu Gradient Xanh Ngọc - Đen cho hợp với app.
          // Bạn có thể thay đoạn Container này bằng Image.asset('đường_dẫn_ảnh', fit: BoxFit.cover) nếu muốn dùng ảnh thật.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Color(0xFF091A16)], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // =========================================================
          // 2. KHỐI THẺ THÔNG TIN (CARD)
          // =========================================================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3), 
                    blurRadius: 20, 
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Icon + Tên Đề Tài ---
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.blueAccent, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Quản lý chi tiêu',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Tên Sinh Viên ---
                  const Text(
                    'Thiều Quang Danh', // Tên của bạn
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  // --- Mô tả & Tên Trường ---
                  const Text(
                    'Ứng dụng theo dõi thu chi, chuyển đổi ngoại tệ thông minh và thống kê trực quan. Đồ án cuối kì - Đại học Gia Định.',
                    style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // --- Nút Bấm ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Chỉnh màu nút giống ảnh mẫu
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Khi bấm sẽ nhảy sang trang Đăng nhập (LoginScreen)
                        context.go('/');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Bắt đầu ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}