import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import './ble_details_screen.dart';

class BleDevices extends StatefulWidget {
  BleDevices(this.favorites, {Key key, this.title, this.onSaveFavorites})
      : super(key: key);

  final SaveFavoritesCallback onSaveFavorites;
  final Set<BluetoothDevice> favorites;
  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = [];
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _BleDevicesState createState() => new _BleDevicesState();
}

class _BleDevicesState extends State<BleDevices> {
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  BluetoothDevice _loadingDevice;

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  void _setFavorite(BluetoothDevice device) {
    if (widget.favorites.contains(device)) {
      widget.favorites.remove(device);
    } else {
      widget.favorites.add(device);
    }
    widget.onSaveFavorites(widget.favorites);
  }

  bool isLoading(BluetoothDevice device) {
    if (_loadingDevice == device) {
      return true;
    } else {
      return false;
    }
  }

  ListView _buildListViewOfDevices() {
    List<Container> containers = [];

    for (BluetoothDevice device in widget.devicesList) {
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
              IconButton(
                icon: new Icon(widget.favorites.contains(device)
                    ? Icons.star
                    : Icons.star_border),
                color: Colors.blue,
                onPressed: () {
                  setState(() {
                    _setFavorite(device);
                  });
                },
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
                              builder: (context) => Details(
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
      body: _buildListViewOfDevices(),
    ));
  }
}

typedef SaveFavoritesCallback = void Function(Set<BluetoothDevice> favorites);
