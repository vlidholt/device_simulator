import 'package:dotup_flutter_widgets/dotup_flutter_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'constants.dart';
import 'device_popup_menu.dart';
import 'device_simulator.dart';
import 'device_spec_list.dart';
import 'device_specification.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    Key? key,
    required this.realMediaQuery,
    required this.orientation,
    required this.device,
    required this.onDeviceChanged,
    required this.simulatedSize,
    required this.devices,
  }) : super(key: key);

  final MediaQueryData realMediaQuery;
  final Orientation orientation;
  final DeviceSpecification device;
  final List<DeviceSpecification> devices;
  final ValueSetter<DeviceChanged> onDeviceChanged;
  final Size simulatedSize;

  @override
  Widget build(BuildContext context) {
    final portraitColor = orientation == Orientation.portrait ? Colors.white : Colors.white24;
    final landscapeColor = orientation == Orientation.landscape ? Colors.white : Colors.white24;

    final iosColor = device.platform == TargetPlatform.iOS ? Colors.white : Colors.white24;
    final androidColor = device.platform == TargetPlatform.android ? Colors.white : Colors.white24;
    final _showDeviceInfo = realMediaQuery.size.width > 500;
    final _showDeviceSlider = realMediaQuery.size.width > 700;

    bool overflowWidth = simulatedSize.width > realMediaQuery.size.width;
    bool overflowHeight = simulatedSize.height > realMediaQuery.size.height - kSettingsHeight;

    return Container(
      height: 72.0,
      color: Colors.black,
      padding: EdgeInsets.only(
          left: 16.0 + realMediaQuery.padding.left, right: 16.0 + realMediaQuery.padding.right, bottom: realMediaQuery.padding.bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DeviceDropDown(
            iconData: Icons.android,
            devices: androidDevices,
            currentIndex: 0,
            backgroundColor: Colors.black,
            iconColor: androidColor,
            onDeviceSelected: (value) {
              onDeviceChanged(DeviceChanged(device: value, orientation: orientation));
            },
          ),
          DeviceDropDown(
            iconData: FontAwesomeIcons.apple,
            devices: iosDevices,
            currentIndex: 0,
            backgroundColor: Colors.black,
            iconColor: iosColor,
            onDeviceSelected: (value) {
              onDeviceChanged(DeviceChanged(device: value, orientation: orientation));
            },
          ),
          VerticalDivider(
            color: kDividerColor,
            indent: 4.0,
          ),
          IconButton(
            onPressed: () {
              onDeviceChanged(DeviceChanged(device: device, orientation: Orientation.portrait));
            },
            icon: Icon(Icons.stay_current_portrait, color: portraitColor),
          ),
          IconButton(
            onPressed: () {
              onDeviceChanged(DeviceChanged(device: device, orientation: Orientation.landscape));
            },
            icon: Icon(Icons.stay_current_landscape, color: landscapeColor),
          ),
          VerticalDivider(
            color: kDividerColor,
            indent: 4.0,
          ),
          if (_showDeviceInfo)
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
                        style: kTextStyle.copyWith(color: overflowWidth ? Colors.orange : null),
                      ),
                      Text(
                        ' • ',
                        style: kTextStyle,
                      ),
                      Text(
                        '${simulatedSize.height.round()} px',
                        style: kTextStyle.copyWith(color: overflowHeight ? Colors.orange : null),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      device.name,
                      style: kTextStyle.copyWith(color: Colors.white54, fontSize: 10.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _showDeviceSlider
                ? Slider(
                    divisions: devices.length - 1,
                    min: 0.0,
                    max: (devices.length - 1).toDouble(),
                    value: devices.indexOf(device).toDouble(),
                    label: device.name,
                    onChanged: (double device) {
                      final newDevice = devices[device.toInt()];
                      onDeviceChanged(DeviceChanged(device: newDevice, orientation: orientation));
                    },
                  )
                : SizedBox.expand(),
          ),
          VerticalDivider(
            color: kDividerColor,
            indent: 4.0,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
            child: DotupLogo(),
          ),
        ],
      ),
    );
  }
}
