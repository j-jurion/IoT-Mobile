import 'dart:io';

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

  Column _buildConnectDeviceView() {
    List<Container> containers = [];

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = [];

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        characteristic.uuid.toString(),
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      containers.add(
        Container(
          margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Column(
            children: [
              Text(
                service.uuid.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Column(
                children: characteristicsWidget,
              ),
              Divider(),
            ],
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        ...containers,
      ],
    );
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
                  onExpansionChanged: (expanding) async {
                    if (expanding) {
                      print("Expanding and connecting...");
                      setState(() {
                        _loadingDevice = device;
                      });
                      widget.flutterBlue.stopScan();
                      try {
                        await device.connect();
                      } catch (e) {
                        if (e.code != 'already_connected') {
                          throw e;
                        }
                      } finally {
                        _services = await device.discoverServices();
                      }
                      setState(() {
                        _connectedDevice = device;
                        _loadingDevice = null;
                      });
                      sleep(Duration(seconds: 1));
                    } else {
                      print("Closing and disconnecting...");
                    }
                  },
                  children: [
                    _connectedDevice != null
                        ? _buildConnectDeviceView()
                        : Text('No connected device'),
                  ],
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
