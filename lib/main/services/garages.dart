import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:garage/config/settings.dart';
import 'package:garage/initials/auth_screen.dart';
import 'package:garage/main/services/each_categories/customizeGarage.dart';
import 'package:garage/models/main_services/garage.dart';
import 'package:garage/models/user.dart';
import 'package:garage/services/database/garageService.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:location/location.dart' as lo;

class Garages extends StatefulWidget {
  final User currentUser;
  Garages({this.currentUser, Key key}) : super(key: key);

  @override
  _GaragesState createState() => _GaragesState();
}

class _GaragesState extends State<Garages> {
  GoogleMapController _controller;
  MapType _currentType = MapType.normal;
  lo.Location _locationTracker = lo.Location();
  bool isNotempty = false;
  Set<Marker> _markers = Set();
  Set<Polyline> _polylines = Set();
  LatLng current;
  bool isLoading = true;
  BitmapDescriptor customIcon;
  StreamSubscription _locationSubscription;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    garagesAll().then((value) {
      if (value.documents.length != 0) {
        setState(() {
          isNotempty = true;
        });
      }
    });
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      setState(() {
        current = LatLng(value.latitude, value.longitude);
        isLoading = false;
      });
    });
  }

  changeMapMode() {
    DateFormat dateFormat = new DateFormat.Hm();
    DateTime now = DateTime.now();
    DateTime open = dateFormat.parse("06:30");
    open = new DateTime(now.year, now.month, now.day, open.hour, open.minute);
    DateTime close = dateFormat.parse("19:00");
    close =
        new DateTime(now.year, now.month, now.day, close.hour, close.minute);

    if (now.isAfter(close)) {
      getJsonFile('assets/json/dark.json').then(setMapStyle);
    } else if (now.isAfter(open)) {
      getJsonFile('assets/json/light.json').then(setMapStyle);
    } else if (now.isBefore(close)) {
      getJsonFile('assets/json/light.json').then(setMapStyle);
    } else if (now.isBefore(open)) {
      getJsonFile('assets/json/dark.json').then(setMapStyle);
    }
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future<ui.Image> getImageFromPath(String imagePath) async {
    File imageFile = await DefaultCacheManager().getSingleFile(imagePath);

    Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }

  Future<BitmapDescriptor> getMarkerIcon(
      String imagePath, Size size, bool isUser, Color color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.transparent;
    final double tagWidth = 4.0;

    final Paint shadowPaint = Paint()..color = color;
    final double shadowWidth = isUser ? 5.0 : 10.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(shadowWidth, shadowWidth,
              size.width - (shadowWidth * 2), size.height - (shadowWidth * 2)),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Add tag circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(size.width - tagWidth, 0.0, tagWidth, tagWidth),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);

    // Oval for the image
    Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
        size.width - (imageOffset * 2), size.height - (imageOffset * 2));

    // Add path for oval image
    canvas.clipPath(Path()..addOval(oval));

    // Add image
    ui.Image image = await getImageFromPath(
        imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fill);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());

    // Convert image to bytes
    final ByteData byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  updateLocation() async {
    try {
      var location = await _locationTracker.getLocation();
      Uint8List markerIcon;
      if (widget.currentUser.userPhotoUrl != null) {
        customIcon = await getMarkerIcon(
            widget.currentUser.thumbnailUserPhotoUrl,
            Size(150.0, 150.0),
            true,
            Color(0xffffd31d));
      } else {
        markerIcon = await getBytesFromAsset('assets/Icons/map_user.png', 150);
      }

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) async {
        if (_controller != null) {
          if (!mounted) {
            return;
          }
          setState(() {
            current = LatLng(newLocalData.latitude, newLocalData.longitude);
            _markers.add(
              Marker(
                markerId: MarkerId("usermarkermap222"),
                position: LatLng(newLocalData.latitude, newLocalData.longitude),
                rotation: newLocalData.heading,
                icon: widget.currentUser.userPhotoUrl != null
                    ? customIcon
                    : BitmapDescriptor.fromBytes(markerIcon),
                flat: true,
                anchor: Offset(1.0, 1.0),
                zIndex: 2,
                draggable: false,
              ),
            );
          });
        }
      });
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AuthScreen()));
      }
    }
  }

  setPolylines(double _originLatitude, double _originLongitude,
      double _destLatitude, double _destLongitude) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GoogleServiceApi,
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      avoidFerries: false,
      avoidHighways: false,
      avoidTolls: false,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    if (!mounted) {
      return;
    }
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("polyForLocation"),
          color: Colors.purple,
          points: polylineCoordinates);

      _polylines.add(polyline);
    });
  }

  @override
  void didUpdateWidget(Garages oldWidget) {
    setState(() {
      isNotempty = true;
    });
    super.didUpdateWidget(oldWidget);
  }

  pinBottomSheet(
      Garage garage, String docId, double distance, bool isAvailable) {
    return showModalBottomSheet(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            useRootNavigator: true,
            clipBehavior: Clip.hardEdge,
            enableDrag: true,
            context: context,
            builder: (BuildContext bc) {
              return Container(
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
                child: new Wrap(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(Icons.near_me, size: 27),
                            Text(
                              garage.garageName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ((distance / 1000).round()) < 1
                                ? Text(
                                    '${(distance).round()}' + " M",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    '${(distance / 1000).round()}' + " Km",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                              garage.garageAddress,
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
                                    "Open",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )
                                : Text(
                                    "Close",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                            backgroundColor:
                                isAvailable ? Color(0xff39b54a) : Colors.red,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () async {},
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
                                        child: Text("know more",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  ],
                ),
              );
            }) ??
        false;
  }

  _onMapTypeButtonPressed() {
    if (_currentType == MapType.normal) {
      setState(() {
        _currentType = MapType.satellite;
      });
    } else if (_currentType == MapType.satellite) {
      setState(() {
        _currentType = MapType.terrain;
      });
    } else if (_currentType == MapType.terrain) {
      setState(() {
        _currentType = MapType.hybrid;
      });
    } else if (_currentType == MapType.hybrid) {
      setState(() {
        _currentType = MapType.normal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AuthScreen()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          brightness: isNotempty ? Brightness.dark : Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
              icon: Image.asset(
                'assets/Icons/left-arrow.png',
                width: width * 0.07,
                height: height * 0.07,
                color: isNotempty ? Colors.white : Colors.black,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AuthScreen()));
              }),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomGarage(
                                currrentUser: widget.currentUser,
                              )));
                },
                child: Center(
                    child: Text("New",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                        ))),
                color: Palette.appColor,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Palette.appColor,
                    )),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: isLoading
            ? Center(child: circularProgress())
            : StreamBuilder(
                stream: streamingGarage(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: circularProgress());
                  }

                  if (snapshot.data.documents.length == 0) {
                    return Center(
                      child: EmptyListWidget(
                          title: 'No Garages',
                          subTitle: 'No garage available yet',
                          image: 'assets/designs/empty.png',
                          titleTextStyle: Theme.of(context)
                              .typography
                              .dense
                              .display1
                              .copyWith(color: Color(0xff9da9c7)),
                          subtitleTextStyle: Theme.of(context)
                              .typography
                              .dense
                              .body2
                              .copyWith(color: Color(0xffabb8d6))),
                    );
                  } else {
                    LatLng _center;
                    Set<Marker> _markersSnap = Set();
                    _markersSnap = _markers;
                    List<Garage> allGarages = [];
                    DateTime date = DateTime.now();
                    snapshot.data.documents.forEach((garageEle) async {
                      Garage aGarage = Garage.fromDocument(garageEle);
                      DateTime openAt = aGarage.openAt.toDate();
                      DateTime closeAt = aGarage.closeAt.toDate();
                      allGarages.add(aGarage);
                      _center = current;
                      if (date.hour < closeAt.hour && date.hour > openAt.hour) {
                        if (aGarage.closedDays.contains(date.weekday)) {
                          _markersSnap.add(Marker(
                            markerId: MarkerId(aGarage.latitude.toString()),
                            position:
                                LatLng(aGarage.latitude, aGarage.longitude),
                            icon: BitmapDescriptor.fromBytes(
                                await getBytesFromAsset(
                                    'assets/markers/garaMarker_red.png', 150)),
                            anchor: Offset(0.5, 0.5),
                            flat: true,
                            draggable: false,
                            onTap: () async {
                              var _distanceInMeters =
                                  await Geolocator().distanceBetween(
                                aGarage.latitude,
                                aGarage.longitude,
                                current.latitude,
                                current.longitude,
                              );
                              await pinBottomSheet(
                                aGarage,
                                garageEle.documentID,
                                _distanceInMeters,
                                false,
                              );
                              await setPolylines(
                                  current.latitude,
                                  current.longitude,
                                  aGarage.latitude,
                                  aGarage.longitude);
                            },
                          ));
                        } else {
                          _markersSnap.add(Marker(
                            markerId: MarkerId(aGarage.latitude.toString()),
                            position:
                                LatLng(aGarage.latitude, aGarage.longitude),
                            icon: BitmapDescriptor.fromBytes(
                                await getBytesFromAsset(
                                    'assets/markers/garaMarker_green.png',
                                    150)),
                            anchor: Offset(0.5, 0.5),
                            flat: true,
                            draggable: false,
                            onTap: () async {
                              var _distanceInMeters =
                                  await Geolocator().distanceBetween(
                                aGarage.latitude,
                                aGarage.longitude,
                                current.latitude,
                                current.longitude,
                              );
                              await pinBottomSheet(
                                aGarage,
                                garageEle.documentID,
                                _distanceInMeters,
                                false,
                              );
                              await setPolylines(
                                  current.latitude,
                                  current.longitude,
                                  aGarage.latitude,
                                  aGarage.longitude);
                            },
                          ));
                        }
                      } else {
                        _markersSnap.add(Marker(
                          markerId: MarkerId(aGarage.latitude.toString()),
                          position: LatLng(aGarage.latitude, aGarage.longitude),
                          icon: BitmapDescriptor.fromBytes(
                              await getBytesFromAsset(
                                  'assets/markers/garaMarker_red.png', 150)),
                          anchor: Offset(0.5, 0.5),
                          flat: true,
                          draggable: false,
                          onTap: () async {
                            var _distanceInMeters =
                                await Geolocator().distanceBetween(
                              aGarage.latitude,
                              aGarage.longitude,
                              current.latitude,
                              current.longitude,
                            );
                            await pinBottomSheet(
                              aGarage,
                              garageEle.documentID,
                              _distanceInMeters,
                              false,
                            );
                            await setPolylines(
                                current.latitude,
                                current.longitude,
                                aGarage.latitude,
                                aGarage.longitude);
                          },
                        ));
                      }
                    });

                    return Stack(
                      children: <Widget>[
                        GoogleMap(
                          mapType: _currentType,
                          compassEnabled: false,
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                              target: _center,
                              bearing: 0.0,
                              tilt: 10,
                              zoom: 8.0),
                          markers: _markersSnap,
                          polylines: _polylines,
                          onMapCreated: (controller) async {
                            _controller = controller;
                            await updateLocation();
                            changeMapMode();
                          },
                          buildingsEnabled: true,
                          myLocationButtonEnabled: true,
                          trafficEnabled: true,
                          rotateGesturesEnabled: true,
                          indoorViewEnabled: true,
                          scrollGesturesEnabled: true,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          mapToolbarEnabled: false,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: height * 0.1),
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    FloatingActionButton(
                                      backgroundColor: Palette.appColor,
                                      onPressed: _onMapTypeButtonPressed,
                                      child: Icon(
                                        Icons.map,
                                        color: Colors.black,
                                      ),
                                      heroTag: "btnMapType",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: height * 0.1),
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    FloatingActionButton(
                                      backgroundColor: Palette.appColor,
                                      onPressed: _onMapTypeButtonPressed,
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.black,
                                      ),
                                      heroTag: "btnSearch",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
