import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garage/config/collections.dart';

Stream<QuerySnapshot> streamingActivityFeed(String currentUserId) {
  return activityFeedRef
      .document(currentUserId)
      .collection('feedItems')
      .orderBy('timestamp', descending: true)
      .snapshots();
}
