import 'package:intl/intl.dart';

String formatCurrency(num value, {String suffix = ' VND'}) {
  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );
  final formatted = formatter.format(value).trim();
  // Đổi dấu phẩy thành dấu chấm để hiển thị kiểu 10.000
  return '${formatted.replaceAll(',', '.')} $suffix';
}
