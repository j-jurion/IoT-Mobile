import 'package:flutter/material.dart';
import 'package:hub/screens/about_screen.dart';
import 'package:hub/screens/ble_favorites_screen.dart';

import './drawer.dart';
import './screens/about_screen.dart';
import './screens/ble_favorites_screen.dart';
import './screens/ble_devices_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final appTitle = 'Hub';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.star)),
                Tab(icon: Icon(Icons.stay_current_portrait_outlined)),
              ],
            ),
            title: Text(appTitle),
          ),
          drawer: AppDrawer(),
          body: TabBarView(
            children: [
              BleFavorites(),
              BleDevices(),
            ],
          ),
        ),
      ),
      routes: {
        '/about': (context) => About(),
      },
    );
  }
}
