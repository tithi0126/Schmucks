import 'package:flutter/material.dart';
import '../models/coffee_item.dart';
import '../../cart/models/cart_item.dart';

class ShopController extends ChangeNotifier {
  int _currentTab = 0;
  String _selectedCategory = 'ALL';
  bool _couponApplied = false;
  int _orderCount = 0;
  int _collectedStampsCount = 0; // Default starting stamps count is 0
  int _activeVouchersCount = 0;  // Track claimed FREE coffee vouchers
  final List<CartItem> _cart = [];
  final List<List<CartItem>> _orderHistory = [];
  String _searchQuery = '';

  // MOCK PRODUCTS DATA
  final List<CoffeeItem> products = const [
    CoffeeItem(
      id: 'latte',
      name: 'ICE LATTE',
      price: 180,
      description: 'Premium espresso brewed over sweet, creamy milk.',
      imagePath: 'assets/images/popular_latte.png',
      category: 'COFFEE',
    ),
    CoffeeItem(
      id: 'begal',
      name: 'BEGAL',
      price: 250,
      description: 'Fresh bagel loaded with gourmet fillings and cheeses.',
      imagePath: 'assets/images/popular_begal.png',
      category: 'SAVOURY',
    ),
    CoffeeItem(
      id: 'matcha_latte',
      name: 'ICED MATCHA LATTE',
      price: 210,
      description: 'Ceremonial stone-ground Uji matcha whisked over velvet milk.',
      imagePath: 'assets/images/popular_matcha.png',
      category: 'MATCHA',
    ),
    CoffeeItem(
      id: 'matcha_dirty',
      name: 'DIRTY MATCHA',
      price: 240,
      description: 'Ceremonial green matcha layered with a signature espresso double-shot.',
      imagePath: 'assets/images/popular_matcha.png',
      category: 'MATCHA',
    ),
    CoffeeItem(
      id: 'frappe_choco',
      name: 'CHOCO FRAPPE',
      price: 220,
      description: 'Rich dark chocolate blended with ice, milk, and espresso.',
      imagePath: 'assets/images/category_frappes.png',
      category: 'FRAPPES',
    ),
    CoffeeItem(
      id: 'slushie_berry',
      name: 'CHILLY SLUSH',
      price: 150,
      description: 'Sweet, layered blue raspberry and strawberry frozen slushie.',
      imagePath: 'assets/images/category_slushies.png',
      category: 'SLUSHIES',
    ),
  ];

  // Getters
  int get currentTab => _currentTab;
  String get selectedCategory => _selectedCategory;
  bool get couponApplied => _couponApplied;
  int get orderCount => _orderCount;
  int get collectedStampsCount => _collectedStampsCount;
  int get activeVouchersCount => _activeVouchersCount;
  List<CartItem> get cart => List.unmodifiable(_cart);
  List<List<CartItem>> get orderHistory => _orderHistory;
  String get searchQuery => _searchQuery;

  List<CoffeeItem> get filteredProducts {
    if (_searchQuery.trim().isNotEmpty) {
      return products.where((p) => p.name.toLowerCase().contains(_searchQuery.trim().toLowerCase())).toList();
    }
    final String catLower = _selectedCategory.toLowerCase();
    if (catLower == 'all') return products;
    return products.where((p) {
      final pCatLower = p.category.toLowerCase();
      if (catLower == 'snacccc' && pCatLower == 'savoury') return true;
      return pCatLower == catLower;
    }).toList();
  }

  int get cartTotalItems {
    int total = 0;
    for (var item in _cart) {
      total += item.quantity;
    }
    return total;
  }

  double get cartSubtotal {
    double subtotal = 0.0;
    for (var item in _cart) {
      subtotal += item.product.price * item.quantity;
    }
    return subtotal;
  }

  double get cartDiscount {
    if (_couponApplied) {
      return cartSubtotal * 0.5; // 50% discount
    }
    return 0.0;
  }

  double get cartTax => (cartSubtotal - cartDiscount) * 0.05; // 5% tax

  double get cartTotal => (cartSubtotal - cartDiscount) + cartTax;

  // Setters & Methods
  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleCoupon() {
    _couponApplied = !_couponApplied;
    notifyListeners();
  }

  void addToCart(CoffeeItem product) {
    int index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromCart(CoffeeItem product) {
    int index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void incrementOrderCount() {
    _orderCount++;
    notifyListeners();
  }

  void setCollectedStampsCount(int val) {
    _collectedStampsCount = val;
    notifyListeners();
  }

  void setActiveVouchersCount(int val) {
    _activeVouchersCount = val;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addOrderToHistory(List<CartItem> orderItems) {
    _orderHistory.insert(0, List.from(orderItems));
    notifyListeners();
  }
}
