import 'package:flutter/material.dart';

import '../state/balance.dart';
import '../theme.dart';
import 'recipients_screen.dart';
import 'select_bank_screen.dart';

class SbpSuccessScreen extends StatefulWidget {
  final BankInfo bank;
  final Contact contact;
  final double amount;
  final String? customName;

  const SbpSuccessScreen({
    super.key,
    required this.bank,
    required this.contact,
    required this.amount,
    this.customName,
  });

  @override
  State<SbpSuccessScreen> createState() => _SbpSuccessScreenState();
}

class _SbpSuccessScreenState extends State<SbpSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _recipientFullName {
    if (widget.customName != null && widget.customName!.isNotEmpty) {
      return widget.customName!;
    }
    return '';
  }

  void _close() {
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final tint = _bankTint(widget.bank.kind);
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          // Фон проявляется вместе с надрывом: от еле заметного к яркому.
          final t = Curves.easeOutCubic.transform(_ctrl.value);
          final opacity = 0.25 + 0.7 * t;
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.45),
                radius: 1.1,
                colors: [
                  tint.withOpacity(opacity),
                  const Color(0xFF0A1622),
                  Colors.black,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _appBar(),
              const Spacer(),
              _Receipt(
                ctrl: _ctrl,
                bankKind: widget.bank.kind,
                bankName: widget.bank.name,
                amount: widget.amount,
                recipientName: _recipientFullName,
                phone: widget.contact.phone,
              ),
              const SizedBox(height: 28),
              const _ActionsRow(),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: _close,
                    child: const Text(
                      'Готово',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _bankTint(BankKind k) {
    switch (k) {
      case BankKind.sber:
        return const Color(0xFF1FB36A);
      case BankKind.tbank:
        return const Color(0xFFE0B400);
      case BankKind.ozon:
        return const Color(0xFF2D6BFF);
      case BankKind.alfa:
        return const Color(0xFFE0382F);
      case BankKind.other:
        return const Color(0xFF4B6EC9);
    }
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          // SBP logo: real PNG with gradient-circle fallback
          SizedBox(
            width: 28,
            height: 28,
            child: Image.asset(
              'assets/sbp/sbp.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4285F4),
                      Color(0xFF34A853),
                      Color(0xFFFBBC05),
                      Color(0xFFEA4335),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 28),
                child: Text(
                  'Система быстрых платежей',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _close,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== Receipt with tear animation =====================
class _Receipt extends StatelessWidget {
  final AnimationController ctrl;
  final BankKind bankKind;
  final String bankName;
  final double amount;
  final String recipientName;
  final String phone;

  const _Receipt({
    required this.ctrl,
    required this.bankKind,
    required this.bankName,
    required this.amount,
    required this.recipientName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    // 0.0–0.25 — весь чек появляется как одно целое (без разрыва)
    final entry = CurvedAnimation(
      parent: ctrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    // 0.25–1.0 — надрыв: зазор растёт, низ отваливается с боку с лёгким
    // отскоком (easeOutBack даёт ощущение, что бумага "хрустит").
    final tear = CurvedAnimation(
      parent: ctrl,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final opacity = entry.value;
        final scale = 0.94 + 0.06 * entry.value;
        final t = tear.value.clamp(0.0, 1.0);
        final gapH = t * 10;
        final tilt = t * 0.015;
        final dropY = t * 4.0;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Transform.translate(
                    offset: Offset(0, -dropY),
                    child: Transform.rotate(
                      angle: -tilt,
                      alignment: Alignment.bottomLeft,
                      child: _topHalf(),
                    ),
                  ),
                  SizedBox(height: gapH),
                  _bottomHalf(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topHalf() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 28),
          decoration: const BoxDecoration(
            color: Color(0xFF1B2129),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 42, 16, 16),
                child: Column(
                  children: [
                    const Text(
                      'Успешно',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '− ${formatRubSmart(amount)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: _DashedLine(),
              ),
            ],
          ),
        ),
        // Floating bank logo with green check, half above the card.
        Stack(
          clipBehavior: Clip.none,
          children: [
            BankLogo(kind: bankKind, size: 56),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF21BA72),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF1B2129), width: 2),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bottomHalf() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1B2129),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: _DashedLine(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              children: [
                Text(
                  bankName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                if (recipientName.isNotEmpty) ...[
                  Text(
                    recipientName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  phone,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter()),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 5.0;
    const gap = 5.0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final cy = size.height / 2;
    double x = 0;
    while (x < size.width) {
      final end = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, cy), Offset(end, cy), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
// ===================== Action row =====================
class _ActionsRow extends StatelessWidget {
  const _ActionsRow();

  static const _items = [
    _Action(Icons.refresh_rounded, 'Повторить'),
    _Action(Icons.description_rounded, 'Документы'),
    _Action(Icons.star_rounded, 'Шаблон'),
    _Action(Icons.autorenew_rounded, 'Автоплатёж'),
    _Action(Icons.help_outline_rounded, 'Помощь'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: _items
            .map<Widget>((a) => Expanded(child: _ActionTile(a: a)))
            .toList(),
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  const _Action(this.icon, this.label);
}

class _ActionTile extends StatelessWidget {
  final _Action a;
  const _ActionTile({required this.a});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF152634),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(a.icon, color: AppColors.accentBlue, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          a.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }
}
