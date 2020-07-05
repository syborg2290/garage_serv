import 'package:flutter/material.dart';
import 'package:garage/messenger/screens/contact_search_screen.dart';
import 'package:garage/messenger/utills/universal_variables.dart';

class NewChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ContactSearchScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
            color: UniversalVariables.fabColor,
            borderRadius: BorderRadius.circular(50)),
        child: Icon(
          Icons.add_comment,
          color: Colors.white,
          size: 25,
        ),
        padding: EdgeInsets.all(15),
      ),
    );
  }
}
