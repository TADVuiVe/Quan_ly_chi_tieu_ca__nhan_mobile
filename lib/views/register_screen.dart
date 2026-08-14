import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/expense_viewmodel.dart';

// Giao diện Đăng ký tài khoản mới:
// Cung cấp biểu mẫu nhập liệu với tính năng kiểm tra tính hợp lệ của mật khẩu (độ dài, chữ hoa, chữ thường, số, ký tự đặc biệt).
// Tích hợp bộ lọc chặn khoảng trắng và ký tự tiếng Việt có dấu.
// Xử lý logic kiểm tra trùng lặp và lưu thông tin tài khoản mới thông qua ViewModel.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,15}$');
    return regex.hasMatch(password);
  }

  void _handleRegister() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (password != confirm) {
      _showMessage('Mật khẩu xác nhận không khớp!');
      return;
    }

    if (!isValidPassword(password)) {
      _showMessage('Mật khẩu phải từ 6-15 ký tự, gồm 1 chữ Hoa, 1 chữ Thường, 1 Số và 1 Ký tự đặc biệt.');
      return;
    }

    final vm = context.read<ExpenseViewModel>();
    final success = await vm.registerAccount(username, password);
    
    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công! Hãy đăng nhập.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.green));
      context.pop(); 
    } else {
      _showMessage('Tên đăng nhập đã tồn tại!');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Tài Khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.teal),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.app_registration, size: 80, color: Colors.teal),
                const SizedBox(height: 24),
                
                TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.visiblePassword, 
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\x21-\x7E]')), 
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Tên đăng nhập', 
                    labelStyle: TextStyle(color: Colors.teal),
                    prefixIcon: Icon(Icons.person, color: Colors.teal), 
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.black87),
                  keyboardType: TextInputType.visiblePassword, 
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\x21-\x7E]')), 
                  ],
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu', 
                    labelStyle: const TextStyle(color: Colors.teal),
                    prefixIcon: const Icon(Icons.lock, color: Colors.teal), 
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.teal), 
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword)
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('* Yêu cầu: 6-15 ký tự, 1 Hoa, 1 Thường, 1 Số, 1 Đặc biệt', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  style: const TextStyle(color: Colors.black87),
                  keyboardType: TextInputType.visiblePassword, 
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\x21-\x7E]')), 
                  ],
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu', 
                    labelStyle: const TextStyle(color: Colors.teal),
                    prefixIcon: const Icon(Icons.lock_clock, color: Colors.teal), 
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.teal), 
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), 
                    backgroundColor: Colors.teal, 
                    foregroundColor: Colors.white
                  ),
                  onPressed: _handleRegister,
                  child: const Text('ĐĂNG KÝ NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}