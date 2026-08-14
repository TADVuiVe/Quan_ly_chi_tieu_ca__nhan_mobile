import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/currency_input_formatter.dart'; 

class NewExpense extends StatefulWidget {
  const NewExpense({super.key});

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  Category _selectedCategory = Category.food; 
  TransactionType _selectedType = TransactionType.expense; 

  void _submitExpenseData() {
    final vm = context.read<ExpenseViewModel>();
    
    // FIX TẠI ĐÂY: Loại bỏ replaceAll('.', '') để giữ lại dấu chấm thập phân
    final rawAmount = _amountController.text.replaceAll(',', '');
    final enteredAmount = double.tryParse(rawAmount);
    
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty || amountIsInvalid) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(vm.getText('invalid_data')),
          content: Text(vm.getText('invalid_data_msg')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(vm.getText('close')),
            ),
          ],
        ),
      );
      return;
    }

    final finalCategory = _selectedType == TransactionType.income ? Category.receive : _selectedCategory;

    // DỊCH NGƯỢC TIỀN NGOẠI TỆ VỀ VND TRƯỚC KHI LƯU VÀO CSDL
    final amountToSave = vm.convertToBaseCurrency(enteredAmount);

    Navigator.pop(
      context,
      Expense(
        title: _titleController.text,
        amount: amountToSave, 
        date: DateTime.now(), 
        category: finalCategory,
        type: _selectedType, 
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseViewModel>();
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final isExpense = _selectedType == TransactionType.expense;

    final dropdownCategories = isExpense 
        ? [Category.food, Category.work, Category.travel, Category.leisure]
        : [Category.receive];

    if (isExpense && !_selectedType.toString().contains('receive') && !dropdownCategories.contains(_selectedCategory)) {
      _selectedCategory = Category.food;
    }

    // ĐÃ TRẢ LẠI ĐUÔI TIỀN TỆ ĐỘNG CHO NGƯỜI DÙNG QUỐC TẾ
    String suffixCurrency = 'VND';
    if (vm.currentLanguage == 'en') suffixCurrency = 'USD';
    else if (vm.currentLanguage == 'zh') suffixCurrency = 'CNY';
    else if (vm.currentLanguage == 'ja') suffixCurrency = 'JPY';

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 48, 16, keyboardSpace + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(vm.getText('expense_tab')), 
                  icon: const Icon(Icons.arrow_upward, color: Colors.redAccent),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(vm.getText('income_tab')),
                  icon: const Icon(Icons.arrow_downward, color: Colors.green),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                  if (_selectedType == TransactionType.income) {
                    _selectedCategory = Category.receive;
                  } else {
                    _selectedCategory = Category.food;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _titleController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50), 
              ],
              decoration: InputDecoration(
                label: Text(isExpense ? vm.getText('reason_expense') : vm.getText('reason_income')),
              ),
            ),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    // Truyền ngôn ngữ vào Formatter để nó biết lúc nào được phép gõ số thập phân
                    inputFormatters: [CurrencyInputFormatter(languageCode: vm.currentLanguage)], 
                    decoration: InputDecoration(
                      suffixText: suffixCurrency, // ĐUÔI TIỀN TỆ LINH HOẠT THEO NGÔN NGỮ
                      label: Text(isExpense ? vm.getText('amount_expense') : vm.getText('amount_income')),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                DropdownButton<Category>(
                  value: _selectedCategory,
                  items: dropdownCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(vm.getText(category.name)), 
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(vm.getText('cancel')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitExpenseData,
                  child: Text(vm.getText('save_transaction')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}