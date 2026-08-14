import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final String languageCode;

  CurrencyInputFormatter({this.languageCode = 'vi'});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    bool allowDecimals = languageCode == 'en' || languageCode == 'zh';
    bool isVi = languageCode == 'vi';

    String cleanText = newValue.text.replaceAll(RegExp(allowDecimals ? r'[^0-9.]' : r'[^0-9]'), '');

    if (allowDecimals && cleanText.split('.').length > 2) {
      cleanText = cleanText.substring(0, cleanText.lastIndexOf('.'));
    }
    
    if (cleanText.startsWith('.')) {
      cleanText = '0$cleanText';
    }

    List<String> parts = cleanText.split('.');
    String wholeNumber = parts.isNotEmpty ? parts[0] : '';
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (decimalPart.length > 3) {
      decimalPart = decimalPart.substring(0, 3);
    }

    if (wholeNumber.isNotEmpty) {
      try {
        int value = int.parse(wholeNumber);
        
        // Mặc định tạo format quốc tế (dấu phẩy)
        wholeNumber = NumberFormat('#,###', 'en_US').format(value);
        
        // NẾU LÀ TIẾNG VIỆT -> Hoán đổi toàn bộ phẩy thành chấm
        if (isVi) {
          wholeNumber = wholeNumber.replaceAll(',', '.');
        }
      } catch (e) {
        // Ignored
      }
    }

    String formattedText = '$wholeNumber$decimalPart';

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}