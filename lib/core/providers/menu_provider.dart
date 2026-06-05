import 'package:flutter/material.dart';

class MenuProvider extends ChangeNotifier {
  bool _isExpanded = true;

  bool get isExpanded => _isExpanded;

  void toggleMenu() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}