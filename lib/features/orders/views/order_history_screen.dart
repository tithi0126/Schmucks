import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../widgets/comic_text.dart';
import '../../../widgets/polka_dot_background.dart';
import '../../shop/controllers/shop_controller.dart';

class OrderHistoryScreen extends StatelessWidget {
  final ShopController controller;

  const OrderHistoryScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // If empty, let's show some cute mock past orders to feel rich!
    final activeOrders = controller.orderHistory;
    final hasActive = activeOrders.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFC5C5),
      body: Stack(
        children: [
          const PolkaDotBackground(),
          SafeArea(
            child: Column(
              children: [
                // Top Custom Header Bar
                _buildHeaderBar(context),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      if (hasActive) ...[
                        const ComicText(
                          text: 'RECENT ORDERS',
                          fontSize: 20,
                          fillColor: Colors.white,
                          strokeWidth: 4.0,
                        ),
                        const SizedBox(height: 12),
                        ...activeOrders.asMap().entries.map((entry) {
                          int index = entry.key;
                          var items = entry.value;
                          double total = items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
                          return _buildOrderCard(
                            id: 'SCHM-${3821 - index}',
                            date: 'Today, Just Now',
                            status: 'Brewed Successfully ✅',
                            itemsText: items.map((i) => '${i.quantity}x ${i.product.name}').join(', '),
                            total: total,
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      const ComicText(
                        text: 'PAST ORDERS',
                        fontSize: 20,
                        fillColor: Colors.white,
                        strokeWidth: 4.0,
                      ),
                      const SizedBox(height: 12),

                      _buildOrderCard(
                        id: 'SCHM-3788',
                        date: 'Yesterday, 4:32 PM',
                        status: 'Completed ✅',
                        itemsText: '1x ICE LATTE (M), 1x BEGAL (Normal)',
                        total: 430,
                      ),
                      _buildOrderCard(
                        id: 'SCHM-3691',
                        date: '14 May 2026, 11:20 AM',
                        status: 'Completed ✅',
                        itemsText: '1x ICED MATCHA LATTE (S, Oat Milk)',
                        total: 230,
                      ),
                      _buildOrderCard(
                        id: 'SCHM-3542',
                        date: '08 May 2026, 6:15 PM',
                        status: 'Completed ✅',
                        itemsText: '2x CHOCO FRAPPE (L), 2x BEGAL (Normal)',
                        total: 1040,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 4),
          ),
        ],
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
              text: 'ORDER HISTORY',
              fontSize: 22,
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

  Widget _buildOrderCard({
    required String id,
    required String date,
    required String status,
    required String itemsText,
    required double total,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: GoogleFonts.lilitaOne(
                  color: const Color(0xFF0C3827),
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C3827),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.lilitaOne(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: GoogleFonts.playfairDisplay(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            itemsText,
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFF0C3827),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1.5, color: Colors.black12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL PAID:',
                style: GoogleFonts.lilitaOne(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              ComicText(
                text: 'INR ${total.toInt()}/-',
                fontSize: 16,
                fillColor: const Color(0xFFFFC5C5),
                strokeWidth: 3.0,
              ),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms)
    .slideY(begin: 0.1, end: 0);
  }
}
