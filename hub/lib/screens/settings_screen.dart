import 'package:flutter/material.dart';

import '../constants/info.dart';
import '../settings.dart';

//ignore: must_be_immutable
class Settings extends StatefulWidget {
  Settings(this.settings, {this.onSaveSettings});

  final SaveSettingsCallback onSaveSettings;
  final BleSettings settings;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
            value: widget.settings.bleSenseMode,
            onChanged: (bool newValue) {
              widget.settings.bleSenseMode = newValue;
              setState(() {
                widget.onSaveSettings(widget.settings);
              });
            },
          ),
        ],
      ),
    );
  }
}

typedef SaveSettingsCallback = void Function(BleSettings settings);
