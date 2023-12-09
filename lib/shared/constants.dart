import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

dynamic kWidth;
dynamic kHeight;
List<CameraDescription>? cameras;

String noImage = "assets/images/no_image.png";

recognitionResult(MapEntry<String, num> recognition) {
  double confidence = (recognition.value * 100);
  var label = recognition.key.split("_").join(" ");
  return "$label (${confidence.roundToDouble()}%)";
}
// With_Mask ----> [With,Mask] --> With Mask (100%)
// {confidence: 1.0, index: 0, label: With_Mask}

checkPermissions(context) async {
  var map = await [Permission.camera, Permission.locationWhenInUse].request();
  if (map[Permission.camera] != PermissionStatus.granted) {
    await Permission.camera.request();
  }
  if (map[Permission.locationWhenInUse] != PermissionStatus.granted) {
    await Permission.locationWhenInUse.request();
  }
}
