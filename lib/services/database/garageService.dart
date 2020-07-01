import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:garage/config/collections.dart';
import 'package:garage/models/activityFeed.dart';
import 'package:garage/models/main_services/garage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as Path;

Future<QuerySnapshot> checkGarageNameAlreadyExist(String garageName) async {
  final result =
      await garageRef.where('garageName', isEqualTo: garageName).getDocuments();
  return result;
}

Stream<QuerySnapshot> streamingGarage() {
  return garageRef.orderBy('timestamp', descending: true).snapshots();
}

Stream<QuerySnapshot> streamingSingleGarage(String garageId) {
  return garageRef
      .where('id', isEqualTo: garageId)
      .orderBy('timestamp', descending: true)
      .snapshots();
}

Future<QuerySnapshot> garagesAll() async {
  final result = await garageRef.getDocuments();
  return result;
}

addAGarage(
  String currentUserId,
  String garageName,
  String garageContactNumber,
  double latitude,
  double longitude,
  dynamic vehicleTypes,
  dynamic vehicleEngineType,
  dynamic preferredRepair,
  dynamic eachRepairPrice,
  dynamic mediaOrig,
  dynamic mediaThumb,
  dynamic mediaTypes,
  String garageAddress,
  Timestamp openAt,
  Timestamp closeAt,
  dynamic closedDays,
  String currencyType,
) {
  var uuid = Uuid();
  garageRef.add({
    "id": uuid.v1().toString() + new DateTime.now().toString(),
    "addedId": currentUserId,
    "garageName": garageName,
    "garageContactNumber": garageContactNumber,
    "garageAddress": garageAddress,
    "latitude": latitude,
    "longitude": longitude,
    "vehiclesType": vehicleTypes,
    "vehicleEngineType": vehicleEngineType,
    "preferredRepair": preferredRepair,
    "preferredRepairForPrice": eachRepairPrice,
    "currencyType": currencyType,
    "mediaOrig": mediaOrig,
    "mediaThumb": mediaThumb,
    "mediaTypes": mediaTypes,
    "openAt": openAt,
    "closeAt": closeAt,
    "closedDays": closedDays,
    "timestamp": timestamp,
  });
}

updateMediaForGarage(String garageId, String mediaOrig, String mediaThumb,
    String type, String docId) async {
  final result =
      await garageRef.where('id', isEqualTo: garageId).getDocuments();
  Garage gar = Garage.fromDocument(result.documents[0]);
  List mediaOrigLi = gar.mediaOrig;
  List mediaThumbLi = gar.mediaThumb;
  List mediaTypesLi = gar.mediaTypes;
  mediaOrigLi.add(mediaOrig);
  mediaThumbLi.add(mediaThumb);
  mediaTypesLi.add(type);

  await garageRef.document(docId).updateData({
    "mediaOrig": mediaOrigLi,
    "mediaThumb": mediaThumbLi,
    "mediaTypes": mediaTypesLi,
  });
}

Future<String> uploadImageToGarage(File imageFile) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();

  StorageUploadTask uploadTask =
      storageRef.child("garage/garage_image/user_$path.jpg").putFile(imageFile);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadThumbImageToGarage(File imageFile) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();

  StorageUploadTask uploadTask = storageRef
      .child("garage/garage_thumbImage/user_$path.jpg")
      .putFile(imageFile);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadVideoToGarage(File video) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();
  StorageUploadTask uploadTask =
      storageRef.child("garage/garage_video/user_$path.mp4").putFile(video);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadThumbVideoToGarage(File imageFile) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();

  StorageUploadTask uploadTask = storageRef
      .child("garage/garage_thumbVideo/user_$path.jpg")
      .putFile(imageFile);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

updateGarageRating(String garageId, double newRating, String currentUserId,
    String docId) async {
  final result =
      await garageRef.where('id', isEqualTo: garageId).getDocuments();
  Garage reGarage = Garage.fromDocument(result.documents[0]);

  garageRef.document(docId).updateData({'ratings.$currentUserId': newRating});
}

