import 'package:flutter/material.dart';

import '../constants/info.dart';
import '../constants/colors.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Column(
        children: [
          Container(
            child: Text(
              'Welcome to ' + Info.appName + '!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            margin: EdgeInsets.all(10),
          ),
          Container(
            child: Text(
              Info.description,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            margin: EdgeInsets.all(10),
          ),
          Container(
            child: Text(
              'Made by ' + Info.author,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.left,
            ),
            width: 300,
            margin: EdgeInsets.only(top: 40.0),
          ),
          Container(
            child: Text(
              'Version: ' + Info.version,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.left,
            ),
            width: 300,
          ),
        ],
      ),
    );
  }
}
