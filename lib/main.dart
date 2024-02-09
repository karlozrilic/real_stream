import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';

List<CameraDescription>? cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  cameras = await availableCameras();

  runApp(MaterialApp(
      theme: ThemeData.dark(),
      home: const MyHome(),
    ),
  );
}