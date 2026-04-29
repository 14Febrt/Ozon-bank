import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/balance.dart';
import '../theme.dart';
import 'recipients_screen.dart';
import 'sbp_success_screen.dart';

enum BankKind { ozon, tbank, sber, alfa, other }

class BankInfo {
  final BankKind kind;
  final String name;
  const BankInfo(this.kind, this.name);
}

class _TransferInput {
  final double amount;
  final String? name;
  const _TransferInput({required this.amount, this.name});
}

class SelectBankScreen extends StatelessWidget {
  final Contact contact;
  const SelectBankScreen({super.key, required this.contact});

  static const _banks = <BankInfo>[
    BankInfo(BankKind.tbank, 'Т-Банк'),
    BankInfo(BankKind.sber, 'Сбербанк'),
    BankInfo(BankKind.alfa, 'Альфа-Банк'),
    BankInfo(BankKind.other, 'Другой банк'),
  ];

  String get _recipientFullName {
    final parts = contact.name.split(' ');
    if (parts.isNotEmpty) {
      return '${parts.first} ${parts.length > 1 ? "${parts[1][0]}." : ""}';
    }
    return contact.name;
  }

  Future<void> _pickBank(BuildContext context, BankInfo bank) async {
    final result = await _askAmount(context);
    if (result == null || result.amount <= 0) return;
    if (!context.mounted) return;
    withdraw(result.amount);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SbpSuccessScreen(
          bank: bank,
          contact: contact,
          amount: result.amount,
          customName: result.name,
        ),
      ),
    );
  }

  Future<_TransferInput?> _askAmount(BuildContext context) async {
    final amountCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    return showModalBottomSheet<_TransferInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardChip,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Сумма перевода',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  hintText: '0 ₽',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 6),
              Container(height: 0.5, color: AppColors.cardChip),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Имя или сообщение получателю (необязательно)',
                  hintStyle: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.cardSoft,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    final raw =
                        amountCtrl.text.replaceAll(',', '.').trim();
                    final v = double.tryParse(raw);
                    if (v == null) return;
                    Navigator.pop(
                      ctx,
                      _TransferInput(
                        amount: v,
                        name: nameCtrl.text.trim().isEmpty
                            ? null
                            : nameCtrl.text.trim(),
                      ),
                    );
                  },
                  child: const Text(
                    'Перевести',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _appBar(context),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _RecipientField(contact: contact),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _LimitCard(),
              ),
              const SizedBox(height: 16),
              const _OzonNotInBank(),
              const SizedBox(height: 8),
              ..._banks.map(
                (b) => _BankRow(
                  bank: b,
                  recipientName: _recipientFullName,
                  onTap: () => _pickBank(context, b),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 40),
                child: Text(
                  'Кому перевести',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientField extends StatelessWidget {
  final Contact contact;
  const _RecipientField({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D3540), width: 0.6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 12),
                ),
                Text(
                  contact.phone,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const _RuFlag(),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }
}

class _RuFlag extends StatelessWidget {
  const _RuFlag();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 0.5),
          shape: BoxShape.circle,
        ),
        child: Column(
          children: const [
            Expanded(child: ColoredBox(color: Colors.white)),
            Expanded(child: ColoredBox(color: Color(0xFF0039A6))),
            Expanded(child: ColoredBox(color: Color(0xFFD52B1E))),
          ],
        ),
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
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
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'В этом месяце можно перевести ещё\n579 766,61 ₽ без комиссии',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OzonNotInBank extends StatelessWidget {
  const _OzonNotInBank();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          BankLogo(kind: BankKind.ozon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ozon Банка у получателя нет',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D6BFF), Color(0xFF7E5BFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🎁', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Text(
                        '800 ₽ за рекомендацию',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _BankRow extends StatelessWidget {
  final BankInfo bank;
  final String recipientName;
  final VoidCallback onTap;
  const _BankRow({
    required this.bank,
    required this.recipientName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            BankLogo(kind: bank.kind),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (bank.kind != BankKind.other) ...[
                    const SizedBox(height: 2),
                    Text(
                      recipientName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BankLogo extends StatelessWidget {
  final BankKind kind;
  final double size;
  const BankLogo({super.key, required this.kind, this.size = 40});

  static const _logoUrls = {
    BankKind.sber: 'https://logo.clearbit.com/sberbank.ru',
    BankKind.tbank: 'https://logo.clearbit.com/tbank.ru',
    BankKind.ozon: 'https://logo.clearbit.com/ozonbank.ru',
    BankKind.alfa: 'https://logo.clearbit.com/alfabank.ru',
  };

  static const _assetPaths = {
    BankKind.sber: 'assets/banks/sber.png',
    BankKind.tbank: 'assets/banks/tbank.png',
    BankKind.ozon: 'assets/banks/ozon.png',
    BankKind.alfa: 'assets/banks/alfa.png',
  };

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.25;
    final bg = _bg(kind);
    final asset = _assetPaths[kind];
    final url = _logoUrls[kind];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: asset != null
          ? Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => url != null
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(),
                      loadingBuilder: (_, child, p) =>
                          p == null ? child : _fallback(),
                    )
                  : _fallback(),
            )
          : _fallback(),
    );
  }

  Color _bg(BankKind k) {
    switch (k) {
      case BankKind.sber:
        return const Color(0xFF21BA72);
      case BankKind.tbank:
        return const Color(0xFFFFDD2D);
      case BankKind.ozon:
        return AppColors.ozonBlue;
      case BankKind.alfa:
        return const Color(0xFFEF3124);
      case BankKind.other:
        return AppColors.cardChip;
    }
  }

  Widget _fallback() {
    switch (kind) {
      case BankKind.ozon:
        return const Center(
          child: Text('o',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              )),
        );
      case BankKind.tbank:
        return const Center(
          child: Text('Т',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              )),
        );
      case BankKind.sber:
        return const Center(
          child: Icon(Icons.check_rounded, color: Colors.white, size: 22),
        );
      case BankKind.alfa:
        return const Center(
          child: Text('А',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              )),
        );
      case BankKind.other:
        return const Center(
          child: Icon(Icons.account_balance_rounded,
              color: AppColors.accentBlue, size: 22),
        );
    }
  }
}
