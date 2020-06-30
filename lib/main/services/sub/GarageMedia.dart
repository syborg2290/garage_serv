import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/models/main_services/garage.dart';

class GarageMedia extends StatefulWidget {
  final Garage garage;
  GarageMedia({this.garage, Key key}) : super(key: key);

  @override
  _GarageMediaState createState() => _GarageMediaState();
}

class _GarageMediaState extends State<GarageMedia> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

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
        title: Text(
          widget.garage.garageName,
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[],
        ),
      ),
    );
  }
}
