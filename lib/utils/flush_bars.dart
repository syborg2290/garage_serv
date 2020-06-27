import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:garage/utils/palette.dart';

class GradientSnackBar {
  static void showMessage(BuildContext context, String message) {
    Flushbar(
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.TOP,
      // message: error,
      messageText: Center(
          child: Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ))),
      duration: Duration(milliseconds: 3500),
      backgroundGradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomRight,
          colors: [
            Palette.appColor,
            Palette.appColor,
          ]),
      backgroundColor: Palette.appColor,
      boxShadows: [
        BoxShadow(
          color: Colors.black38,
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    )..show(context);
  }
}
