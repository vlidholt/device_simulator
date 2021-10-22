import 'package:dotup_device_simulator/dotup_device_simulator.dart';
import 'package:dotup_flutter_widgets/dotup_flutter_widgets.dart';
import 'package:flutter/material.dart';

// It's good practice to define a constant for enabling the device simulator
// so you can easily turn it on or off
const bool debugEnableDeviceSimulator = true;

void main() => runApp(MyApp());

// Insert Device simulator at the top of your widget, as a child of your
// App widget. Build the rest of your widget tree as you would normally do.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dotup rapid flutter prototyping',
      home: DeviceSimulator(
        initialDeviceIndex: 3,
        initialPlatform: TargetPlatform.android,
        orientation: Orientation.portrait,
        brightness: Brightness.dark,
        showBottomBar: true,
        enable: debugEnableDeviceSimulator,
        builder: (_) => ScreenInfoPage(),
      ),
    );
  }
}
