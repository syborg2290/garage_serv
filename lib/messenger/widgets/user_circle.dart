import 'package:flutter/material.dart';
import 'package:garage/main/main_pages/profile.dart';
import 'package:garage/messenger/provider/user_provider.dart';
import 'package:garage/messenger/utills/universal_variables.dart';
import 'package:garage/messenger/utills/utilities.dart';
import 'package:garage/models/user.dart';
import 'package:provider/provider.dart';

class UserCircle extends StatelessWidget {
  final GestureTapCallback onTap;
  final User currentMainUser;

  UserCircle({
    this.currentMainUser,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return GestureDetector(
        onTap: () {},
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: UniversalVariables.appBarUserIcon,
          ),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  Utils.getInitials(userProvider.getUser.name),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: UniversalVariables.whiteColor,
                    fontSize: 13,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: UniversalVariables.appBarUserIcon, width: 1),
                      color: UniversalVariables.onlineDotColor),
                ),
              )
            ],
          ),
        ));
  }
}
