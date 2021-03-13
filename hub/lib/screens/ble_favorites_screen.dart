import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BleFavorites extends StatefulWidget {
  BleFavorites(this.favorites);
  final Set<BluetoothDevice> favorites;

  @override
  _BleFavoritesState createState() => _BleFavoritesState();
}

class _BleFavoritesState extends State<BleFavorites> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.favorites is Set<BluetoothDevice>
            ? widget.favorites.toString()
            : ""),
      ], //DEBUG),
    );
  }
}
