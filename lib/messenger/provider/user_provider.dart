import 'package:flutter/widgets.dart';
import 'package:garage/messenger/chat_models/chat_user.dart';
import 'package:garage/messenger/resources/authentication_methods.dart';

class UserProvider with ChangeNotifier {
  ChatUser _user;
  AuthenticationMethods _authenticationMethods = AuthenticationMethods();

  ChatUser get getUser => _user;

  Future<void> refreshUser() async {
    ChatUser user = await _authenticationMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}