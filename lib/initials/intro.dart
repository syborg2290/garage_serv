import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/animation/fadeAnimation.dart';
import 'package:garage/initials/login.dart';
import 'package:garage/utils/palette.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
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
              Navigator.pop(context);
            }),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        width: width,
        height: height,
        child: Column(
          children: <Widget>[
            // FadeAnimation(0.8, Image.asset("assets/designs/avatar-up2.png")),
            // Padding(
            //   padding: EdgeInsets.only(
            //     top: height * 0.01,
            //     right: width * 0.01,
            //     left: width * 0.5,
            //   )
            // ),
            Padding(
              padding: EdgeInsets.only(
                top: height * 0.009,
                right: width * 0.01,
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
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
                            top: height * 0.02,
                            bottom: height * 0.02,
                            // right: width * 0.4,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/Icons/normal.png",
                                  width: width * 0.2,
                                  height: height * 0.2,
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Vehicle',
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Palette.appColorservice,
                    ),
                    width: width * 0.8,
                    // color: Colors.black,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.002,
                        bottom: height * 0.01,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              "assets/Icons/service.png",
                              width: width * 0.2,
                              height: height * 0.2,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Service',
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
            Padding(
              padding: EdgeInsets.only(
                top: height * 0.08,
              ),
              child:
                  FadeAnimation(0.8, Image.asset("assets/designs/avatar.png")),
            ),
          ],
        ),
      ),
    );
  }
}