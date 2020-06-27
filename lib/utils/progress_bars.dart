import 'package:flutter/material.dart';
import 'package:garage/utils/palette.dart';
import 'package:grafpix/pixloaders/pix_loader.dart';

Container circularProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child:
        PixLoader(loaderType: LoaderType.Spinner, faceColor: Palette.appColor),
  );
}
