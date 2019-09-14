import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'parser.dart';
import 'stateData.dart';

class Profile {
  Parser parser;
  String data;
  List<Assignment> newAssignments = [];
  Profile.fromRemote(String username, String password, String inputData) {
    Map<String, dynamic> json = jsonDecode(inputData);
    json.putIfAbsent('username', () => username);
    json.putIfAbsent('password', () => password);
    json.putIfAbsent('lastUpdated', () => DateTime.now().toIso8601String());
    data = jsonEncode(json);
    newAssignments = [];
    updateParser();
  }
  Profile.fromLocal(this.data) {
    if(newAssignments == null) newAssignments = [];
    updateParser();
  }

  void saveSnapshot() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${this.getUsername()}-graph.txt');
      await file.writeAsString(parser.graphSnaphot(), mode: FileMode.append);
    } catch (e, t) {
      StateData.logError('Snapshot save failed', error: e, trace: t);
    }
  }

  Future<String> readGraph() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${this.getUsername()}-graph.txt');
      String text = await file.readAsString();
      return text;
    } catch (e, t) {
      StateData.logError('Snapshot read failed', error: e, trace: t);
    }
    return null;
  }

  void updateParser() {
    Parser old = parser;
    parser = Parser(data);
    newAssignments.addAll(parser.gradesHasChanged(old));
    this.saveSnapshot();
    StateData.logInfo('Parser Updated');
    StateData.logVerbose('New Assignments: ${newAssignments.toString()}');
    StateData.logVerbose(parser.toString());
  }

  List<Assignment> updateParserChanges() {
    Parser newParser = Parser(data);
    List<Assignment> a = newParser.gradesHasChanged(parser);
    parser = newParser;
    StateData.logInfo('Parser Updated (${a.length} new classes}');
    StateData.logInfo('${a.toString()}');
    return a;
  }

  Future<List<Assignment>> updateData() async {
    StateData.logInfo("Grades Updated");
    http.Response response = await http.post('${StateData.url}/Student', body: {
      "username": getUsername(),
      "password": getPassword(),
      "id": StateData.deviceID
    });
    if (response.statusCode == 200) {
      String data = response.body;
      Map<String, dynamic> json = jsonDecode(data);
      if (json.containsKey('success') && json['success'] == false) {
        StateData.logError('Update Fetch Failed');
        return null;
      } else {
        StateData.logInfo('Grade Fetch Success');
        Map<String, dynamic> json = jsonDecode(data);
        json.putIfAbsent('username', () => getUsername());
        json.putIfAbsent('password', () => getPassword());
        json.putIfAbsent('lastUpdated', () => DateTime.now().toIso8601String());
        data = jsonEncode(json);
        this.data = data;
        newAssignments = [];
        List<Assignment> ass = updateParserChanges();
        Profile.save(this);
        if (this.parser.error == null) {
          if (this.parser.classes.fold(true,
              (bool b, Class c) => c.grade != null && b && c.grade >= 89.5)) {
            StateData.unlockTheme(3);
          }
          if (this.parser.classes.fold(true,
              (bool b, Class c) => c.grade != null && b && c.grade <= 69.5)) {
            StateData.unlockTheme(4);
          }
        }
        return ass;
      }
    } else {
      StateData.logError('Update Fetch Failed: ${response.toString()}');
      return null;
    }
    //if auth returns a non null value this should also create the profile
  }

  String getName() => jsonDecode(data)['name'];
  String getUsername() => jsonDecode(data)['username'];
  String getPassword() => jsonDecode(data)['password'];
  String toString() => '${getName()} ${getUsername()} ${getPassword()}';
  static Profile current;

  static Future<Profile> read(String username) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$username.profile');
      String text = await file.readAsString();
      return Profile.fromLocal(text);
    } catch (e, t) {
      StateData.logError('Couldnt Read File', error: e, trace: t);
    }
    return null;
  }

  static Future<Profile> readFS(FileSystemEntity s) async {
    try {
      if (s is File) {
        File file = s;
        String text = await file.readAsString();
        return Profile.fromLocal(text);
      }
    } catch (e, t) {
      StateData.logError('Couldnt read FSE', error: e, trace: t);
    }
    return null;
  }

  static void save(Profile profile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${profile.getUsername()}.profile');
      await file.writeAsString(profile.data);
    } catch (e, t) {
      StateData.logError('Couldnt Save Profile', error: e, trace: t);
    }
  }

  static void printAllProfileNames() async {
    final directory = await getApplicationDocumentsDirectory();
    directory
        .list()
        .map((FileSystemEntity s) => s.toString())
        .toList()
        .then((List<String> s) {
      StateData.logInfo('Profile name: $s');
    });
  }

  static void deleteAll() async {
    final directory = await getApplicationDocumentsDirectory();
    directory
        .list()
        .where((FileSystemEntity s) =>
            s.path.endsWith('profile') || s.path.endsWith('graph.txt'))
        .forEach((FileSystemEntity s) {
      StateData.logInfo('${s.path} deleted');
      s.delete();
    });
  }

  static Future<List<Profile>> getAllProfiles() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> profileFS = await directory
        .list()
        .where((FileSystemEntity s) => s.path.endsWith('profile'))
        .toList();
    StateData.logVerbose(profileFS.toString());
    List<Future<Profile>> futureProfiles = profileFS.map(readFS).toList();
    List<Profile> finalProfiles = await Future.wait(futureProfiles);
    return finalProfiles;
  }

  static void setDefaultProfile(Profile p) async {
    current = p;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    p == null
        ? await prefs.setString('defaultProfile', null)
        : prefs.setString('defaultProfile', p.getUsername());
    StateData.logInfo('Default Profile Set To ${p?.getName()}');
  }

  static Future<Profile> getDefaultProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('defaultProfile');
    if (username == null) return null;
    return read(username);
  }

  static void deleteProfile(Profile p) async {
    StateData.logInfo('Deleting ${p.getUsername()}');
    final directory = await getApplicationDocumentsDirectory();
    directory
        .list()
        .where((FileSystemEntity s) =>
            s.path.endsWith('${p.getUsername()}.profile'))
        .forEach((FileSystemEntity s) => s.delete());
    Profile defaultProfile = await getDefaultProfile();
    if (p.getUsername() == defaultProfile.getUsername()) {
      setDefaultProfile(null);
    }
  }
}
