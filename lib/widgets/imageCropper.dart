import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

cropImageFile(File imageFile) async {
  File intFile = imageFile;
  File croppedImage = await ImageCropper.cropImage(
    androidUiSettings: AndroidUiSettings(
      statusBarColor: Colors.black,
      activeControlsWidgetColor: Colors.black,
      toolbarColor: Colors.black,
      toolbarWidgetColor: Colors.white,
      toolbarTitle: 'Customize image',
    ),
    sourcePath: imageFile.path,
    aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
  );

  if (croppedImage == null) {
    croppedImage = intFile;
  }
  return croppedImage;
}
