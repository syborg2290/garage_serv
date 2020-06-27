import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/initials/home.dart';
import 'package:garage/utils/palette.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(persistenceEnabled: true, sslEnabled: true).then(
      (_) {
    print("Timestamps enabled is snapshots\n");
  }, onError: (_) {
    print("Error enabiling timestamps in snapshots\n");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Garage',
      debugShowCheckedModeBanner: false, //remove debug banner
      theme: ThemeData(
        primaryColor: Palette.appColor,

        // visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}
