import 'package:flutter/material.dart';
import 'package:device_simulator/device_simulator.dart';

const bool debugEnableDeviceSimulator = true;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeviceSimulator demo',
      home: DeviceSimulator(
        brightness: Brightness.dark,
        enable: debugEnableDeviceSimulator,
        child: Scaffold(
          appBar: AppBar(
            title: Text('DeviceSimulator Demo'),
          ),
          body: Center(
            child: Text('Hello multiple resolutions!'),
          ),
        ),
      ),
    );
  }
}