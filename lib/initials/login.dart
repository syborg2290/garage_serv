import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/initials/home.dart';
import 'package:garage/initials/intro.dart';
import 'package:garage/services/database/userStuff.dart';
import 'package:garage/utils/flush_bars.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool secureText = true;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      textDirection: TextDirection.ltr,
      isDismissible: false,
      customBody: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        width: 100,
        height: 100,
        child: Center(
          child: flashProgress(),
        ),
      ),
      showLogs: false,
    );
  }

  loginFunc() async {
    if (email.text.trim() != "") {
      if (password.text.trim() != "") {
        if (RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email.text.trim())) {
          pr.show();
          try {
            AuthResult _authenticatedUser = await signInWithEmailAndPasswordSe(
                email.text.trim(), password.text.trim());
            if (_authenticatedUser.user.uid != null) {
              final SharedPreferences pref =
                  await SharedPreferences.getInstance();

              pref.setString('userid', _authenticatedUser.user.uid);
              pr.hide().whenComplete(() {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Home()));
              });
            } else {
              pr.hide();
              GradientSnackBar.showMessage(context, "Sorry! no account found!");
            }
          } catch (e) {
            if (e.code == "ERROR_USER_NOT_FOUND") {
              pr.hide();
              GradientSnackBar.showMessage(context, "Sorry! no account found!");
            }
          }
        } else {
          GradientSnackBar.showMessage(context, "Please provide valid email!");
        }
      } else {
        GradientSnackBar.showMessage(context, "Password is required!");
      }
    } else {
      GradientSnackBar.showMessage(context, "Email is required!");
    }
  }

  Widget login(String textHint, TextEditingController _controller) {
    return TextField(
      textAlign: TextAlign.center,
      controller: _controller,
      decoration: InputDecoration(
        hintText: textHint,
        border: InputBorder.none,
        hintStyle: TextStyle(),
      ),
    );
  }

  Widget loginPasswordField(
      String textHint, TextEditingController _controller) {
    return TextField(
      textAlign: TextAlign.center,
      controller: _controller,
      obscureText: secureText,
      decoration: InputDecoration(
        hintText: textHint,
        border: InputBorder.none,
        hintStyle: TextStyle(),
        suffixIcon: GestureDetector(
            onTap: () {
              if (secureText) {
                setState(() {
                  secureText = false;
                });
              } else {
                setState(() {
                  secureText = true;
                });
              }
            },
            child: Icon(!secureText ? Icons.security : Icons.remove_red_eye)),
      ),
    );
  }

  Widget loginTextField(double width, double height, String hint,
      bool secureText, TextEditingController _controller) {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.04,
        right: width * 0.1,
        left: width * 0.1,
      ),
      child: Center(
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            width: width * 0.9,
            height: height * 0.09,
            child: Padding(
              padding: EdgeInsets.only(
                top: height * 0.02,
                bottom: height * 0.02,
                // right: width * 0.4,
              ),
              child: Center(
                child: secureText
                    ? loginPasswordField(hint, _controller)
                    : login(hint, _controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Intro()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
              icon: Image.asset(
                'assets/Icons/left-arrow.png',
                width: width * 0.07,
                height: height * 0.07,
              ),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Intro()));
              }),
        ),
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: width,
            height: height,
            child: Column(
              children: <Widget>[
                Image.asset('assets/designs/login-intro.png'),
                loginTextField(width, height, "Email address", false, email),
                loginTextField(width, height, "Password", true, password),
                Padding(
                  padding: EdgeInsets.all(height * 0.05),
                  child: Container(
                    width: width * 0.9,
                    height: height * 0.09,
                    child: FlatButton(
                      onPressed: () async {
                        await loginFunc();
                      },
                      child: Center(
                          child: Text("Login",
                              style: TextStyle(
                                fontSize: 19,
                                color: Colors.black,
                              ))),
                      color: Palette.appColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                          side: BorderSide(
                            color: Palette.appColor,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
