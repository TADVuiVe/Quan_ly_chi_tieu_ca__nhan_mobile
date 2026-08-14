import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Tự động định dạng số tiền khi nhập liệu theo thời gian thực:
// Thêm phân cách hàng nghìn (VD: 1.000.000 hoặc 1,000,000).
// Thay đổi luật nhập liệu theo ngôn ngữ: Tiếng Việt (chỉ nhập số nguyên, phân cách bằng dấu chấm), Tiếng Anh/Trung (cho phép 2 số thập phân, phân cách bằng dấu phẩy).
// Chặn ký tự lạ và ngăn người dùng gõ sai cú pháp thập phân.
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
        
        wholeNumber = NumberFormat('#,###', 'en_US').format(value);
        
        if (isVi) {
          wholeNumber = wholeNumber.replaceAll(',', '.');
        }
      } catch (e) {
      }
    }

    String formattedText = '$wholeNumber$decimalPart';

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}