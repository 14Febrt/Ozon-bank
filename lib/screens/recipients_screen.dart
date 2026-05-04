import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'select_bank_screen.dart';

class Contact {
  final String initials;
  final String name;
  final String phone;
  final int heartsInName;
  final bool heartBadge;
  const Contact({
    required this.initials,
    required this.name,
    required this.phone,
    this.heartsInName = 0,
    this.heartBadge = false,
  });
}

const List<Contact> kContacts = [
  Contact(
    initials: 'Л',
    name: 'Любимая',
    phone: '+7 (950) 854-36-53',
    heartsInName: 3,
    heartBadge: true,
  ),
  Contact(initials: 'РП', name: 'Рубен Самвелович П.', phone: '+7 (988) 995-00-29'),
  Contact(initials: 'Н', name: 'Некит', phone: '+7 (952) 416-70-94'),
  Contact(
      initials: 'АИ',
      name: 'Адександр Информатика',
      phone: '+7 (928) 134-67-57'),
  Contact(initials: 'АТ', name: 'акиф такси', phone: '+7 (900) 130-40-03'),
  Contact(initials: 'А9', name: 'ангелина 9кл', phone: '+7 (960) 459-18-66'),
  Contact(initials: 'АН', name: 'артем никиф', phone: '+7 (928) 125-29-79'),
  Contact(
      initials: 'БВ',
      name: 'Бабушка Валя',
      phone: '+7 (950) 849-46-65',
      heartsInName: 1),
  Contact(initials: 'БЛ', name: 'бабушка лена', phone: '+7 (951) 848-04-75'),
  Contact(initials: 'В', name: 'влад', phone: '+7 (939) 954-26-73'),
  Contact(initials: 'В', name: 'Влад!!!', phone: '+7 (918) 552-04-56'),
  Contact(initials: 'Д', name: 'Данил', phone: '+7 (988) 123-45-67'),
  Contact(initials: 'ДМ', name: 'Дима', phone: '+7 (961) 222-33-44'),
  Contact(initials: 'ЕК', name: 'Екатерина', phone: '+7 (962) 555-66-77'),
  Contact(initials: 'ИП', name: 'Иван Петров', phone: '+7 (903) 111-22-33'),
  Contact(initials: 'МК', name: 'Максим', phone: '+7 (915) 444-55-66'),
  Contact(initials: 'ОВ', name: 'Ольга', phone: '+7 (926) 777-88-99'),
  Contact(initials: 'ПС', name: 'Папа', phone: '+7 (905) 333-44-55'),
  Contact(initials: 'СН', name: 'Серёга', phone: '+7 (964) 888-99-00'),
];

class RecipientsScreen extends StatefulWidget {
  const RecipientsScreen({super.key});

  @override
  State<RecipientsScreen> createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> {
  final TextEditingController _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  /// Если в поле ввода — не пустой запрос, отдаём виртуальный контакт
  /// с распознанным телефоном (если введены цифры) или именем.
  Contact? _manualContact() {
    final raw = _q.text.trim();
    if (raw.isEmpty) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      // Телефон
      final formatted = _formatPhone(digits);
      return Contact(
        initials: '+',
        name: 'Новый получатель',
        phone: formatted,
      );
    }
    if (digits.isEmpty) {
      // Только имя/текст
      final initials = raw.isNotEmpty ? raw[0].toUpperCase() : '?';
      return Contact(
        initials: initials,
        name: raw,
        phone: '',
      );
    }
    return null;
  }

  String _formatPhone(String digits) {
    var d = digits;
    if (d.length == 11 && d.startsWith('8')) d = '7${d.substring(1)}';
    if (d.length == 10) d = '7$d';
    if (d.length < 11) return '+$d';
    return '+${d[0]} (${d.substring(1, 4)}) '
        '${d.substring(4, 7)}-${d.substring(7, 9)}-${d.substring(9, 11)}';
  }

  List<Contact> _filtered() {
    final q = _q.text.trim().toLowerCase();
    if (q.isEmpty) return kContacts;
    return kContacts
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phone.replaceAll(RegExp(r'\D'), '').contains(q.replaceAll(RegExp(r'\D'), '')))
        .toList();
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
            children: [
              _buildAppBar(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _SearchField(
                  controller: _q,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (_q.text.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _SelfTransferTile(
                    phone: '+7 (904) 345-55-21',
                  ),
                ),
              if (_q.text.trim().isNotEmpty && _manualContact() != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _ManualEntryTile(
                    contact: _manualContact()!,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            SelectBankScreen(contact: _manualContact()!),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: _filtered().length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, i) {
                    final c = _filtered()[i];
                    return _ContactRow(
                      contact: c,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SelectBankScreen(contact: c),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D3540), width: 0.6),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.text,
              inputFormatters: [PhoneOrTextFormatter()],
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Номер телефона или имя получателя',
                hintStyle:
                    TextStyle(color: AppColors.textTertiary, fontSize: 15),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const Icon(Icons.qr_code_2_rounded,
              color: AppColors.textSecondary, size: 22),
        ],
      ),
    );
  }
}

class _SelfTransferTile extends StatelessWidget {
  final String phone;
  const _SelfTransferTile({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15324F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Себе в другой банк',
                  style: TextStyle(
                    color: AppColors.accentBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.accentBlue, size: 22),
        ],
      ),
    );
  }
}

/// Если пользователь начал вводить цифры (или +) — форматирует ввод как
/// российский телефон вида `+7 (XXX) XXX-XX-XX`. Если ввели буквы —
/// оставляет как есть (для поиска по имени).
class PhoneOrTextFormatter extends TextInputFormatter {
  static final _letterRe = RegExp(r'[A-Za-zА-Яа-яЁё]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (_letterRe.hasMatch(text)) return newValue;

    var d = text.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return const TextEditingValue();

    if (d.length == 11 && d.startsWith('8')) d = '7${d.substring(1)}';
    if (d.length > 11) d = d.substring(0, 11);
    if (d[0] != '7') {
      d = '7$d';
      if (d.length > 11) d = d.substring(0, 11);
    }

    final buf = StringBuffer('+');
    for (int i = 0; i < d.length; i++) {
      if (i == 1) {
        buf.write(' (');
      } else if (i == 4) {
        buf.write(') ');
      } else if (i == 7) {
        buf.write('-');
      } else if (i == 9) {
        buf.write('-');
      }
      buf.write(d[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ManualEntryTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  const _ManualEntryTile({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF15324F),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.accentBlue,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.phone.isNotEmpty
                        ? 'Перевести по номеру'
                        : 'Перевести «${contact.name}»',
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (contact.phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.phone,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.accentBlue, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  const _ContactRow({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const heartColor = Color(0xFFE53935);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.cardChip,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    contact.initials,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (contact.heartBadge)
                  const Positioned(
                    right: -2,
                    bottom: -2,
                    child: Icon(Icons.favorite,
                        color: heartColor, size: 14),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          contact.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (contact.heartsInName > 0) ...[
                        const SizedBox(width: 6),
                        Row(
                          children: List.generate(
                            contact.heartsInName,
                            (_) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.5),
                              child: Icon(Icons.favorite,
                                  color: heartColor, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.phone,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
