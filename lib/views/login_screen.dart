import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/expense_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() {
    final user = _usernameController.text;
    final pass = _passwordController.text;
    
    if (user.isEmpty || pass.isEmpty) {
      _showDevMessage('Vui lòng nhập tài khoản và mật khẩu!');
      return;
    }

    final vm = context.read<ExpenseViewModel>();
    if (vm.login(user, pass)) {
      context.go('/home'); 
    } else {
      _showDevMessage('Sai tài khoản hoặc mật khẩu!');
    }
  }

  void _handleOfflineMode() {
    context.read<ExpenseViewModel>().setOfflineMode(true);
    context.go('/home');
  }

  void _showDevMessage(String msg) {
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet, size: 100, color: Colors.teal),
                const SizedBox(height: 16),
                const Text('QUẢN LÝ CHI TIÊU', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.teal)),
                const SizedBox(height: 40),
                
                // Ô NHẬP TÊN ĐĂNG NHẬP
                TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.visiblePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    // KHIÊN BẤT TỬ: CHỈ CHO PHÉP ASCII CƠ BẢN. CHẶN KHOẢNG TRẮNG & TIẾNG VIỆT
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
                
                // Ô NHẬP MẬT KHẨU
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    // KHIÊN BẤT TỬ: CHỈ CHO PHÉP ASCII CƠ BẢN. CHẶN KHOẢNG TRẮNG & TIẾNG VIỆT
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
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: _handleLogin,
                    child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => context.push('/register'), child: const Text('Tạo tài khoản mới', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                    TextButton(onPressed: () => _showDevMessage('Tính năng đang được phát triển'), child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.teal))),
                  ],
                ),
                
                const Divider(height: 40, color: Colors.grey),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.orange, width: 2), foregroundColor: Colors.orange),
                    onPressed: _handleOfflineMode,
                    icon: const Icon(Icons.wifi_off),
                    label: const Text('VÀO CHẾ ĐỘ OFFLINE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.facebook, color: Colors.teal, size: 40), onPressed: () => _showDevMessage('Tính năng đang được phát triển')),
                    const SizedBox(width: 16),
                    IconButton(icon: const Icon(Icons.g_mobiledata, color: Colors.teal, size: 50), onPressed: () => _showDevMessage('Tính năng đang được phát triển')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}