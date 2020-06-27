import 'package:cloud_firestore/cloud_firestore.dart';

class Garage {
  final String id;
  final String addedId;
  final String garageName;
  final String owenerName;
  final String ownerContactNumber;
  final String garageContactNumber;
  final double latitude;
  final double longitude;
  final dynamic vehiclesType;
  final dynamic vehicleEngineType;
  final dynamic preferredRepair;
  final dynamic media;
  final Timestamp openAt;
  final Timestamp closeAt;
  final Timestamp timestamp;

  Garage(
      {this.id,
      this.addedId,
      this.garageName,
      this.owenerName,
      this.ownerContactNumber,
      this.garageContactNumber,
      this.latitude,
      this.longitude,
      this.vehiclesType,
      this.vehicleEngineType,
      this.preferredRepair,
      this.media,
      this.openAt,
      this.closeAt,
      this.timestamp});

  factory Garage.fromDocument(DocumentSnapshot doc) {
    return Garage(
        id: doc["id"],
        addedId: doc['addedId'],
        garageName: doc['garageName'],
        owenerName: doc['owenerName'],
        ownerContactNumber: doc['ownerContactNumber'],
        garageContactNumber: doc['garageContactNumber'],
        latitude: doc['latitude'],
        longitude: doc['longitude'],
        vehiclesType: doc['vehiclesType'],
        vehicleEngineType: doc['vehicleEngineType'],
        preferredRepair: doc['preferredRepair'],
        media: doc['media'],
        openAt: doc['openAt'],
        closeAt: doc['closeAt'],
        timestamp: doc['timestamp']);
  }
}
