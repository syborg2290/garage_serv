import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/messenger/provider/user_provider.dart';
import 'package:garage/messenger/resources/authentication_methods.dart';
import 'package:garage/messenger/screens/dashboard.dart';
import 'package:garage/models/user.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:provider/provider.dart';
import 'provider/image_upload_provider.dart';

class MainScreen extends StatefulWidget {
  final User userMain;
  MainScreen({Key key, this.userMain}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthenticationMethods _authenticationMethods = AuthenticationMethods();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static const platform = const MethodChannel('TokenChannel');
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
    });
    isLoading = false;
  }

  // Future<void> sendData(String dtoken) async {
  //   String message;
  //   try {
  //     message = await platform.invokeMethod(dtoken);
  //     print(message);
  //   } on PlatformException catch (e) {
  //     message = "Failed to get data from native : '${e.message}'.";
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? circularProgress()
        : MultiProvider(
            providers: [
                ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
                ChangeNotifierProvider(create: (_) => UserProvider()),
              ],
            child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Chat App',
                theme: ThemeData(brightness: Brightness.dark),
                home: Dashboard(
                  currentuserMain: widget.userMain,
                )));
  }
}
