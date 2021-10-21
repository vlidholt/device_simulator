import 'package:dotup_device_simulator/dotup_device_simulator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeviceDropDown extends StatelessWidget {
  const DeviceDropDown({
    Key? key,
    required this.devices,
    required this.currentIndex,
    required this.backgroundColor,
    required this.onDeviceSelected,
    required this.iconData,
    required this.iconColor,
  }) : super(key: key);

  final List<DeviceSpecification> devices;
  final int currentIndex;
  final Color backgroundColor;
  final ValueSetter<DeviceSpecification> onDeviceSelected;
  final IconData iconData;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: PopupMenuButton<DeviceSpecification>(
        key: key,
        // color: Colors.green,
        padding: EdgeInsets.zero,
        initialValue: devices.first,
        icon: Icon(
          iconData,
          color: iconColor,
        ),
        onSelected: onDeviceSelected,
        itemBuilder: (context) => _getMenuItems(context),
      ),
    );
  }

  List<PopupMenuItem<DeviceSpecification>> _getMenuItems(BuildContext context) {
    var index = 1;
    final style = TextStyle(color: index == currentIndex ? Colors.white : null);

    return devices.map((e) {
      index++;
      final leading = e.tablet == true ? Icons.tablet : Icons.phone;

      return PopupMenuItem(
        child: ListTile(
          // tileColor: index == currentIndex ? Colors.grey.shade800 : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          dense: true,
          title: Text(
            e.name,
            style: style,
          ),
          leading: Icon(leading),
        ),
        value: e,
        enabled: index != currentIndex,
      );
    }).toList();
  }
}
