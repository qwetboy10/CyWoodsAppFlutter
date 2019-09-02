import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'parser.dart';
import 'profile.dart';

class TranscriptView extends StatelessWidget {
  final Future<Profile> profile = Profile.getDefaultProfile();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcript'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: profile,
          builder: (BuildContext context, AsyncSnapshot<Profile> snap) {
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
                if (snap.hasError ||
                    snap.data == null ||
                    snap.data.parser == null ||
                    snap.data.parser.error != null)
                  return Center(child: Text('Not Logged In'));
                return buildTranscript(context, snap.data);
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget buildTranscript(BuildContext context, Profile profile) {
    //todo
    //add case for no transcript / profile available
    Transcript trans = profile.parser.transcript;
    //just stick everything in a fucking list and display it
    List<Widget> children = []
      ..addAll([
        ListTile(
          title: Text('GPA: ${trans.gpa.toStringAsFixed(4)}'),
        ),
        ListTile(
          title: Text('Class Rank: ${trans.rank}'),
        ),
      ])
      ..addAll(
        trans.years.map((Year y) => yearTile(context, y)).toList(),
      );
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 1,
      ),
      itemBuilder: (BuildContext context, int index) => children[index],
      itemCount: children.length,
    );
  }

  Widget yearTile(BuildContext context, Year y) => ExpansionTile(
        title: Text(
          y.year,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        trailing: Text('${y.totalCredit.toStringAsFixed(1)} Credits'),
        children: y.courses.map((Course c) => buildCourse(c)).toList(),
      );
  Widget buildCourse(Course c) => ListTile(
        title: Text(c.description),
        trailing: Text('${c.credit.toString()} Credits'),
        subtitle: Text(c.getSemesters().trim()),
      );
}
