# ☕ Schmucks Coffee & Snack Club

A high-fidelity, premium **Flutter** mobile application featuring a gorgeous **Neobrutalist Comic Book Design Aesthetic**. Schmucks is designed with bold borders, solid shadows, vibrant HSL tailored color schemes, and lively micro-animations to create an extremely interactive, tactile, and premium user experience.

---

## 🎨 Design Philosophy & Themes

Schmucks embraces **Neobrutalism** and **Comic-Halftone Art Styles**:
* **Brand Color Palette**:
  * Forest Green (`#0C3827`) — Deep primary tone.
  * Soft Pink (`#FFFFC5C5`) — Delicate contrast/accent.
  * Cream Paper (`#F9F6EE`) — Warm paper background.
  * Comic Black (`Colors.black`) — Hard thick borders (`3.5` width) and solid offsets (`Offset(0, 4)`).
* **Typography**: Heavy custom headers using `GoogleFonts.lilitaOne` paired with elegant book-like body fonts using `GoogleFonts.playfairDisplay`.
* **Micro-Animations**: Uses `flutter_animate` for smooth springy scales, slide-ins, and repeating loop floating effects.

---

## ✨ Key Features Built

### 🔒 1. Local Persistent Authentication & Gatekeeping
* **Local Phone Database**: Powered by `shared_preferences` for secure local key-value storage.
* **SignUp Flow ("Join the Club")**: Prompts users for Name and Phone, saving details permanently to the local device database.
* **Strict Login Block**: Unregistered phone numbers are fully blocked from entering the app, prompting them to sign up first.
* **OTP Simulation**: Enforces a strict testing OTP code (`0000`). Incorrect codes trigger light haptic warnings and block transitions.
* **Auto-Seeded Test Credentials**:
  * **Test Number**: `1234567890` (welcomes you as **`Vinay Shah`**).

### ☕ 2. Interactive Coffee Shop Catalog & Customization
* **Polaroid Product Carousel**: Displays premium coffees, bagles, matcha lattes, and frappes with full search functionality.
* **Drink Customizer**: Popups allow deep customization of:
  * Cup size (S / M / L) — dynamic price calculations.
  * Sweetness levels (25% / 50% / 75% / 100%).
  * Milk Alternatives (Regular / Oat Milk / Almond Milk).
* **Interactive Stamp Card**: Fully animated Neobrutalist stamp system that increments with orders, working towards free coffee!

### 🛒 3. Cart & Promotional Offers
* **Automatic Discounts**: A persistent bottom promotional card that grants **50% OFF** when tapped, auto-applied seamlessly to the subtotal in the `ShopController` state.
* **ChangeNotifier Architecture**: Smooth state listener broadcasts that trigger standard reactive UI rebuilds.

---

## 📁 Feature-First Directory Structure

Refactored from standard flat directory layouts into a highly scalable, **proper modular architecture**:

```text
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart         # Semantic color palette
│       └── app_theme.dart          # System theme configurations
│
├── widgets/
│   ├── comic_text.dart             # Comic-style stroked texts
│   └── polka_dot_background.dart   # Interactive canvas background
│
├── features/
│   ├── auth/
│   │   ├── controllers/
│   │   │   └── auth_controller.dart
│   │   └── views/
│   │       └── login_screen.dart
│   │
│   ├── shop/
│   │   ├── controllers/
│   │   │   └── shop_controller.dart
│   │   ├── models/
│   │   │   └── coffee_item.dart
│   │   └── views/
│   │       ├── home_screen.dart
│   │       └── product_detail_screen.dart
│   │
│   ├── cart/
│   │   └── models/
│   │       └── cart_item.dart
│   │
│   ├── orders/
│   │   └── views/
│   │       └── order_history_screen.dart
│   │
│   ├── notifications/
│   │   └── views/
│   │       └── notification_screen.dart
│   │
│   └── settings/
│       └── views/
│           └── settings_screen.dart
│
└── main.dart                       # App entry point & initialization
```

---

## 🚀 Getting Started

### 📋 Prerequisites
Ensure you have the Flutter SDK installed on your system:
```bash
flutter --version
```

### 🛠️ Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/tithi0126/Schmucks.git
   ```
2. Retrieve packages:
   ```bash
   flutter pub get
   ```
3. Install iOS CocoaPods dependencies:
   ```bash
   cd ios && pod install
   ```

### 💻 Running the App
Run on a connected mobile device or emulator:
```bash
flutter run
```

---

## 🧪 Testing Guidelines

1. **Test Enforced Sign-up**: Try logging in with an arbitrary phone number (e.g. `9876543210`). The app will block login and prompt you to Sign Up ("Join the Club").
2. **Test Enforced OTP**: When entering OTP, type anything other than `0000` to see the incorrect OTP warning. Type `0000` to successfully proceed.
3. **Test Local Database Persistence**: Tap the "Join the Club" toggle, sign up with your name and phone, then enter `0000`. You will be logged in with your customized name. Force-close and restart the app, then log in using your phone number—your name will be retrieved from the local device database successfully!
