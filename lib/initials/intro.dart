import 'package:flutter/material.dart';

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

    return Scaffold(
      body: Container(
        color: Colors.lightBlueAccent,
        width: width,
        height: height,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: height * 0.1,
                right: width * 0,
                left: width * 0.5,
              ),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "I'm already Here",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
