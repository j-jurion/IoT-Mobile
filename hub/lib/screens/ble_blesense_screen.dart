import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../settings.dart';

class BleSenseScreen extends StatefulWidget {
  BleSenseScreen(this.favorites, this.settings);
  final Set<BluetoothDevice> favorites;
  final BleSettings settings;

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final Map<Guid, int> readValues = new Map<Guid, int>();

  @override
  _BleSenseScreenState createState() => _BleSenseScreenState();
}

class _BleSenseScreenState extends State<BleSenseScreen> {
  List<BluetoothService> _services;
  bool isLoading = true;

  final _writeController = TextEditingController();

  List<ButtonTheme> _buildReadWriteNotifyButton(
    BluetoothCharacteristic characteristic,
  ) {
    List<ButtonTheme> buttons = [];

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              child: Text('READ'),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value[0];
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              child: Text('WRITE'),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _writeController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Send"),
                            onPressed: () {
                              characteristic.write(
                                  utf8.encode(_writeController.value.text));
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              child: Text('NOTIFY'),
              onPressed: () async {
                characteristic.value.listen((value) {
                  widget.readValues[characteristic.uuid] = value[0];
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  Column _buildConnectDeviceView() {
    List<Container> containers = [];

    for (BluetoothService service in _services) {
      if (service.uuid.toString() == widget.settings.service) {
        List<Widget> characteristicsWidget = [];
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          String characteristicText = characteristic.uuid.toString();
          if (characteristic.uuid.toString() == widget.settings.moisture) {
            characteristicText = "Moisture";
          } else if (characteristic.uuid.toString() ==
              widget.settings.temperature) {
            characteristicText = "Temperature";
          } else if (characteristic.uuid.toString() == widget.settings.light) {
            characteristicText = "Light";
          }
          characteristicsWidget.add(
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 180,
                          child: Text(
                            characteristicText,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        //To build for each characteristic a READ/WRITE/NOTIFY button
                        //..._buildReadWriteNotifyButton(characteristic),
                        Container(
                          width: 180,
                          child: Text(
                            widget.readValues[characteristic.uuid].toString(),
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.right,
                          ),
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
                  "Sensor",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Column(
                  children: characteristicsWidget,
                ),
                TextButton(
                  child: Text('READ ALL'),
                  onPressed: () async {
                    for (BluetoothCharacteristic characteristic
                        in service.characteristics) {
                      var sub = characteristic.value.listen((value) {
                        setState(() {
                          widget.readValues[characteristic.uuid] = value[0];
                        });
                      });
                      await characteristic.read();
                      sub.cancel();
                    }
                  },
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
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
                      setState(() {
                        isLoading = true;
                      });
                      print("Expanding and connecting...");
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
                        isLoading = false;
                      });
                    } else {
                      await device.disconnect();
                    }
                  },
                  children: [
                    isLoading
                        ? Container(
                            height: 60,
                            child: Center(
                              child: CircularProgressIndicator(),
                              widthFactor: 1.9,
                            ),
                          )
                        : _buildConnectDeviceView()
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
