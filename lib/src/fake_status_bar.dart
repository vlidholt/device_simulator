import 'package:flutter/material.dart';

import '../dotup_device_simulator.dart';
import 'fake_android_status_bar.dart';
import 'fake_ios_status_bar.dart';

class FakeStatusBar extends StatelessWidget {
  const FakeStatusBar({
    Key? key,
    required this.padding,
    required TargetPlatform platform,
    required this.widget,
    required this.spec,
  })  : _platform = platform,
        super(key: key);

  final EdgeInsets padding;
  final TargetPlatform _platform;
  final DeviceSimulator widget;
  final DeviceSpecification spec;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      height: padding.top,
      child: _platform == TargetPlatform.iOS
          ? FakeIOSStatusBar(
              brightness: widget.brightness,
              height: padding.top,
              notch: spec.notchSize != null,
              roundedCorners: spec.cornerRadius > 0.0,
            )
          : FakeAndroidStatusBar(
              height: padding.top,
              backgroundColor: widget.androidStatusBarBackgroundColor,
            ),
    );
  }
}
