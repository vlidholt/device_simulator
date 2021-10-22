import 'package:dotup_device_simulator/dotup_device_simulator.dart';
import 'package:dotup_device_simulator/src/Notch.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'bottom_bar.dart';
import 'custom_navigator.dart';
import 'device_spec_list.dart';
// import 'disabled.dart';
import 'fake_android_status_bar.dart';
import 'fake_ios_status_bar.dart';
import 'fake_status_bar.dart';

/// Add the [DeviceSimulator] at the root of your widget tree, right below your
/// App widget. DeviceSimulator will override the devices [MediaQueryData] and
/// draw simulated device frames for different devices. It will also simulate
/// the iOS or Android status bars (and on Android bottom navigation).
/// You can disable the [DeviceSimulator] by setting the [enable] property to
/// false.
class DeviceSimulator extends StatefulWidget {
  /// The widget tree that is affected handled by the [DeviceSimulator],
  /// typically this is your whole app except the top [App] widget.
  late final WidgetBuilder builder;

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

  final bool showBottomBar;

  final bool showDeviceSlider;

  static late MediaQueryData mediaQueryData;

  /// Creates a new [DeviceSimulator].
  DeviceSimulator({
    // Widget? child,
    required this.builder,
    this.enable = true,
    this.brightness = Brightness.light,
    this.iOSMultitaskBarColor = Colors.grey,
    this.androidShowNavigationBar = true,
    this.androidStatusBarBackgroundColor = Colors.black26,
    this.orientation,
    this.initialDeviceIndex = 0,
    this.initialPlatform = TargetPlatform.android,
    Color? backgroundColor,
    this.showBottomBar = true,
    this.showDeviceSlider = true,
  }) : this.backgroundColor = backgroundColor ?? Colors.grey.shade900;

  _DeviceSimulatorState createState() => _DeviceSimulatorState();
}

class _DeviceSimulatorState extends State<DeviceSimulator> {
  final _contentKey = UniqueKey();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late DeviceSpecification _currentDevice;
  late TargetPlatform _platform;
  // final _menuKey = GlobalKey();
  late Orientation _orientation;
  late bool _showDeviceSlider;
  late List<DeviceSpecification> devices;

  @override
  void initState() {
    super.initState();

    if (widget.enable) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
    _orientation = widget.orientation ?? Orientation.landscape;
    _platform = widget.initialPlatform;
    devices = _platform == TargetPlatform.iOS ? iosDevices : androidDevices;
    _currentDevice = devices[widget.initialDeviceIndex];
    _showDeviceSlider = widget.showDeviceSlider;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) {
      DeviceSimulator.mediaQueryData = MediaQuery.of(context);
      return widget.builder(context);
    }

    var realMediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);

    devices = _platform == TargetPlatform.iOS ? iosDevices : androidDevices;

    Size simulatedSize = _currentDevice.size;

    final isLandscape = _orientation == Orientation.landscape;

    // final isLandscape =
    //     widget.orientation == null ? realMediaQuery.orientation == Orientation.landscape : widget.orientation == Orientation.landscape;

    if (isLandscape) {
      simulatedSize = simulatedSize.flipped;
    }

    double navBarHeight = 0.0;
    if (_platform == TargetPlatform.android && widget.androidShowNavigationBar) {
      navBarHeight = _currentDevice.navBarHeight;
    }

    EdgeInsets padding = _currentDevice.padding;
    if (isLandscape && _currentDevice.paddingLandscape != null) {
      padding = _currentDevice.paddingLandscape!;
    }

    DeviceSimulator.mediaQueryData = realMediaQuery.copyWith(
      size: Size(simulatedSize.width, simulatedSize.height - navBarHeight),
      padding: padding,
    );

    Widget clippedContent = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(_currentDevice.cornerRadius)),
      child: Padding(
        padding: EdgeInsets.only(bottom: navBarHeight),
        child: MediaQuery(
          key: _contentKey,
          data: DeviceSimulator.mediaQueryData,
          child: Theme(
            data: theme.copyWith(platform: _platform),
            child: CustomNavigator(
              navigatorKey: _navigatorKey,
              home: widget.builder(context),
              pageRoute: PageRoutes.materialPageRoute,
            ),
          ),
        ),
      ),
    );

    clippedContent = Stack(
      children: <Widget>[
        Container(width: simulatedSize.width, height: simulatedSize.height, child: clippedContent),
        Notch(
          simulatedSize: simulatedSize,
          notchSize: _currentDevice.notchSize,
          isLandscape: isLandscape,
          backgroundColor: widget.backgroundColor,
        ),
        FakeStatusBar(
          padding: padding,
          platform: _platform,
          widget: widget,
          spec: _currentDevice,
        ),
        if (_platform == TargetPlatform.iOS && _currentDevice.cornerRadius > 0.0 && realMediaQuery.size != simulatedSize)
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            height: _currentDevice.padding.bottom,
            child: FakeIOSMultitaskBar(
              width: simulatedSize.width / 3.0,
              color: widget.iOSMultitaskBarColor,
              tablet: _currentDevice.tablet,
            ),
          ),
        if (_platform == TargetPlatform.android && widget.androidShowNavigationBar)
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            height: _currentDevice.navBarHeight,
            child: FakeAndroidNavBar(
              height: _currentDevice.navBarHeight,
              cornerRadius: _currentDevice.cornerRadius,
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
              child: FittedBox(
                child: Container(
                  width: simulatedSize.width,
                  height: simulatedSize.height,
                  child: clippedContent,
                ),
              ),
            ),
          ),
          if (widget.showBottomBar)
            BottomBar(
              devices: devices,
              device: _currentDevice,
              orientation: _orientation,
              realMediaQuery: realMediaQuery,
              simulatedSize: simulatedSize,
              onDeviceChanged: (value) {
                setState(() {
                  _platform = value.device.platform;
                  _currentDevice = value.device;
                  _orientation = value.orientation;
                });
              },
            ),
        ],
      ),
    );
  }
}

class DeviceChanged {
  DeviceSpecification device;
  Orientation orientation;

  DeviceChanged({required this.device, required this.orientation});
}
