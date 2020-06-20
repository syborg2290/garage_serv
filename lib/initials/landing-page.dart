import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:garage/animation/fadeAnimation.dart';
import 'package:garage/initials/intro.dart';
import 'package:garage/utils/palette.dart';

import 'login.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

    // SystemChrome.setSystemUIOverlayStyle(
    //     SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          color: Colors.white,
          child: orientation == Orientation.landscape
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Image.asset(
                          'assets/designs/login-intro-landscape.png',
                          height: height * 0.93,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: height * 0.02,
                          ),
                          child: Center(
                              child: Text(
                            "Garage",
                            style: TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 38,
                              fontFamily: 'Schyler',
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * 0.1,
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              top: height * 0.00,
                            ),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
                                },
                                child: FadeAnimation(
                                  0.8,
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: height * 0.1,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: Colors.black,
                                          gradient: LinearGradient(
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                              colors: [
                                                Palette.appColor,
                                                Palette.appColor,
                                                // Colors.black,
                                              ])),
                                      width: width * 0.4,
                                      height: height * 0.4,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: height * 0.0,
                                          bottom: height * 0.00,
                                          // right: width * 0.4,
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Image.asset(
                                                "assets/Icons/user.png",
                                                width: width * 0.1,
                                                height: height * 0.3,
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width * 0.02,
                                                ),
                                                child: Text(
                                                  'Login',
                                                  style: TextStyle(
                                                    color: Color(0xffFFFFFF),
                                                    fontSize: 28,
                                                    fontFamily: 'Schyler',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
                              child: FadeAnimation(
                                0.8,
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Intro()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Palette.appColorservice,
                                    ),
                                    width: width * 0.4,
                                    height: height * 0.4,
                                    // color: Colors.black,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: height * 0.0,
                                        bottom: height * 0.00,
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              "assets/Icons/computer.png",
                                              width: width * 0.1,
                                              height: height * 0.2,
                                              color: Colors.white,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text(
                                                'Register',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Schyler'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Image.asset(
                          'assets/designs/login-intro.png',
                          height: height * 0.4,
                          width: width,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: height * 0.1,
                            left: width * 0.3,
                            right: width * 0.3,
                          ),
                          child: Center(
                              child: Text(
                            "Garage",
                            style: TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 38,
                              fontFamily: 'Schyler',
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.009,
                        right: width * 0.01,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()));
                          },
                          child: FadeAnimation(
                            0.8,
                            Padding(
                              padding: EdgeInsets.only(
                                top: height * 0.1,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.black,
                                    gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Palette.appColor,
                                          Palette.appColor,
                                          // Colors.black,
                                        ])),
                                width: width * 0.8,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: height * 0.0,
                                    bottom: height * 0.00,
                                    // right: width * 0.4,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          "assets/Icons/user.png",
                                          width: width * 0.2,
                                          height: height * 0.2,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 28,
                                              fontFamily: 'Schyler',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                        child: FadeAnimation(
                          0.8,
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Intro()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Palette.appColorservice,
                              ),
                              width: width * 0.8,
                              // color: Colors.black,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: height * 0.0,
                                  bottom: height * 0.00,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        "assets/Icons/computer.png",
                                        width: width * 0.2,
                                        height: height * 0.2,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Register',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Schyler'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
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
