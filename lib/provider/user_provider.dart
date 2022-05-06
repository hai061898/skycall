import 'package:flutter/material.dart';
import 'package:skype_c/data/firebase/auth_methods.dart.dart';
import 'package:skype_c/data/models/use_respone.dart' as model;

class UserProvider extends ChangeNotifier {
  late model.User _user;
  // ignore: prefer_final_fields
  AuthMethods _authMethods = AuthMethods();

  model.User get getUser => _user;

  Future<void> refreshUser() async {
    model.User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
