import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';

Future<File> compressImageFile(File imageFile, int size) async {
  Directory tempDir = await getTemporaryDirectory();
  String path = tempDir.path;
  Im.Image mediaFile = Im.decodeImage(imageFile.readAsBytesSync());
  var randomizer = new Random(); // can get a seed as a parameter

  // Integer between 0 and 100 (0 can be 100 not)
  var num = randomizer.nextInt(10000000);

  final compressMediaFile = File('$path/$num.')
    ..writeAsBytesSync(Im.encodeJpg(mediaFile, quality: size));

  return compressMediaFile;
}

Future<File> getThumbnailForImage(File image, int size) async {
  Directory tempDir = await getTemporaryDirectory();
  String path = tempDir.path;
  Im.Image mediaFile = Im.decodeImage(image.readAsBytesSync());
  var randomizer = new Random(); // can get a seed as a parameter

  // Integer between 0 and 100 (0 can be 100 not)
  var num = randomizer.nextInt(10000000);

  final compressMediaFile = File('$path/$num.')
    ..writeAsBytesSync(Im.encodeJpg(mediaFile, quality: size));

  return compressMediaFile;
}
