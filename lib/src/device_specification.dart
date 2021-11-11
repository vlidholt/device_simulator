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

  DeviceSpecification({
    required this.name,
    required this.size,
    required this.padding,
    required this.platform,
    this.paddingLandscape,
    this.cornerRadius = 0.0,
    this.notchSize,
    this.tablet = false,
    this.navBarHeight = 48.0,
  });

  factory DeviceSpecification.fromPixel({
    required double height,
    required double width,
    required double pixelRatio,
    required EdgeInsets padding,
    EdgeInsets? paddingLandscape,
    required String name,
    double cornerRadius = 0.0,
    Size? notchSize,
    bool tablet = false,
    double navBarHeight = 48,
    required TargetPlatform platform,
  }) {
    return DeviceSpecification(
      name: name,
      padding: padding,
      platform: platform,
      size: Size(width / pixelRatio, height / pixelRatio),
      cornerRadius: cornerRadius,
      navBarHeight: navBarHeight,
      notchSize: notchSize,
      paddingLandscape: paddingLandscape,
      tablet: tablet,
    );
  }
}
