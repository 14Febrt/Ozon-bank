import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/balance.dart';
import '../state/operations.dart';
import '../theme.dart';

class OperationsSection extends StatelessWidget {
  const OperationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Последние операции',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF15324F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Text('Все',
                      style: TextStyle(
                          color: AppColors.accentBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.accentBlue, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<BankOperation>>(
          valueListenable: operationsNotifier,
          builder: (_, ops, __) {
            if (ops.isEmpty) {
              return const _EmptyDemo();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildGroups(ops),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildGroups(List<BankOperation> ops) {
    final out = <Widget>[];
    String? lastLabel;
    for (final op in ops) {
      final label = _dayLabel(op.date);
      if (label != lastLabel) {
        if (out.isNotEmpty) out.add(const SizedBox(height: 8));
        out.add(Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ));
        out.add(const SizedBox(height: 8));
        lastLabel = label;
      }
      out.add(_OperationRow.fromOp(op));
    }
    return out;
  }

  static String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    const months = [
      'января','февраля','марта','апреля','мая','июня',
      'июля','августа','сентября','октября','ноября','декабря',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class _EmptyDemo extends StatelessWidget {
  const _EmptyDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Вчера',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        _OperationRow(
          iconBg: Color(0xFFF5D135),
          icon: Icons.account_balance_wallet_rounded,
          iconColor: Colors.black,
          title: 'Иван Васильевич К.',
          subtitle: 'Переводы',
          amount: '−250 ₽',
        ),
        _OperationRow(
          iconBg: Color(0xFF7A1F1F),
          icon: Icons.directions_bus_rounded,
          iconColor: Colors.white,
          title: 'Транспорт Ростова-на-Дону',
          subtitle: 'Транспорт',
          amount: '−55 ₽',
        ),
      ],
    );
  }
}

class _OperationRow extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;

  final BankOperation? op;
  final Color amountColor;

  const _OperationRow({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.op,
    this.amountColor = AppColors.textPrimary,
  });

  factory _OperationRow.fromOp(BankOperation op) {
    Color bg;
    IconData ic;
    Color icColor;
    switch (op.kind) {
      case OpKind.transport:
        bg = const Color(0xFF7A1F1F);
        ic = Icons.directions_bus_rounded;
        icColor = Colors.white;
        break;
      case OpKind.atm:
        bg = const Color(0xFF21BA72);
        ic = Icons.credit_card_rounded;
        icColor = Colors.white;
        break;
      case OpKind.transfer:
      case OpKind.other:
        bg = const Color(0xFFF5D135);
        ic = Icons.account_balance_wallet_rounded;
        icColor = Colors.black;
        break;
    }
    final positive = op.amount >= 0;
    final sign = positive ? '+' : '−';
    final abs = op.amount.abs();
    return _OperationRow(
      iconBg: bg,
      icon: ic,
      iconColor: icColor,
      title: op.title,
      subtitle: op.subtitle,
      amount: '$sign${formatRubSmart(abs)}',
      op: op,
      amountColor:
          positive ? const Color(0xFF21BA72) : AppColors.textPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
    final target = op;
    if (target == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        removeOperation(target);
      },
      child: row,
    );
  }
}
