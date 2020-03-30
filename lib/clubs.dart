import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'stateData.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'clubs_more_info.dart';

class Clubs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ClubsState();
}

class ClubInfo {
  String clubName;
  String teacherName;
  String teacherEmail;
  String dayOfWeek;
  String startTime, endTime;
  String description;

  ClubInfo(Map<String, dynamic> data) {
    clubName = data['clubName'];
    teacherName = data['teacherName'];
    teacherEmail = data['teacherEmail'];
    dayOfWeek = data['dayOfWeek'];
    startTime = data['startTime'];
    endTime = data['endTime'];
    description = 'A description of the club goes here';
  }
}

class ClubsState extends State<Clubs> {
  TextEditingController search = TextEditingController();
  List<ClubInfo> clubs = new List<ClubInfo>();
  List<ClubInfo> filteredClubs;
  static Map<String, dynamic> tempMap = {
    'clubName': 'CS Club',
    'teacherName': 'Armstrong, Stacey',
    'teacherEmail': 'stacey.armstrong@cfisd.net',
    'dayOfWeek': 'Thursday',
    'startTime': '2:40',
    'endTime': '4:30'
  };
  static Map<String, dynamic> tempMap2 = {
    'clubName': 'Key Club',
    'teacherName': 'Kent, John',
    'teacherEmail': 'john.kent@cfisd.net',
    'dayOfWeek': 'Monday',
    'startTime': '2:40',
    'endTime': '3:20'
  };

  Widget build(BuildContext context) {
    clubs.add(new ClubInfo(tempMap));
    clubs.add(new ClubInfo(tempMap2));
    return Scaffold(
      appBar: AppBar(
        title: Text('Clubs'),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 4),
          child: TextField(
            controller: search,
            textAlign: TextAlign.center,
            decoration: InputDecoration(hintText: 'Search'),
            onChanged: (String s) {
              setState(() {
                filteredClubs = clubs
                    .where((ClubInfo c) =>
                        search.text.length == 0 ||
                        c.clubName
                            .toLowerCase()
                            .contains(c.clubName.toLowerCase()))
                    .toList();
              });
            },
          ),
        ),
        Expanded(
          flex: 4,
          child: buildClubsList(context),
        )
      ]),
    );
  }

  Widget buildClubsList(BuildContext context) {
    if (filteredClubs == null) filteredClubs = []..addAll(clubs);
    return ListView.separated(
      itemCount: filteredClubs.length,
      itemBuilder: (BuildContext context, int index) =>
          buildClubTile(context, clubs[index]),
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 1,
      ),
    );
  }

  Widget buildClubTile(BuildContext context, ClubInfo c) {
    return ListTile(
        title: Text(c.clubName),
        subtitle: Text(c.teacherName),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ClubsMoreInfo(c), fullscreenDialog: true));
        });
  }
}
