import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'stateData.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'clubs.dart';

// ignore: must_be_immutable
class ClubsMoreInfo extends StatefulWidget {
  ClubInfo clubInfo;
  ClubsMoreInfo(this.clubInfo);
  State<ClubsMoreInfo> createState() => ClubsMoreInfoState(clubInfo);
}
class ClubsMoreInfoState extends State<ClubsMoreInfo> {
  ClubInfo clubInfo;

  ClubsMoreInfoState(ClubInfo c) {
    clubInfo = c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clubInfo.clubName),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: ListView.builder(
          itemCount: 4,
          itemBuilder: (BuildContext context, int index) =>
              buildClubInfoTile(context, index),
        ),
      ),
    );
  }

  Widget buildClubInfoTile(BuildContext context, int index) {
    switch (index) {
      case 0:
        return ListTile(
          title: Text(
            'Sponsor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(clubInfo.teacherName),
        );
      case 1:
        return ListTile(
          title: Text(
            'Sponsor Email',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(clubInfo.teacherEmail),
          onLongPress: () {
            ClipboardManager.copyToClipBoard(clubInfo.teacherEmail)
                .then((result) {
              final snackBar = SnackBar(
                content: Text('Email Copied to Clipboard'),
              );
              Scaffold.of(context).showSnackBar(snackBar);
            });
          },
        );
      case 2:
        return ListTile(
          title: Text(
            'Meeting Times',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(clubInfo.dayOfWeek +
              's from ' +
              clubInfo.startTime +
              ' to ' +
              clubInfo.endTime),
        );
      case 3:
        return ListTile(
          title: Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(clubInfo.description),
        );
    }
    return null;
  }
}
