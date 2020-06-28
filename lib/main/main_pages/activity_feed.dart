import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/models/user.dart';

class ActivityFeed extends StatefulWidget {
   final User currentUser;
  ActivityFeed({this.currentUser,Key key}) : super(key: key);

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
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