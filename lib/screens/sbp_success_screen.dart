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
    final parts = widget.contact.name.split(' ');
    if (parts.length > 1) return '${parts[0]} ${parts[1][0]}.';
    return widget.contact.name;
  }

  void _close() {
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final tint = _bankTint(widget.bank.kind);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: [
              tint.withOpacity(0.55),
              const Color(0xFF071119),
              Colors.black,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
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
        return const Color(0xFF1A6B47);
      case BankKind.tbank:
        return const Color(0xFF8A6E00);
      case BankKind.ozon:
        return const Color(0xFF1A3F8E);
      case BankKind.alfa:
        return const Color(0xFF7A1E18);
      case BankKind.other:
        return const Color(0xFF1F3556);
    }
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          // SBP logo (gradient circle)
          Container(
            width: 28,
            height: 28,
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
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 28),
                child: Text(
                  'Система быстрых платежей',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
        final gapH = 2 + t * 18; // 2 → 20 px (растёт зазор)
        // Низ "отрывается" — наклоняется и сползает вниз.
        // Ось по левому краю → правый бок отходит сильнее.
        final tilt = t * 0.025;
        final dropY = t * 6.0;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  _topHalf(),
                  _perforation(gapH),
                  Transform.translate(
                    offset: Offset(0, dropY),
                    child: Transform.rotate(
                      angle: tilt,
                      alignment: Alignment.centerLeft,
                      child: _bottomHalf(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topHalf() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF1B2129),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              BankLogo(kind: bankKind, size: 64),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 22,
                  height: 22,
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
          const SizedBox(height: 18),
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
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomHalf() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1B2129),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardChip,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              bankName,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            recipientName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            phone,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _perforation(double height) {
    return Container(
      height: height,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // notches on sides (overlap card edges)
          Positioned(
            left: -11,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF071119),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            right: -11,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF071119),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // dashed line band (drawn as full ribbon dark, with dashes painted)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1B2129),
              child: const _DashedLine(),
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
    return LayoutBuilder(
      builder: (_, c) {
        const dash = 4.0;
        const gap = 4.0;
        final count = (c.maxWidth / (dash + gap)).floor();
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                count,
                (_) => Container(
                  width: dash,
                  height: 1.2,
                  color: AppColors.textTertiary.withOpacity(0.6),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _items.map((a) => _ActionTile(a: a)).toList(),
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
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(a.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            a.label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
