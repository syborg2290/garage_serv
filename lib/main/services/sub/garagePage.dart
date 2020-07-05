import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:garage/initials/auth_screen.dart';
import 'package:garage/main/services/sub/GarageMedia.dart';
import 'package:garage/main/services/sub/garageComment.dart';
import 'package:garage/models/main_services/garage.dart';
import 'package:garage/models/user.dart';
import 'package:garage/services/database/garageService.dart';
import 'package:garage/services/database/userStuff.dart';
import 'package:garage/utils/palette.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

class GaragePage extends StatefulWidget {
  final Garage garage;
  final String docId;
  final User currentUser;
  final bool isFromAuth;
  GaragePage(
      {this.garage, this.docId, this.currentUser, this.isFromAuth, Key key})
      : super(key: key);

  @override
  _GaragePageState createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  double distance = 0.0;
  User addedUser;
  List likes = [];
  List comments = [];
  double allRating = 0.0;
  double currentRating = 0.0;
  LatLng current;
  Garage snapGarage;
  bool isAvailable = true;

  Widget vehicleTech(String type, String imagePath, bool isContain) {
    return Container(
      width: 100,
      height: 100,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          color: isContain ? Palette.appColor : Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      imagePath,
                      width: 40,
                      height: 40,
                      color: Colors.black,
                    ),
                    Text(
                      type,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 5,
        margin: EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      current = LatLng(value.latitude, value.longitude);
    });
    return WillPopScope(
      onWillPop: () async {
        if (widget.isFromAuth == null) {
          Navigator.pop(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthScreen()),
          );
        }
        return false;
      },
      child: Scaffold(
        body: StreamBuilder(
            stream: streamingGarage(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                snapshot.data.documents.forEach((doc) {
                  Garage snapDoc = Garage.fromDocument(doc);
                  if (snapDoc.id == widget.garage.id) {
                    snapGarage = snapDoc;
                    likes = snapDoc.likes;
                    comments = json.decode(snapDoc.comments);
                  }
                });

                if (snapGarage.ratings != null) {
                  snapGarage.ratings.forEach((key, value) {
                    allRating = allRating + value;
                  });
                }
                if (snapGarage.ratings != null) {
                  bool isContain =
                      snapGarage.ratings.containsKey(widget.currentUser.id);
                  if (isContain) {
                    currentRating = snapGarage.ratings[widget.currentUser.id];
                  }
                }
              }

              if (snapGarage != null) {
                DateTime date = DateTime.now();
                DateTime openAt = snapGarage.openAt.toDate();
                DateTime closeAt = snapGarage.closeAt.toDate();
                if (date.hour < closeAt.hour && date.hour > openAt.hour) {
                  if (snapGarage.closedDays.contains(date.weekday)) {
                    isAvailable = false;
                  } else {
                    isAvailable = true;
                  }
                } else {
                  isAvailable = false;
                }
              }

              if (snapGarage != null) {
                if (current != null) {
                  Geolocator()
                      .distanceBetween(
                    snapGarage.latitude,
                    snapGarage.longitude,
                    current.latitude,
                    current.longitude,
                  )
                      .then((value) {
                    distance = value;
                  });
                }
              }

              if (allRating >= 1 && allRating <= 10) {
                allRating = (allRating) / 10;
              }
              if (allRating > 10 && allRating <= 100) {
                allRating = (allRating) / 100;
              }
              if (allRating > 100 && allRating <= 1000) {
                allRating = (allRating) / 1000;
              }

              if (allRating > 1000 && allRating <= 10000) {
                allRating = (allRating) / 10000;
              }

              if (allRating > 10000 && allRating <= 100000) {
                allRating = (allRating) / 100000;
              }

              if (allRating > 100000 && allRating <= 1000000) {
                allRating = (allRating) / 1000000;
              }

              if (allRating > 1000000 && allRating <= 10000000) {
                allRating = (allRating) / 10000000;
              }

              if (allRating > 10000000 && allRating <= 100000000) {
                allRating = (allRating) / 100000000;
              }

              if (snapGarage != null) {
                getUserObj(snapGarage.addedId).then((addedUserDoc) {
                  addedUser = User.fromDocument(addedUserDoc);
                });
              }

              return SingleChildScrollView(
                child: Container(
                  decoration: new BoxDecoration(
                      color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(50.0),
                          topRight: const Radius.circular(50.0))),
                  padding: EdgeInsets.only(
                    left: 40,
                    right: 40,
                    bottom: 3,
                    top: 30,
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(Icons.near_me),
                          Text(
                            widget.garage.garageName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 30,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                if (widget.isFromAuth == null) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AuthScreen()),
                                  );
                                }
                              }),
                        ],
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.location_on, size: 20),
                          Text(
                            widget.garage.garageAddress,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      ((distance / 1000).round()) < 1
                          ? Text(
                              '( ${(distance).round()}' + " M )",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              '( ${(distance / 1000).round()}' + " Km )",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.phone, size: 20),
                          Text(
                            widget.garage.garageContactNumber,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Chip(
                          label: isAvailable
                              ? Text(
                                  "Open now",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                )
                              : Text(
                                  "Close now",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                          backgroundColor:
                              isAvailable ? Color(0xff39b54a) : Colors.red,
                        ),
                      ),
                      snapGarage != null
                          ? snapGarage.vehicleEngineType != null
                              ? SizedBox(
                                  height: 100,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: <Widget>[
                                      vehicleTech(
                                          "Any",
                                          "assets/Icons/any.png",
                                          snapGarage.vehicleEngineType
                                              .contains("Any")),
                                      vehicleTech(
                                          "None h/e",
                                          "assets/Icons/none.png",
                                          snapGarage.vehicleEngineType.contains(
                                              "None hybrid/electric")),
                                      vehicleTech(
                                          "Hybrid",
                                          "assets/Icons/hybrid.png",
                                          snapGarage.vehicleEngineType
                                              .contains("Hybrid")),
                                      vehicleTech(
                                          "Electric",
                                          "assets/Icons/electric.png",
                                          snapGarage.vehicleEngineType
                                              .contains("Electric")),
                                    ],
                                  ),
                                )
                              : SizedBox.shrink()
                          : SizedBox.shrink(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Repairing vehicle types of " +
                            widget.garage.garageName,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      snapGarage == null
                          ? SizedBox.shrink()
                          : snapGarage.vehiclesType == null
                              ? SizedBox.shrink()
                              : SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                      itemCount: snapGarage.vehiclesType.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          width: 150,
                                          height: 80,
                                          child: Card(
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            child: Container(
                                              color: Palette.appColor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  snapGarage
                                                      .vehiclesType[index],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            elevation: 5,
                                            margin: EdgeInsets.all(10),
                                          ),
                                        );
                                      }),
                                ),
                      SizedBox(
                        height: 10,
                      ),
                      snapGarage != null
                          ? snapGarage.preferredRepair.length == 0
                              ? SizedBox.shrink()
                              : Text(
                                  "Common repairs mentioned on " +
                                      snapGarage.garageName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                )
                          : SizedBox.shrink(),
                      snapGarage == null
                          ? SizedBox.shrink()
                          : snapGarage.preferredRepair.length == 0
                              ? SizedBox.shrink()
                              : SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                      itemCount:
                                          snapGarage.preferredRepair.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Map snapRepairPrice = json.decode(
                                                snapGarage
                                                    .preferredRepairForPrice);
                                            AwesomeDialog(
                                              context: context,
                                              animType: AnimType.SCALE,
                                              dialogType: DialogType.NO_HEADER,
                                              body: Column(
                                                children: <Widget>[
                                                  Text(
                                                    "Rough cost for the repair",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 130,
                                                    child: ListView.builder(
                                                        itemCount: snapGarage
                                                            .vehiclesType
                                                            .length,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, index2) {
                                                          return Container(
                                                            width: 150,
                                                            height: 130,
                                                            child: Card(
                                                              clipBehavior: Clip
                                                                  .antiAliasWithSaveLayer,
                                                              child: Container(
                                                                color: Palette
                                                                    .appColor,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        snapGarage
                                                                            .vehiclesType[index2],
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      Divider(),
                                                                      snapRepairPrice[snapGarage.preferredRepair[index]] ==
                                                                              null
                                                                          ? SizedBox
                                                                              .shrink()
                                                                          : Text(
                                                                              snapRepairPrice[snapGarage.preferredRepair[index]][index2].toString() == null ? "It's depend" : widget.garage.currencyType + " " + snapRepairPrice[snapGarage.preferredRepair[index]][index2].toString(),
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0),
                                                              ),
                                                              elevation: 5,
                                                              margin: EdgeInsets
                                                                  .all(10),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                ],
                                              ),
                                              btnOkText: 'Minimize',
                                            )..show();
                                          },
                                          child: Container(
                                            width: 150,
                                            height: 150,
                                            child: Card(
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              child: Container(
                                                color: Palette.appColor,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text(
                                                        snapGarage
                                                                .preferredRepair[
                                                            index],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Image.asset(
                                                        'assets/Icons/price.png',
                                                        width: 40,
                                                        height: 40,
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              elevation: 5,
                                              margin: EdgeInsets.all(10),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GarageMedia(
                                            garage: snapGarage,
                                            docId: widget.docId,
                                          )),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(15.0),
                                padding: const EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black)),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text("Images & Videos",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                          )),
                                    ),
                                    Icon(
                                      Icons.forward,
                                      size: 30,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      snapGarage == null
                          ? SizedBox.shrink()
                          : Text(
                              "Rate the " + snapGarage.garageName,
                              style: TextStyle(fontSize: 18),
                            ),
                      SizedBox(
                        height: 5,
                      ),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RatingBar(
                                onRatingChanged: (rating) async {
                                  await updateGarageRating(
                                      widget.garage.id,
                                      rating,
                                      widget.currentUser.id,
                                      widget.docId);
                                },
                                filledIcon: Icons.sentiment_satisfied,
                                emptyIcon: Icons.sentiment_dissatisfied,
                                halfFilledIcon: Icons.sentiment_neutral,
                                isHalfAllowed: true,
                                filledColor: Colors.green,
                                emptyColor: Colors.redAccent,
                                halfFilledColor: Colors.amberAccent,
                                size: 48,
                                initialRating: currentRating,
                              ),
                              Text(
                                  " / " +
                                      (allRating.toStringAsFixed(2)).toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          snapGarage == null
                              ? SizedBox.shrink()
                              : addedUser == null
                                  ? SizedBox.shrink()
                                  : Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 2.0, top: 10),
                                      child: ListTile(
                                        title: RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: 'Made by ',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  )),
                                              TextSpan(
                                                  text: addedUser.username,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        leading: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Color(0xffe0e0e0),
                                          backgroundImage:
                                              addedUser.thumbnailUserPhotoUrl ==
                                                      null
                                                  ? AssetImage(
                                                      'assets/Icons/user.png')
                                                  : NetworkImage(addedUser
                                                      .thumbnailUserPhotoUrl),
                                        ),
                                        subtitle: Text(
                                          timeago.format(
                                              snapGarage.timestamp.toDate()),
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () async {
                                      await likesToGarage(
                                          widget.docId,
                                          widget.garage.id,
                                          widget.currentUser.id,
                                          widget.garage.addedId,
                                          widget.currentUser.username,
                                          widget.currentUser
                                              .thumbnailUserPhotoUrl);
                                    },
                                    child: Image.asset(
                                      likes == null
                                          ? 'assets/Icons/love.png'
                                          : likes.contains(
                                                  widget.currentUser.id)
                                              ? 'assets/Icons/love_red.png'
                                              : 'assets/Icons/love.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  Text(likes == null
                                      ? 0.toString() + " likes"
                                      : likes.length.toString() + " likes"),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GarageComments(
                                                  garage: snapGarage,
                                                  docId: widget.docId,
                                                )),
                                      );
                                    },
                                    child: Image.asset(
                                      'assets/Icons/comment.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  Text(comments == null
                                      ? 0.toString() + " comments"
                                      : comments.length.toString() +
                                          " comments"),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/Icons/share.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                  Text("0 shares"),
                                ],
                              ),
                              Image.asset(
                                'assets/Icons/options.png',
                                width: 30,
                                height: 30,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
