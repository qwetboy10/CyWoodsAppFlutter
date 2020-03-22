import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateData {
  static int chosenTheme = 0;
  static Logger logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 10,
          lineLength: 100,
          printTime: true));
  static String deviceID;

  static void logError(dynamic message, {Error error, StackTrace trace}) {
    logger.e(message, error, trace);
  }

  static void logInfo(dynamic message) {
    logger.i(message);
  }

  static void logVerbose(dynamic message) {
    logger.v(message);
  }

  static void unlockTheme(int theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("THEME$theme", true);
    logInfo("unlocked theme $theme");
  }

//uses to persist lunch across going to different tabs
  static int lunch = 0;
  static int sport = 0;
  static int gender = 0;

  //url of the server
  //static String url = 'http://dent.ml:8080/CyWoodsAppServer';
  static String url =
      'http://cywoodsappserver.us-west-2.elasticbeanstalk.com';

//      'http://CyWoodsAppServer-env.fsa2ppmecc.us-west-2.elasticbeanstalk.com';
  //base theme
  //use this to create any more themes
  //theme 0
  static ThemeData defaultTheme = ThemeData(
    colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Colors.red,
        primaryVariant: Colors.red[700],
        secondary: Color.fromRGBO(0xff, 0xeb, 0x40, .90),
        secondaryVariant: Colors.yellow[700],
        background: Colors.grey[200],
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white),
    primaryColor: Colors.red,
    accentColor: Color.fromRGBO(0xff, 0xeb, 0x40, .90),
    backgroundColor: Colors.grey[200],
  );

//dark theme - in progress
//theme 1
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.red,
        primaryVariant: Colors.red[700],
        secondary: Colors.red,
        secondaryVariant: Colors.yellow[700],
        background: Colors.black,
        surface: Colors.black,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.black,
        onSurface: Colors.white,
        onError: Colors.white),
    primaryColor: Colors.red,
    accentColor: Colors.red,
    backgroundColor: Colors.grey[900],
    buttonColor: Colors.red,
    brightness: Brightness.dark,
    textTheme: Typography.whiteMountainView,
  );

  //theme 2
  //in progress
  static ThemeData hackerTheme = ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.green,
          primaryVariant: Colors.green[700],
          secondary: Colors.grey[900],
          secondaryVariant: Colors.grey[900],
          background: Colors.black,
          surface: Colors.black,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.green,
          onError: Colors.white),
      primaryColor: Colors.green,
      accentColor: Colors.greenAccent[700],
      backgroundColor: Colors.black,
      buttonColor: Colors.green,
      brightness: Brightness.dark,
      textTheme: Typography.whiteMountainView
          .apply(bodyColor: Colors.green, displayColor: Colors.green));

  static ThemeData oceanTheme = ThemeData(
    colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Colors.blue,
        primaryVariant: Colors.blue[700],
        secondary: Colors.blueAccent,
        secondaryVariant: Colors.blueAccent[700],
        background: Colors.grey[200],
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white),
    primaryColor: Colors.blue,
    accentColor: Colors.blueAccent,
    backgroundColor: Colors.grey[200],
  );

  static ThemeData eyePainTheme = ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.cyan,
          primaryVariant: Colors.cyan[700],
          secondary: Colors.cyanAccent,
          secondaryVariant: Colors.cyanAccent[700],
          background: Colors.pinkAccent,
          surface: Colors.pink,
          error: Colors.red,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.black,
          onError: Colors.black),
      primaryColor: Colors.cyan,
      accentColor: Colors.cyanAccent,
      backgroundColor: Colors.pinkAccent,
      textTheme: Typography.whiteMountainView.apply(
          bodyColor: Colors.cyanAccent, displayColor: Colors.cyanAccent));

  static ThemeData patriotTheme = ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.red,
          primaryVariant: Colors.red[700],
          secondary: Colors.blue[200],
          secondaryVariant: Colors.blue[700],
          background: Colors.grey[200],
          surface: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.black,
          onError: Colors.white),
      primaryColor: Colors.red,
      accentColor: Colors.blue[200],
      backgroundColor: Colors.grey[200],
      textTheme: Typography.whiteCupertino
          .apply(bodyColor: Colors.blue[900], displayColor: Colors.blue[900])
  );

  static ThemeData deepTheme = ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.blue,
          primaryVariant: Colors.blue[700],
          secondary: Colors.grey[900],
          secondaryVariant: Colors.grey[900],
          background: Colors.black,
          surface: Colors.black,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.blue,
          onError: Colors.white),
      primaryColor: Colors.blue,
      accentColor: Colors.blueAccent[700],
      backgroundColor: Colors.black,
      buttonColor: Colors.blue,
      brightness: Brightness.dark,
      textTheme: Typography.whiteCupertino
          .apply(bodyColor: Colors.blue, displayColor: Colors.blue));

  static ThemeData getThemeByIndex(int i) {
    switch (i) {
      case 0:
        return defaultTheme;
      case 1:
        return darkTheme;
      case 2:
        return hackerTheme;
      case 3:
        return oceanTheme;
      case 4:
        return eyePainTheme;
      case 5:
        return patriotTheme;
      case 6:
        return deepTheme;
    }
    return null;
  }

  static String getThemeName(int i) {
    switch (i) {
      case 0:
        return "Default Theme";
      case 1:
        return "Dark Theme";
      case 2:
        return "Hacker Theme";
      case 3:
        return "Ocean Theme";
      case 4:
        return "Eye Pain";
      case 5:
        return "Patriot Theme";
      case 6:
        return "Deep Theme";
    }
    return "";
  }

}
