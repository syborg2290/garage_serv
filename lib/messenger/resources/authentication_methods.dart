import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garage/messenger/chat_models/chat_user.dart';
import 'package:garage/messenger/constants/strings.dart';
import 'package:garage/messenger/enum/user_state.dart';
import 'package:garage/messenger/utills/utilities.dart';
import 'package:garage/models/user.dart';

class AuthenticationMethods {
  static final Firestore _firestore = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Firestore firestore = Firestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }

  Future<DocumentSnapshot> checkIsNew(String id) async {
    DocumentSnapshot documentSnapshot =
        await _userCollection.document(id).get();
    return documentSnapshot;
  }

  Future<ChatUser> getUserDetails() async {
    FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();

    return ChatUser.fromMap(documentSnapshot.data);
  }

  Future<ChatUser> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _userCollection.document(id).get();
      return ChatUser.fromMap(documentSnapshot.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> addDataToDb(User currentUser, String token) async {
    ChatUser user = ChatUser(
      uid: currentUser.id,
      email: currentUser.email,
      name: currentUser.username,
      profilePhoto: currentUser.userPhotoUrl,
      firebaseToken: token,
      username: currentUser.username,
    );

    firestore
        .collection(USERS_COLLECTION)
        .document(currentUser.id)
        .setData(user.toMap(user));
  }

  Future<List<ChatUser>> fetchAllUsers(FirebaseUser currentUser) async {
    List<ChatUser> userList = List<ChatUser>();

    QuerySnapshot querySnapshot =
        await firestore.collection(USERS_COLLECTION).getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != currentUser.uid) {
        userList.add(ChatUser.fromMap(querySnapshot.documents[i].data));
      }
    }
    return userList;
  }

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.document(userId).updateData({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.document(uid).snapshots();
}
