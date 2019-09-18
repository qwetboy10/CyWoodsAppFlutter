import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_id/device_id.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger_flutter/logger_flutter.dart' as logger_flutter;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about.dart';
import 'athletics.dart';
import 'attendance.dart';
import 'changeProfile.dart';
import 'cywoodsapp_icons.dart';
import 'faculty.dart';
import 'final_calculator.dart';
import 'grades.dart';
import 'graph.dart';
import 'home.dart';
import 'login.dart';
import 'parser.dart';
import 'profile.dart';
import 'schedule.dart';
import 'stateData.dart';
import 'transcript.dart';
import 'customExpansionTile.dart' as custom;

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Text(details.toString());
  };
  logger_flutter.LogConsole.init(bufferSize: 20);
  Logger.level = Level.verbose;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  //static const AndroidNotificationChannel channel =
  //    const AndroidNotificationChannel(
  //        id: 'Cypress Woods',
  //       name: 'Cypress Woods App',
  //       description: 'Grant this app the ability to show notifications',
  //      importance: AndroidNotificationChannelImportance.HIGH);*/
  MyAppState createState() {
    //LocalNotifications.createAndroidNotificationChannel(channel: channel);
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  void initState() {
    super.initState();
    initPlatformState();
    Profile.getDefaultProfile().then((Profile p) {
      if (p == null) return;
      setState(() {
        Profile.current = p;
        Profile.current.updateParser();
      });
      StateData.logInfo('Default Profile: ${p.getUsername()}');
    });
  }

  Future<void> initPlatformState() async {
    StateData.deviceID = await DeviceId.getID;
    StateData.logInfo('Device ID is ${StateData.deviceID}');
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: false), () async {
      // This is the fetch-event callback.
      Profile prof = await Profile.getDefaultProfile();
      List<Assignment> ass = prof.updateParserChanges();
      StateData.logInfo('Notification Fetch, ${ass.length} found');
      if (ass.length != 0) {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            '0', 'Cy Woods App Grades', 'Recieve notifications of grades',
            importance: Importance.Max,
            priority: Priority.High,
            ticker: 'New Grade');
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
          0,
          'New  Grades',
          ass.map((Assignment a) => a.name).toList().join(', '),
          platformChannelSpecifics,
        );
      }
      // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish();
    }).then((int status) {}).catchError((e, trace) {
      StateData.logError("BACKGROUND FETCH FAILED", error: e, trace: trace);
    });

    // Optionally query the current BackgroundFetch status.

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: StateData.defaultTheme,
      home: Scaffold(
        body: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (BuildContext context, AsyncSnapshot snap) {
            switch (snap.connectionState) {
              case ConnectionState.active:
              case ConnectionState.none:
              case ConnectionState.waiting:
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                );
              case ConnectionState.done:
                return buildMainApp(snap.data);
            }
          },
        ),
      ),
    );
  }

  DynamicTheme buildMainApp(SharedPreferences prefs) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) =>
            StateData.getThemeByIndex(prefs.getInt("DEFAULTTHEME") ?? 0),
        themedWidgetBuilder: (BuildContext context, ThemeData theme) =>
            theme.brightness == Brightness.light
                ? CustomTheme(
                    child: MaterialApp(
                    title: 'Home',
                    home: WidgetContainer(
                      prefs: prefs,
                    ),
                    theme: theme,
                  ))
                : CustomThemeDark(
                    child: MaterialApp(
                    title: 'Home',
                    home: WidgetContainer(
                      prefs: prefs,
                    ),
                    theme: theme,
                  )));
  }
}

class CustomTheme extends InheritedWidget {
  CustomTheme({Widget child}) : super(child: child);
  final Color a = Color.fromRGBO(181, 255, 181, 1);
  final Color b = Color.fromRGBO(254, 255, 181, 1);
  final Color c = Color.fromRGBO(255, 236, 209, 1);
  final Color f = Color.fromRGBO(254, 208, 208, 1);

  static CustomTheme of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(CustomTheme) as CustomTheme;
  }

  @override
  bool updateShouldNotify(CustomTheme old) =>
      a != old.a || b != old.b || c != old.c || f != old.f;
}

//put your custom colors here
class CustomThemeDark extends InheritedWidget {
  CustomThemeDark({Widget child}) : super(child: child);
  final Color a = Color.fromRGBO(0, 72, 0, 1);
  final Color b = Color.fromRGBO(72, 72, 0, 1);
  final Color c = Color.fromRGBO(48, 29, 0, 1);
  final Color f = Color.fromRGBO(48, 0, 0, 1);

  static CustomThemeDark of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(CustomThemeDark)
        as CustomThemeDark;
  }

  @override
  bool updateShouldNotify(CustomThemeDark old) =>
      a != old.a || b != old.b || c != old.c || f != old.f;
}

//defines a screen shown on the bottom navigation bar
class Screen {
  final String title;
  final Widget content;
  final IconData icon;
  const Screen(this.title, this.content, this.icon);
}

