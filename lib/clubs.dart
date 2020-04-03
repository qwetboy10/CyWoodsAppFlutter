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
    //update description from cy woods website
    description = 'A description of the club goes here';
  }
}

class ClubsState extends State<Clubs> {
  TextEditingController search = TextEditingController();
  List<ClubInfo> clubs;
  List<ClubInfo> filteredClubs;

  //These are two temporary clubs added for testing
  Map<String, dynamic> tempMap = {
    'clubName': 'CS Club',
    'teacherName': 'Armstrong, Stacey',
    'teacherEmail': 'stacey.armstrong@cfisd.net',
    'dayOfWeek': 'Thursday',
    'startTime': '2:40',
    'endTime': '4:30'
  };
  Map<String, dynamic> tempMap2 = {
    'clubName': 'Key Club',
    'teacherName': 'Kent, John',
    'teacherEmail': 'john.kent@cfisd.net',
    'dayOfWeek': 'Monday',
    'startTime': '2:40',
    'endTime': '3:20'
  };

  Widget build(BuildContext context) {
    clubs = new List<ClubInfo>();
    //adding temporary maps to clubs list
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
                            .contains(search.text.toLowerCase()))
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

//specifically adding the number of changes i made to the search text for some reason
  Widget buildClubsList(BuildContext context) {
    if (filteredClubs == null) filteredClubs = []..addAll(clubs);
    return ListView.separated(
      itemCount: filteredClubs.length,
      itemBuilder: (BuildContext context, int index) =>
          buildClubTile(context, filteredClubs[index]),
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
