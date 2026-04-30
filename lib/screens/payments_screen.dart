import 'package:flutter/material.dart';

import '../theme.dart';
import 'recipients_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _showCommissionBanner = true;

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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _AppBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(child: _MyPaymentsCard()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(child: _TransfersCard()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(child: _BillsCard()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (_showCommissionBanner)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _CommissionBanner(
                      onClose: () =>
                          setState(() => _showCommissionBanner = false),
                    ),
                  ),
                ),
              if (_showCommissionBanner)
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(child: _PaymentsList()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(child: _OtherSection()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ App bar ============
class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const SizedBox(width: 40),
          const Expanded(
            child: Center(
              child: Text(
                'Платежи и переводы',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded,
                color: AppColors.textPrimary, size: 24),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner_rounded,
                color: AppColors.textPrimary, size: 24),
          ),
        ],
      ),
    );
  }
}

// ============ "Мои платежи" ============
class _MyPaymentsCard extends StatelessWidget {
  const _MyPaymentsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text(
            'Мои платежи',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary, size: 22),
          const Spacer(),
          const _BluePill(text: 'Все'),
        ],
      ),
    );
  }
}

// ============ "Переводы" ============
class _TransfersCard extends StatelessWidget {
  const _TransfersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Переводы',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              _BluePill(text: 'Доступные лимиты'),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionLabel('ПО НОМЕРУ ТЕЛЕФОНА'),
          const SizedBox(height: 8),
          _PhoneInput(),
          const SizedBox(height: 14),
          const _RecentContacts(),
          const SizedBox(height: 16),
          const _SectionLabel('ДРУГИЕ СПОСОБЫ'),
          const SizedBox(height: 8),
          const _OtherMethods(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecipientsScreen()),
        );
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.cardSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2D3540), width: 0.6),
        ),
        child: Row(
        children: [
          const Expanded(
            child: Text(
              'Номер или имя получателя',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 15),
            ),
          ),
          const Icon(Icons.qr_code_2_rounded,
              color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 10),
          SizedBox(
            width: 22,
            height: 22,
            child: Image.asset('assets/sbp/sbp.png', fit: BoxFit.contain),
          ),
        ],
      ),
      ),
    );
  }
}

class _RecentContacts extends StatelessWidget {
  const _RecentContacts();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _ContactData('С', 'Себе'),
      _ContactData('Л', 'Любимая', heartsBelow: 3, heartBadge: true),
      _ContactData('Н', 'Некит'),
      _ContactData('АИ', 'Адександр\nИнформат'),
      _ContactData('АТ', 'акиф\nтакси'),
      _ContactData('АН', 'Антон'),
    ];

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _ContactTile(data: items[i]),
      ),
    );
  }
}

class _ContactData {
  final String initials;
  final String name;
  final int heartsBelow;
  final bool heartBadge;
  const _ContactData(
    this.initials,
    this.name, {
    this.heartsBelow = 0,
    this.heartBadge = false,
  });
}

class _ContactTile extends StatelessWidget {
  final _ContactData data;
  const _ContactTile({required this.data});

  @override
  Widget build(BuildContext context) {
    const heartColor = Color(0xFFE53935);
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.cardChip,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  data.initials,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (data.heartBadge)
                const Positioned(
                  right: -2,
                  top: -2,
                  child: Icon(Icons.favorite,
                      color: heartColor, size: 14),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              height: 1.15,
            ),
          ),
          if (data.heartsBelow > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                data.heartsBelow,
                (_) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.5),
                  child: Icon(Icons.favorite,
                      color: heartColor, size: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OtherMethods extends StatelessWidget {
  const _OtherMethods();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _MethodData('Между\nсчетами', Icons.swap_horiz_rounded),
      _MethodData('По номеру\nкарты', Icons.credit_card_rounded),
      _MethodData('За рубеж', Icons.public_rounded),
      _MethodData('По\nреквизитам', Icons.description_rounded),
    ];
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _MethodTile(data: items[i]),
      ),
    );
  }
}

class _MethodData {
  final String label;
  final IconData icon;
  const _MethodData(this.label, this.icon);
}

class _MethodTile extends StatelessWidget {
  final _MethodData data;
  const _MethodTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(data.icon, color: AppColors.accentBlue, size: 24),
          Text(
            data.label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ "Счета на оплату" ============
class _BillsCard extends StatelessWidget {
  const _BillsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Счета на оплату',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_up_rounded,
                  color: AppColors.textSecondary, size: 22),
              Spacer(),
              _BluePill(text: 'Подробнее'),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Добавьте подписку и не пропускайте счета',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.cardSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add_rounded,
                    color: AppColors.accentBlue, size: 28),
              ),
              const SizedBox(height: 6),
              const Text(
                'Добавить',
                style: TextStyle(
                  color: AppColors.accentBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ Зелёный баннер ============
class _CommissionBanner extends StatelessWidget {
  final VoidCallback onClose;
  const _CommissionBanner({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1FB35B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Не берём комиссию за платежи 💙',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// ============ Список платежей ============
class _PaymentsList extends StatelessWidget {
  const _PaymentsList();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _PayItem('Оплата QR', Icons.qr_code_scanner_rounded),
      _PayItem('Мобильная связь', Icons.smartphone_rounded),
      _PayItem('Коммунальные услуги', Icons.apartment_rounded),
      _PayItem('Интернет и ТВ', Icons.tv_rounded),
      _PayItem('Образование', Icons.school_rounded),
      _PayItem('Транспорт', Icons.directions_car_filled_rounded),
      _PayItem('Налоги, штрафы, ФССП', Icons.account_balance_rounded),
      _PayItem('Игры и досуг', Icons.sports_esports_rounded),
      _PayItem('Зарубежные сервисы', Icons.language_rounded),
      _PayItem('Интернет за границей', Icons.wifi_rounded),
      _PayItem('Благотворительность', Icons.volunteer_activism_rounded),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              'Платежи',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...items.map((e) => _PaymentRow(item: e)),
        ],
      ),
    );
  }
}

class _PayItem {
  final String title;
  final IconData icon;
  const _PayItem(this.title, this.icon);
}

class _PaymentRow extends StatelessWidget {
  final _PayItem item;
  const _PaymentRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon,
                  color: AppColors.accentBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 22),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

// ============ "Другое" ============
class _OtherSection extends StatelessWidget {
  const _OtherSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Другое',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OtherTile(
                  label: 'Лимиты\nи тарифы',
                  icon: Icons.speed_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OtherTile(
                  label: 'Банкоматы',
                  icon: Icons.atm_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OtherTile(
                  label: 'Настройки\nСБП',
                  icon: Icons.payments_rounded,
                  iconGradient: const LinearGradient(
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
            ],
          ),
        ],
      ),
    );
  }
}

class _OtherTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient? iconGradient;
  const _OtherTile({
    required this.label,
    required this.icon,
    this.iconGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (iconGradient != null)
            SizedBox(
              width: 22,
              height: 22,
              child: Image.asset('assets/sbp/sbp.png', fit: BoxFit.contain),
            )
          else
            Icon(icon, color: AppColors.accentBlue, size: 24),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Reusable blue pill ============
class _BluePill extends StatelessWidget {
  final String text;
  const _BluePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF15324F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.accentBlue, size: 16),
        ],
      ),
    );
  }
}