removeMediaFromGarage(int index, String garageId, String docId) async {
  final result =
      await garageRef.where('id', isEqualTo: garageId).getDocuments();
  Garage gar = Garage.fromDocument(result.documents[0]);

  List mediaOrigLi = gar.mediaOrig;
  List mediaThumbLi = gar.mediaThumb;
  List mediaTypesLi = gar.mediaTypes;
  mediaOrigLi.removeAt(index);
  mediaThumbLi.removeAt(index);
  mediaTypesLi.removeAt(index);

  await garageRef.document(docId).updateData({
    "mediaOrig": mediaOrigLi,
    "mediaThumb": mediaThumbLi,
    "mediaTypes": mediaTypesLi,
  });
}

Future<void> deleteStorage(String imageFileUrl) async {
  var fileUrl = Uri.decodeFull(Path.basename(imageFileUrl))
      .replaceAll(new RegExp(r'(\?alt).*'), '');

  final StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child(fileUrl);
  await firebaseStorageRef.delete();
}

likesToGarage(String docId, String garageId, String currentUserId,
    String addedId, String username, String userImage) async {
  final result =
      await garageRef.where('id', isEqualTo: garageId).getDocuments();
  Garage gar = Garage.fromDocument(result.documents[0]);
  List likes = [];

  if (gar.likes != null) {
    likes = gar.likes;
  }
  if (likes == null) {
    likes.add(currentUserId);
    if (addedId != currentUserId) {
      await likeAddToAcivityFeed(
          currentUserId, addedId, username, userImage, docId);
    }
  } else {
    if (likes.contains(currentUserId)) {
      likes.remove(currentUserId);
      if (addedId != currentUserId) {
        await removeLikeFromActivityFeed(currentUserId, addedId);
      }
    } else {
      likes.add(currentUserId);
      if (addedId != currentUserId) {
        await likeAddToAcivityFeed(
            currentUserId, addedId, username, userImage, docId);
      }
    }
  }

  await garageRef.document(docId).updateData({
    "likes": likes,
  });
}

likeAddToAcivityFeed(String userId, String addedId, String username,
    String userImage, String docId) {
  var uuid = Uuid();

  activityFeedRef.document(addedId).collection('feedItems').add({
    "id": uuid.v1().toString() + new DateTime.now().toString(),
    "userId": userId,
    "username": username,
    "userProfileImage": userImage,
    "type": "likeGarage",
    "typeId": docId,
    "read": false,
    "timestamp": timestamp,
  });
}

removeLikeFromActivityFeed(
  String userId,
  String addedId,
) async {
  QuerySnapshot snp = await activityFeedRef
      .document(addedId)
      .collection('feedItems')
      .getDocuments();

  snp.documents.forEach((element) async {
    ActivityFeedNotify activityFeed = ActivityFeedNotify.fromDocument(element);
    if (activityFeed.type == "likeGarage") {
      await activityFeedRef
          .document(addedId)
          .collection('feedItems')
          .document(userId)
          .delete();
    }
  });
}

commentsToGarage(String docId, String garageId, String currentUserId,
    String comment, String type) async {
  final result =
      await garageRef.where('id', isEqualTo: garageId).getDocuments();
  Garage gar = Garage.fromDocument(result.documents[0]);
  List commentsForGarage = [];
  if (gar.comments != null) {
    commentsForGarage = gar.comments;
  }

  var aComment = {
    "userId": currentUserId,
    "comment": comment,
    "type": type,
    "timestamp": timestamp
  };

  commentsForGarage.add(aComment);

  await garageRef.document(docId).updateData({
    "comments": json.encode(commentsForGarage),
  });
}

commentAddToAcivityFeed(String userId, String addedId, String username,
    String userImage, String docId) {
  var uuid = Uuid();

  activityFeedRef.document(addedId).collection('feedItems').add({
    "id": uuid.v1().toString() + new DateTime.now().toString(),
    "userId": userId,
    "username": username,
    "userProfileImage": userImage,
    "type": "commentGarage",
    "typeId": docId,
    "read": false,
    "timestamp": timestamp,
  });
}

removeCommentFromActivityFeed(
  String userId,
  String addedId,
) async {
 QuerySnapshot snp = await activityFeedRef
      .document(addedId)
      .collection('feedItems')
      .getDocuments();

  snp.documents.forEach((element) async {
    ActivityFeedNotify activityFeed = ActivityFeedNotify.fromDocument(element);
    if (activityFeed.type == "commentGarage") {
      await activityFeedRef
          .document(addedId)
          .collection('feedItems')
          .document(userId)
          .delete();
    }
  });
}
