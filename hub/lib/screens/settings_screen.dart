import 'package:flutter/material.dart';

import '../constants/info.dart';

//ignore: must_be_immutable
class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool bleSenseMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text(
              Info.bleAppName + " Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            margin: EdgeInsets.all(10),
          ),
          CheckboxListTile(
            title: Text("BLE Sense mode"),
            value: bleSenseMode,
            onChanged: (bool newValue) {
              setState(() {
                bleSenseMode = newValue;
              });
            },
          ),
        ],
      ),
    );
  }
}
