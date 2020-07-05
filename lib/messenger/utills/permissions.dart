import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> cameraandmicrophonePermissionsGranted() async {
    PermissionStatus cameraPermissionStatus = await _getCameraPermission();
    PermissionStatus microphonePermissionStatus =
        await _getMicrophonePermission();

    if (cameraPermissionStatus == PermissionStatus.granted &&
        microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handlecameraandmicrophoneInvalidPermissions(
          cameraPermissionStatus, microphonePermissionStatus);
      return false;
    }
  }

  static Future<bool> microphonePermissionsGranted() async {
    PermissionStatus microphonePermissionStatus =
        await _getMicrophonePermission();

    if (microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handlemicrophoneInvalidPermissions(microphonePermissionStatus);
      return false;
    }
  }

  static Future<PermissionStatus> _getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted &&
        status != PermissionStatus.restricted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
      ].request();
      return statuses[Permission.camera] ?? PermissionStatus.undetermined;
    } else {
      return status;
    }
  }

  static Future<PermissionStatus> _getMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status != PermissionStatus.granted &&
        status != PermissionStatus.restricted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
      ].request();
      return statuses[Permission.microphone] ?? PermissionStatus.undetermined;
    } else {
      return status;
    }
  }

  static void _handlecameraandmicrophoneInvalidPermissions(
      PermissionStatus cameraPermissionStatus,
      PermissionStatus microphonePermissionStatus) {
    if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (cameraPermissionStatus == PermissionStatus.restricted &&
        microphonePermissionStatus == PermissionStatus.restricted) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  static void _handlemicrophoneInvalidPermissions(
      PermissionStatus microphonePermissionStatus) {
    if (microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to microphone denied",
          details: null);
    } else if (microphonePermissionStatus == PermissionStatus.restricted) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }
}
