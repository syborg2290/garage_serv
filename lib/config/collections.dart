import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final StorageReference storageRef = FirebaseStorage.instance.ref();
final firestoreRef = Firestore.instance;
final DateTime timestamp = DateTime.now();
final userRef = Firestore.instance.collection('user');
final garageRef = Firestore.instance.collection('garage');
final followersRef = Firestore.instance.collection("followers");
final followingRef = Firestore.instance.collection("following");
final activityFeedRef = Firestore.instance.collection("feedNotification");
final recentySerach = Firestore.instance.collection("recentlySearch");
