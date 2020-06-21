import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garage/utils/progress_bars.dart';

class MainCategory extends StatefulWidget {
  MainCategory({Key key}) : super(key: key);

  @override
  _MainCategoryState createState() => _MainCategoryState();
}

class _MainCategoryState extends State<MainCategory> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        title: Text(
          "Category",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Schyler',
            fontWeight: FontWeight.bold,
          ),
        ),
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
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 0),
        child: Container(
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

              return GridView.count(
                crossAxisCount: 2,
                children: List.generate(myData.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      // locationDialog(myData[index]['category_name'],
                      //     myData[index]['image_path']);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                myData[index]['image_path'],
                                width: 120,
                                height: 120,
                              ),
                              Text(
                                myData[index]['category_name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 20,
                        margin: EdgeInsets.all(1),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
