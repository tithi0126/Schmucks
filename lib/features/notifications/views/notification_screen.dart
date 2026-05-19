import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../widgets/comic_text.dart';
import '../../../widgets/polka_dot_background.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC5C5),
      body: Stack(
        children: [
          const PolkaDotBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeaderBar(context),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      _buildNotificationItem(
                        icon: Icons.card_giftcard_rounded,
                        title: '🎁 Flat 50% OFF Applied!',
                        time: 'Just Now',
                        description: 'Your starting discount coupon is active! Place your order and get flat half-price off your beverages automatically.',
                      ),
                      _buildNotificationItem(
                        icon: Icons.emoji_emotions_outlined,
                        title: '🐶 Snoopy Says Hello!',
                        time: '1 Hour Ago',
                        description: 'Snoopy is waiting at the counter with a steaming, sweet cup of green ceremonial Matcha! Come grab a seat.',
                      ),
                      _buildNotificationItem(
                        icon: Icons.stars_rounded,
                        title: '⭐ Double Stamps Event!',
                        time: 'Yesterday',
                        description: 'Earn 2x Loyalty stamps for every slushie or frappe ordered today! Fill up your card and claim free coffee!',
                      ),
                      _buildNotificationItem(
                        icon: Icons.payments_outlined,
                        title: '💰 Wallet Credited',
                        time: '2 Days Ago',
                        description: 'Schmucks Pay Wallet successfully loaded with INR 850/- balance. Fast, tap-to-pay checkouts are active!',
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

  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0C3827),
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 4.0),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC5C5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: ComicText(
              text: 'NOTIFICATIONS',
              fontSize: 20,
              fillColor: Colors.white,
              strokeColor: Colors.black,
              strokeWidth: 4.0,
              shadowColor: Color(0xFFFFC5C5),
              shadowOffset: Offset(1.5, 1.5),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String time,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC5C5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(icon, color: const Color(0xFF0C3827), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.lilitaOne(
                          color: const Color(0xFF0C3827),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFF0C3827).withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 250.ms)
    .slideY(begin: 0.1, end: 0);
  }
}
