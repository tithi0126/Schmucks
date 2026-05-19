import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/comic_text.dart';
import '../../../widgets/polka_dot_background.dart';
import '../controllers/auth_controller.dart';
import '../../shop/views/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final AuthController _controller = AuthController();
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  
  // OTP Input Controllers & Focus Nodes
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _seedDefaultUser();
  }

  void _seedDefaultUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Seed default test user (Phone: 1234567890, Name: Vinay Shah)
    if (!prefs.containsKey('user_name_1234567890')) {
      await prefs.setString('user_name_1234567890', 'Vinay Shah');
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
    _phoneController.dispose();
    _nameController.dispose();
    _phoneFocusNode.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      HapticFeedback.vibrate();
      _showErrorSnackBar('Please enter a valid 10-digit mobile number!');
      return;
    }

    HapticFeedback.mediumImpact();

    // Check if the phone number is registered
    final prefs = await SharedPreferences.getInstance();
    final nameKey = 'user_name_$phone';
    if (!prefs.containsKey(nameKey)) {
      HapticFeedback.vibrate();
      _showErrorSnackBar('This phone number is not registered. Please Join the Club first!');
      return;
    }

    _controller.setOtpSent(true);

    // Focus on the first OTP digit
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _otpFocusNodes[0].requestFocus();
      }
    });
  }

  void _submitSignUp() {
    if (_nameController.text.trim().isEmpty) {
      HapticFeedback.vibrate();
      _showErrorSnackBar('Please enter your full name to join!');
      return;
    }
    if (_phoneController.text.length < 10) {
      HapticFeedback.vibrate();
      _showErrorSnackBar('Please enter a valid 10-digit mobile number!');
      return;
    }

    HapticFeedback.mediumImpact();
    _controller.setOtpSent(true);

    // Focus on the first OTP digit
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _otpFocusNodes[0].requestFocus();
      }
    });
  }

  void _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp != "0000") {
      HapticFeedback.vibrate();
      _showErrorSnackBar("Incorrect OTP! Hint: Use '0000' for testing.");
      return;
    }

    HapticFeedback.lightImpact();
    _controller.setIsVerifying(true);

    final prefs = await SharedPreferences.getInstance();
    final phone = _phoneController.text.trim();

    // Simulate verification delay & proceed to main dashboard
    Timer(const Duration(seconds: 1), () async {
      if (mounted) {
        _controller.setIsVerifying(false);
        
        String finalName = 'Vinay Shah';

        if (_controller.isSignUp) {
          finalName = _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : 'Vinay Shah';
          // Save registration locally to SharedPreferences
          await prefs.setString('user_name_$phone', finalName);
        } else {
          // Retrieve registered user
          finalName = prefs.getString('user_name_$phone') ?? 'Vinay Shah';
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 850),
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(userName: finalName),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
              );
              var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeIn),
              );
              return FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(scale: scaleAnimation, child: child),
              );
            },
          ),
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0C3827),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black, width: 2.5),
        ),
        content: Text(
          message,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFC5C5), // Soft pink brand background
      body: Stack(
        children: [
          // Premium subtle polka-dot background grid
          const PolkaDotBackground(),

          // Main Layout Scroll view
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Snoopy graphic with custom cartoon speech bubble
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/snoopy_welcome.png',
                          height: size.height * 0.26,
                          fit: BoxFit.contain,
                        )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .moveY(begin: -5, end: 5, duration: 1800.ms, curve: Curves.easeInOut),
                        
                        const SizedBox(height: 8),

                        // Snoopy Comic Speech Bubble
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F6EE), // warm cream paper
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(2.5, 2.5),
                              ),
                            ],
                          ),
                          child: Text(
                            _controller.otpSent 
                                ? "Checking your credentials... 🕒"
                                : (_controller.isSignUp 
                                    ? "Come, join the club! 🍵" 
                                    : "Welcome back, Schmuck! ☕"),
                            style: GoogleFonts.lilitaOne(
                              color: const Color(0xFF0C3827),
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                        .animate(key: ValueKey('${_controller.isSignUp}-${_controller.otpSent}'))
                        .scale(begin: const Offset(0.9, 0.9), curve: Curves.elasticOut, duration: 400.ms),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Redesigned Neobrutalist Dual Switch
                    _buildToggleSwitch(),

                    const SizedBox(height: 24),

                    // Interactive login/signup animated switcher
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.15, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: _controller.otpSent
                          ? _buildOtpInput(size)
                          : (_controller.isSignUp 
                              ? _buildSignUpInput(size) 
                              : _buildPhoneInput(size)),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // REDESIGNED NEOBRUTALIST TOGGLE SWITCH
  Widget _buildToggleSwitch() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF0C3827), // Forest Green base
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 4.5),
          ),
        ],
      ),
      child: Row(
        children: [
          // LOG IN TAB
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_controller.isSignUp) {
                  HapticFeedback.mediumImpact();
                  _controller.setSignUp(false);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !_controller.isSignUp ? const Color(0xFFFFC5C5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'LOG IN',
                  style: GoogleFonts.lilitaOne(
                    color: !_controller.isSignUp ? Colors.black : Colors.white60,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
          
          // SIGN UP TAB
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_controller.isSignUp) {
                  HapticFeedback.mediumImpact();
                  _controller.setSignUp(true);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _controller.isSignUp ? const Color(0xFFFFC5C5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'JOIN CLUB',
                  style: GoogleFonts.lilitaOne(
                    color: _controller.isSignUp ? Colors.black : Colors.white60,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PHONE NUMBER INPUT CONTAINER
  Widget _buildPhoneInput(Size size) {
    return Column(
      key: const ValueKey('phone_input_key'),
      children: [
        // Title Text
        const ComicText(
          text: 'LOG IN TO SCHMUCKS',
          fontSize: 22,
          fillColor: Colors.white,
          strokeColor: Colors.black,
          strokeWidth: 4.5,
          shadowColor: Color(0xFFDF533D),
          shadowOffset: Offset(2, 2),
        ),
        
        const SizedBox(height: 16),

        // Phone Input Container
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF0C3827), // Forest Green
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 4.5),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.phone_android_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Container(
                width: 3.5,
                height: 28,
                color: Colors.black,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: Colors.black,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    hintStyle: GoogleFonts.playfairDisplay(
                      color: Colors.white70,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Send OTP Button
        GestureDetector(
          onTap: _sendOTP,
          child: Container(
            width: double.infinity,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF0C3827),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 3.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 4.5),
                ),
              ],
            ),
            child: Text(
              'SEND OTP',
              style: GoogleFonts.lilitaOne(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // SIGN UP FORM WITH PERSONALIZED FLAVOUR PICKER
  Widget _buildSignUpInput(Size size) {
    return Column(
      key: const ValueKey('signup_input_key'),
      children: [
        const ComicText(
          text: 'CREATE ACCOUNT',
          fontSize: 22,
          fillColor: Colors.white,
          strokeColor: Colors.black,
          strokeWidth: 4.5,
          shadowColor: Color(0xFFDF533D),
          shadowOffset: Offset(2, 2),
        ),
        
        const SizedBox(height: 16),

        // Full Name Field
        Container(
          height: 56,
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
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.face_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Container(
                width: 3.5,
                height: 28,
                color: Colors.black,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'Your Full Name',
                    hintStyle: GoogleFonts.playfairDisplay(
                      color: Colors.white70,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // Mobile Number Field
        Container(
          height: 56,
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
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.phone_android_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Container(
                width: 3.5,
                height: 28,
                color: Colors.black,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: Colors.black,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    hintStyle: GoogleFonts.playfairDisplay(
                      color: Colors.white70,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Specialty Selector Card
        _buildSpecialtyChoice(),

        const SizedBox(height: 22),

        // Join Club Button
        GestureDetector(
          onTap: _submitSignUp,
          child: Container(
            width: double.infinity,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF0C3827),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 3.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 4.5),
                ),
              ],
            ),
            child: Text(
              'JOIN THE CLUB! 🚀',
              style: GoogleFonts.lilitaOne(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // SPECIALTY PILL CHIPS SELECTOR
  Widget _buildSpecialtyChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            'CHOOSE YOUR FAVORITE SPECIALTY:',
            style: GoogleFonts.lilitaOne(
              color: const Color(0xFF0C3827),
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['MATCHA', 'COFFEE', 'SAVOURY'].map((item) {
            bool isSel = _controller.selectedSpecialty == item;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _controller.setSelectedSpecialty(item);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF0C3827) : const Color(0xFFF9F6EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: isSel ? const Offset(1, 2) : const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.lilitaOne(
                      color: isSel ? const Color(0xFFFFC5C5) : const Color(0xFF0C3827),
                      fontSize: 11,
                      letterSpacing: 0.3,
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

  // OTP INTERACTIVE INPUT GRID
  Widget _buildOtpInput(Size size) {
    return Column(
      key: const ValueKey('otp_input_key'),
      children: [
        const ComicText(
          text: 'VERIFY CODE',
          fontSize: 22,
          fillColor: Colors.white,
          strokeColor: Colors.black,
          strokeWidth: 4.5,
          shadowColor: Color(0xFFDF533D),
          shadowOffset: Offset(2, 2),
        ),
        
        const SizedBox(height: 12),

        Text(
          'Verification Code sent to +91 ${_phoneController.text.substring(0, 5)}-${_phoneController.text.substring(5)}',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF0C3827),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        
        const SizedBox(height: 20),

        // OTP inputs row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _otpFocusNodes[index].hasFocus ? const Color(0xFF0C3827) : Colors.black,
                  width: _otpFocusNodes[index].hasFocus ? 4.0 : 3.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: GoogleFonts.lilitaOne(
                  color: Colors.black,
                  fontSize: 24,
                ),
                cursorColor: const Color(0xFF0C3827),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    if (index < 3) {
                      _otpFocusNodes[index + 1].requestFocus();
                    } else {
                      _otpFocusNodes[index].unfocus();
                      _verifyOTP(); // Auto-verify on final digit
                    }
                  } else {
                    if (index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                  }
                  setState(() {});
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 26),

        // Verify OTP Button
        GestureDetector(
          onTap: _verifyOTP,
          child: Container(
            width: double.infinity,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF0C3827),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 3.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 4.5),
                ),
              ],
            ),
            child: _controller.isVerifying 
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'VERIFY & LOGIN',
                  style: GoogleFonts.lilitaOne(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 0.8,
                  ),
                ),
          ),
        ),

        const SizedBox(height: 14),

        // Go Back / Change Number Button
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _controller.setOtpSent(false);
            Timer(const Duration(milliseconds: 300), () {
              if (mounted) {
                _phoneFocusNode.requestFocus();
              }
            });
          },
          child: Text(
            'Change Mobile Number',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFF0C3827),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF0C3827),
            ),
          ),
        ),
      ],
    );
  }
}