//Widget Container defines the titlebar and the bottom navigation bar.
//It also controls which of the screens is displayed
class WidgetContainer extends StatefulWidget {
  final SharedPreferences prefs;
  WidgetContainer({Key key, this.prefs}) : super(key: key);
  //static list of all the screens displayed on the bottom navigation bar
  static List<Screen> screens = [
    Screen('Home', Home(), Icons.home),
    Screen('Grades', Grades(), Icons.school),
    Screen('Schedule', null, Icons.notifications),
    Screen('Athletics', Athletics(), Cywoodsapp.american_football_ball),
    //Screen('More', More(), Icons.more_horiz),
  ];

  @override
  WidgetContainerState createState() => WidgetContainerState(prefs);
}

class WidgetContainerState extends State<WidgetContainer> {
  bool seconds;
  int lunch;
  WidgetContainerState(SharedPreferences prefs) {
    seconds = prefs.getBool("SECONDS") ?? false;
    lunch = prefs.getInt("DEFAULTLUNCH");
  }
  SharedPreferences prefs;
  int currentScreen = 0;
  final GlobalKey<ScheduleState> scheduleStateKey = GlobalKey<ScheduleState>();
  final GlobalKey<GradesState> gradesStateKey = GlobalKey<GradesState>();
  List<Widget> getActions(int currentScreen, BuildContext context) {
    switch (currentScreen) {
      case 1:
        return <Widget>[
          IconButton(
            icon: Icon(
              Icons.assignment,
            ),
            onPressed: () {
              //transcript view
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => TranscriptView(),
                    fullscreenDialog: true),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.schedule,
            ),
            onPressed: () {
              //transcript view
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => Attendance(), fullscreenDialog: true),
              );
            },
          )
        ];
      case 2:
        return <Widget>[
          PopupMenuButton(
            onSelected: (dynamic value) {
              setState(() {
                ScheduleState.schedule = value == 'null' ? null : value;
                scheduleStateKey.currentState.updateSchedule();
              });
            },
            itemBuilder: (BuildContext context) {
              return ['standard', 'second', 'seventh', 'null'].map((String s) {
                String fullName;
                switch (s) {
                  case 'standard':
                    fullName = 'Regular Bell Schedule';
                    break;
                  case 'second':
                    fullName = 'Extended Second';
                    break;
                  case 'seventh':
                    fullName = 'Extended Seventh';
                    break;
                  default:
                    fullName = "Use Today's Schedule";
                }
                return PopupMenuItem(
                  child: Text(fullName),
                  value: s,
                );
              }).toList();
            },
          ),
        ];
      default:
        return null;
    }
  }

  Widget build(BuildContext context) {
    SharedPreferences.getInstance()
        .then((SharedPreferences prefsss) => prefs = prefsss);
    return Scaffold(
      appBar: AppBar(
        title: Theme.of(context).accentColor == Colors.blue[200]
            ? Text(WidgetContainer.screens[currentScreen].title)
            : Text(WidgetContainer.screens[currentScreen].title),
        actions: getActions(currentScreen, context),
      ),
      body: SafeArea(child: getCurrentScreen(currentScreen)),
      backgroundColor: Theme.of(context).backgroundColor,
      drawer: buildDrawer(context),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  getCurrentScreen(int current) {
    if (current == 1)
      return Grades(key: gradesStateKey);
    else if (current == 2)
      return Schedule(
        key: scheduleStateKey,
      );
    else
      return WidgetContainer.screens[currentScreen].content;
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: currentScreen,
      onTap: onItemTapped,
      items: WidgetContainer.screens
          .map((Screen s) => BottomNavigationBarItem(
                icon: Icon(s.icon, color: Colors.grey),
                activeIcon:
                    Icon(s.icon, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  s.title,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ))
          .toList(),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    if (prefs != null &&
        prefs.getBool("ADMIN") != null &&
        prefs.getBool("ADMIN")) {
      return Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text(
                Profile.current != null
                    ? 'Logged in as:\n${Profile.current?.getName()}'
                    : 'Please Select A Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 2,
              ),
            ),
            ListTile(
              title: Text('Final Calculator'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => FinalCalculator(),
                      fullscreenDialog: true),
                );
              },
            ),
            ListTile(
              title: Text('Faculty List'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Faculty(), fullscreenDialog: true),
                );
              },
            ),
            ListTile(
              title: Text('Grade Graph'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Graph(), fullscreenDialog: true),
                );
              },
            ),
            ListTile(
              title: Text('Delete All Files'),
              onTap: () => Profile.deleteAll(),
            ),
            ListTile(
                title: Text('Reset Shared Preferences'),
                onTap: () => SharedPreferences.getInstance()
                    .then((SharedPreferences prefs) => prefs.clear())),
            ListTile(
              title: Text('View Logs'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return logger_flutter.LogConsole(
                      dark: true,
                      showCloseButton: true,
                    );
                  },
                  fullscreenDialog: true)),
            ),
            ListTile(
              title: Text('Exit Admin Mode'),
              onTap: () => SharedPreferences.getInstance()
                  .then((SharedPreferences prefs) =>
                      prefs.setBool("ADMIN", false))
                  .then((bool b) => Navigator.of(context).pop()),
            ),
            ListTile(
              title: Text('Add Account'),
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                          builder: (context) => NotLogin(),
                          fullscreenDialog: true),
                    )
                    .then((_) => gradesStateKey?.currentState?.refreshProfile())
                    .then((_) => Navigator.of(context).pop());
              },
            ),
            ListTile(
              title: Text('Change Account'),
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                          builder: (context) => ChangeProfile(),
                          fullscreenDialog: true),
                    )
                    .then((_) => gradesStateKey?.currentState?.refreshProfile())
                    .then((_) => Navigator.of(context).pop());
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                setState(() {
                  Profile.setDefaultProfile(null);
                  gradesStateKey?.currentState?.refreshProfile();
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => About(), fullscreenDialog: true),
                );
              },
            ),
            ListTile(
              title: Text('Change Theme'),
              onTap: () => showDialog<ThemeData>(
                context: context,
                builder: chooseThemeDialog,
              ).then((ThemeData data) {
                setState(() {
                  if (data != null) DynamicTheme.of(context).setThemeData(data);
                });
              }),
            ),
          ],
        ),
      );
    } else
      return Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text(
                Profile.current != null
                    ? 'Logged in as:\n${Profile.current?.getName()}'
                    : 'Please Select A Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 2,
              ),
            ),
            ListTile(
              title: Text('Final Calculator'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => FinalCalculator(),
                      fullscreenDialog: true),
                );
              },
            ),
            ListTile(
              title: Text('Faculty List'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Faculty(), fullscreenDialog: true),
                );
              },
            ),
            ListTile(
              title: Text('Manage Accounts'),
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                          builder: (context) => ChangeProfile(),
                          fullscreenDialog: true),
                    )
                    .then((_) => gradesStateKey?.currentState?.refreshProfile())
                    .then((_) => Navigator.of(context).pop());
              },
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => About(), fullscreenDialog: true),
                );
              },
            ),
            ListTile(
              title: Text('Change Theme'),
              onTap: () => showDialog<int>(
                context: context,
                builder: chooseThemeDialog,
              ).then((int data) {
                if (data != null) {
                  DynamicTheme.of(context)
                      .setThemeData(StateData.getThemeByIndex(data));
                  prefs.setInt("DEFAULTTHEME", data);
                }
              }),
            ),
            custom.ExpansionTile(
              title: Text(
                'More Settings',
                //style:
                 //   TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              headerBackgroundColor: Theme.of(context).canvasColor,
              children: <Widget>[
                ListTile(
                  title: Text('Show seconds on schedule?'),
                  trailing: Switch(
                    activeColor: Theme.of(context).accentColor,
                    value: seconds,
                    onChanged: (bool b) {
                      setState(() {
                        seconds = b;
                      });
                      prefs.setBool("SECONDS", seconds);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Default Lunch'),
                      DropdownButton(
                        value: lunch,
                        items: [
                          DropdownMenuItem(
                            child: Text('A'),
                            value: 0,
                          ),
                          DropdownMenuItem(
                            child: Text('B'),
                            value: 1,
                          ),
                          DropdownMenuItem(
                            child: Text('C'),
                            value: 2,
                          ),
                        ],
                        onChanged: (int i) {
                          setState(() {
                            changeDefaultLunch(i);
                            lunch = i;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          ].where((dynamic d) => d != null).toList(),
        ),
      );
  }

  void changeDefaultLunch(int i) {
    prefs.setInt("DEFAULTLUNCH", i);
  }

  Widget chooseThemeDialog(BuildContext context) => SimpleDialog(
        title: Text("Choose Theme"),
        children: buildThemeDialogChildren(context),
      );

  List<Widget> buildThemeDialogChildren(BuildContext context) {
    Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    return [
      FutureBuilder(
        future: prefs,
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snap) {
          switch (snap.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              );
            case ConnectionState.done:
              List<int> themes = [0, 1];
              if (snap.data.getBool("THEME2") != null &&
                  snap.data.getBool("THEME2")) themes.add(2);

              if (snap.data.getBool("THEME3") != null &&
                  snap.data.getBool("THEME3")) themes.add(3);

              if (snap.data.getBool("THEME4") != null &&
                  snap.data.getBool("THEME4")) themes.add(4);

              if (snap.data.getBool("THEME5") != null &&
                  snap.data.getBool("THEME5")) themes.add(5);

              if (snap.data.getBool("THEME6") != null &&
                  snap.data.getBool("THEME6")) themes.add(6);
              StateData.logInfo("Themes: ${themes}");
              return Column(
                  children: themes
                      .map((int i) => SimpleDialogOption(
                            child: Text(StateData.getThemeName(i)),
                            onPressed: () => Navigator.of(context).pop(i),
                          ))
                      .toList());
          }
          return null;
        },
      )
    ];
  }

  //called when one of the bottom navigation bar items is tapped
  void onItemTapped(int index) {
    setState(() {
      currentScreen = index;
    });
  }
}
