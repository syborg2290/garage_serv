import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garage/config/collections.dart';
import 'package:uuid/uuid.dart';

Future<QuerySnapshot> checkGarageNameAlreadyExist(String garageName) async {
  final result =
      await garageRef.where('garageName', isEqualTo: garageName).getDocuments();
  return result;
}

Stream<QuerySnapshot> streamingGarage() {
  return garageRef.orderBy('timestamp', descending: true).snapshots();
}

addAGarage() {
  var uuid = Uuid();
  garageRef.add({"id": uuid.v1().toString() + new DateTime.now().toString()});
}
