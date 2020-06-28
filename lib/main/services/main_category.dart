import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garage/main/services/each_categories/emergency_truck.dart';
import 'package:garage/main/services/each_categories/hire.dart';
import 'package:garage/main/services/each_categories/parking.dart';
import 'package:garage/main/services/each_categories/rent.dart';
import 'package:garage/main/services/each_categories/service_centers.dart';
import 'package:garage/main/services/each_categories/spare_parts.dart';
import 'package:garage/main/services/each_categories/tire_services.dart';
import 'package:garage/main/services/each_categories/vehicle_modify.dart';
import 'package:garage/main/services/garages.dart';
import 'package:garage/models/user.dart';
import 'package:garage/utils/progress_bars.dart';

class MainCategory extends StatefulWidget {
  final User currentUser;
  MainCategory({this.currentUser,Key key}) : super(key: key);

  @override
  _MainCategoryState createState() => _MainCategoryState();
}

class _MainCategoryState extends State<MainCategory> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

    return Padding(
        padding: EdgeInsets.only(top: 0),
        child: Container(
          height: height * 0.18,
          color: Colors.white,
          child: FutureBuilder(
              future: DefaultAssetBundle.of(context)
                  .loadString('assets/json/main_category.json'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }
                List myData = json.decode(snapshot.data);
                // myData.shuffle();

                return ListView.builder(
                    itemCount: myData.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (myData[index]['category_name'] == "Garages") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Garages(
                                      currentUser: widget.currentUser,
                                    )));
                          }
                          if (myData[index]['category_name'] == "Parkings") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Parking()));
                          }
                          if (myData[index]['category_name'] ==
                              "Service centers") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ServiceCenters()));
                          }
                          if (myData[index]['category_name'] ==
                              "Spare parts/accessories") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SpareParts()));
                          }
                          if (myData[index]['category_name'] ==
                              "Emergency vehicles") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EmergencyTruck()));
                          }
                          if (myData[index]['category_name'] ==
                              "Vehicle Modifications") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VehicleModify()));
                          }
                          if (myData[index]['category_name'] ==
                              "Tire services & shops") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TireService()));
                          }
                          if (myData[index]['category_name'] ==
                              "Hiring vehicles") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HireVehicles()));
                          }
                          if (myData[index]['category_name'] ==
                              "Renting vehicles") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RentVehicles()));
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: Container(
                            width: width * 0.30,
                            height: height * 0.2,
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                width: width * 0.30,
                                height: height * 0.2,
                                child: Column(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            myData[index]['category_name'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Image.asset(
                                          myData[index]['image_path'],
                                          width: 60,
                                          height: 60,
                                          color: Colors.black54,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 10,
                              margin: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                      );
                    });
              }),
        ));
  }
}
