import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/comic_text.dart';
import '../models/coffee_item.dart';
import '../../cart/models/cart_item.dart';
import '../controllers/shop_controller.dart';
import 'product_detail_screen.dart';
import '../../orders/views/order_history_screen.dart';
import '../../settings/views/settings_screen.dart';
import '../../notifications/views/notification_screen.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, this.userName = 'Vinay Shah'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShopController _controller = ShopController();

  int get _currentTab => _controller.currentTab;
  set _currentTab(int val) => _controller.setTab(val);

  List<CartItem> get _cart => _controller.cart;

  bool get _couponApplied => _controller.couponApplied;
  set _couponApplied(bool val) {
    if (_controller.couponApplied != val) {
      _controller.toggleCoupon();
    }
  }

  List<CoffeeItem> get _products => _controller.products;

  String get _selectedCategory => _controller.selectedCategory;
  set _selectedCategory(String val) => _controller.selectCategory(val);

  int get _cartTotalItems => _controller.cartTotalItems;
  double get _cartSubtotal => _controller.cartSubtotal;
  double get _cartTotal => _controller.cartTotal;
  late String _currentUserName;

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
    _controller.addListener(_onControllerChanged);
    // Initialize category filter
    _controller.selectCategory('ALL');
    // Auto-apply starting coupon
    if (!_controller.couponApplied) {
      _controller.toggleCoupon();
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  // Add Item to Cart with Animation & Haptic
  void _addToCart(CoffeeItem product) {
    HapticFeedback.lightImpact();
    _controller.addToCart(product);

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
                '${product.name} added to order!',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _controller.setTab(2); // Jump to cart tab
              },
              child: Text(
                'VIEW CART',
                style: GoogleFonts.lilitaOne(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC5C5), // Same Forest Green Theme
      body: SafeArea(
        top: false, // Let the top bar extend underneath status bar
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildSelectedView(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // SWAP THE MAIN SCENE BASED ON TAB INDEX
  Widget _buildSelectedView() {
    switch (_currentTab) {
      case 0:
        return _buildHomeFeedView();
      case 1:
        return _buildMenuView();
      case 2:
        return _buildCartView();
      case 3:
        return _buildProfileView();
      default:
        return _buildHomeFeedView();
    }
  }

  // --- TAB 0: HOME FEED VIEW (Replicates mockup perfectly) ---
  Widget _buildHomeFeedView() {
    return Column(
      key: const ValueKey('home_feed_key'),
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 12 + MediaQuery.of(context).padding.top, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF0C3827),
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 4.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Delivery details
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFFFC5C5), // Soft Pink location icon
                    size: 32,
                  )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .moveY(begin: -2, end: 2, duration: 1000.ms, curve: Curves.easeInOut),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deliver to ${_currentUserName.split(' ')[0]}',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Vip Road , Vesu',
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xFFFFC5C5), // Soft Pink location subtitle
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Bell icon in white/cream circle
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder: (context, anim, secAnim) => const NotificationScreen(),
                      transitionsBuilder: (context, anim, secAnim, child) => SlideTransition(
                        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(anim),
                        child: child,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6EE),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2a. Search Bar
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.creamPaper,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cartoonBlack, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cartoonBlack,
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.forestGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: _controller.setSearchQuery,
                          cursorColor: AppColors.forestGreen,
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.forestGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search for your favorite coffee/snacks...',
                            hintStyle: GoogleFonts.playfairDisplay(
                              color: AppColors.forestGreen.withOpacity(0.5),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.05, end: 0),

                const SizedBox(height: 18),

                // 2b. High-Fidelity Banner
                Container(
                  height: 160,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: 1.15, // Zoom in slightly to cut out generated margins and fill the frame perfectly
                    child: Image.asset(
                      'assets/images/snoopy_banner.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 150.ms, duration: 500.ms)
                .scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 24),

                // Instagram Bio Card
                _buildInstagramBioCard(),

                const SizedBox(height: 24),

                // 2c. Categories Title
                const ComicText(
                  text: 'CATEGORIES',
                  fontSize: 26,
                  fillColor: Color(0xFFFFC5C5),
                  strokeColor: Colors.black,
                  strokeWidth: 4.5,
                  shadowColor: Color(0xFFDF533D),
                  shadowOffset: Offset(2.5, 2.5),
                ),

                const SizedBox(height: 14),

                // 2d. Categories Scrollable Row
                SizedBox(
                  height: 105,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCategoryItem('COFFEE', 'assets/images/category_coffee.png'),
                      _buildCategoryItem('MATCHA', 'assets/images/popular_matcha.png'),
                      _buildCategoryItem('SNACCCC', 'assets/images/category_snacccc.png'),
                      _buildCategoryItem('FRAPPES', 'assets/images/category_frappes.png'),
                      _buildCategoryItem('SLUSHIES', 'assets/images/category_slushies.png'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2e. Popular Items Title
                const ComicText(
                  text: 'POPULAR ITEMS',
                  fontSize: 26,
                  fillColor: Color(0xFFFFC5C5),
                  strokeColor: Colors.black,
                  strokeWidth: 4.5,
                  shadowColor: Color(0xFFDF533D),
                  shadowOffset: Offset(2.5, 2.5),
                ),

                const SizedBox(height: 14),

                // 2f. Polaroids horizontal neobrutalist scrapbook carousel
                SizedBox(
                  height: 290,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    itemCount: _products.where((p) => p.category == 'COFFEE' || p.category == 'SNACCCC' || p.category == 'MATCHA').length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final popularList = _products.where((p) => p.category == 'COFFEE' || p.category == 'SNACCCC' || p.category == 'MATCHA').toList();
                      final product = popularList[index];
                      return _buildPolaroidCard(product, index);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 2g. Flat 50% OFF bottom discount banner
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _couponApplied = !_couponApplied;
                    });
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF0C3827),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        content: Text(
                          _couponApplied 
                            ? '🎉 flat 50% OFF auto-applied at checkout!'
                            : 'Removed 50% OFF coupon.',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 3.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Transform.scale(
                      scale: 1.15, // Zoom in slightly to cut out generated margins and fill the frame perfectly
                      child: Image.asset(
                        'assets/images/snoopy_discount_banner.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02), duration: 2000.ms, curve: Curves.easeInOut),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // BUILD INDIVIDUAL CATEGORY ICON BUTTON
  Widget _buildCategoryItem(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedCategory = title;
          _currentTab = 1; // Direct user to interactive Menu View with selected category
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 14, bottom: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0C3827), // Coral pink background
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2.5, 3.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            
            // Text Label
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: ComicText(
                text: title == 'SNACCCC' ? 'SAVOURY' : title,
                fontSize: 10,
                strokeWidth: 3.0,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms)
    .scale(begin: const Offset(0.9, 0.9));
  }

  // BUILD POPULAR PRODUCT POLAROID SCENE CARD
  Widget _buildPolaroidCard(CoffeeItem product, int index) {
    double rotation = (index % 2 == 0) ? -0.035 : 0.035;
    
    return Transform.rotate(
      angle: rotation,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(
                product: product,
                controller: _controller,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                  child: child,
                );
              },
            ),
          );
        },
        child: Container(
          width: 195,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Polaroid photo image slot
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6EE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Hero(
                    tag: 'product_image_${product.id}',
                    child: Image.asset(
                      product.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // Decorative Comic Sticker & Round Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C3827), // Forest green sticker
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Text(
                      index % 2 == 0 ? 'FAVOURITE' : 'BEST SELLER',
                      style: GoogleFonts.lilitaOne(
                        color: Colors.white,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  // Circular Neobrutalist Price Badge
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC5C5), // Soft Pink
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Text(
                      '${product.price.toInt()}',
                      style: GoogleFonts.lilitaOne(
                        color: Colors.black,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Polaroid name caption
              Expanded(
                child: Text(
                  product.name.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lilitaOne(
                    color: const Color(0xFF0C3827),
                    fontSize: 15,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), curve: Curves.elasticOut);
  }

  // --- TAB 1: MENU VIEW (Interactive Catalog View) ---
  Widget _buildMenuView() {
    // Filter items by category & search query reactively
    final items = _controller.filteredProducts;

    return Column(
      key: const ValueKey('menu_view_key'),
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 12 + MediaQuery.of(context).padding.top, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF0C3827),
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 4.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ComicText(
                text: 'SCHMUCKS MENU',
                fontSize: 22,
                fillColor: Colors.white, // White fill on Green
                strokeColor: Colors.black,
                strokeWidth: 4.0,
                shadowColor: Color(0xFFFFC5C5), // Pink shadow pop
                shadowOffset: Offset(1.5, 1.5),
              ),
              // Small Cart Icon Button with Stagger badge count
              _buildSmallCartBadge(),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle category filter picker row
        Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['ALL', 'COFFEE', 'MATCHA', 'SNACCCC', 'FRAPPES', 'SLUSHIES'].map((cat) {
              bool isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.only(right: 10, bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0C3827) : const Color(0xFFF9F6EE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: isSelected ? const Offset(1, 2.5) : const Offset(0, 1.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    cat == 'SNACCCC' ? 'SAVOURY' : cat,
                    style: GoogleFonts.lilitaOne(
                      color: isSelected ? const Color(0xFFFFC5C5) : const Color(0xFF0C3827),
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Items Grid
        Expanded(
          child: items.isEmpty 
          ? Center(
              child: Text(
                'Coming Soon!',
                style: GoogleFonts.playfairDisplay(color: const Color(0xFF0C3827), fontSize: 18),
              ),
            )
          : GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                return _buildGridMenuItem(product);
              },
            ),
        ),
      ],
    );
  }

  // BUILD GRID MENU ITEM
  Widget _buildGridMenuItem(CoffeeItem product) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(
              product: product,
              controller: _controller,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C3827), // Coral background
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black, width: 3.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Container
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: Hero(
                  tag: 'menu_image_${product.id}',
                  child: Image.asset(product.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),

            // Thick black divider
            Container(
              height: 3.5,
              color: Colors.black,
            ),

            // Text details & Buy Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ComicText(
                    text: product.name,
                    fontSize: 14,
                    textAlign: TextAlign.left,
                    strokeWidth: 3.0,
                    fillColor: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'INR ${product.price.toInt()}/-',
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xFFFFC5C5),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      
                      // Add Button
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Text(
                            '+ ADD',
                            style: GoogleFonts.lilitaOne(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 250.ms)
    .scale(begin: const Offset(0.9, 0.9));
  }

  // SMALL CART ICON WITH FLOATING BADGE
  Widget _buildSmallCartBadge() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentTab = 2; // Navigate to cart
        });
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6EE),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart_rounded,
              color: Colors.black,
              size: 18,
            ),
          ),
          if (_cartTotalItems > 0)
            Transform.translate(
              offset: const Offset(4, -4),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C3827),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  '$_cartTotalItems',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lilitaOne(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ).animate(target: _cartTotalItems.toDouble()).scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
        ],
      ),
    );
  }

  // --- TAB 2: CART / CHECKOUT VIEW ---
  Widget _buildCartView() {
    return Column(
      key: const ValueKey('cart_view_key'),
      children: [
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(16, 12 + MediaQuery.of(context).padding.top, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF0C3827),
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 4.0),
            ),
          ),
          child: const ComicText(
            text: 'YOUR CART',
            fontSize: 22,
            fillColor: Colors.white, // White fill on Green
            strokeColor: Colors.black,
            strokeWidth: 4.0,
            shadowColor: Color(0xFFFFC5C5), // Pink shadow pop
            shadowOffset: Offset(1.5, 1.5),
          ),
        ),

        const SizedBox(height: 16),

        // Cart items list
        Expanded(
          child: _cart.isEmpty
              ? _buildEmptyCartPlaceholder()
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _cart.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = _cart[index];
                    return _buildCartListItem(item, index);
                  },
                ),
        ),

        // Cart checkout bill summary
        if (_cart.isNotEmpty) _buildCheckoutPanel(),
      ],
    );
  }

  // EMPTY CART PLACEHOLDER WITH SNOOPY VIBE
  Widget _buildEmptyCartPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: const Color(0xFF0C3827).withOpacity(0.4),
            size: 80,
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(begin: -5, end: 5, duration: 1500.ms),
          const SizedBox(height: 18),
          Text(
            'Your bag is empty!',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFF0C3827),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add some delicious Schmucks coffees & bagels",
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFF0C3827).withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _currentTab = 1; // Go to menu tab
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0C3827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'Browse Menu',
                style: GoogleFonts.lilitaOne(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CART LIST ITEM
  Widget _buildCartListItem(CartItem item, int index) {
    return Container(
      height: 105,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3827), // Coral background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.product.imagePath,
              width: 80,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ComicText(
                  text: item.product.name,
                  fontSize: 14,
                  textAlign: TextAlign.left,
                  strokeWidth: 3.0,
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 6),
                Text(
                  'INR ${item.product.price.toInt()}/-',
                  style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFFFFC5C5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            children: [
              // Minus button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _controller.removeFromCart(item.product);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.remove, size: 14, color: Colors.black),
                ),
              ),

              // Quantity Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ComicText(
                  text: '${item.quantity}',
                  fontSize: 16,
                  strokeWidth: 3.0,
                  fillColor: Colors.white,
                ),
              ),

              // Plus button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _controller.addToCart(item.product);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 250.ms);
  }

  // SUMMARY BILL & CHECKOUT BUTTON
  Widget _buildCheckoutPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3827), // Deep dark green summary
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: const Border(
          top: BorderSide(color: Colors.black, width: 3.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subtotal row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: GoogleFonts.playfairDisplay(color: Colors.white70, fontSize: 15),
              ),
              Text(
                'INR ${_cartSubtotal.toInt()}/-',
                style: GoogleFonts.playfairDisplay(color: const Color(0xFF0C3827), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          
          if (_couponApplied) ...[
            const SizedBox(height: 8),
            // Coupon Discount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Snoopy 50% Coupon',
                  style: GoogleFonts.playfairDisplay(color: const Color(0xFFFFC5C5), fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '- INR ${(_cartSubtotal * 0.5).toInt()}/-',
                  style: GoogleFonts.playfairDisplay(color: const Color(0xFF0C3827), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          // Thick black divider line
          Container(height: 2, color: Colors.black54),
          const SizedBox(height: 12),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ComicText(
                text: 'TOTAL',
                fontSize: 18,
                strokeWidth: 3.0,
                fillColor: Colors.white,
              ),
              ComicText(
                text: 'INR ${_cartTotal.toInt()}/-',
                fontSize: 20,
                strokeWidth: 3.5,
                fillColor: const Color(0xFFFFC5C5),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Place Order Button
          GestureDetector(
            onTap: _processCheckoutSimulation,
            child: Container(
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0C3827), // Coral buttons
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
                'Place Order',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CHECKOUT LOADING & SUCCESS MODAL SIMULATION
  void _processCheckoutSimulation() {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildBrewingOverlay();
      },
    );

    // Simulate coffee brewing time
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Dismiss loader overlay
      
      // Show success modal
      HapticFeedback.heavyImpact();
      _showOrderSuccessModal();
      
      // Save order to history before clearing
      _controller.addOrderToHistory(_cart);
      // Clear Cart & Increment Loyalty Stamps via controller
      _controller.clearCart();
      _controller.incrementOrderCount();
    });
  }

  // COFFEE BREWING LOADER OVERLAY
  Widget _buildBrewingOverlay() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFFFC5C5).withOpacity(0.95),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating Coffee loader cup illustration
            Image.asset(
              'assets/images/category_coffee.png',
              width: 140,
              height: 140,
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(begin: -10, end: 10, duration: 1000.ms, curve: Curves.easeInOut)
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1500.ms),

            const SizedBox(height: 24),
            
            const ComicText(
              text: 'BREWING YOUR COFFEE...',
              fontSize: 22,
              strokeWidth: 4.5,
              fillColor: Colors.white,
              shadowColor: Color(0xFFDF533D),
              shadowOffset: Offset(2, 2),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Grinding premium coffee beans...',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white60,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ORDER PLACED SUCCESS POPUP
  void _showOrderSuccessModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 480,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC5C5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border.all(color: Colors.black, width: 3.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Snoopy holding wood sign banner (as a celebration visual)
              Image.asset(
                'assets/images/snoopy_welcome.png',
                height: 180,
              )
              .animate()
              .scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut, duration: 800.ms),
              
              const SizedBox(height: 20),

              const ComicText(
                text: 'ORDER SUCCESSFUL!',
                fontSize: 26,
                fillColor: Color(0xFFFFC5C5),
                strokeWidth: 5.0,
                shadowColor: Color(0xFFDF533D),
                shadowOffset: Offset(2.5, 2.5),
              ),

              const SizedBox(height: 12),

              Text(
                'Your delicious coffee and snacks are being prepared by Snoopy. You can collect your order or wait for delivery to ${_currentUserName.split(' ')[0]}!',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop(); // Dismiss success modal
                  setState(() {
                    _currentTab = 0; // Return home
                  });
                },
                child: Container(
                  width: 200,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C3827),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'SIP. RELAX. REPEAT.',
                    style: GoogleFonts.lilitaOne(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: PROFILE & LOYALTY STAMPS VIEW ---
  // Store Loyalty Stamp Stamps Completed
  int get _collectedStampsCount => _controller.collectedStampsCount;
  set _collectedStampsCount(int val) => _controller.setCollectedStampsCount(val);

  Widget _buildProfileView() {
    return Column(
      key: const ValueKey('profile_view_key'),
      children: [
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(16, 12 + MediaQuery.of(context).padding.top, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF0C3827),
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 4.0),
            ),
          ),
          child: const ComicText(
            text: "MY PROFILE",
            fontSize: 22,
            fillColor: Colors.white, // White fill on Green
            strokeColor: Colors.black,
            strokeWidth: 4.0,
            shadowColor: Color(0xFFFFC5C5), // Pink shadow pop
            shadowOffset: Offset(1.5, 1.5),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Snoopy Avatar & Username card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C3827),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar (Snoopy circle photo/asset)
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC5C5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2.5),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/snoopy_welcome.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Profile Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUserName,
                              style: GoogleFonts.lilitaOne(
                                color: const Color(0xFFFFC5C5),
                                fontSize: 24,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Schmucker ID: #98291',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. STAMPS LOYALTY CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C3827),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'STAMPS LOYALTY',
                            style: GoogleFonts.lilitaOne(
                              color: const Color(0xFFFFC5C5),
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC5C5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Text(
                              '$_collectedStampsCount/5 STAMPS',
                              style: GoogleFonts.lilitaOne(
                                color: Colors.black,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buy 5 coffees, get the 6th completely free!',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Stamp Grid Row (5 slots)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          final bool isCollected = index < _collectedStampsCount;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                if (isCollected) {
                                  _collectedStampsCount = index;
                                } else {
                                  _collectedStampsCount = index + 1;
                                  if (_collectedStampsCount == 5) {
                                    _showFreeCoffeeAwardMessage();
                                  }
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutBack,
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isCollected ? const Color(0xFFFFC5C5) : Colors.black26,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: isCollected ? 3.0 : 2.0,
                                ),
                                boxShadow: isCollected
                                    ? const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 3),
                                          blurRadius: 0,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isCollected
                                    ? const Icon(
                                        Icons.pets_rounded, // Cute paw stamp!
                                        color: Color(0xFF0C3827),
                                        size: 26,
                                      )
                                        .animate()
                                        .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 600.ms)
                                        .rotate(begin: -0.15, end: 0)
                                    : Text(
                                        '${index + 1}',
                                        style: GoogleFonts.lilitaOne(
                                          color: Colors.white30,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 16),
                      
                      // Progress Slider
                      LinearProgressIndicator(
                        value: _collectedStampsCount / 5.0,
                        backgroundColor: Colors.black12,
                        color: const Color(0xFF0C3827),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: 24),

                // collapsible settings option buttons
                _buildProfileOption(
                  Icons.receipt_long_rounded,
                  'Order History',
                  'Check recent snacks and coffees',
                  () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 350),
                        pageBuilder: (context, anim, secAnim) => OrderHistoryScreen(controller: _controller),
                        transitionsBuilder: (context, anim, secAnim, child) => SlideTransition(
                          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(anim),
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
                _buildProfileOption(
                  Icons.savings_rounded,
                  'Schmucks Pay Wallet',
                  'INR 850/- balance loaded',
                  () {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF0C3827),
                        content: Text(
                          '💳 Schmucks Pay Wallet has INR 850/- loaded!',
                          style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
                _buildProfileOption(
                  Icons.tune_rounded,
                  'Settings & Notifications',
                  'Manage locations and sounds',
                  () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 350),
                        pageBuilder: (context, anim, secAnim) => SettingsScreen(
                          currentName: _currentUserName,
                          onSaveName: (newName) {
                            setState(() {
                              _currentUserName = newName;
                            });
                          },
                        ),
                        transitionsBuilder: (context, anim, secAnim, child) => SlideTransition(
                          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(anim),
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0C3827), size: 28),
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(color: const Color(0xFF0C3827), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.playfairDisplay(color: const Color(0xFF0C3827).withOpacity(0.7), fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFF0C3827).withOpacity(0.4), size: 16),
        onTap: onTap,
      ),
    );
  }

  // LOYALTY FREE COFFEE REWARD CONGRATS POPUP
  void _showFreeCoffeeAwardMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFC5C5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 3.5),
          ),
          title: const ComicText(
            text: 'CONGRATULATIONS!',
            fontSize: 20,
            fillColor: Color(0xFFFFC5C5),
            strokeWidth: 4.0,
          ),
          content: Text(
            '🌟 You have collected all 5 stamps! Your next coffee at Schmucks is 100% FREE! We have credited the voucher to your profile.',
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _collectedStampsCount = 0; // Reset loyalty card for fresh stamps!
                });
              },
              child: Text(
                'AWESOME!',
                style: GoogleFonts.lilitaOne(
                  color: const Color(0xFF0C3827),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- GENERAL MOCK MODALS / DETAIL DIALOGS ---
  
  // POPULAR PRODUCT CUSTOMIZER MODAL SHEET




  // --- 3. PREMIUM BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNav() {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 70 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF0C3827), // Solid green bottom nav background
        border: Border(
          top: BorderSide(color: Colors.black, width: 4.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.storefront_rounded, Icons.storefront_outlined, 'Home'),
          _buildNavItem(1, Icons.local_cafe_rounded, Icons.local_cafe_outlined, 'Menu'),
          _buildNavItem(2, Icons.shopping_basket_rounded, Icons.shopping_basket_outlined, 'Order', isCart: true),
          _buildNavItem(3, Icons.face_rounded, Icons.face_outlined, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, {bool isCart = false}) {
    bool isActive = _currentTab == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _currentTab = index;
        });
      },
      child: Container(
        color: Colors.transparent, // Expand tap area
        width: 80,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  isActive ? activeIcon : inactiveIcon,
                  color: isActive ? const Color(0xFFFFC5C5) : Colors.white60, // Pink highlight active, white60 inactive
                  size: 26,
                )
                .animate(target: isActive ? 1.0 : 0.0)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 250.ms, curve: Curves.elasticOut),
                
                // Overlay item count badge specifically for Order (Cart) tab
                if (isCart && _cartTotalItems > 0)
                  Transform.translate(
                    offset: const Offset(8, -8),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC5C5), // Soft Pink badge on green nav bar
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Text(
                        '$_cartTotalItems',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lilitaOne(
                          color: Colors.black,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  )
                  .animate(target: _cartTotalItems.toDouble())
                  .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0), duration: 500.ms, curve: Curves.elasticOut),
              ],
            ),
            const SizedBox(height: 4),

            // Label Text in classy sans-serif
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? const Color(0xFFFFC5C5) : Colors.white60, // Pink active, white60 inactive
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramBioCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3827), // brand green
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC5C5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2.5),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/snoopy_welcome.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              
              // Bio content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'schmucks',
                          style: GoogleFonts.lilitaOne(
                            color: const Color(0xFFFFC5C5),
                            fontSize: 22,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your daily neighborhood café',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🍵 matcha | ☕ coffee | 🥐 savoury',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🕒 Open Daily: 7:30 AM - 11:30 PM',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFC5C5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // "Come, get schmucked!" bubble
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC5C5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFF0C3827), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Come , get schmucked!',
                  style: GoogleFonts.lilitaOne(
                    color: const Color(0xFF0C3827),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.star_rounded, color: Color(0xFF0C3827), size: 18),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Follow Button
          GestureDetector(
            onTap: () {
              HapticFeedback.vibrate();
              _showInstagramLinkOverlay();
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'FOLLOW US @GETSCHMUCKED',
                    style: GoogleFonts.lilitaOne(
                      color: Colors.black,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(delay: 200.ms, duration: 500.ms)
    .scale(begin: const Offset(0.95, 0.95));
  }

  void _showInstagramLinkOverlay() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Instagram Dismiss',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC5C5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GET SCHMUCKED!',
                        style: GoogleFonts.lilitaOne(
                          color: const Color(0xFF0C3827),
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.black, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Snoopy cute image
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C3827),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        'assets/images/popular_matcha.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    '@getschmucked',
                    style: GoogleFonts.lilitaOne(
                      color: Colors.black,
                      fontSize: 24,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan or visit our official Instagram page to discover secret menus, customer features, and fresh daily matcha posts!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Copy link action button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🔗 Link copied: instagram.com/getschmucked',
                            style: GoogleFonts.lilitaOne(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF0C3827),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3827),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'OPEN INSTAGRAM LINK',
                          style: GoogleFonts.lilitaOne(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
