import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hub/screens/about_screen.dart';

import './drawer.dart';
import './screens/about_screen.dart';

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
      home: Scaffold(
        appBar: AppBar(title: Text(appTitle)),
        body: Text('App under construction...'),
        drawer: AppDrawer(),
      ),
      routes: {
        '/about': (context) => About(),
      },
    );
  }
}
