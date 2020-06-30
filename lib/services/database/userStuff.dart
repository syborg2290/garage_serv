import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:garage/config/collections.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<QuerySnapshot> usernameCheckSe(String username) async {
  final result =
      await userRef.where('username', isEqualTo: username).getDocuments();
  return result;
}

Future<DocumentSnapshot> getUserObj(String id) async {
  DocumentSnapshot doc = await userRef.document(id).get();
  return doc;
}

Stream<QuerySnapshot> streamingUser(String currentUserId) {
  return userRef
      .where('id', isEqualTo: currentUserId)
      .orderBy('timestamp', descending: true)
      .snapshots();
}

Future<QuerySnapshot> emailCheckSe(String email) async {
  final result = await userRef.where('email', isEqualTo: email).getDocuments();
  return result;
}

Future<AuthResult> createUserWithEmailAndPasswordSe(
    String email, String password) async {
  AuthResult result =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  return result;
}

createUserInDatabaseSe(
  String uid,
  String firstname,
  String lastname,
  String username,
  String email,
) async {
  await userRef.document(uid).setData({
    "id": uid,
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "contactNumber": null,
    "location": null,
    "dob": null,
    "userPhotoUrl": null,
    "thumbnailUserPhotoUrl": null,
    "aboutYou": null,
    "email": email,
    "isOnline": true,
    "recentOnline": timestamp,
    "active": true,
    "timestamp": timestamp,
  });
}

Future<AuthResult> signInWithEmailAndPasswordSe(
    String email, String password) async {
  var _authenticatedUser =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return _authenticatedUser;
}

Future<DocumentSnapshot> getCurrentUserSe(String uid) async {
  DocumentSnapshot snapshot = await userRef.document(uid).get();
  return snapshot;
}

createMessagingToken(String token, String currentUserId) async {
  await userRef
      .document(currentUserId)
      .updateData({"androidNotificationToken": token});
}

logoutUser() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  await FirebaseAuth.instance.signOut();
  pref.clear();
}

updateUserImage(String userId, String userImageUrl, String thumbnailUrl) async {
  userRef.document(userId).updateData({
    'userPhotoUrl': userImageUrl,
    "thumbnailUserPhotoUrl": thumbnailUrl,
  });
}

Future<String> uploadImageProfilePic(String userId, File imageFile) async {
  StorageUploadTask uploadTask =
      storageRef.child("user_image/user_$userId.jpg").putFile(imageFile);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadImageProfilePicThumbnail(
    String userId, File imageFile) async {
  StorageUploadTask uploadTask = storageRef
      .child("user_image_thumbnail/user_$userId.jpg")
      .putFile(imageFile);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

updateProfile(String userId, dynamic obj) {
  userRef.document(userId).updateData(obj);
}

Future<DocumentSnapshot> checkIfFollowingSe(
    String profileId, String currentUserId) async {
  DocumentSnapshot doc = await followersRef
      .document(profileId)
      .collection('userFollowers')
      .document(currentUserId)
      .get();

  return doc;
}

Future<QuerySnapshot> getFollowersSe(String profileId) async {
  QuerySnapshot snapshot = await followersRef
      .document(profileId)
      .collection('userFollowers')
      .getDocuments();
  return snapshot;
}

Future<QuerySnapshot> getFollowingSe(String profileId) async {
  QuerySnapshot snapshot = await followingRef
      .document(profileId)
      .collection('userFollowing')
      .getDocuments();
  return snapshot;
}

handleUnfollowUserSe(String profileId, String currentUserId) {
  //followers deleted
  followersRef
      .document(profileId)
      .collection('userFollowers')
      .document(currentUserId)
      .get()
      .then((doc) {
    if (doc.exists) {
      doc.reference.delete();
    }
  });
  //following deleted
  followingRef
      .document(currentUserId)
      .collection('userFollowing')
      .document(profileId)
      .get()
      .then((doc) {
    if (doc.exists) {
      doc.reference.delete();
    }
  });

  //remove activity feed
  activityFeedRef
      .document(profileId)
      .collection('feedItems')
      .document(currentUserId)
      .get()
      .then((doc) {
    if (doc.exists) {
      doc.reference.delete();
    }
  });
}

handleFollowUserSe(String profileId, String currentUserId,
    String currentUsername, String currentPhotoUrl) {
  //followers update
  followersRef
      .document(profileId)
      .collection('userFollowers')
      .document(currentUserId)
      .setData({});
  //following update
  followingRef
      .document(currentUserId)
      .collection('userFollowing')
      .document(profileId)
      .setData({});

  var uuid = Uuid();
  //add activity feed
  activityFeedRef
      .document(profileId)
      .collection('feedItems')
      .document(currentUserId)
      .setData({
    "id": uuid.v1().toString() + new DateTime.now().toString(),
    "userId": currentUserId,
    "username": currentUsername,
    "userProfileImage": currentPhotoUrl,
    "type": "follow",
    "typeId": profileId,
    "read": false,
    "timestamp": timestamp,
  });
}
