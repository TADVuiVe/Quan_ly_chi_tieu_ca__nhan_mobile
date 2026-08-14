import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:intl/intl.dart'; 
import '../viewmodels/expense_viewmodel.dart';
import '../models/currency_input_formatter.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _amountController = TextEditingController();
  String _fromCurrency = 'VND';
  String _toCurrency = 'USD';
  double _convertedResult = 0;
  
  // Biến dùng để theo dõi sự thay đổi ngôn ngữ
  String _lastLanguage = ''; 

  final Map<String, String> currencySymbols = {
    'VND': '₫', 'USD': '\$', 'CNY': '¥', 'JPY': '¥'
  };

  double _parseAmount(String text, String currentLanguage) {
    if (text.isEmpty) return 0;
    
    if (currentLanguage == 'vi') {
      String normalized = text.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0;
    } else {
      return double.tryParse(text.replaceAll(',', '')) ?? 0;
    }
  }

  String _formatConvertedAmount(double value, String targetCurrency) {
    if (targetCurrency == 'VND') {
      String formatted = NumberFormat('#,##0.##', 'en_US').format(value);
      return formatted.replaceAll(',', '_').replaceAll('.', ',').replaceAll('_', '.');
    } else if (targetCurrency == 'JPY') {
      return NumberFormat('#,##0', 'en_US').format(value);
    } else {
      return NumberFormat('#,##0.00', 'en_US').format(value);
    }
  }

  void _convertCurrency(ExpenseViewModel viewModel) {
    final amount = _parseAmount(_amountController.text, viewModel.currentLanguage);
    final rates = viewModel.exchangeRates;
    
    if (rates.containsKey(_fromCurrency) && rates.containsKey(_toCurrency)) {
      final rateFrom = rates[_fromCurrency]!;
      final rateTo = rates[_toCurrency]!;
      setState(() {
        _convertedResult = (amount / rateFrom) * rateTo;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseViewModel>();

    // =======================================================================
    // TỰ ĐỘNG ĐỒNG BỘ CẶP TIỀN TỆ THEO NGÔN NGỮ
    // =======================================================================
    if (_lastLanguage != viewModel.currentLanguage) {
      _lastLanguage = viewModel.currentLanguage;
      
      if (_lastLanguage == 'vi') {
        _fromCurrency = 'VND';
        _toCurrency = 'USD';
      } else if (_lastLanguage == 'en') {
        _fromCurrency = 'USD';
        _toCurrency = 'VND';
      } else if (_lastLanguage == 'zh') {
        _fromCurrency = 'CNY';
        _toCurrency = 'VND';
      } else if (_lastLanguage == 'ja') {
        _fromCurrency = 'JPY';
        _toCurrency = 'VND';
      }

      // Ép hệ thống tính toán lại ngay khi vừa đổi ngôn ngữ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _convertCurrency(viewModel);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.getText('stats_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(viewModel.getText('currency_convert'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [CurrencyInputFormatter(languageCode: viewModel.currentLanguage)],
                            onChanged: (_) => _convertCurrency(viewModel),
                            decoration: InputDecoration(
                              labelText: viewModel.getText('amount'),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _fromCurrency,
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                            items: currencySymbols.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              setState(() => _fromCurrency = val!);
                              _convertCurrency(viewModel);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // =======================================================================
                    // NÚT ĐẢO CHIỀU (HOẠT ĐỘNG 100%)
                    // =======================================================================
                    IconButton(
                      icon: const Icon(Icons.swap_vert, color: Colors.teal, size: 28),
                      onPressed: () {
                        setState(() {
                          final temp = _fromCurrency;
                          _fromCurrency = _toCurrency;
                          _toCurrency = temp;
                        });
                        _convertCurrency(viewModel);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${currencySymbols[_toCurrency]} ${_formatConvertedAmount(_convertedResult, _toCurrency)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _toCurrency,
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                            items: currencySymbols.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              setState(() => _toCurrency = val!);
                              _convertCurrency(viewModel);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(viewModel.getText('market_today'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMarketCard('Bitcoin (BTC)', '\$${NumberFormat('#,##0.##', 'en_US').format(viewModel.btcPrice)}', viewModel.btcStatus, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildMarketCard(viewModel.getText('gold_tael'), '${(viewModel.goldPricePerTael / 10000000).toStringAsFixed(2)} Tr', viewModel.goldStatus, Colors.amber)),
              ],
            ),
            const SizedBox(height: 8),
            _buildMarketCard(viewModel.getText('gold_sjc'), '${(viewModel.goldPricePerTael / 1000000).toStringAsFixed(2)} Triệu VND', viewModel.goldStatus, Colors.amber),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios, size: 16), onPressed: () => viewModel.changeYear(-1)),
                Text('${viewModel.getText('yearly_chart')} ${viewModel.selectedYear}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, size: 16, color: viewModel.selectedYear < DateTime.now().year ? null : Colors.transparent),
                  onPressed: viewModel.selectedYear < DateTime.now().year ? () => viewModel.changeYear(1) : null, 
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.blueGrey.shade900.withValues(alpha: 0.9),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            viewModel.formatDynamicCurrency(spot.y), 
                            TextStyle(color: spot.barIndex == 0 ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('T${value.toInt() + 1}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: viewModel.yearlyChartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['income']!)).toList(),
                      isCurved: true, color: Colors.green, barWidth: 3, dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: viewModel.yearlyChartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['expense']!)).toList(),
                      isCurved: true, color: Colors.redAccent, barWidth: 3, dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Row(children: [const Icon(Icons.circle, size: 10, color: Colors.green), const SizedBox(width: 4), Text(viewModel.getText('total_income'), style: const TextStyle(color: Colors.grey))]),
                    Text(viewModel.formatDynamicCurrency(viewModel.yearlyTotalIncome), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                  ],
                ),
                Column(
                  children: [
                    Row(children: [const Icon(Icons.circle, size: 10, color: Colors.redAccent), const SizedBox(width: 4), Text(viewModel.getText('total_expense'), style: const TextStyle(color: Colors.grey))]),
                    Text(viewModel.formatDynamicCurrency(viewModel.yearlyTotalExpense), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            Text(viewModel.getText('activity_this_month'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(viewModel.getText('spent_this_month'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  Text(viewModel.formatDynamicCurrency(viewModel.currentMonthExpense), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(viewModel.getText('earned_this_month'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  Text(viewModel.formatDynamicCurrency(viewModel.currentMonthIncome), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketCard(String title, String price, int status, Color iconColor) {
    IconData statusIcon = Icons.remove;
    Color statusColor = Colors.grey;
    if (status == 1) { statusIcon = Icons.trending_up; statusColor = Colors.green; }
    else if (status == -1) { statusIcon = Icons.trending_down; statusColor = Colors.red; }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: iconColor)),
                Icon(statusIcon, color: statusColor, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}