import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/expense_viewmodel.dart';

// Giao diện Hồ sơ cá nhân (Profile Screen):
// Hiển thị thông tin người dùng, ảnh đại diện (tích hợp tải ảnh từ thư viện) và trạng thái gói thành viên hiện tại.
// Cung cấp giao diện quản lý liên kết ví điện tử/ngân hàng và xử lý thao tác đăng xuất an toàn.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseViewModel>();
    final currentPlan = viewModel.currentPlan;
    final avatarPath = viewModel.avatarPath;

    String currentPlanKey = currentPlan; 
    if (currentPlan.contains('Cơ bản')) currentPlanKey = 'plan_basic';
    else if (currentPlan.contains('Thành viên')) currentPlanKey = 'plan_member';
    else if (currentPlan.contains('VIP')) currentPlanKey = 'plan_vip';
    else if (currentPlan == 'Miễn phí' || currentPlan == 'Chưa đăng ký') currentPlanKey = 'plan_free';

    final displayPlan = viewModel.getText(currentPlanKey);

    Color badgeColor = Colors.grey;
    IconData badgeIcon = Icons.account_circle;
    
    if (currentPlanKey == 'plan_basic') {
      badgeColor = Colors.blue;
      badgeIcon = Icons.shield;
    } else if (currentPlanKey == 'plan_member') {
      badgeColor = Colors.purple;
      badgeIcon = Icons.stars;
    } else if (currentPlanKey == 'plan_vip') {
      badgeColor = Colors.orange;
      badgeIcon = Icons.workspace_premium;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.getText('profile_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: avatarPath.isNotEmpty 
                      ? FileImage(File(avatarPath)) as ImageProvider
                      : const NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                    onPressed: () => viewModel.pickAvatar(), 
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              viewModel.getText('anonymous_user'), 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: badgeColor, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, color: badgeColor),
                  const SizedBox(width: 8),
                  Text(
                    displayPlan, 
                    style: TextStyle(
                      color: badgeColor, 
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(viewModel.getText('finance_payment'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.account_balance_wallet, color: Colors.white),
                ),
                title: Text(viewModel.getText('wallet_bank'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Text('ZaloPay, MoMo, Vietcombank...'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showPaymentLinksBottomSheet(context, viewModel),
              ),
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(viewModel.getText('logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    content: Text(viewModel.currentLanguage == 'en' ? 'Are you sure you want to log out?' : 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx), 
                        child: Text(viewModel.getText('cancel'), style: const TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(ctx); 
                          context.go('/'); 
                        },
                        child: Text(viewModel.getText('logout')),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: Text(viewModel.getText('logout'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPaymentLinksBottomSheet(BuildContext context, ExpenseViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(vm.getText('payment_link_title'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(vm.getText('payment_link_desc'), style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              
              _buildPaymentOption(Icons.account_balance, Colors.blue.shade700, vm.getText('bank_account'), vm.getText('not_linked'), vm),
              const Divider(),
              _buildPaymentOption(Icons.qr_code_scanner, Colors.pink, vm.getText('momo_wallet'), vm.getText('not_linked'), vm),
              const Divider(),
              _buildPaymentOption(Icons.payment, Colors.green.shade600, vm.getText('zalopay_wallet'), vm.getText('not_linked'), vm),
              
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPaymentOption(IconData icon, Color color, String title, String status, ExpenseViewModel vm) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(status, style: const TextStyle(color: Colors.grey)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        onPressed: () {},
        child: Text(vm.getText('link_btn')),
      ),
    );
  }
}