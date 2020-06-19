import 'package:flutter/material.dart';

Widget login(String textHint, bool secureText) {
  return TextField(
    obscureText: secureText,
    textAlign: TextAlign.center,
    decoration: InputDecoration(
        hintText: textHint, border: InputBorder.none, hintStyle: TextStyle()),
  );
}
