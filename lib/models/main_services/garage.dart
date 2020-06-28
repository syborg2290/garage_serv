import 'package:cloud_firestore/cloud_firestore.dart';

class Garage {
  final String id;
  final String addedId;
  final String garageName;
  final String owenerName;
  final String ownerContactNumber;
  final String garageContactNumber;
  final String garageAddress;
  final double latitude;
  final double longitude;
  final dynamic vehiclesType;
  final dynamic vehicleEngineType;
  final dynamic preferredRepair;
  final dynamic mediaOrig;
  final dynamic mediaThumb;
  final dynamic mediaTypes;
  final Timestamp openAt;
  final Timestamp closeAt;
  final dynamic closedDays;
  final Timestamp timestamp;

  Garage(
      {this.id,
      this.addedId,
      this.garageName,
      this.owenerName,
      this.ownerContactNumber,
      this.garageContactNumber,
      this.garageAddress,
      this.latitude,
      this.longitude,
      this.vehiclesType,
      this.vehicleEngineType,
      this.preferredRepair,
      this.mediaOrig,
      this.mediaThumb,
      this.mediaTypes,
      this.openAt,
      this.closeAt,
      this.closedDays,
      this.timestamp});

  factory Garage.fromDocument(DocumentSnapshot doc) {
    return Garage(
        id: doc["id"],
        addedId: doc['addedId'],
        garageName: doc['garageName'],
        owenerName: doc['owenerName'],
        ownerContactNumber: doc['ownerContactNumber'],
        garageContactNumber: doc['garageContactNumber'],
        garageAddress: doc['garageAddress'],
        latitude: doc['latitude'],
        longitude: doc['longitude'],
        vehiclesType: doc['vehiclesType'],
        vehicleEngineType: doc['vehicleEngineType'],
        preferredRepair: doc['preferredRepair'],
        mediaOrig: doc['mediaOrig'],
        mediaThumb: doc['mediaThumb'],
        mediaTypes: doc['mediaTypes'],
        openAt: doc['openAt'],
        closeAt: doc['closeAt'],
        closedDays: doc['closedDays'],
        timestamp: doc['timestamp']);
  }
}
