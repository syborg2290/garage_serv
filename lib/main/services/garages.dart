import 'dart:typed_data';

import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/main/services/each_categories/customizeGarage.dart';
import 'package:garage/models/main_services/garage.dart';
import 'package:garage/services/database/garageService.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:location/location.dart' as lo;

class Garages extends StatefulWidget {
  Garages({Key key}) : super(key: key);

  @override
  _GaragesState createState() => _GaragesState();
}

class _GaragesState extends State<Garages> {
  GoogleMapController _controller;
  MapType _currentType = MapType.normal;
  lo.Location _locationTracker = lo.Location();

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
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
            icon: Image.asset(
              'assets/Icons/left-arrow.png',
              width: width * 0.07,
              height: height * 0.07,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CustomGarage()));
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
      body: StreamBuilder(
        stream: streamingGarage(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            Center(child: circularProgress());
          }

          if (snapshot.data == null) {
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
              Set<Marker> _markers = Set();
              List<Garage> allGarages = [];
              snapshot.data.documents.forEach((garageEle) async {
                Garage aGarage = Garage.fromDocument(garageEle);
                allGarages.add(aGarage);
                _center = LatLng(aGarage.latitude, aGarage.longitude);
                _markers.add(Marker(
                  markerId: MarkerId(aGarage.latitude.toString()),
                  position: LatLng(aGarage.latitude, aGarage.longitude),
                  icon: BitmapDescriptor.fromBytes(await getBytesFromAsset(
                      'assets/markers/garage2.png', 200)),
                  anchor: Offset(0.5, 0.5),
                  flat: true,
                  draggable: false,
                  onTap: () {},
                ));
              });

              return GoogleMap(
                mapType: _currentType,
                compassEnabled: false,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                    target: _center, bearing: 0.0, tilt: 10, zoom: 8.0),
                markers: _markers,
                onMapCreated: (controller) async {
                  _controller = controller;
                   var location = await _locationTracker.getLocation();
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
              );
            }
          }
        },
      ),
    );
  }
}
