import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as lo;
import 'dart:ui' as ui;

class Location extends StatefulWidget {
  final List<double> locationCoord;
  Location({this.locationCoord, Key key}) : super(key: key);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  GoogleMapController _controller;
  MapType _currentType = MapType.normal;
  LatLng _center;
  Set<Marker> _markers = Set();
  LatLng _lastMapPosition;
  lo.Location _locationTracker = lo.Location();
  StreamSubscription _locationSubscription;

  double latitude;
  double longitude;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.locationCoord != null) {
      setState(() {
        _center = LatLng(widget.locationCoord[0], widget.locationCoord[1]);
        _lastMapPosition =
            LatLng(widget.locationCoord[0], widget.locationCoord[1]);

        latitude = widget.locationCoord[0];
        longitude = widget.locationCoord[1];
        isLoading = false;
      });
    } else {
      Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((position) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _lastMapPosition = LatLng(position.latitude, position.longitude);

          latitude = position.latitude;
          longitude = position.longitude;
          isLoading = false;
        });
      });
    }
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

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
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

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  setCoord() async {
    var location = await _locationTracker.getLocation();
    changeMapMode();
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/markers/garaMarker_blue.png', 200);
    _markers.add(
      Marker(
        markerId: MarkerId("garage1"),
        position: LatLng(latitude, longitude),
        // rotation: newLocalData.heading,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        flat: true,
        anchor: Offset(1.0, 1.0),
        zIndex: 2,
        draggable: true,
        onDragEnd: (value) {
          setState(() {
            latitude = value.latitude;
            longitude = value.longitude;
            _lastMapPosition = LatLng(value.latitude, value.longitude);
          });
        },
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(60))),
            child: IconButton(
                icon: Image.asset(
                  'assets/Icons/left-arrow.png',
                  width: width * 0.07,
                  height: height * 0.07,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: () {
                List<double> locationCoord = [];
                locationCoord.add(latitude);
                locationCoord.add(longitude);
                Navigator.pop(context, locationCoord);
              },
              child: Center(
                  child: Text("Done",
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: circularProgress())
          : Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: _currentType,
                  compassEnabled: false,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: _center, bearing: 0.0, tilt: 10, zoom: 8.0),
                  markers: _markers,
                  onCameraMove: _onCameraMove,
                  onMapCreated: (controller) async {
                    _controller = controller;
                    await setCoord();
                    // await updateLocation();
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
              ],
            ),
    );
  }
}
