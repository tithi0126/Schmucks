import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../widgets/comic_text.dart';
import '../../../widgets/polka_dot_background.dart';
import '../models/coffee_item.dart';
import '../controllers/shop_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  final CoffeeItem product;
  final ShopController controller;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  String _selectedSweetness = '100%';
  String _selectedMilk = 'Regular';

  double get _calculatedPrice {
    double base = widget.product.price;
    if (_selectedSize == 'S') base -= 20;
    if (_selectedSize == 'L') base += 40;

    if (_selectedMilk == 'Oat Milk') base += 40;
    if (_selectedMilk == 'Almond Milk') base += 50;

    return base;
  }

  void _addItemToCart() {
    HapticFeedback.heavyImpact();
    // Build a customized CoffeeItem for the cart to represent selection
    final customizedProduct = CoffeeItem(
      id: '${widget.product.id}_${_selectedSize}_${_selectedMilk.replaceAll(' ', '')}',
      name: '${widget.product.name} ($_selectedSize, ${widget.product.category == 'COFFEE' || widget.product.category == 'MATCHA' ? _selectedMilk : 'Normal'})',
      price: _calculatedPrice,
      description: widget.product.description,
      imagePath: widget.product.imagePath,
      category: widget.product.category,
    );

    widget.controller.addToCart(customizedProduct);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0C3827),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Added Custom ${widget.product.name} to Cart!',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isBeverage = widget.product.category == 'COFFEE' ||
        widget.product.category == 'MATCHA' ||
        widget.product.category == 'FRAPPES';

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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Product image container with neobrutalist border
                        _buildImageCard(size),

                        const SizedBox(height: 24),

                        // Title and Price Box
                        _buildTitlePriceBox(),

                        const SizedBox(height: 20),

                        // Description
                        _buildDescriptionBox(),

                        const SizedBox(height: 24),

                        // Customizations (Only show size/milk for beverages)
                        if (isBeverage) ...[
                          _buildSizeSelection(),
                          const SizedBox(height: 20),
                          _buildSweetnessSelection(),
                          const SizedBox(height: 20),
                          _buildMilkSelection(),
                          const SizedBox(height: 30),
                        ],
                      ],
                    ),
                  ),
                ),

                // Add to Order bottom panel
                _buildBottomOrderPanel(),
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
          Expanded(
            child: ComicText(
              text: widget.product.name,
              fontSize: 20,
              fillColor: Colors.white,
              strokeColor: Colors.black,
              strokeWidth: 4.0,
              shadowColor: const Color(0xFFFFC5C5),
              shadowOffset: const Offset(1.5, 1.5),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(Size size) {
    return Container(
      height: size.height * 0.3,
      decoration: BoxDecoration(
        color: const Color(0xFF0C3827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 4.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          const PolkaDotBackground(),
          Center(
            child: Hero(
              tag: 'product_tag_${widget.product.id}',
              child: Image.asset(
                widget.product.imagePath,
                height: size.height * 0.24,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 350.ms)
    .scale(begin: const Offset(0.9, 0.9), curve: Curves.elasticOut);
  }

  Widget _buildTitlePriceBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.product.name,
              style: GoogleFonts.playfairDisplay(
                color: const Color(0xFF0C3827),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ComicText(
            text: 'INR ${widget.product.price.toInt()}/-',
            fontSize: 18,
            fillColor: const Color(0xFFFFC5C5),
            strokeColor: Colors.black,
            strokeWidth: 3.5,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.product.description,
        style: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT DRINK SIZE:',
          style: GoogleFonts.lilitaOne(
            color: const Color(0xFF0C3827),
            fontSize: 14,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['S', 'M', 'L'].map((size) {
            bool isSelected = _selectedSize == size;
            String text = size == 'S' ? 'Small' : size == 'M' ? 'Medium' : 'Large';
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedSize = size;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0C3827) : const Color(0xFFF9F6EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: isSelected ? const Offset(1, 2) : const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.lilitaOne(
                      color: isSelected ? const Color(0xFFFFC5C5) : const Color(0xFF0C3827),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSweetnessSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SWEETNESS LEVEL:',
          style: GoogleFonts.lilitaOne(
            color: const Color(0xFF0C3827),
            fontSize: 14,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['25%', '50%', '75%', '100%'].map((sugar) {
            bool isSelected = _selectedSweetness == sugar;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedSweetness = sugar;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0C3827) : const Color(0xFFF9F6EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: isSelected ? const Offset(1, 2) : const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Text(
                    sugar,
                    style: GoogleFonts.lilitaOne(
                      color: isSelected ? const Color(0xFFFFC5C5) : const Color(0xFF0C3827),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMilkSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MILK ALTERNATIVES:',
          style: GoogleFonts.lilitaOne(
            color: const Color(0xFF0C3827),
            fontSize: 14,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Regular', 'Oat Milk', 'Almond Milk'].map((milk) {
            bool isSelected = _selectedMilk == milk;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedMilk = milk;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0C3827) : const Color(0xFFF9F6EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: isSelected ? const Offset(1, 2) : const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Text(
                    milk,
                    style: GoogleFonts.lilitaOne(
                      color: isSelected ? const Color(0xFFFFC5C5) : const Color(0xFF0C3827),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomOrderPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0C3827),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: Colors.black, width: 4.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL PRICE:',
                  style: GoogleFonts.lilitaOne(color: Colors.white54, fontSize: 12),
                ),
                ComicText(
                  text: 'INR ${_calculatedPrice.toInt()}/-',
                  fontSize: 20,
                  fillColor: const Color(0xFFFFC5C5),
                  strokeColor: Colors.black,
                  strokeWidth: 3.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _addItemToCart,
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC5C5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black, width: 3.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'ADD TO ORDER ☕',
                  style: GoogleFonts.lilitaOne(
                    color: const Color(0xFF0C3827),
                    fontSize: 14,
                    letterSpacing: 0.5,
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
