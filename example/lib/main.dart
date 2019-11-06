import 'package:device_simulator/device_simulator.dart';
import 'package:flutter/material.dart';

// It's good practice to define a constant for enabling the device simulator
// so you can easily turn it on or off
const bool debugEnableDeviceSimulator = true;

void main() => runApp(MyApp());

// Insert Device simulator at the top of your widget, as a child of your
// App widget. Build the rest of your widget tree as you would normally do.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DeviceSimulator(
        brightness: Brightness.dark,
        enable: debugEnableDeviceSimulator,
        child: MaterialApp(
          title: 'DeviceSimulator demo',
          initialRoute: '/',
          routes: {
            '/': (context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('DeviceSimulator Demo'),
                ),
                body: SizedBox.expand(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      Text('Hello multiple resolutions!'),
                      RaisedButton(
                        child: Text('Open'),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/test');
                        },
                      )
                    ])),
              );
            },
            '/test': (context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Navigator Test'),
                ),
                body: Center(
                  child: Text('Hello  multiple resolutions!'),
                ),
              );
            }
          },
        ));
  }
}
