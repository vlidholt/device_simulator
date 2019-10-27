import 'package:flutter/material.dart';

class DeviceSpecification {
  final Size size;
  final EdgeInsets padding;
  final EdgeInsets paddingLandscape;
  final String name;
  final double cornerRadius;
  final Size notchSize;
  final bool tablet;
  final double navBarHeight;

  DeviceSpecification({this.name, this.size, this.padding, this.paddingLandscape, this.cornerRadius=0.0, this.notchSize, this.tablet=false, this.navBarHeight=48.0});
}
