import 'package:flutter/material.dart';

import '../theme.dart';

class _Stub extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Stub({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textTertiary, size: 64),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Раздел в разработке',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _Stub(title: 'Выгода', icon: Icons.favorite_rounded);
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _Stub(title: 'Чат', icon: Icons.chat_bubble_rounded);
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _Stub(title: 'Ещё', icon: Icons.apps_rounded);
}
