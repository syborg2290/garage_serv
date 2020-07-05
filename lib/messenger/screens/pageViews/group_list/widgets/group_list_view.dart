import 'package:flutter/material.dart';
import 'package:garage/messenger/chat_models/chat_user.dart';
import 'package:garage/messenger/chat_models/group.dart';
import 'package:garage/messenger/provider/user_provider.dart';
import 'package:garage/messenger/resources/authentication_methods.dart';
import 'package:garage/messenger/resources/group_methods.dart';
import 'package:garage/messenger/screens/groupChatScreens/chat_screen.dart';
import 'package:garage/messenger/screens/groupChatScreens/widgets/cached_image.dart';
import 'package:garage/messenger/screens/pageViews/chat_list/widgets/last_message_container.dart';
import 'package:garage/messenger/screens/pageViews/group_list/widgets/online_dot_indicator.dart';
import 'package:garage/messenger/utills/universal_variables.dart';
import 'package:garage/messenger/widgets/custom_tile.dart';
import 'package:provider/provider.dart';

class GroupListView extends StatelessWidget {
  final Group group;
  final AuthenticationMethods _authenticationMethods = AuthenticationMethods();

  GroupListView(this.group);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatUser>(
      future: _authenticationMethods.getUserDetailsById(group.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ChatUser user = snapshot.data;

          return ViewLayout(
            contact: user,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final ChatUser contact;
  final GroupMethods _groupMethods = GroupMethods();

  ViewLayout({
    @required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: contact,
            ),
          )),
      title: Padding(
        padding: EdgeInsets.only(left: 8, top: 0, right: 0, bottom: 0),
        child: Text(
          (contact != null ? contact.name : null) != null ? contact.name : "..",
          style: TextStyle(
              color: UniversalVariables.textColor,
              fontFamily: "Arial",
              fontSize: 19),
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(left: 8, top: 0, right: 0, bottom: 0),
        child: LastMessageContainer(
          stream: _groupMethods.fetchLastMessageBetween(
            senderId: userProvider.getUser.uid,
            receiverId: contact.uid,
          ),
        ),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              contact.profilePhoto,
              radius: 80,
              isRound: true,
            ),
            OnlineDotIndicator(
              uid: contact.uid,
            ),
          ],
        ),
      ),
    );
  }
}
