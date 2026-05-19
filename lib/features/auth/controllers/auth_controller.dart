import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  bool _isSignUp = false;
  String _selectedSpecialty = 'MATCHA';
  bool _otpSent = false;
  bool _isVerifying = false;

  // Getters
  bool get isSignUp => _isSignUp;
  String get selectedSpecialty => _selectedSpecialty;
  bool get otpSent => _otpSent;
  bool get isVerifying => _isVerifying;

  // Methods
  void setSignUp(bool val) {
    _isSignUp = val;
    _otpSent = false;
    notifyListeners();
  }

  void setSelectedSpecialty(String val) {
    _selectedSpecialty = val;
    notifyListeners();
  }

  void setOtpSent(bool val) {
    _otpSent = val;
    notifyListeners();
  }

  void setIsVerifying(bool val) {
    _isVerifying = val;
    notifyListeners();
  }
}
