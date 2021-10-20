import 'package:flutter/material.dart';

class FakeIOSStatusBar extends StatelessWidget {
  final double height;
  final Brightness brightness;
  final bool tablet;
  final bool roundedCorners;
  final bool notch;

  final _uiStyle = TextStyle(
    fontFamily: '.SF UI',
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
  );

  final _uiStyleNotch = TextStyle(
    fontFamily: '.SF UI',
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
  );

  FakeIOSStatusBar({required this.height, required this.brightness, this.tablet = false, this.notch = true, this.roundedCorners = true});

  @override
  Widget build(BuildContext context) {
    TextStyle style = notch ? _uiStyleNotch : _uiStyle;
    style = style.copyWith(color: brightness == Brightness.light ? Colors.black : Colors.white);

    double leftPadding;
    double rightPadding;
    if (notch) {
      leftPadding = 20.0;
      rightPadding = 20.0;
    } else if (roundedCorners) {
      leftPadding = 20.0;
      rightPadding = 20.0;
    } else {
      leftPadding = 12.0;
      rightPadding = 8.0;
    }

    return Container(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: leftPadding, top: notch ? 2.0 : 2.0),
            child: Text(
              notch ? '1:37 PM' : '1:37 PM   Mon May 4',
              style: style,
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.only(right: rightPadding),
            child: SizedBox(
              height: notch ? 14.0 : 12.0,
              child: Image.asset(
                brightness == Brightness.light ? 'assets/ios-bar-black.png' : 'assets/ios-bar-white.png',
                // package: 'device_simulator',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FakeIOSMultitaskBar extends StatelessWidget {
  final double width;
  final bool tablet;
  final Color color;

  FakeIOSMultitaskBar({required this.width, required this.tablet, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      child: Center(
        child: Container(
          width: width,
          height: tablet ? 5.0 : 4.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
      ),
    );
  }
}
