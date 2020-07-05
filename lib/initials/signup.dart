import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/initials/auth_screen.dart';
import 'package:garage/services/database/userStuff.dart';
import 'package:garage/utils/flush_bars.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool secureText = true;
  bool consecureText = true;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController conPassword = TextEditingController();

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
          child: Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 10,
            ),
            child: Column(
              children: <Widget>[
                flashProgress(),
                Text("creating your account...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(129, 165, 168, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
      ),
      showLogs: false,
    );
  }

  signupFunc() async {
    if (fname.text.trim() != "") {
      if (lname.text.trim() != "") {
        if (email.text.trim() != "") {
          if (password.text.trim() != "") {
            if (conPassword.text.trim() != "") {
              if (RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(email.text.trim())) {
                if (password.text.trim() == conPassword.text.trim()) {
                  try {
                    pr.show();
                    String username =
                        fname.text.trim() + " " + lname.text.trim();
                    QuerySnapshot snapUser = await usernameCheckSe(username);
                    QuerySnapshot snapEmail =
                        await emailCheckSe(email.text.trim());

                    if (snapEmail.documents.isEmpty) {
                      if (snapUser.documents.isEmpty) {
                        AuthResult result =
                            await createUserWithEmailAndPasswordSe(
                                email.text.trim(), password.text.trim());
                        await createUserInDatabaseSe(
                            result.user.uid,
                            fname.text.trim(),
                            lname.text.trim(),
                            username,
                            email.text.trim());
                        final SharedPreferences pref =
                            await SharedPreferences.getInstance();

                        pref.setString('userid', result.user.uid);

                        _firebaseMessaging.getToken().then((token) {
                          print("Firebase Messaging Token: $token\n");
                          createMessagingToken(token, result.user.uid);
                        });

                        pr.hide().whenComplete(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AuthScreen()),
                          );
                        });
                      } else {
                        pr.hide();
                        GradientSnackBar.showMessage(
                            context, "Firstname and Lastname already used!");
                      }
                    } else {
                      pr.hide();
                      GradientSnackBar.showMessage(
                          context, "Email address already used!");
                    }
                  } catch (e) {
                    if (e.code == "ERROR_WEAK_PASSWORD") {
                      pr.hide();
                      GradientSnackBar.showMessage(context,
                          "Weak password, password should be at least 6 characters!");
                    }
                  }
                } else {
                  GradientSnackBar.showMessage(
                      context, "Passwords are not matched!");
                }
              } else {
                GradientSnackBar.showMessage(context, "Provide valid email!");
              }
            } else {
              GradientSnackBar.showMessage(
                  context, "Confirm password is required");
            }
          } else {
            GradientSnackBar.showMessage(context, "Password is required");
          }
        } else {
          GradientSnackBar.showMessage(context, "Email is required");
        }
      } else {
        GradientSnackBar.showMessage(context, "Lastname is required");
      }
    } else {
      GradientSnackBar.showMessage(context, "Firstname is required");
    }
  }

  Widget signup(String textHint, TextEditingController _controller) {
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

  Widget signupPasswordField(
      String textHint, TextEditingController _controller) {
    return TextField(
      textAlign: TextAlign.center,
      controller: _controller,
      obscureText: textHint == "Confirm password" ? consecureText : secureText,
      decoration: InputDecoration(
        hintText: textHint,
        border: InputBorder.none,
        hintStyle: TextStyle(),
        suffixIcon: GestureDetector(
            onTap: () {
              if (textHint == "Confirm password") {
                if (consecureText) {
                  setState(() {
                    consecureText = false;
                  });
                } else {
                  setState(() {
                    consecureText = true;
                  });
                }
              } else {
                if (secureText) {
                  setState(() {
                    secureText = false;
                  });
                } else {
                  setState(() {
                    secureText = true;
                  });
                }
              }
            },
            child: textHint == "Confirm password"
                ? Icon(!consecureText ? Icons.security : Icons.remove_red_eye)
                : Icon(!secureText ? Icons.security : Icons.remove_red_eye)),
      ),
    );
  }

  Widget signupTextField(double width, double height, String hint,
      bool secureText, TextEditingController _controller) {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.03,
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
                    ? signupPasswordField(hint, _controller)
                    : signup(hint, _controller),
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
    var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        title: Text(
          "Create account",
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
          ),
        ),
        elevation: 0.0,
        leading: IconButton(
            icon: Image.asset(
              'assets/Icons/left-arrow.png',
              width: width * 0.07,
              height: height * 0.07,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: height * 0.03),
          child: Column(
            children: <Widget>[
              signupTextField(width, height, "Firstname", false, fname),
              signupTextField(width, height, "Lastname", false, lname),
              signupTextField(width, height, "Email address", false, email),
              signupTextField(width, height, "Password", true, password),
              signupTextField(
                  width, height, "Confirm password", true, conPassword),
              Padding(
                padding:
                    EdgeInsets.only(top: height * 0.05, bottom: height * 0.05),
                child: Container(
                  width: width * 0.9,
                  height: height * 0.09,
                  child: FlatButton(
                    onPressed: () async {
                      await signupFunc();
                    },
                    child: Center(
                        child: Text("Signup",
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
    );
  }
}
