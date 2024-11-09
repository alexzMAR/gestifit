// user_model.dart
import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String _uid = '';

  String get uid => _uid;

  void setUid(String uid) {
    _uid = uid;
    notifyListeners();
  }
}
