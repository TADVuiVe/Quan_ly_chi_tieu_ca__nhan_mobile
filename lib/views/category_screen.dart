import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_viewmodel.dart';

// Giao diện màn hình Danh mục & Cài đặt hệ thống:
// Quản lý hiển thị các tính năng nâng cao: Nâng cấp gói thành viên, Liên kết tài khoản, Bảo mật và Đổi ngôn ngữ.
// Cung cấp giao diện dọn dẹp bộ nhớ (xóa dữ liệu cũ) và thiết lập ứng dụng (Dark Mode, Thông báo).
// Xử lý logic hiển thị cảnh báo chặn thao tác khi người dùng đang ở chế độ Offline.
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  void _showDevMessage(BuildContext context) {
    final vm = context.read<ExpenseViewModel>();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.getText('dev_feature')), backgroundColor: Colors.grey.shade800));
  }

  void _showOfflineWarning(BuildContext context) {
    final vm = context.read<ExpenseViewModel>();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(vm.getText('offline_blocked'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseViewModel>();
    
    String displayPlanKey = viewModel.currentPlan;
    if (displayPlanKey.contains('Cơ bản')) displayPlanKey = 'plan_basic';
    else if (displayPlanKey.contains('Thành viên')) displayPlanKey = 'plan_member';
    else if (displayPlanKey.contains('VIP')) displayPlanKey = 'plan_vip';
    else if (displayPlanKey == 'Miễn phí' || displayPlanKey == 'Chưa đăng ký') displayPlanKey = 'plan_free';

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.getText('category_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Nâng cấp gói thành viên
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.workspace_premium, color: Colors.orange, size: 28),
                ),
                title: Text(viewModel.getText('upgrade_account'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                subtitle: Text('${viewModel.getText('current_plan')} ${viewModel.getText(displayPlanKey)}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  if (viewModel.isOfflineMode) {
                    _showOfflineWarning(context);
                  } else {
                    _showSubscriptionBottomSheet(context, viewModel);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(viewModel.getText('system'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),

          // 1. Quản lý bộ nhớ
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.storage, color: Colors.white)),
              title: Text(viewModel.getText('memory_management'), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${viewModel.getText('used')} ${viewModel.storageSize}'),
              trailing: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 28),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Row(children: [const Icon(Icons.warning_amber_rounded, color: Colors.redAccent), const SizedBox(width: 8), Text(viewModel.getText('warning_delete'), style: const TextStyle(fontWeight: FontWeight.bold))]),
                    content: Text(viewModel.getText('warning_msg'), style: const TextStyle(fontSize: 15, height: 1.5)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(viewModel.getText('cancel'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        onPressed: () {
                          context.read<ExpenseViewModel>().clearOldData();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.getText('delete_success')), backgroundColor: Colors.green));
                        },
                        child: Text(viewModel.getText('confirm_delete')),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 2. Cài đặt hệ thống
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.settings, color: Colors.white)),
              title: Text(viewModel.getText('system_settings'), style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (ctx) {
                    return Consumer<ExpenseViewModel>(
                      builder: (context, vm, child) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                              const SizedBox(height: 20),
                              Text(vm.getText('system_settings'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              SwitchListTile(
                                activeThumbColor: Colors.teal,
                                title: Text(vm.getText('dark_mode')),
                                secondary: Icon(vm.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: vm.isDarkMode ? Colors.purpleAccent : Colors.orange),
                                value: vm.isDarkMode,
                                onChanged: (val) => vm.toggleTheme(val),
                              ),
                              const Divider(),
                              SwitchListTile(
                                activeThumbColor: Colors.teal,
                                title: Text(vm.getText('notifications')),
                                secondary: Icon(vm.isNotificationEnabled ? Icons.notifications_active : Icons.notifications_off, color: Colors.blue),
                                value: vm.isNotificationEnabled,
                                onChanged: (val) => vm.toggleNotification(val),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      }
                    );
                  }
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 3. Liên kết tài khoản
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.link, color: Colors.white)),
              title: Text(viewModel.getText('link_account'), style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                if (viewModel.isOfflineMode) {
                  _showOfflineWarning(context);
                } else {
                  _showLinkAccountsBottomSheet(context, viewModel);
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // 4. Bảo mật tài khoản
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const CircleAvatar(backgroundColor: Colors.deepOrange, child: Icon(Icons.security, color: Colors.white)),
              title: Text(viewModel.getText('security'), style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                if (viewModel.isOfflineMode) {
                  _showOfflineWarning(context);
                } else {
                  _showSecurityBottomSheet(context, viewModel);
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // 5. Cài đặt ngôn ngữ (Hỗ trợ Offline)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const CircleAvatar(backgroundColor: Colors.lightBlue, child: Icon(Icons.language, color: Colors.white)),
              title: Text(viewModel.getText('language'), style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showLanguageBottomSheet(context, viewModel);
              },
            ),
          ),
          const SizedBox(height: 12),

          // 6. Điều khoản và chính sách
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.policy, color: Colors.white)),
              title: Text(viewModel.getText('policy'), style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionBottomSheet(BuildContext context, ExpenseViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text(vm.getText('choose_plan'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildPlanCard(context, vm, 'plan_basic', 25000, Colors.blue, [vm.getText('perk_basic_1'), vm.getText('perk_basic_2'), vm.getText('perk_basic_3')]),
                    const SizedBox(height: 12),
                    _buildPlanCard(context, vm, 'plan_member', 125000, Colors.purple, [vm.getText('perk_member_1'), vm.getText('perk_member_2'), vm.getText('perk_member_3')]),
                    const SizedBox(height: 12),
                    _buildPlanCard(context, vm, 'plan_vip', 225000, Colors.orange, [vm.getText('perk_vip_1'), vm.getText('perk_vip_2'), vm.getText('perk_vip_3'), vm.getText('perk_vip_4')]),
                    const SizedBox(height: 24),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildPlanCard(BuildContext context, ExpenseViewModel vm, String planKey, double priceAmount, Color color, List<String> perks) {
    String planName = vm.getText(planKey);
    String priceStr = '${vm.formatDynamicCurrency(priceAmount)} ${vm.getText('per_month')}';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withValues(alpha: 0.5), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(planName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                Text(priceStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            ...perks.map((perk) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(children: [Icon(Icons.check_circle, color: color, size: 20), const SizedBox(width: 12), Expanded(child: Text(perk))]),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: Text(vm.getText('confirm_payment'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      content: Text('${vm.getText('payment_confirm_msg')} $priceStr ${vm.getText('for_plan')} $planName?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(vm.getText('cancel'), style: const TextStyle(color: Colors.grey))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
                          onPressed: () {
                            context.read<ExpenseViewModel>().updatePlan(planKey); 
                            Navigator.pop(dialogCtx);
                            Navigator.pop(context); 
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${vm.getText('upgrade_success')} $planName!'), backgroundColor: Colors.green));
                          },
                          child: Text(vm.getText('agree')),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(vm.getText('register_now'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showLinkAccountsBottomSheet(BuildContext context, ExpenseViewModel vm) {
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
              Text(vm.getText('link_account'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(vm.getText('link_desc'), style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              
              _buildLinkOption(context, vm, Icons.phone_android, Colors.green, vm.getText('phone'), vm.getText('not_linked')),
              const Divider(),
              _buildLinkOption(context, vm, Icons.facebook, Colors.blue, 'Facebook', vm.getText('not_linked')),
              const Divider(),
              _buildLinkOption(context, vm, Icons.g_mobiledata, Colors.red, 'Google', vm.getText('not_linked')),
              const Divider(),
              _buildLinkOption(context, vm, Icons.email, Colors.redAccent, 'Gmail', vm.getText('not_linked')),
              
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _buildLinkOption(BuildContext context, ExpenseViewModel vm, IconData icon, Color color, String title, String status) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 36),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(status, style: const TextStyle(color: Colors.grey)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color.withValues(alpha: 0.1), foregroundColor: color, elevation: 0),
        onPressed: () {
          if (vm.isOfflineMode) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(vm.getText('offline_blocked'), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating)
            );
          } else {
            _showDevMessage(context);
          }
        },
        child: Text(vm.getText('link_btn')),
      ),
    );
  }

  void _showSecurityBottomSheet(BuildContext context, ExpenseViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(vm.getText('security_center'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(vm.getText('security_desc'), style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              
              _buildSecurityOption(context: context, vm: vm, icon: Icons.message, color: Colors.blue, title: vm.getText('2fa'), subtitle: vm.getText('2fa_desc'), isPro: false),
              const SizedBox(height: 12),
              _buildSecurityOption(context: context, vm: vm, icon: Icons.fingerprint, color: Colors.purple, title: vm.getText('biometric'), subtitle: vm.getText('biometric_desc'), isPro: false),
              const SizedBox(height: 12),
              _buildSecurityOption(context: context, vm: vm, icon: Icons.key, color: Colors.orange, title: vm.getText('fido'), subtitle: vm.getText('fido_desc'), isPro: true),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSecurityOption({required BuildContext context, required ExpenseViewModel vm, required IconData icon, required Color color, required String title, required String subtitle, required bool isPro}) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            if (isPro) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)), child: const Text('MAX', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)))
          ],
        ),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(subtitle, style: const TextStyle(fontSize: 12))),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, elevation: 0),
          onPressed: () {
            if (vm.isOfflineMode) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.getText('offline_blocked'), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
            } else {
              _showDevMessage(context);
            }
          },
          child: Text(vm.getText('turn_on')),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, ExpenseViewModel vm) {
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
              Text(vm.getText('language'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(vm.getText('lang_desc'), style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              
              _buildLanguageOption(context, vm, 'vi', Icons.flag, Colors.red, 'Tiếng Việt (Viet nam)', vm.getText('in_use')),
              const Divider(),
              _buildLanguageOption(context, vm, 'en', Icons.language, Colors.blue, 'Tiếng anh (English)', vm.getText('in_use')),
              const Divider(),
              _buildLanguageOption(context, vm, 'zh', Icons.translate, Colors.redAccent, 'Tiếng Trung (中文)', vm.getText('in_use')),
              const Divider(),
              _buildLanguageOption(context, vm, 'ja', Icons.translate, Colors.pinkAccent, 'Tiếng nhật (日本語)', vm.getText('in_use')),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _buildLanguageOption(BuildContext context, ExpenseViewModel vm, String langCode, IconData icon, Color color, String title, String inUseText) {
    final isSelected = vm.currentLanguage == langCode;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 30),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.teal : null)),
      subtitle: isSelected ? Text(inUseText, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)) : null,
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.teal) : null,
      onTap: () {
        vm.changeLanguage(langCode);
        Navigator.pop(context); 
      },
    );
  }
}