import 'package:flutter/material.dart';

import '../theme.dart';

class PromoBanners extends StatelessWidget {
  const PromoBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          _PremiumBanner(),
          SizedBox(width: 12),
          _RecommendBanner(),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E2A6B),
            Color(0xFF1F4FBF),
            Color(0xFF6BA3FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Crown decoration
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 140,
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          // Close
          Positioned(
            top: 8,
            right: 8,
            child: _CloseChip(),
          ),
          // % toggle pill
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.percent_rounded,
                        size: 16, color: AppColors.ozonBlue),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 26,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendBanner extends StatelessWidget {
  const _RecommendBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E5BD0), Color(0xFFB7A7E8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '500 ₽ за рекомендацию\nзарплатной карты',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Как получить',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
    );
  }
}
