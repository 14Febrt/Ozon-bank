import 'package:flutter/material.dart';

import '../state/balance.dart';
import '../theme.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  Future<void> _showTopUpDialog(BuildContext context) async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Пополнение',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Сумма, ₽',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.cardChip)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.accentBlue)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final raw = controller.text.replaceAll(',', '.').trim();
              final v = double.tryParse(raw);
              Navigator.pop(ctx, v);
            },
            child: const Text('Пополнить',
                style: TextStyle(color: AppColors.accentBlue)),
          ),
        ],
      ),
    );
    if (amount != null && amount > 0) topUp(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Основной счёт',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => _showTopUpDialog(context),
            child: ValueListenableBuilder<double>(
              valueListenable: balanceNotifier,
              builder: (_, value, __) => Text(
                formatRub(value),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Mini cards row
          SizedBox(
            height: 44,
            child: Row(
              children: const [
                _MiniCard(
                  last4: '3814',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0AB36B), Color(0xFF064E2F)],
                  ),
                ),
                SizedBox(width: 8),
                _MiniCard(
                  last4: '7129',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E88FF), Color(0xFF0E47A1)],
                  ),
                ),
                SizedBox(width: 8),
                _MiniCard(
                  last4: '5949',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D6BFF), Color(0xFF0E47A1)],
                  ),
                ),
                SizedBox(width: 8),
                _AddCard(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Оплата QR',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Пополнить',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionTile(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Перевести',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String last4;
  final Gradient gradient;
  const _MiniCard({required this.last4, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            last4,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'МИР',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.cardChip,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.add_rounded,
          color: AppColors.textPrimary, size: 22),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: AppColors.accentBlue, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.accentBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
