import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garage/messenger/chat_models/contact.dart';
import 'package:garage/messenger/provider/user_provider.dart';
import 'package:garage/messenger/resources/contact_methods.dart';
import 'package:garage/messenger/screens/callScreens/pickup/pickup_layout.dart';
import 'package:garage/messenger/screens/pageViews/contact_list/widgets/contact_list_view.dart';
import 'package:garage/messenger/screens/pageViews/contact_list/widgets/new_chat_button.dart';
import 'package:garage/messenger/utills/universal_variables.dart';
import 'package:garage/messenger/widgets/quiet_box.dart';
import 'package:provider/provider.dart';

class ContactListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.transparentColor,
        body: ContactListContainer(),
        floatingActionButton: NewChatButton(),
      ),
    );
  }
}

class ContactListContainer extends StatelessWidget {
  final ContactMethods _contactMethods = ContactMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _contactMethods.fetchContacts(
            userId: userProvider.getUser.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.documents;

              if (docList.isEmpty) {
                return ContactQuietBox();
              }
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  Contact contact = Contact.fromMap(docList[index].data);

                  return ContactListView(contact);
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
