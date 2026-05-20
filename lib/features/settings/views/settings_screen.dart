import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/comic_text.dart';
import '../../../widgets/polka_dot_background.dart';
import '../../auth/views/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String currentName;
  final Function(String) onSaveName;

  const SettingsScreen({
    super.key,
    required this.currentName,
    required this.onSaveName,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  bool _hapticFeedback = true;
  bool _walkPaws = true;
  bool _brewNotifications = true;
  bool _joinNewsletter = true;
  String _selectedAvatar = 'assets/images/category_coffee.png';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hapticFeedback = prefs.getBool('pref_haptics') ?? true;
      _walkPaws = prefs.getBool('pref_walk_paws') ?? true;
      _brewNotifications = prefs.getBool('pref_brew_notifications') ?? true;
      _joinNewsletter = prefs.getBool('pref_newsletter') ?? true;
      _selectedAvatar = prefs.getString('pref_avatar') ?? 'assets/images/category_coffee.png';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    HapticFeedback.heavyImpact();
    final String newName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Vinay Shah';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    await prefs.setBool('pref_haptics', _hapticFeedback);
    await prefs.setBool('pref_walk_paws', _walkPaws);
    await prefs.setBool('pref_brew_notifications', _brewNotifications);
    await prefs.setBool('pref_newsletter', _joinNewsletter);
    await prefs.setString('pref_avatar', _selectedAvatar);

    widget.onSaveName(newName);
    
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
          '🎉 Settings saved successfully!',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void _logOut() async {
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C3827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 3.5),
          ),
          title: const ComicText(
            text: 'LOG OUT?',
            fontSize: 20,
            fillColor: Color(0xFF0C3827),
            strokeWidth: 4.0,
          ),
          content: Text(
            'Are you sure you want to log out from Schmucks? We will miss you! 🐾☕',
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CANCEL',
                style: GoogleFonts.lilitaOne(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                HapticFeedback.heavyImpact();
                Navigator.of(context).pop(); // pop dialog
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_name'); // Clear login name
                
                // Navigate back to LoginScreen and clear stack
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: Text(
                'LOG OUT',
                style: GoogleFonts.lilitaOne(
                  color: const Color(0xFFFFC5C5),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Edit Card
                        _buildSectionHeader('EDIT PROFILE'),
                        const SizedBox(height: 12),
                        _buildProfileEditCard(),

                        const SizedBox(height: 24),

                        // System Toggles Card
                        _buildSectionHeader('PREFERENCES'),
                        const SizedBox(height: 12),
                        _buildSystemPreferencesCard(),

                        const SizedBox(height: 32),

                        // Save Button
                        GestureDetector(
                          onTap: _saveSettings,
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C3827),
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
                              'SAVE CHANGES 💾',
                              style: GoogleFonts.lilitaOne(
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Logout Button
                        GestureDetector(
                          onTap: _logOut,
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDF533D), // Premium Coral-Red
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
                              'LOG OUT 🐾👋',
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
              text: 'SETTINGS',
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

  Widget _buildSectionHeader(String title) {
    return ComicText(
      text: title,
      fontSize: 16,
      fillColor: Colors.white,
      strokeWidth: 3.5,
    );
  }

  Widget _buildProfileEditCard() {
    return Container(
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
          // Name TextField
          Text(
            'DISPLAY NAME',
            style: GoogleFonts.lilitaOne(
              color: const Color(0xFF0C3827),
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2.5),
            ),
            child: TextField(
              controller: _nameController,
              style: GoogleFonts.playfairDisplay(
                color: const Color(0xFF0C3827),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your name...',
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Select Avatar Title
          Text(
            'CHOOSE PROFILE CHARACTER',
            style: GoogleFonts.lilitaOne(
              color: const Color(0xFF0C3827),
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              'assets/images/category_coffee.png',
              'assets/images/category_frappes.png',
              'assets/images/category_slushies.png',
            ].map((path) {
              bool isSel = _selectedAvatar == path;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedAvatar = path;
                  });
                },
                child: Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFFFC5C5) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: isSel ? 3.5 : 2.0,
                    ),
                  ),
                  child: Image.asset(path, fit: BoxFit.contain),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPreferencesCard() {
    return Container(
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
        children: [
          _buildToggleRow(
            title: 'Haptic Vibrations',
            subtitle: 'Tactile physical screen responses',
            value: _hapticFeedback,
            onChanged: (val) {
              setState(() {
                _hapticFeedback = val;
              });
              if (val) HapticFeedback.heavyImpact();
            },
          ),
          const SizedBox(height: 16),
          _buildToggleRow(
            title: 'Walk Paw Background',
            subtitle: 'Show walking dog paw prints dynamically',
            value: _walkPaws,
            onChanged: (val) {
              setState(() {
                _walkPaws = val;
              });
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(height: 16),
          _buildToggleRow(
            title: 'Brew Alerts',
            subtitle: 'Receive alerts when Snoopy finishes brewing',
            value: _brewNotifications,
            onChanged: (val) {
              setState(() {
                _brewNotifications = val;
              });
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(height: 16),
          _buildToggleRow(
            title: 'Weekly Vouchers',
            subtitle: 'Receive discount coupons & special codes',
            value: _joinNewsletter,
            onChanged: (val) {
              setState(() {
                _joinNewsletter = val;
              });
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lilitaOne(
                  color: const Color(0xFF0C3827),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF0C3827) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2.5),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC5C5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(0, 1)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
