import 'package:flutter/material.dart';

import '../theme.dart';
import 'home_screen.dart';
import 'placeholder_screens.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    PaymentsScreen(),
    BenefitsScreen(),
    ChatScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _BarItem(icon: Icons.home_rounded, label: 'Главная'),
      _BarItem(icon: Icons.compare_arrows_rounded, label: 'Платежи'),
      _BarItem(icon: Icons.favorite_rounded, label: 'Выгода'),
      _BarItem(icon: Icons.chat_bubble_rounded, label: 'Чат'),
      _BarItem(icon: Icons.apps_rounded, label: 'Ещё'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E13),
        border: Border(top: BorderSide(color: Color(0xFF12161C), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == index;
              final color = selected ? AppColors.accentBlue : AppColors.textTertiary;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i].icon, color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BarItem {
  final IconData icon;
  final String label;
  const _BarItem({required this.icon, required this.label});
}
