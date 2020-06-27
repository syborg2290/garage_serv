import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/main/services/main_category.dart';
import 'package:garage/utils/palette.dart';

class Timeline extends StatefulWidget {
  Timeline({Key key}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
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
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text("Garage"),
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(
            left: 10,
          ),
          child: IconButton(
              icon: Image.asset(
                'assets/Icons/chat.png',
                color: Colors.black54,
                width: 80,
                height: 80,
              ),
              onPressed: () {}),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: IconButton(
                icon: Image.asset(
                  'assets/Icons/places.png',
                  width: 50,
                  height: 50,
                  color: Colors.black54,
                ),
                onPressed: () {}),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            MainCategory(),
          ],
        ),
      ),
    );
  }
}
