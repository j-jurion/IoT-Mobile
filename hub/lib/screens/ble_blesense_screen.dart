import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import './ble_details_screen.dart';

class BleSenseScreen extends StatefulWidget {
  BleSenseScreen(this.favorites);
  final Set<BluetoothDevice> favorites;

  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  _BleSenseScreenState createState() => _BleSenseScreenState();
}

class _BleSenseScreenState extends State<BleSenseScreen> {
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  BluetoothDevice _loadingDevice;

  bool isLoading(BluetoothDevice device) {
    if (_loadingDevice == device) {
      return true;
    } else {
      return false;
    }
  }

  ListView _buildListViewOfFavoriteDevices() {
    List<Container> containers = [];

    for (BluetoothDevice device in widget.favorites) {
      containers.add(
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: ExpansionTile(
                  title: Text(
                    device.name == '' ? '(unknown device)' : device.name,
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    device.id.toString(),
                    textAlign: TextAlign.center,
                  ),
                  children: [],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      body: _buildListViewOfFavoriteDevices(),
    ));
  }
}
