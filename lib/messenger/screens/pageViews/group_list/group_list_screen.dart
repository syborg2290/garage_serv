import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garage/messenger/chat_models/group.dart';
import 'package:garage/messenger/provider/user_provider.dart';
import 'package:garage/messenger/resources/group_methods.dart';
import 'package:garage/messenger/screens/callScreens/pickup/pickup_layout.dart';
import 'package:garage/messenger/screens/pageViews/chat_list/widgets/new_chat_button.dart';
import 'package:garage/messenger/screens/pageViews/group_list/widgets/group_list_view.dart';
import 'package:garage/messenger/utills/universal_variables.dart';
import 'package:garage/messenger/widgets/quiet_box.dart';
import 'package:provider/provider.dart';

class GroupListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.transparentColor,
        body: GroupListContainer(),
        floatingActionButton: NewGroupButton(),
      ),
    );
  }
}

class GroupListContainer extends StatelessWidget {
  final GroupMethods _groupMethods = GroupMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _groupMethods.fetchGroups(
            userId: userProvider.getUser.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.documents;

              if (docList.isEmpty) {
                return GroupQuietBox();
              }
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  Group group = Group.fromMap(docList[index].data);

                  return GroupListView(group);
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
