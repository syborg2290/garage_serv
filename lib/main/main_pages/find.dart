import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/models/user.dart';

class Find extends StatefulWidget {
  final User currentUser;
  Find({this.currentUser, Key key}) : super(key: key);

  @override
  _FindState createState() => _FindState();
}

class _FindState extends State<Find> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Container();
  }
}
