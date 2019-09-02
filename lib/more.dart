import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_notifications/local_notifications.dart';
import 'faculty.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'stateData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'profile.dart';
//import 'package:logger_flutter/logger_flutter.dart';

class More extends StatelessWidget {
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          RaisedButton(
              child: Text('Print All Files'),
              onPressed: () => Profile.printAllProfileNames()),
          RaisedButton(
            child: Text('Delete All Files'),
            onPressed: () => Profile.deleteAll(),
          ),
          RaisedButton(
            child: Text('Save Graph'),
            onPressed: () {
              Profile.getDefaultProfile().then((Profile p) => p.saveSnapshot());
            },
          ),
          RaisedButton(
            child: Text('Read Graph'),
            onPressed: () {
              Profile.getDefaultProfile().then((Profile p) =>
                  p.readGraph().then((String s) => debugPrint(s)));
            },
          ),
          RaisedButton(
            child: Text('Change Theme'),
            onPressed: () {
              DynamicTheme.of(context).setThemeData(StateData.darkTheme);
            },
          ),
          RaisedButton(
            child: Text('Reset Themes'),
            onPressed: () {
              resetThemes();
            },
          ),
          RaisedButton(
            child: Text('Send Notification'),
            onPressed: () {
              print('sent');
              LocalNotifications.createNotification(
                  title: "Test",
                  content: "YAY",
                  id: 0,
                  androidSettings: AndroidSettings(channel: MyApp.channel));
            },
          )
        ],
      ),
    );
  }

  void resetThemes() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("THEME2", false);
  }
}
