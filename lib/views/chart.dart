import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense.dart'; 

class Chart extends StatelessWidget {
  const Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  void _showDaySummary(BuildContext context, DateTime date, double income, double expense) {
    final vm = context.read<ExpenseViewModel>();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${vm.getText('stats_day')} ${date.day}/${date.month}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${vm.getText('total_income')}:', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(vm.formatDynamicCurrency(income), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${vm.getText('total_expense')}:', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(vm.formatDynamicCurrency(expense), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(vm.getText('remaining_amount'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  vm.formatDynamicCurrency(income - expense), 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: (income - expense) >= 0 ? Colors.teal : Colors.red,
                  )
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(vm.getText('cancel'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseViewModel>();
    final today = DateTime.now();
    final List<Map<String, dynamic>> last5DaysData = List.generate(5, (index) {
      final targetDate = today.subtract(Duration(days: 4 - index)); 
      double income = 0;
      double expense = 0;
      
      for (final exp in expenses) {
        if (exp.date.year == targetDate.year && exp.date.month == targetDate.month && exp.date.day == targetDate.day) {
          if (exp.type == TransactionType.income) {
            income += exp.amount;
          } else {
            expense += exp.amount;
          }
        }
      }
      return {'date': targetDate, 'income': income, 'expense': expense};
    });

    double maxAmount = 0;
    for (final data in last5DaysData) {
      if ((data['income'] as double) > maxAmount) maxAmount = data['income'] as double;
      if ((data['expense'] as double) > maxAmount) maxAmount = data['expense'] as double;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      width: double.infinity,
      height: 220, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5), Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, color: Colors.green, margin: const EdgeInsets.only(right: 6)),
              Text(vm.getText('income_tab'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 24),
              Container(width: 12, height: 12, color: Colors.redAccent, margin: const EdgeInsets.only(right: 6)),
              Text(vm.getText('expense_tab'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: last5DaysData.map((data) {
                final targetDate = data['date'] as DateTime;
                final income = data['income'] as double;
                final expense = data['expense'] as double;
                
                return Expanded(
                  child: GestureDetector(
                    onLongPress: () => _showDaySummary(context, targetDate, income, expense),
                    child: InkWell(
                      onLongPress: () => _showDaySummary(context, targetDate, income, expense),
                      splashColor: Colors.teal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildBar(income, maxAmount, Colors.green),
                                _buildBar(expense, maxAmount, Colors.redAccent),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${targetDate.day}/${targetDate.month}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double amount, double maxAmount, Color color) {
    final factor = maxAmount == 0 ? 0.0 : (amount / maxAmount);
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: factor,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2), 
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          ),
        ),
      ),
    );
  }
}