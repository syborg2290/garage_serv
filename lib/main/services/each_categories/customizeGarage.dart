import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/main/services/each_categories/forms/garageForm.dart';
import 'package:garage/utils/flush_bars.dart';
import 'package:garage/utils/palette.dart';
import 'package:garage/utils/progress_bars.dart';

class CustomGarage extends StatefulWidget {
  CustomGarage({Key key}) : super(key: key);

  @override
  _CustomGarageState createState() => _CustomGarageState();
}

class _CustomGarageState extends State<CustomGarage> {
  List engineType = ["Any"];
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
          "Customize your garage",
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
                if (vehicleType.isNotEmpty) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GarageForm(
                                engineType: engineType,
                                vehicleType: vehicleType,
                              )));
                } else {
                  GradientSnackBar.showMessage(
                      context, "You have to select atleast one vehicle type!");
                }
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
                  left: height * 0.03,
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          engineType.clear();
                          engineType.add("Any");
                        });
                      },
                      child: Container(
                        width: width * 0.30,
                        height: height * 0.20,
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            color: engineType.contains('Any')
                                ? Palette.appColor
                                : Colors.white,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(height * 0.01),
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/Icons/any.png',
                                        width: 60,
                                        height: 60,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Any',
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
                        if (engineType.contains('Any')) {
                          setState(() {
                            engineType.clear();
                          });
                        }
                        if (engineType.contains('None hybrid/electric')) {
                          setState(() {
                            engineType.remove('None hybrid/electric');
                          });
                          if (engineType.length == 0) {
                            engineType.add('Any');
                          }
                        } else {
                          setState(() {
                            engineType.add('None hybrid/electric');
                          });
                        }
                      },
                      child: Container(
                        width: width * 0.30,
                        height: height * 0.20,
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            color: engineType.contains('None hybrid/electric')
                                ? Palette.appColor
                                : Colors.white,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(height * 0.01),
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/Icons/none.png',
                                        width: 60,
                                        height: 60,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'None hybrid/electric',
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
                        if (engineType.contains('Any')) {
                          setState(() {
                            engineType.clear();
                          });
                        }
                        if (engineType.contains('Hybrid')) {
                          setState(() {
                            engineType.remove('Hybrid');
                          });
                          if (engineType.length == 0) {
                            engineType.add('Any');
                          }
                        } else {
                          setState(() {
                            engineType.add('Hybrid');
                          });
                        }
                      },
                      child: Container(
                        width: width * 0.30,
                        height: height * 0.20,
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            color: engineType.contains('Hybrid')
                                ? Palette.appColor
                                : Colors.white,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(height * 0.01),
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/Icons/hybrid.png',
                                        width: 60,
                                        height: 60,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Hybrid',
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
                        if (engineType.contains('Any')) {
                          setState(() {
                            engineType.clear();
                          });
                        }

                        if (engineType.contains('Electric')) {
                          setState(() {
                            engineType.remove('Electric');
                          });
                          if (engineType.length == 0) {
                            engineType.add('Any');
                          }
                        } else {
                          setState(() {
                            engineType.add('Electric');
                          });
                        }
                      },
                      child: Container(
                        width: width * 0.30,
                        height: height * 0.20,
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            color: engineType.contains('Electric')
                                ? Palette.appColor
                                : Colors.white,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(height * 0.01),
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/Icons/electric.png',
                                        width: 60,
                                        height: 60,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Electric',
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
