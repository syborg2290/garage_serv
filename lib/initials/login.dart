import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/widgets/loginTextfield.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        width: width,
        height: height,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: height * 0.2,
                right: width * 0.01,
              ),
              child: Center(
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey,
                    ),
                    width: width * 0.77,
                    height: height * 0.06,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.02,
                        bottom: height * 0.02,
                        // right: width * 0.4,
                      ),
                      child: Center(
                        child: login("E-mail Address", false),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: height * 0.02,
                right: width * 0.01,
              ),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey,
                  ),
                  width: width * 0.77,
                  height: height * 0.06,
                  // color: Colors.black,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: height * 0.02,
                      bottom: height * 0.02,
                    ),
                    child: Center(
                      child: login("Password", true),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
