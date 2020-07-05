import 'package:flutter/material.dart';
import 'package:garage/messenger/chat_models/chat_user.dart';
import 'package:garage/messenger/provider/user_provider.dart';
import 'package:garage/messenger/utills/universal_variables.dart';
import 'package:garage/messenger/widgets/mainAppBar.dart';
import 'package:provider/provider.dart';

import 'chatScreens/widgets/cached_image.dart';

double itemHeight;
double itemWidth;

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    Size media = MediaQuery.of(context).size;
    itemHeight = media.height;
    itemWidth = media.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: UniversalVariables.whiteColor),
        child: Column(
          children: <Widget>[
            PreferredSize(
              child: MainAppBar(
                  title: userProvider.getUser.name, back: "userprofile"),
              preferredSize: Size.fromHeight(itemHeight),
            ),
            UserDetailsBody(),
          ],
        ),
      ),
    );
  }
}

class UserDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final ChatUser user = userProvider.getUser;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CachedImage(
            user.profilePhoto,
            isRound: true,
            radius: 80,
          ),
          SizedBox(width: itemWidth * 0.01),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: UniversalVariables.blueColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: UniversalVariables.subtextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
