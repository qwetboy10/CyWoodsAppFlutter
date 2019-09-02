import 'stateData.dart';
import 'package:flutter/material.dart';
import 'profile.dart';

class Attendance extends StatefulWidget {
  State createState() => AttendanceState();
}

class AttendanceState extends State<Attendance> {
  Future<Profile> profile = Profile.getDefaultProfile();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance (This Month)'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: profile,
          builder: (BuildContext context, AsyncSnapshot snap) {
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
                if (snap.data == null) {
                  return Center(child: Text('Not Logged In'));
                }
                if (snap.hasError ||
                    snap.data.parser == null ||
                    snap.data.parser.error != null) {
                      StateData.logError("Attendence Fetch Failed", error: snap.data.parser?.error, trace: snap.data.parser?.trace);
                  return Center(child: Text('No Data Found'));
                }
                return buildAttendance(context, snap.data);
            }
            return null;
          },
        ),
      ),
    );
  }

  buildAttendance(BuildContext context, Profile prof) => ListView.separated(
        separatorBuilder: (_, __) => Divider(
          height: 1,
        ),
        itemBuilder: (BuildContext context, int i) => buildTile(context,
            prof.parser.attendance[i].date, prof.parser.attendance[i].code),
        itemCount: prof.parser.attendance.length,
      );
  Widget buildTile(BuildContext context, String date, String code) => ListTile(
        title: Text(code),
        subtitle: Text(date),
      );
}
