import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/balance.dart';
import '../state/operations.dart';
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

class PhoneTransferScreen extends StatefulWidget {
  final BankInfo bank;
  final Contact contact;
  const PhoneTransferScreen({
    super.key,
    required this.bank,
    required this.contact,
  });

  @override
  State<PhoneTransferScreen> createState() => _PhoneTransferScreenState();
}

class _PhoneTransferScreenState extends State<PhoneTransferScreen> {
  final _amountCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Если контакт из списка — подставляем его имя в поле "сообщение".
    // Виртуальный контакт ручного ввода телефона имеет имя 'Новый получатель' — его не подставляем.
    final name = widget.contact.name.trim();
    if (name.isNotEmpty && name != 'Новый получатель') {
      _msgCtrl.text = name;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _amountCtrl.text.replaceAll(',', '.').trim();
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return;
    final msg = _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim();
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ConfirmTransferScreen(
          bank: widget.bank,
          contact: widget.contact,
          amount: v,
          message: msg,
        ),
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    Navigator.pop(context, _TransferInput(amount: v, name: msg));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _appBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionLabel('СЧЁТ СПИСАНИЯ'),
                      const SizedBox(height: 8),
                      _accountCard(),
                      const SizedBox(height: 18),
                      const _SectionLabel('ПОЛУЧАТЕЛЬ'),
                      const SizedBox(height: 8),
                      _recipientCard(),
                      const SizedBox(height: 12),
                      _amountField(),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(14, 4, 14, 0),
                        child: Text(
                          'Без комиссии',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _messageField(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 12,
                ),
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
                    onPressed: _submit,
                    child: const Text(
                      'Продолжить',
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

  Widget _appBar() {
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
                  'По номеру телефона',
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

  Widget _accountCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Основной счёт',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder<double>(
            valueListenable: balanceNotifier,
            builder: (_, value, __) => Text(
              formatRubSmart(value),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recipientCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          BankLogo(kind: widget.bank.kind, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.contact.phone,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 22),
        ],
      ),
    );
  }

  Widget _amountField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _amountCtrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        decoration: const InputDecoration(
          hintText: 'Сумма до 600 000 ₽',
          hintStyle:
              TextStyle(color: AppColors.textTertiary, fontSize: 15),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _messageField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _msgCtrl,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        decoration: const InputDecoration(
          hintText: 'Сообщение получателю',
          hintStyle:
              TextStyle(color: AppColors.textTertiary, fontSize: 15),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class ConfirmTransferScreen extends StatelessWidget {
  final BankInfo bank;
  final Contact contact;
  final double amount;
  final String? message;

  const ConfirmTransferScreen({
    super.key,
    required this.bank,
    required this.contact,
    required this.amount,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = message != null && message!.isNotEmpty;
    final headline = hasName ? message! : contact.phone;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Подтвердите перевод',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _card(
                        headline: headline,
                        showPhone: hasName,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'Перевести ${formatRubSmart(amount)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Image.asset('assets/sbp/sbp.png',
                          fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Система быстрых платежей',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required String headline, required bool showPhone}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (showPhone) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            contact.phone,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit_outlined,
                              color: AppColors.textSecondary, size: 14),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              BankLogo(kind: bank.kind, size: 44),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 0.5, color: AppColors.cardChip),
          const SizedBox(height: 14),
          _kv('Банк получателя', bank.name),
          const SizedBox(height: 14),
          _kvBalance(),
          const SizedBox(height: 14),
          _kvAmount(),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          v,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _kvBalance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Счёт списания',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Основной счёт',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        ValueListenableBuilder<double>(
          valueListenable: balanceNotifier,
          builder: (_, value, __) => Text(
            formatRubSmart(value),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _kvAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Сумма списания',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatRubSmart(amount),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Без комиссии',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
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
    final result = await Navigator.of(context).push<_TransferInput>(
      MaterialPageRoute(
        builder: (_) => PhoneTransferScreen(bank: bank, contact: contact),
      ),
    );
    if (result == null || result.amount <= 0) return;
    if (!context.mounted) return;
    withdraw(result.amount);
    addOperation(BankOperation(
      title: (result.name != null && result.name!.isNotEmpty)
          ? result.name!
          : contact.phone,
      subtitle: 'Переводы · ${bank.name}',
      amount: -result.amount,
      date: DateTime.now(),
      kind: OpKind.transfer,
    ));
    // Маленькая задержка — "перевод обрабатывается".
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => const Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // close loader
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
          SizedBox(
            width: 28,
            height: 28,
            child: Image.asset('assets/sbp/sbp.png', fit: BoxFit.contain),
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
