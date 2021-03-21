import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import './ble_details_screen.dart';

class BleFavoritesScreen extends StatefulWidget {
  BleFavoritesScreen(this.favorites);
  final Set<BluetoothDevice> favorites;

  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  _BleFavoritesState createState() => _BleFavoritesState();
}

class _BleFavoritesState extends State<BleFavoritesScreen> {
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
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      device.name == '' ? '(unknown device)' : device.name,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      device.id.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              !isLoading(device)
                  ? TextButton(
                      child: Text('Connect'),
                      onPressed: () async {
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                  connectedDevice: _connectedDevice,
                                  services: _services)),
                        );
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                      widthFactor: 1.9,
                    )
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
