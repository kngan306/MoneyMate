import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Chuyển đổi giá trị mới thành số
    final int value = int.tryParse(newValue.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;

    // Định dạng số với dấu phẩy ngăn cách
    final String newText = NumberFormat('#,###', 'vi_VN').format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}