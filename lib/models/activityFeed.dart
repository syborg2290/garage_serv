import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityFeedNotify {
  final String id;
  final String userId;
  final String username;
  final String userImage;
  final String type;
  final String typeId;
  final int anyIndex;
  final bool read;
  final Timestamp timestamp;

  ActivityFeedNotify(
      {this.id,
      this.userId,
      this.username,
      this.userImage,
      this.type,
      this.typeId,
      this.read,
      this.anyIndex,
      this.timestamp});

  factory ActivityFeedNotify.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedNotify(
      id: doc['id'],
      userId: doc['userId'],
      username: doc['username'],
      userImage: doc['userProfileImage'],
      type: doc['type'],
      typeId: doc['typeId'],
      read: doc['read'],
      anyIndex: doc['anyIndex'],
      timestamp: doc['timestamp'],
    );
  }
}
