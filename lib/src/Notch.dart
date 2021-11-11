import 'package:dotup_device_simulator/dotup_device_simulator.dart';
import 'package:flutter/material.dart';

class Notch extends StatelessWidget {
  const Notch({
    Key? key,
    required this.simulatedSize,
    Size? notchSize,
    required this.isLandscape,
    required this.backgroundColor,
  })  : this.notchSize = notchSize ?? Size.zero,
        super(key: key);

  final Size notchSize;
  final Size simulatedSize;
  final bool isLandscape;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (isLandscape) {
      return Positioned(
        left: 0.0,
        top: (simulatedSize.height - notchSize.width) / 2.0,
        width: notchSize.height,
        height: notchSize.width,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(notchSize.height / 2.0),
              bottomRight: Radius.circular(notchSize.height / 2.0),
            ),
            color: backgroundColor,
          ),
        ),
      );
    } else {
      return Positioned(
        top: 0.0,
        right: (simulatedSize.width - notchSize.width) / 2.0,
        width: notchSize.width,
        height: notchSize.height,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(notchSize.height / 2.0),
              bottomRight: Radius.circular(notchSize.height / 2.0),
            ),
            color: backgroundColor,
          ),
        ),
      );
    }
  }
}
