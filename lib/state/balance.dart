import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBalanceKey = 'app.balance';

/// Глобальный баланс. Меняется через [topUp] (скрытое пополнение).
final ValueNotifier<double> balanceNotifier = ValueNotifier<double>(7.04);

bool _persistInitialized = false;

Future<void> initBalancePersistence() async {
  if (_persistInitialized) return;
  _persistInitialized = true;
  final prefs = await SharedPreferences.getInstance();
  final v = prefs.getDouble(_kBalanceKey);
  if (v != null) balanceNotifier.value = v;
  balanceNotifier.addListener(() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kBalanceKey, balanceNotifier.value);
  });
}

void topUp(double amount) {
  if (amount <= 0) return;
  balanceNotifier.value =
      double.parse((balanceNotifier.value + amount).toStringAsFixed(2));
}

void withdraw(double amount) {
  if (amount <= 0) return;
  balanceNotifier.value =
      double.parse((balanceNotifier.value - amount).toStringAsFixed(2));
}

String formatRubSmart(double v) {
  if (v == v.roundToDouble()) {
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₽';
  }
  return formatRub(v);
}

String formatRub(double v) {
  final fixed = v.toStringAsFixed(2).replaceAll('.', ',');
  // разделители тысяч обычным пробелом
  final parts = fixed.split(',');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(' ');
    buf.write(intPart[i]);
  }
  return '${buf.toString()},${parts[1]} ₽';
}
