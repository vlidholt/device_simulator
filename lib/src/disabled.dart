import 'package:flutter/material.dart';

class DisabledDeviceSimulator extends StatefulWidget {
  final Widget child;
  final TextStyle style;

  DisabledDeviceSimulator({this.child, this.style});

  _DisabledDeviceSimulatorState createState() => _DisabledDeviceSimulatorState();
}

class _DisabledDeviceSimulatorState extends State<DisabledDeviceSimulator> {
  bool showWarning = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: showWarning ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      onTap: () {
        setState(() {
          showWarning = false;
        });
      },
      child: IgnorePointer(
        ignoring: showWarning,
        child: Stack(
          children: <Widget>[
            widget.child,
            if (showWarning) Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    elevation: 8.0,
                    color: Colors.black,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'DeviceSimulator is enabled, but the screen size is too small. This widget is best used on tablets.',
                        style: widget.style,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}