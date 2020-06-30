import 'package:cloud_firestore/cloud_firestore.dart';

class Garage {
  final String id;
  final String addedId;
  final String garageName;
  final String garageContactNumber;
  final String garageAddress;
  final double latitude;
  final double longitude;
  final dynamic vehiclesType;
  final dynamic vehicleEngineType;
  final dynamic preferredRepair;
  final dynamic preferredRepairForPrice;
  final String currencyType;
  final dynamic mediaOrig;
  final dynamic mediaThumb;
  final dynamic mediaTypes;
  final Timestamp openAt;
  final Timestamp closeAt;
  final dynamic closedDays;
  final dynamic ratings;
  final Timestamp timestamp;

  Garage(
      {this.id,
      this.addedId,
      this.garageName,
      this.garageContactNumber,
      this.garageAddress,
      this.latitude,
      this.longitude,
      this.vehiclesType,
      this.vehicleEngineType,
      this.preferredRepair,
      this.preferredRepairForPrice,
      this.currencyType,
      this.mediaOrig,
      this.mediaThumb,
      this.mediaTypes,
      this.openAt,
      this.closeAt,
      this.closedDays,
      this.ratings,
      this.timestamp});

  factory Garage.fromDocument(DocumentSnapshot doc) {
    return Garage(
        id: doc["id"],
        addedId: doc['addedId'],
        garageName: doc['garageName'],
        garageContactNumber: doc['garageContactNumber'],
        garageAddress: doc['garageAddress'],
        latitude: doc['latitude'],
        longitude: doc['longitude'],
        vehiclesType: doc['vehiclesType'],
        vehicleEngineType: doc['vehicleEngineType'],
        preferredRepair: doc['preferredRepair'],
        preferredRepairForPrice: doc['preferredRepairForPrice'],
        currencyType: doc['currencyType'],
        mediaOrig: doc['mediaOrig'],
        mediaThumb: doc['mediaThumb'],
        mediaTypes: doc['mediaTypes'],
        openAt: doc['openAt'],
        closeAt: doc['closeAt'],
        closedDays: doc['closedDays'],
        ratings: doc['ratings'],
        timestamp: doc['timestamp']);
  }
}
