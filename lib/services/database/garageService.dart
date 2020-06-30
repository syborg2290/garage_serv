import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:garage/config/collections.dart';
import 'package:garage/models/main_services/garage.dart';
import 'package:uuid/uuid.dart';

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
