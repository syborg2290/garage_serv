import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garage/messenger/chat_models/chat_user.dart';
import 'package:garage/messenger/enum/user_state.dart';
import 'package:garage/messenger/resources/authentication_methods.dart';
import 'package:garage/messenger/utills/universal_variables.dart';
import 'package:garage/messenger/utills/utilities.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final AuthenticationMethods _authenticationMethods = AuthenticationMethods();

  OnlineDotIndicator({
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return UniversalVariables.offlineDotColor;
        case UserState.Online:
          return UniversalVariables.onlineDotColor;
        case UserState.Waiting:
          return UniversalVariables.waitingDotColor;
        default:
          return UniversalVariables.waitingDotColor;
      }
    }

    return Align(
      alignment: Alignment.topRight,
      child: StreamBuilder<DocumentSnapshot>(
        stream: _authenticationMethods.getUserStream(
          uid: uid,
        ),
        builder: (context, snapshot) {
          ChatUser user;

          if (snapshot.hasData && snapshot.data.data != null) {
            user = ChatUser.fromMap(snapshot.data.data);
          }

          return Container(
            height: 10,
            width: 10,
            margin: EdgeInsets.only(right: 2, top: 46),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColor(user?.state),
            ),
          );
        },
      ),
    );
  }
}
