import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOpsKey = 'app.operations';

enum OpKind { transfer, transport, atm, other }

class BankOperation {
  final String title;
  final String subtitle;
  final double amount; // отрицательное — расход, положительное — приход
  final DateTime date;
  final OpKind kind;

  const BankOperation({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    this.kind = OpKind.transfer,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'amount': amount,
        'date': date.millisecondsSinceEpoch,
        'kind': kind.name,
      };

  static BankOperation fromJson(Map<String, dynamic> j) => BankOperation(
        title: j['title'] as String,
        subtitle: j['subtitle'] as String,
        amount: (j['amount'] as num).toDouble(),
        date: DateTime.fromMillisecondsSinceEpoch(j['date'] as int),
        kind: OpKind.values.firstWhere(
          (k) => k.name == (j['kind'] as String? ?? 'transfer'),
          orElse: () => OpKind.transfer,
        ),
      );
}

/// Список операций, новые — впереди.
final ValueNotifier<List<BankOperation>> operationsNotifier =
    ValueNotifier<List<BankOperation>>(<BankOperation>[]);

bool _opsInitialized = false;

Future<void> initOperationsPersistence() async {
  if (_opsInitialized) return;
  _opsInitialized = true;
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kOpsKey);
  if (raw != null && raw.isNotEmpty) {
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => BankOperation.fromJson(e as Map<String, dynamic>))
          .toList();
      operationsNotifier.value = list;
    } catch (_) {
      // ignore corrupted
    }
  }
  operationsNotifier.addListener(_persist);
}

Future<void> _persist() async {
  final prefs = await SharedPreferences.getInstance();
  final encoded =
      jsonEncode(operationsNotifier.value.map((e) => e.toJson()).toList());
  await prefs.setString(_kOpsKey, encoded);
}

void addOperation(BankOperation op) {
  operationsNotifier.value = <BankOperation>[op, ...operationsNotifier.value];
}

void removeOperation(BankOperation op) {
  final list = List<BankOperation>.from(operationsNotifier.value);
  // Удаляем именно этот объект (по identity), чтобы не задеть похожие.
  final idx = list.indexWhere((e) => identical(e, op));
  if (idx == -1) return;
  list.removeAt(idx);
  operationsNotifier.value = list;
}

void clearOperations() {
  operationsNotifier.value = <BankOperation>[];
}
