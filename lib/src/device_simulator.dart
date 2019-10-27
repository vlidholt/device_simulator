import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'device_spec_list.dart';
import 'disabled.dart';
import 'fake_android_status_bar.dart';
import 'fake_ios_status_bar.dart';
import 'apple_icon.dart';

const double _kSettingsHeight = 72.0;
final Color _kBackgroundColor = Colors.grey[900];
final Color _kDividerColor = Colors.grey[700];
final _kTextStyle = TextStyle(
  color: Colors.white,
  fontFamily: '.SF UI Text',
  fontSize: 12.0,
  decoration: TextDecoration.none,
);

int _currentDevice = 0;
bool _screenshotMode = false;
TargetPlatform _platform = TargetPlatform.iOS;

class DeviceSimulator extends StatefulWidget {
  final Widget child;
  final bool enable;
  final Brightness brightness;
  final Color iOSMultitaskBarColor;
  final bool androidShowNavigationBar;
  final Color androidStatusBarBackgroundColor;

  DeviceSimulator(
      {this.child,
      this.enable = true,
      this.brightness = Brightness.light,
      this.iOSMultitaskBarColor = Colors.grey,
      this.androidShowNavigationBar = true,
      this.androidStatusBarBackgroundColor = Colors.black26});

  _DeviceSimulatorState createState() => _DeviceSimulatorState();
}

class _DeviceSimulatorState extends State<DeviceSimulator> {
  Key _contentKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    if (widget.enable) SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) return widget.child;

    var mq = MediaQuery.of(context);
    var theme = Theme.of(context);

    if (mq.size.width < 768.0 || mq.size.height < 768.0) {
      return DisabledDeviceSimulator(
        child: widget.child,
        style: _kTextStyle,
      );
    }

    var specs = _platform == TargetPlatform.iOS ? iosSpecs : androidSpecs;
    var spec = specs[_currentDevice];

    Size simulatedSize = spec.size;
    if (mq.orientation == Orientation.landscape)
      simulatedSize = simulatedSize.flipped;

    double navBarHeight = 0.0;
    if (_platform == TargetPlatform.android && widget.androidShowNavigationBar)
      navBarHeight = spec.navBarHeight;

    bool overflowWidth = false;
    bool overflowHeight = false;

    if (simulatedSize.width > mq.size.width) {
      simulatedSize = Size(mq.size.width, simulatedSize.height);
      overflowWidth = true;
    }

    double settingsHeight = _screenshotMode ? 0.0 : _kSettingsHeight;
    if (simulatedSize.height > mq.size.height - settingsHeight) {
      simulatedSize =
          Size(simulatedSize.width, mq.size.height - settingsHeight);
      overflowHeight = true;
    }

    double cornerRadius = _screenshotMode ? 0.0 : spec.cornerRadius;

    EdgeInsets padding = spec.padding;
    if (mq.orientation == Orientation.landscape &&
        spec.paddingLandscape != null) padding = spec.paddingLandscape;

    var content = MediaQuery(
      key: _contentKey,
      data: mq.copyWith(
        size: Size(simulatedSize.width, simulatedSize.height - navBarHeight),
        padding: padding,
      ),
      child: Theme(
        data: theme.copyWith(platform: _platform),
        child: widget.child,
      ),
    );

    Widget clippedContent = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
      child: Padding(
        padding: EdgeInsets.only(bottom: navBarHeight),
        child: content,
      ),
    );

    Size notchSize = _screenshotMode ? Size.zero : spec.notchSize ?? Size.zero;
    Widget notch;
    if (mq.orientation == Orientation.landscape) {
      notch = Positioned(
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
            color: _kBackgroundColor,
          ),
        ),
      );
    } else {
      notch = Positioned(
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
            color: _kBackgroundColor,
          ),
        ),
      );
    }

    Widget fakeStatusBar = Positioned(
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

    Widget fakeMultitaskBar = Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      height: spec.padding.bottom,
      child: FakeIOSMultitaskBar(
        width: simulatedSize.width / 3.0,
        color: widget.iOSMultitaskBarColor,
        tablet: spec.tablet,
      ),
    );

    Widget fakeNavigationBar = Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      height: spec.navBarHeight,
      child: FakeAndroidNavBar(
        height: spec.navBarHeight,
        cornerRadius: cornerRadius,
      ),
    );

    clippedContent = Stack(
      children: <Widget>[
        clippedContent,
        notch,
        fakeStatusBar,
        if (_platform == TargetPlatform.iOS &&
            spec.cornerRadius > 0.0 &&
            mq.size != simulatedSize)
          fakeMultitaskBar,
        if (widget.androidShowNavigationBar &&
            _platform == TargetPlatform.android)
          fakeNavigationBar,
      ],
    );

    var screen = Material(
      color: _kBackgroundColor,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment:
                  _screenshotMode ? Alignment(-1.0, -1.0) : Alignment(0.0, 0.0),
              child: Container(
                width: simulatedSize.width,
                height: simulatedSize.height,
                child: clippedContent,
              ),
            ),
          ),
          if (!_screenshotMode)
            Container(
              height: 72.0,
              color: Colors.black,
              padding: EdgeInsets.only(
                  left: 16.0 + mq.padding.left,
                  right: 16.0 + mq.padding.right,
                  bottom: mq.padding.bottom),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.android,
                      color: _platform == TargetPlatform.android
                          ? Colors.white
                          : Colors.white24,
                      size: 22.0,
                    ),
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.android;
                        _currentDevice = 0;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      IconApple.apple, // TODO: better image
                      color: _platform == TargetPlatform.iOS
                          ? Colors.white
                          : Colors.white24,
                      size: 20.0,
                    ),
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.iOS;
                        _currentDevice = 0;
                      });
                    },
                  ),
                  VerticalDivider(
                    color: _kDividerColor,
                    indent: 4.0,
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        _screenshotMode = true;
                      });
                    },
                  ),
                  VerticalDivider(
                    color: _kDividerColor,
                    indent: 4.0,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 8.0),
                    width: 120.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${simulatedSize.width.round()} px',
                              style: _kTextStyle.copyWith(
                                  color: overflowWidth ? Colors.orange : null),
                            ),
                            Text(
                              ' • ',
                              style: _kTextStyle,
                            ),
                            Text(
                              '${simulatedSize.height.round()} px',
                              style: _kTextStyle.copyWith(
                                  color: overflowHeight ? Colors.orange : null),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            specs[_currentDevice].name,
                            style: _kTextStyle.copyWith(
                                color: Colors.white54, fontSize: 10.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      divisions: specs.length - 1,
                      min: 0.0,
                      max: (specs.length - 1).toDouble(),
                      value: _currentDevice.toDouble(),
                      label: specs[_currentDevice].name,
                      onChanged: (double device) {
                        setState(() {
                          _currentDevice = device.round();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      behavior: _screenshotMode
          ? HitTestBehavior.opaque
          : HitTestBehavior.deferToChild,
      child: IgnorePointer(
        ignoring: _screenshotMode,
        child: screen,
      ),
      onTap: _screenshotMode
          ? () {
              setState(() {
                _screenshotMode = false;
              });
            }
          : null,
    );
  }
}
