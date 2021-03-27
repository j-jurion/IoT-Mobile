import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hub/screens/ble_blesense_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './drawer.dart';
import './screens/about_screen.dart';
import './screens/settings_screen.dart';
import './screens/ble_favorites_screen.dart';
import './screens/ble_devices_screen.dart';
import './constants/colors.dart';
import './constants/info.dart';
import './settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  Set<BluetoothDevice> favorites = new Set<BluetoothDevice>();
  BleSettings settings = new BleSettings();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadSettings();
  }

  _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = (prefs.getStringList('devices') ?? {});
    });
  }

  _saveFavorite(favorites) async {
    //print("SAVING..."); //DEBUG
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteNames = [];
    for (BluetoothDevice device in favorites) {
      //print("DEVICE" + device.name); //DEBUG
      favoriteNames.add(device.id.toString());
    }
    prefs.setStringList('devices', favoriteNames);
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      settings.bleSenseMode = (prefs.getBool('settings') ?? false);
    });
  }

  _saveSettings(settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('settings', settings.bleSenseMode);
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.primary,
      ),
      title: Info.bleAppName,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              indicatorColor: AppColors.background,
              tabs: [
                Tab(icon: Icon(Icons.star)),
                Tab(icon: Icon(Icons.stay_current_portrait_outlined)),
              ],
            ),
            title: Text(Info.bleAppName),
          ),
          drawer: AppDrawer(),
          body: TabBarView(
            children: [
              settings.bleSenseMode
                  ? BleSenseScreen(favorites, settings)
                  : BleFavoritesScreen(favorites),
              BleDevicesScreen(
                favorites,
                onSaveFavorites: (Set<BluetoothDevice> favorites) {
                  _saveFavorite(favorites);
                },
              ),
            ],
          ),
        ),
      ),
      routes: {
        '/about': (context) => AboutScreen(),
        '/settings': (context) => SettingsScreen(
              settings,
              onSaveSettings: (BleSettings settings) {
                _saveSettings(settings);
              },
            ),
      },
    );
  }
}
