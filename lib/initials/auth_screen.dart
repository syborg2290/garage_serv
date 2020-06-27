import 'dart:io';

import 'package:animator/animator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:garage/main/main_pages/activity_feed.dart';
import 'package:garage/main/main_pages/find.dart';
import 'package:garage/main/main_pages/profile.dart';
import 'package:garage/main/main_pages/timeline.dart';
import 'package:garage/services/database/userStuff.dart';
import 'package:garage/utils/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  PageController pageController;
  int pageIndex = 0;
  String currentUserId;
  Color bottomActionBar = Palette.appColor;
  Brightness bottomBrightness = Brightness.light;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    getCurrentUser();

    initializeLocalNotification();

    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          IosNotificationSettings(alert: true, badge: true, sound: true));
      _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
        print('Settings Registered:$settings');
      });
    } else {
      _firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
        _showNotificationWithSound(msg['notification']['body']);
      }, onResume: (Map<String, dynamic> msg) {
        _showNotificationWithSound(msg['notification']['body']);
      }, onMessage: (Map<String, dynamic> msg) {
        _showNotificationWithSound(msg['notification']['body']);
      });
    }

    pageController = PageController();
  }

  getCurrentUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await configureFirebaseMessaging(pref.getString('userid'));
    setState(() {
      currentUserId = pref.getString('userid');
    });
  }

  configureFirebaseMessaging(String currentUserId) async {
    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      createMessagingToken(token, currentUserId);
    });
  }

  initializeLocalNotification() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // If you have skipped STEP 3 then change app_icon to @mipmap/ic_launcher
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  Future _showNotificationWithSound(String message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      enableVibration: true,
      playSound: true,
      importance: Importance.Max,
      priority: Priority.High,

      //ongoing: true,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification service of wlkmo',
      message,
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: width,
          height: height,
          child: PageView(
            allowImplicitScrolling: true,
            children: <Widget>[
              Timeline(),
              ActivityFeed(),
              Find(),
              Profile(
                profileId: currentUserId,
              ),
            ],
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
        //floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: ClipOval(
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            elevation: 9.0,
            highlightElevation: 9.0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            heroTag: "hero1",
            child: Animator(
              duration: Duration(milliseconds: 1000),
              tween: Tween(begin: 1.0, end: 1.5),
              curve: Curves.bounceIn,
              cycles: 0,
              builder: (Animation<double> anim) => Transform.scale(
                scale: anim.value,
                child: Image.asset(
                  'assets/Icons/add.png',
                  color: Colors.black,
                  width: 36,
                  height: 36,
                ),
              ),
            ),
            onPressed: () {},
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(40), topLeft: Radius.circular(40)),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
            child: BottomAppBar(
              shape: CircularNotchedRectangle(),
              notchMargin: 6.0,
              elevation: 9.0,
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 55,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      iconSize: pageIndex == 0 ? 40.0 : 30.0,
                      padding: EdgeInsets.only(left: 28.0),
                      icon: Image(
                        image: AssetImage("assets/Icons/main-page.png"),
                        color: pageIndex == 0 ? Colors.black : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(0);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 1 ? 40.0 : 30.0,
                      padding: EdgeInsets.only(right: 28.0),
                      icon: Image(
                        image: AssetImage("assets/Icons/notification.png"),
                        color: pageIndex == 1 ? Colors.black : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(1);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 2 ? 40.0 : 30.0,
                      padding: EdgeInsets.only(left: 28.0),
                      icon: Image(
                        image: AssetImage("assets/Icons/search.png"),
                        color: pageIndex == 2 ? Colors.black : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(2);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 3 ? 40.0 : 30.0,
                      padding: EdgeInsets.only(right: 28.0),
                      icon: Image(
                        image: AssetImage("assets/Icons/person.png"),
                        color: pageIndex == 3 ? Colors.black : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(3);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
