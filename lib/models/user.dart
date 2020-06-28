import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String firstname;
  final String lastname;
  final String username;
  final String contactNumber;
  final String location;
  final Timestamp dob;
  final String userPhotoUrl;
  final String thumbnailUserPhotoUrl;
  final String aboutYou;
  final String email;
  final bool isOnline;
  final Timestamp recentOnline;
  final bool active;
  final Timestamp timestamp;

  User(
      {this.id,
      this.firstname,
      this.lastname,
      this.username,
      this.contactNumber,
      this.location,
      this.dob,
      this.userPhotoUrl,
      this.thumbnailUserPhotoUrl,
      this.aboutYou,
      this.email,
      this.isOnline,
      this.recentOnline,
      this.active,
      this.timestamp});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc["id"],
        firstname: doc['firstname'],
        lastname: doc['lastname'],
        username: doc['username'],
        contactNumber: doc['contactNumber'],
        location: doc['location'],
        dob: doc['dob'],
        userPhotoUrl: doc['userPhotoUrl'],
        thumbnailUserPhotoUrl: doc['thumbnailUserPhotoUrl'],
        aboutYou: doc['aboutYou'],
        email: doc['email'],
        isOnline: doc['isOnline'],
        recentOnline: doc['recentOnline'],
        active: doc['active'],
        timestamp: doc['timestamp']);
  }
}
