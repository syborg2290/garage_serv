import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final StorageReference storageRef = FirebaseStorage.instance.ref();
final firestoreRef = Firestore.instance;
final DateTime timestamp = DateTime.now();
final userRef = Firestore.instance.collection('user');
final garageRef = Firestore.instance.collection('garage');
