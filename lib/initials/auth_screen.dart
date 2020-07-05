import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:animator/animator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:garage/main/main_pages/activity_feed.dart';
import 'package:garage/main/main_pages/find.dart';
import 'package:garage/main/main_pages/profile.dart';
import 'package:garage/main/main_pages/timeline.dart';
import 'package:garage/main/services/sub/garageComment.dart';
import 'package:garage/messenger/chat_models/chat_user.dart';
import 'package:garage/messenger/resources/authentication_methods.dart';
import 'package:garage/models/main_services/garage.dart';
import 'package:garage/models/user.dart';
import 'package:garage/services/database/userStuff.dart';
import 'package:garage/utils/palette.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:http/http.dart' as http;
import 'package:garage/services/database/garageService.dart';
import 'package:garage/main/services/sub/garagePage.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  PageController pageController;
  int pageIndex = 0;
  String currentUserId;
  User currentUser;
  Color bottomActionBar = Palette.appColor;
  Brightness bottomBrightness = Brightness.light;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final AuthenticationMethods _authenticationMethods = AuthenticationMethods();
  bool isLoading = true;
  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');

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
        _showNotificationWithSound(msg);
      }, onResume: (Map<String, dynamic> msg) {
        _showNotificationWithSound(msg);
      }, onMessage: (Map<String, dynamic> msg) {
        _showNotificationWithSound(msg);
      });
    }

    pageController = PageController();
  }

  getCurrentUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    User currentUserObj =
        User.fromDocument(await getUserObj(pref.getString('userid')));
    await chatConfig(currentUserObj);
    setState(() {
      currentUser = currentUserObj;
      currentUserId = pref.getString('userid');
      isLoading = false;
    });
  }

  chatConfig(User currentMainUser) async {
    DocumentSnapshot chatUser =
        await _authenticationMethods.checkIsNew(currentMainUser.id);
    if (!chatUser.exists) {
      String deviceToken = await _firebaseMessaging.getToken();
      await _authenticationMethods.addDataToDb(currentMainUser, deviceToken);
    }
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
    Map<String, dynamic> re = json.decode(payload);
    if (re["data"]["type"] == "commentGarage") {
      Garage garage = await getSpecificGarage(re["data"]["typeId"]);
      if (garage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GarageComments(
                    docId: re["data"]["typeId"],
                    index: int.parse(re["data"]["index"]),
                    garage: garage,
                  )),
        );
      }
    }

    if (re["data"]["type"] == "likeGarage") {
      Garage garage = await getSpecificGarage(re["data"]["typeId"]);
      if (garage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GaragePage(
                    currentUser: currentUser,
                    docId: re["data"]["typeId"],
                    garage: garage,
                  )),
        );
      }
    }

    if (re["data"]["type"] == "follow") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(
                  profileId: re["data"]["typeId"],
                  isFromAuth: true,
                )),
      );
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future _showNotificationWithSound(Map<String, dynamic> message) async {
    String path =
        await _downloadAndSaveFile(message["data"]["userImage"], "userImage");
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      currentUser.id,
      currentUser.username,
      'your channel description',
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      importance: Importance.Max,
      priority: Priority.High,
      playSound: true,
      enableLights: true,
      color: Palette.appColor,
      ledColor: Palette.appColor,
      ledOnMs: 1000,
      ledOffMs: 500,
      sound: RawResourceAndroidNotificationSound('swiftly'),
      largeIcon: FilePathAndroidBitmap(path),
      styleInformation: MediaStyleInformation(),

      //ongoing: true,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message["data"]["username"],
      message["notification"]["body"],
      platformChannelSpecifics,
      payload: json.encode(message),
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
    return WillPopScope(
      onWillPop: () async {
        AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: Center(
            child: Text(
              'Are you sure ' + currentUser.firstname + '?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          btnOkText: 'Yes',
          btnCancelText: 'No',
          btnOkOnPress: () {
            exit(0);
          },
          btnCancelOnPress: () {},
        )..show();
        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: isLoading
              ? Center(child: circularProgress())
              : Container(
                  width: width,
                  height: height,
                  child: PageView(
                    allowImplicitScrolling: true,
                    children: <Widget>[
                      Timeline(
                        currentUser: currentUser,
                      ),
                      ActivityFeed(
                        currentUser: currentUser,
                      ),
                      Find(
                        currentUser: currentUser,
                      ),
                      Profile(
                        profileId: currentUserId,
                        isFromAuth: true,
                      ),
                    ],
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ),
          //floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ClipOval(
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 9.0,
              highlightElevation: 9.0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              heroTag: "hero1",
              child: Animator(
                duration: Duration(milliseconds: 1000),
                tween: Tween(begin: 1.4, end: 1.5),
                curve: Curves.bounceIn,
                cycles: 0,
                builder: (Animation<double> anim) => Transform.scale(
                  scale: anim.value,
                  child: Image.asset(
                    'assets/Icons/add.png',
                    color: Colors.black54,
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
                BoxShadow(
                    color: Colors.black38, spreadRadius: 0, blurRadius: 10),
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
          )),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
