import 'package:CyWoodsAppFlutter/stateData.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class About extends StatefulWidget {
  AboutState createState() => AboutState();
}

class AboutState extends State<About> {
  GlobalKey key = GlobalKey();
  int buttonPresses = 0;
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 24,
              ),
              Text(
                'Cypress Woods App',
                textScaleFactor: 1.5,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 16,
              ),
              Container(
                width: 200,
                child: RaisedButton(
                  child: Text('School Website'),
                  onPressed: launchWebsite,
                ),
              ),
              Container(
                height: 8,
              ),
              /*Container(
                width: 200,
                child: OutlineButton(
                  child: Text('Report Bug'),
                  onPressed: null,
                ),
              ),*/
              Expanded(child: Container()),
              InkWell(
                child: Center(
                    child: Text(
                        'Developed by Tristan Wiesepape and Ronak Malik', textAlign: TextAlign.center,)),
                onTap: () {
                  buttonPresses++;
                  if (buttonPresses == 13) {
                    StateData.logInfo('Theme 2 Unlocked');
                    unlockTheme();
                    setState(() {
                      (key.currentState as ScaffoldState).showSnackBar(SnackBar(
                        content: Text('New Theme Unlocked'),
                      ));
                    });
                  }
                },
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => SimpleDialog(
                            title: Text('Enter Admin Passcode'),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                    obscureText: true,
                                    onSubmitted: (String s) {
                                      if (s == 'RALSUCKS') {
                                        SharedPreferences.getInstance().then(
                                            (SharedPreferences prefs) =>
                                                prefs.setBool("ADMIN", true));
                                        StateData.logInfo('Admin Enabled');
                                      } else if (s == 'DUMBYTHICC') {
                                        SharedPreferences.getInstance()
                                            .then((SharedPreferences prefs) {
                                          prefs.setBool("THEME2", true);
                                          prefs.setBool("THEME3", true);
                                          prefs.setBool("THEME4", true);
                                          prefs.setBool("THEME5", true);
                                        });
                                      }
                                      Navigator.of(context).pop();
                                    }),
                              )
                            ],
                          ));
                },
              ),
              Text('Art by Amal Gupta'),
              Container(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void unlockTheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('THEME2', true);
  }

  void launchWebsite() async {
    StateData.logInfo('Website Launched');
    launch('https://cywoods.cfisd.net/en/');
  }
}
