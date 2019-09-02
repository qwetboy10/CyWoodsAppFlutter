import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'stateData.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

class Faculty extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FacultyState();
}

class Teacher {
  String name;
  String email;
  String website;
  Teacher(Map<String, dynamic> data) {
    name = data['name'];
    email = data['email'];
    website = data['website'];
  }
}

class FacultyState extends State<Faculty> {
  TextEditingController search = TextEditingController();
  List<Teacher> teachers;
  List<Teacher> filteredTeachers;

  Future<http.Response> faculty = http.get('${StateData.url}/Faculty');
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty'),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: FutureBuilder(
          future: faculty,
          builder: (BuildContext context, AsyncSnapshot snap) {
            switch (snap.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                //loading animation
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                );
              case ConnectionState.done:
                if (snap.hasError || snap.data == null) {
                  StateData.logError(
                      "Faculty Fetch Failed: ${snap.data.toString()}",
                      error: snap.error);
                  return Center(
                    child: Text('Network Error'),
                  );
                }
                return Column(
                  children: [
                    //search bar
                    //show anything that contains the search bar text
                    //todo: switch to fuzzy search algorithm
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 4),
                      child: TextField(
                        controller: search,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(hintText: 'Search'),
                        onChanged: (String s) {
                          setState(() {
                            filteredTeachers = teachers
                                .where((Teacher t) =>
                                    search.text.length == 0 ||
                                    t.name
                                        .toLowerCase()
                                        .contains(search.text.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    //list of faculty
                    Expanded(
                        flex: 4, child: buildFacultyList(context, snap.data))
                  ],
                );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget buildFacultyList(BuildContext context, http.Response response) {
    try {
      Map<String, dynamic> root = jsonDecode(response.body);
      List<dynamic> faculty = root['faculty'];
      teachers = faculty.map((dynamic d) => Teacher(d)).toList();
      //create backup teachers list
      //filteredTeachers is whats actually displayed tho
      if (filteredTeachers == null) filteredTeachers = []..addAll(teachers);
      return ListView.separated(
        itemCount: filteredTeachers.length,
        itemBuilder: (BuildContext context, int index) =>
            buildTeacherTile(context, filteredTeachers[index]),
        separatorBuilder: (BuildContext context, int index) => Divider(
          height: 1,
        ),
      );
    } catch (e, t) {
      StateData.logError("Faculty List Build Failed", error: e, trace: t);
      return Center(child: Text('Network Error'),);
    }
  }

  Widget buildTeacherTile(BuildContext context, Teacher t) => ListTile(
        title: Text(t.name),
        subtitle: Text(t.email),
        onTap: () => launchWebsite(t),
        onLongPress: () {
          //ClipboardManager is a third party package
          ClipboardManager.copyToClipBoard(t.email).then((result) {
            final snackBar = SnackBar(
              content: Text('Email Copied to Clipboard'),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          });
        },
      );
//do nothing if url is not calid
  void launchWebsite(Teacher t) async {
    if (t.website == null || t.website.length == 0) return;
    String uri = Uri.encodeFull(t.website);
    if (await canLaunch(uri)) {
      await launch(uri);
    }
  }
}
