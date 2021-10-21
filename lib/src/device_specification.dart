import 'package:flutter/material.dart';

class DeviceSpecification {
  final Size size;
  final EdgeInsets padding;
  final EdgeInsets? paddingLandscape;
  final String name;
  final double cornerRadius;
  final Size? notchSize;
  final bool tablet;
  final double navBarHeight;
  final TargetPlatform platform;

  DeviceSpecification(
      {required this.name,
      required this.size,
      required this.padding,
      required this.platform,
      this.paddingLandscape,
      this.cornerRadius = 0.0,
      this.notchSize,
      this.tablet = false,
      this.navBarHeight = 48.0});
}
