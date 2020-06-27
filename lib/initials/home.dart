import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garage/initials/auth_screen.dart';
import 'package:garage/initials/intro.dart';
import 'package:garage/models/user.dart';
import 'package:garage/services/database/userStuff.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isActive = true;
  bool isAuth = false;
  String userId;
  User currentUserm;
  bool isLoading = true;

  @override
  void initState() {
    getUserId();
    super.initState();
  }

  getUserId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    userId = pref.getString('userid');
    if (userId != null) {
      DocumentSnapshot snapshot = await getCurrentUserSe(userId);
      currentUserm = User.fromDocument(snapshot);
      setState(() {
        isAuth = true;
      });
      currentUser();
    } else {
      setState(() {
        isAuth = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  currentUser() {
    if (currentUserm.active == true) {
      setState(() {
        isActive = true;
      });
    } else {
      setState(() {
        isActive = false;
      });
    }
  }

  logoutInHome() async {
    await logoutUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      if (isAuth) {
        if (isActive) {
          return AuthScreen();
        } else {
          AwesomeDialog(
            context: context,
            animType: AnimType.SCALE,
            dialogType: DialogType.WARNING,
            body: Center(
              child: Text(
                'Your account was blocked!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            btnOkOnPress: () {
              logoutInHome();
            },
          )..show();
        }
      } else {
        return Intro();
      }
    } else {
      return Container(
        color: Colors.white,
        child: Center(
          child: circularProgress(),
        ),
      );
    }
  }
}
