import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../viewmodels/expense_viewmodel.dart'; 
import '../models/expense.dart';
import 'new_expense.dart';
import 'chart.dart';
import 'package:intl/intl.dart'; 
import '../models/currency_input_formatter.dart'; 

// Giao diện Trang chủ (Home Screen) hiển thị tổng quan thu/chi và biểu đồ thống kê:
// Tích hợp máy tính nhẩm nhanh với thuật toán bóc tách chuỗi thông minh từ văn bản (hỗ trợ đa ngôn ngữ).
// Quản lý danh sách giao dịch nhóm theo tháng, bộ lọc danh mục, thanh tìm kiếm và hiển thị thông báo hệ thống.
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, 
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _budgetController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemAmountController = TextEditingController();
  final _searchController = TextEditingController(); 
  double _remaining = 0;

  double _parseAmount(String text) {
    if (text.isEmpty) return 0;
    final vm = context.read<ExpenseViewModel>();
    if (vm.currentLanguage == 'vi') {
      return double.tryParse(text.replaceAll('.', '')) ?? 0;
    } else {
      return double.tryParse(text.replaceAll(',', '')) ?? 0;
    }
  }

  String _formatAmount(double value) {
    final vm = context.read<ExpenseViewModel>();
    String formatted = NumberFormat('#,##0.##', 'en_US').format(value);
    
    if (vm.currentLanguage == 'vi') {
      formatted = formatted.replaceAll(',', '_').replaceAll('.', ',').replaceAll('_', '.');
    }
    return formatted;
  }

  void _calculate() {
    final total = _parseAmount(_budgetController.text);
    final itemCost = _parseAmount(_itemAmountController.text);
    setState(() {
      _remaining = total - itemCost;
    });
  }

  // Hàm quét thông minh bóc tách số tiền từ chuỗi (Hỗ trợ đơn vị tiền tệ đa quốc gia)
  void _autoCalculateFromNotes(String text) {
    if (!text.contains('(') && !text.contains(')')) {
      if (_itemAmountController.text.isNotEmpty) {
        _itemAmountController.text = '';
        _calculate();
      }
      return;
    }

    final vm = context.read<ExpenseViewModel>();
    final isDecimalAllowed = vm.currentLanguage == 'en' || vm.currentLanguage == 'zh';

    double sum = 0;
    bool hasMatches = false;

    final RegExp regex = RegExp(r'\(\s*[^\d]*([0-9]*[\.,]?[0-9]+)\s*([a-zA-Z万億亿千]*)[^\d]*\)');
    final matches = regex.allMatches(text);

    for (final match in matches) {
      String numberStr = match.group(1)!;
      String rawSuffix = match.group(2)!; 
      String suffixLower = rawSuffix.toLowerCase();
      double? val;

      numberStr = numberStr.replaceAll(',', '.');

      if (isDecimalAllowed) {
        val = double.tryParse(numberStr);
      } else {
        if (rawSuffix.isNotEmpty) {
          val = double.tryParse(numberStr);
        } else {
          val = double.tryParse(numberStr.replaceAll('.', ''));
        }
      }

      if (val != null) {
        if (vm.currentLanguage == 'vi') {
          if (suffixLower == 'k') val *= 1000;
          else if (suffixLower == 'tr' || rawSuffix == 'M') val *= 1000000; 
          else if (rawSuffix == 'T' || rawSuffix == 'B') val *= 1000000000; 
        } 
        else if (vm.currentLanguage == 'en') {
          if (suffixLower == 'k') val *= 1000;
          else if (rawSuffix == 'M') val *= 1000000; 
          else if (rawSuffix == 'B') val *= 1000000000; 
        } 
        else if (vm.currentLanguage == 'zh') {
          if (suffixLower == 'q' || rawSuffix == '千' || suffixLower == 'k') val *= 1000;
          else if (suffixLower == 'w' || rawSuffix == '万') val *= 10000; 
          else if (suffixLower == 'y' || rawSuffix == '亿' || rawSuffix == '億') val *= 100000000; 
          else if (rawSuffix == 'M') val *= 1000000;
          else if (rawSuffix == 'B') val *= 1000000000;
        } 
        else if (vm.currentLanguage == 'ja') {
          if (suffixLower == 's' || rawSuffix == '千' || suffixLower == 'k') val *= 1000;
          else if (suffixLower == 'w' || rawSuffix == '万') val *= 10000; 
          else if (suffixLower == 'y' || rawSuffix == '億') val *= 100000000; 
          else if (rawSuffix == 'M') val *= 1000000;
          else if (rawSuffix == 'B') val *= 1000000000;
        }

        sum += val;
        hasMatches = true;
      }
    }

    if (hasMatches) {
      _itemAmountController.text = _formatAmount(sum);
    } else {
      _itemAmountController.text = ''; 
    }
    _calculate(); 
  }

  void _openAddExpenseOverlay() async {
    final vm = context.read<ExpenseViewModel>();
    if (vm.isOfflineMode) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.getText('offline_blocked'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
          backgroundColor: Colors.redAccent, 
          behavior: SnackBarBehavior.floating
        ),
      );
      return;
    }

    final newExpense = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const NewExpense(),
    );

    if (newExpense != null && mounted) {
      vm.addExpense(newExpense);
      
      final isIncome = newExpense.type == TransactionType.income;
      final timeStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      
      final formattedAmount = vm.formatDynamicCurrency(newExpense.amount);
      final notiMsg = '[$timeStr] ${vm.getText('recorded')}${newExpense.title} (${isIncome ? '+' : '-'}$formattedAmount)';
      
      vm.addNotification(notiMsg);
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating, 
          margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          backgroundColor: isIncome ? Colors.green.shade700 : Colors.redAccent.shade700,
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.shield, color: Colors.white), 
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notiMsg,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showNotificationPanel(ExpenseViewModel viewModel) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(viewModel.getText('system_notification'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              if (viewModel.notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(viewModel.getText('no_noti'), style: const TextStyle(color: Colors.grey)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.notifications.length,
                    itemBuilder: (context, index) {
                      final notiMsg = viewModel.notifications[index];
                      final isIncome = notiMsg.contains('(+');
                      final isExpense = notiMsg.contains('(-');
                      
                      Color avatarColor = Colors.teal;
                      IconData iconData = Icons.info;
                      
                      if (isIncome) {
                        avatarColor = Colors.green;
                        iconData = Icons.arrow_downward;
                      } else if (isExpense) {
                        avatarColor = Colors.redAccent;
                        iconData = Icons.arrow_upward;
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: avatarColor.withValues(alpha: 0.2), 
                          child: Icon(iconData, color: avatarColor)
                        ),
                        title: Text(notiMsg),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _itemNameController.dispose();
    _itemAmountController.dispose();
    _searchController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseViewModel>();
    final registeredExpenses = viewModel.expenses; 
    final currentBalance = viewModel.totalBalance; 
    final isOffline = viewModel.isOfflineMode;

    String suffixCurrency = 'VND';
    if (viewModel.currentLanguage == 'en') suffixCurrency = 'USD';
    else if (viewModel.currentLanguage == 'zh') suffixCurrency = 'CNY';
    else if (viewModel.currentLanguage == 'ja') suffixCurrency = 'JPY';

    String calcPrefix = '';
    if (viewModel.currentLanguage == 'en') calcPrefix = '\$';
    else if (viewModel.currentLanguage == 'zh' || viewModel.currentLanguage == 'ja') calcPrefix = '¥';

    String formattedRemainingCalc = '$calcPrefix${_formatAmount(_remaining)}';

    String rawHint = viewModel.getText('item_name_hint');
    String baseHint = rawHint.split(' (')[0].trim(); 
    
    String smartHintLabel = '';
    switch (viewModel.currentLanguage) {
      case 'en':
        smartHintLabel = '$baseHint e.g. Hamburger (\$1.50),(1k),(1M),(1B)'; 
        break;
      case 'zh':
        smartHintLabel = '$baseHint 例如: 汉堡 (¥25.50),(1q/千),(1w/万),(1y/亿)'; 
        break;
      case 'ja':
        smartHintLabel = '$baseHint 例: 弁当 (¥500),(1s/千),(1w/万),(1y/億)'; 
        break;
      case 'vi':
      default:
        smartHintLabel = '$baseHint VD: Cơm (10k),(1tr/M),(1T/B)'; 
        break;
    }

    final categories = [null, Category.food, Category.work, Category.travel, Category.leisure, Category.receive];
    List<Widget> sliversList = [];

    sliversList.add(
      SliverToBoxAdapter(
        child: Chart(expenses: viewModel.expenses),
      ),
    );

    sliversList.add(
      SliverPersistentHeader(
        pinned: true,
        delegate: _StickyHeaderDelegate(
          minHeight: 340, 
          maxHeight: 340,
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: categories.map((cat) {
                    final isSelected = viewModel.selectedTabCategory == cat;
                    String label = viewModel.getText('all');
                    if (cat != null) {
                      label = viewModel.getText(cat.name);
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) => viewModel.selectTabCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController, 
                  onChanged: (value) => viewModel.runFilter(value),
                  decoration: InputDecoration(
                    hintText: viewModel.getText('search_hint'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              viewModel.getText('quick_calc'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            if (isOffline) 
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                                child: Text(viewModel.getText('offline_mode'), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _budgetController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [CurrencyInputFormatter(languageCode: viewModel.currentLanguage)],
                                onChanged: (_) => _calculate(),
                                decoration: InputDecoration(
                                  labelText: viewModel.getText('calc_amount'),
                                  suffixText: suffixCurrency, 
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _itemAmountController,
                                readOnly: true, 
                                decoration: InputDecoration(
                                  labelText: viewModel.getText('item_amount'), 
                                  suffixText: suffixCurrency,
                                  isDense: true,
                                  filled: true, 
                                  fillColor: Colors.grey.withValues(alpha: 0.15), 
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _itemNameController,
                          onChanged: _autoCalculateFromNotes, 
                          decoration: InputDecoration(
                            labelText: smartHintLabel, 
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                viewModel.getText('remaining_amount'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$formattedRemainingCalc $suffixCurrency', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _remaining >= 0 ? Colors.teal : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (registeredExpenses.isEmpty) {
      sliversList.add(
        SliverFillRemaining(
          child: Center(
            child: Text(
              viewModel.getText('no_transactions'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    } else {
      final sortedExpenses = List<Expense>.from(registeredExpenses)..sort((a, b) => b.date.compareTo(a.date));
      
      Map<String, List<Expense>> groupedExpenses = {};
      for (var exp in sortedExpenses) {
        String key = '${exp.date.month}-${exp.date.year}';
        if (!groupedExpenses.containsKey(key)) {
          groupedExpenses[key] = [];
        }
        groupedExpenses[key]!.add(exp);
      }

      for (var key in groupedExpenses.keys) {
        var expensesInMonth = groupedExpenses[key]!;
        var firstExp = expensesInMonth.first;

        sliversList.add(
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  minHeight: 50,
                  maxHeight: 50,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade600, 
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            '${viewModel.getText('month')} ${firstExp.date.month} - ${viewModel.getText('year')} ${firstExp.date.year}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    final expense = expensesInMonth[index];
                    final isIncome = expense.type == TransactionType.income;
                    final sign = isIncome ? '+' : '-';
                    final amountColor = isIncome ? Colors.green : Colors.redAccent;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: amountColor.withValues(alpha: 0.2),
                          child: Icon(
                            isIncome ? Icons.attach_money : categoryIcons[expense.category], 
                            color: amountColor, 
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(viewModel.getText(expense.category.name)), 
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd/MM/yyyy • HH:mm').format(expense.date),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '$sign${viewModel.formatDynamicCurrency(expense.amount)} $suffixCurrency', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16, 
                            color: amountColor,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: expensesInMonth.length,
                ),
              ),
            ]
          )
        );
      }
    }

    sliversList.add(const SliverToBoxAdapter(child: SizedBox(height: 80)));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              viewModel.getText('total_balance'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            Text(
              '${currentBalance > 0 ? '+' : ''}${viewModel.formatDynamicCurrency(currentBalance)} $suffixCurrency', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: viewModel.unreadNotiCount > 0,
              label: Text(viewModel.unreadNotiCount.toString()), 
              child: const Icon(Icons.notifications),
            ),
            onPressed: () {
              viewModel.markNotificationsAsRead();
              _showNotificationPanel(viewModel);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: sliversList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseOverlay,
        backgroundColor: isOffline ? Colors.grey : null,
        child: const Icon(Icons.add),
      ),
    );
  }
}