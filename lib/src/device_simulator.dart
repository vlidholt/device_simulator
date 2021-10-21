import 'dart:io';

import 'package:dotup_device_simulator/src/Notch.dart';
import 'package:dotup_device_simulator/src/device_specification.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'custom_navigator.dart';
import 'device_spec_list.dart';
import 'disabled.dart';
import 'fake_android_status_bar.dart';
import 'fake_ios_status_bar.dart';
import 'apple_icon.dart';

const double _kSettingsHeight = 72.0;
final Color? _kDividerColor = Colors.grey[700];

final _kTextStyle = TextStyle(
  color: Colors.white,
  fontFamily: '.SF UI Text',
  fontSize: 12.0,
  decoration: TextDecoration.none,
);

/// Add the [DeviceSimulator] at the root of your widget tree, right below your
/// App widget. DeviceSimulator will override the devices [MediaQueryData] and
/// draw simulated device frames for different devices. It will also simulate
/// the iOS or Android status bars (and on Android bottom navigation).
/// You can disable the [DeviceSimulator] by setting the [enable] property to
/// false.
class DeviceSimulator extends StatefulWidget {
  /// The widget tree that is affected handled by the [DeviceSimulator],
  /// typically this is your whole app except the top [App] widget.
  final Widget child;

  /// Enables or disables the DeviceSimulator, default is enabled, but this
  /// should be set to false in production.
  final bool enable;

  /// The [brightness] decides how to draw the status bar (black or white).
  final Brightness brightness;

  /// The color of the iOS multitasking bar that is available on newer
  /// iOS devices without a home button.
  final Color iOSMultitaskBarColor;

  /// Visibility of the bottom Android navigation bar (default is visible).
  final bool androidShowNavigationBar;

  /// The color of the top Android status bar (default is transparent black).
  final Color androidStatusBarBackgroundColor;

  final Orientation? orientation;

  final Color backgroundColor;

  final int initialDeviceIndex;
  final TargetPlatform initialPlatform;

  /// Creates a new [DeviceSimulator].
  DeviceSimulator({
    required this.child,
    this.enable = true,
    this.brightness = Brightness.light,
    this.iOSMultitaskBarColor = Colors.grey,
    this.androidShowNavigationBar = true,
    this.androidStatusBarBackgroundColor = Colors.black26,
    this.orientation,
    this.initialDeviceIndex = 0,
    this.initialPlatform = TargetPlatform.android,
    Color? backgroundColor,
  }) : this.backgroundColor = backgroundColor ?? Colors.grey.shade900;

  _DeviceSimulatorState createState() => _DeviceSimulatorState();
}

class _DeviceSimulatorState extends State<DeviceSimulator> {
  final _contentKey = UniqueKey();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late int _currentDevice;
  late TargetPlatform _platform;

  @override
  void initState() {
    super.initState();
    if (widget.enable) SystemChrome.setEnabledSystemUIOverlays([]);

    _platform = widget.initialPlatform;
    _currentDevice = widget.initialDeviceIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) {
      return widget.child;
    }

    var realMediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);

    if (realMediaQuery.size.width < 768.0 || realMediaQuery.size.height < 768.0) {
      return DisabledDeviceSimulator(
        child: widget.child,
        style: _kTextStyle,
      );
    }

    var specs = _platform == TargetPlatform.iOS ? iosSpecs : androidSpecs;
    var spec = specs[_currentDevice];

    Size simulatedSize = spec.size;

    final isLandscape =
        widget.orientation == null ? realMediaQuery.orientation == Orientation.landscape : widget.orientation == Orientation.landscape;
    if (isLandscape) {
      simulatedSize = simulatedSize.flipped;
    }
    double navBarHeight = 0.0;
    if (_platform == TargetPlatform.android && widget.androidShowNavigationBar) {
      navBarHeight = spec.navBarHeight;
    }

    bool overflowWidth = false;
    bool overflowHeight = false;

    if (simulatedSize.width > realMediaQuery.size.width) {
      simulatedSize = Size(realMediaQuery.size.width, simulatedSize.height);
      overflowWidth = true;
    }

    double settingsHeight = _kSettingsHeight;
    if (simulatedSize.height > realMediaQuery.size.height - settingsHeight) {
      simulatedSize = Size(simulatedSize.width, realMediaQuery.size.height - settingsHeight);
      overflowHeight = true;
    }

    EdgeInsets padding = spec.padding;
    if (isLandscape && spec.paddingLandscape != null) padding = spec.paddingLandscape!;

    Widget clippedContent = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(spec.cornerRadius)),
      child: Padding(
        padding: EdgeInsets.only(bottom: navBarHeight),
        child: MediaQuery(
          key: _contentKey,
          data: realMediaQuery.copyWith(
            size: Size(simulatedSize.width, simulatedSize.height - navBarHeight),
            padding: padding,
          ),
          child: Theme(
            data: theme.copyWith(platform: _platform),
            child: CustomNavigator(
              navigatorKey: _navigatorKey,
              home: widget.child,
              pageRoute: PageRoutes.materialPageRoute,
            ),
          ),
        ),
      ),
    );

    clippedContent = Stack(
      children: <Widget>[
        clippedContent,
        Notch(
          simulatedSize: simulatedSize,
          notchSize: spec.notchSize,
          isLandscape: isLandscape,
          backgroundColor: widget.backgroundColor,
        ),
        FakeStatusBar(
          padding: padding,
          platform: _platform,
          widget: widget,
          spec: spec,
        ),
        if (_platform == TargetPlatform.iOS && spec.cornerRadius > 0.0 && realMediaQuery.size != simulatedSize)
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            height: spec.padding.bottom,
            child: FakeIOSMultitaskBar(
              width: simulatedSize.width / 3.0,
              color: widget.iOSMultitaskBarColor,
              tablet: spec.tablet,
            ),
          ),
        if (widget.androidShowNavigationBar && _platform == TargetPlatform.android)
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            height: spec.navBarHeight,
            child: FakeAndroidNavBar(
              height: spec.navBarHeight,
              cornerRadius: spec.cornerRadius,
            ),
          ),
      ],
    );

    return Material(
      color: widget.backgroundColor,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment(0.0, 0.0),
              child: Container(
                width: simulatedSize.width,
                height: simulatedSize.height,
                child: clippedContent,
              ),
            ),
          ),
          Container(
            height: 72.0,
            color: Colors.black,
            padding: EdgeInsets.only(
                left: 16.0 + realMediaQuery.padding.left,
                right: 16.0 + realMediaQuery.padding.right,
                bottom: realMediaQuery.padding.bottom),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.android,
                    color: _platform == TargetPlatform.android ? Colors.white : Colors.white24,
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
                    color: _platform == TargetPlatform.iOS ? Colors.white : Colors.white24,
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
                            style: _kTextStyle.copyWith(color: overflowWidth ? Colors.orange : null),
                          ),
                          Text(
                            ' • ',
                            style: _kTextStyle,
                          ),
                          Text(
                            '${simulatedSize.height.round()} px',
                            style: _kTextStyle.copyWith(color: overflowHeight ? Colors.orange : null),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          specs[_currentDevice].name,
                          style: _kTextStyle.copyWith(color: Colors.white54, fontSize: 10.0),
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

    // return GestureDetector(
    //   behavior: HitTestBehavior.deferToChild,
    //   child: IgnorePointer(
    //     ignoring: _screenshotMode,
    //     child: screen,
    //   ),
    //   onTap: _screenshotMode
    //       ? () {
    //           setState(() {
    //             _screenshotMode = false;
    //           });
    //         }
    //       : null,
    // );
  }
}

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
