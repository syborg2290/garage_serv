import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:garage/config/collections.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    "email": email,
    "services": null,
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


updateProfile(String userId,dynamic obj){
   userRef.document(userId).updateData(obj);
}