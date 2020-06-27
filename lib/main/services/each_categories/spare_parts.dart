import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';

class SpareParts extends StatefulWidget {
  SpareParts({Key key}) : super(key: key);

  @override
  _SparePartsState createState() => _SparePartsState();
}

class _SparePartsState extends State<SpareParts> {
  List engineType = [];
  List vehicleType = [];

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
        title: Text(
          "Customize store",
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
          ),
        ),
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
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => GarageForm(
                //               engineType: engineType,
                //               vehicleType: vehicleType,
                //             )));
              },
              child: Center(
                  child: Text("Next",
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: height * 0.20,
              child: Padding(
                padding: EdgeInsets.only(
                  top: height * 0.01,
                  left: height * 0.01,
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (engineType.contains('Brand new')) {
                          setState(() {
                            engineType.remove('Brand new');
                          });
                        } else {
                          setState(() {
                            engineType.add('Brand new');
                          });
                        }
                      },
                      child: Container(
                        width: width * 0.35,
                        height: height * 0.20,
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            color: engineType.contains('Brand new')
                                ? Palette.appColor
                                : Colors.white,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(height * 0.01),
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/Icons/new.png',
                                        width: 60,
                                        height: 60,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Brand new',
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
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (engineType.contains('Second hand')) {
                          setState(() {
                            engineType.remove('Second hand');
                          });
                        } else {
                          setState(() {
                            engineType.add('Second hand');
                          });
                        }
                      },
                      child: Container(
                        width: width * 0.35,
                        height: height * 0.20,
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            color: engineType.contains('Second hand')
                                ? Palette.appColor
                                : Colors.white,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(height * 0.01),
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/Icons/use.png',
                                        width: 60,
                                        height: 60,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Second hand',
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  color: Colors.white,
                  child: FutureBuilder(
                    future: DefaultAssetBundle.of(context)
                        .loadString('assets/json/garage_vehicles.json'),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return circularProgress();
                      }
                      List myData = json.decode(snapshot.data);
                      // myData.shuffle();

                      return GridView.count(
                        crossAxisCount: 2,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: List.generate(myData.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              if (vehicleType
                                  .contains(myData[index]['vehicle'])) {
                                setState(() {
                                  vehicleType.remove(myData[index]['vehicle']);
                                });
                              } else {
                                setState(() {
                                  vehicleType.add(myData[index]['vehicle']);
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                width: width * 0.20,
                                height: height * 0.15,
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Container(
                                    width: width * 0.20,
                                    height: height * 0.15,
                                    child: Column(
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Image.asset(
                                              myData[index]['image_path'],
                                              width: 80,
                                              height: 80,
                                              color: vehicleType.contains(
                                                      myData[index]['vehicle'])
                                                  ? Palette.appColor
                                                  : Colors.black54,
                                              fit: BoxFit.contain,
                                            ),
                                            Text(
                                              myData[index]['vehicle'],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: vehicleType.contains(
                                                        myData[index]
                                                            ['vehicle'])
                                                    ? Palette.appColor
                                                    : Colors.black54,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  elevation: 15,
                                  margin: EdgeInsets.all(10),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
