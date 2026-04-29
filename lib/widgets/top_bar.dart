import 'package:flutter/material.dart';

import '../theme.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF2A3340),
                child: Icon(
                  Icons.person,
                  color: AppColors.textTertiary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Кирилл Г.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 22),
              const Spacer(),
              _CircleIconButton(
                onTap: () {},
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2D6BFF), Color(0xFF7E5BFF)],
                    ),
                  ),
                  child: const Icon(Icons.card_giftcard_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                onTap: () {},
                child: const Icon(Icons.search_rounded,
                    color: AppColors.textPrimary, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _CircleIconButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(child: child),
      ),
    );
  }
}
