import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'stateData.dart';
import 'changeProfile.dart';
import 'main.dart';
import 'grade_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'profile.dart';
import 'parser.dart';
import 'login.dart';
import 'cywoodsapp_icons.dart';

class Grades extends StatefulWidget {
  Grades({Key key}) : super(key: key);
  State<Grades> createState() => GradesState();
}

class GradesState extends State<Grades> {
  void refreshProfile() {
    setState(() {
      profile = Profile.getDefaultProfile();
    });
    profile.then(
        (Profile p) => StateData.logInfo('New Profile: ${p.getUsername()}'));
  }

  Future<Profile> profile = Profile.getDefaultProfile();
  Widget build(BuildContext context) {
    profile.then((Profile p) => p == null ? null : p.updateParser());
    return FutureBuilder(
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
            return buildGrades(context, snap.data);
        }
        return null;
      },
    );
  }

  Widget buildGrades(BuildContext context, Profile profile) {
    if (profile == null)
      return Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: RaisedButton(
                child: Text('Manage Accounts'),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                            builder: (context) => ChangeProfile(),
                            fullscreenDialog: true),
                      )
                      .then((_) => refreshProfile());
                },
              ),
            ),
          ),
          /*Expanded(
            child: FutureBuilder(
              future: Profile.getAllProfiles(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Profile>> snap) {
                switch (snap.connectionState) {
                  case ConnectionState.done:
                    StateData.logVerbose(snap.toString());
                    return Column(
                        children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Select an Account',
                          textScaleFactor: 1.1,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ]..addAll(snap.data
                            .where((Profile p) => p != null)
                            .map((Profile p) => Padding(
                              padding: const EdgeInsets.symmetric(horiztonal: 16.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface),
                                  child: ListTile(
                                    title: Text(p.getName()),
                                  )),
                            ))
                            .toList()));
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return Container();
                }
              },
            ),
          )*/
        ],
      );
    if (profile.parser == null) {
      return Center(
        child: Text(
            'Parser Error.\nThe Server May Be Down For Maintenance Currently'),
      );
    }
    return Center(
      child: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        child: ListView.separated(
          itemCount: profile.parser.classes.length + 2,
          separatorBuilder: (BuildContext context, int index) => Divider(
            height: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (context) => ChangeProfile(),
                              fullscreenDialog: true),
                        )
                        .then((_) => refreshProfile());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text(profile.getName()),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface),
                  ),
                ),
                margin: EdgeInsets.all(8),
              );
            } else if (index == profile.parser.classes.length + 1) {
              return Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).colorScheme.surface),
                child: ListTile(
                  title: Center(
                    child:
                        Text('Last Updated ${profile.parser.getLastUpdated()}'),
                  ),
                ),
              );
            } else {
              return buildGradeTile(context, profile, index);
            }
          },
        ),
        onRefresh: () {
          return profile.updateData().then((List<Assignment> changes) {
            if (changes == null) {
              Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text("Grade Fetch Failed. Grades Not Updated"),
              ));
            } else {
              Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text(
                    "Grade Fetch Succeeded. ${changes.length} New Assignment${changes.length != 1 ? 's' : ''} Found"),
              ));
            }
          }).then((_) => {setState(() => profile.updateParser())});
        },
      ),
    );
  }

  Widget buildGradeTile(BuildContext context, Profile profile, int index) {
    try {
      return Container(
        child: ListTile(
          onTap: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                  builder: (context) => GradeDetail(
                        currentClass: profile.parser.classes[index - 1],
                        profile: profile,
                      ),
                  fullscreenDialog: true),
            )
                .then((_) {
              setState(() {
                profile.newAssignments = profile.newAssignments
                    .where((Assignment a) => !profile
                        .parser.classes[index - 1].assignments
                        .contains(a))
                    .toList();
                StateData.logInfo(profile.newAssignments.toString());
                profile.parser.classes
                    .forEach((Class c) => c.removeAllPseudoAssignments());
              });
            });
          },
          title: profile.parser.classes[index - 1].assignments
                  .any((Assignment a) => profile.newAssignments.contains(a))
              ? Row(children: [
                  Text(profile.parser.classes[index - 1].name),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      FontAwesomeIcons.solidCircle,
                      size: 8,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ])
              : Text(profile.parser.classes[index - 1].name),
          trailing: Text(profile.parser.classes[index - 1].getGradeString()),
        ),
        decoration: BoxDecoration(
            gradient:
                getGradient(context, profile.parser.classes[index - 1].grade)),
      );
    } catch (e, trace) {
      StateData.logError("Grade Build Failed", error: e, trace: trace);
      return Divider(
        height: 10,
      );
    }
  }

  static LinearGradient getGradientAssignment(
      BuildContext context, Assignment a,
      {bool pseudo = false}) {
    if (a.extraCredit ?? false)
      return getGradient(context, 100, pseudo: pseudo);
    else
      return getGradient(
          context,
          a.maxScore == null || a.score == null
              ? double.tryParse(a.score)
              : double.parse(a.score) / a.maxScore * 100,
          pseudo: pseudo);
  }

  static LinearGradient getGradient(BuildContext context, double grade,
      {bool pseudo = false}) {
    if (pseudo)
      return LinearGradient(
        colors: [Theme.of(context).colorScheme.secondary],
        stops: [1],
      );
    if (grade == null)
      return LinearGradient(
          colors: [Theme.of(context).colorScheme.surface], stops: [1]);
    if (Theme.of(context).brightness == Brightness.light) {
      if (grade >= 89.5)
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            CustomTheme.of(context).a
          ],
          stops: [.65, 1],
        );
      else if (grade >= 79.5)
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            CustomTheme.of(context).b
          ],
          stops: [.65, 1],
        );
      else if (grade >= 69.5)
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            CustomTheme.of(context).c
          ],
          stops: [.65, 1],
        );
      else
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            CustomTheme.of(context).f
          ],
          stops: [.65, 1],
        );
    }
    if (Theme.of(context).brightness == Brightness.dark) {
      if (grade >= 89.5)
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            CustomThemeDark.of(context).a
          ],
          stops: [.65, 1],
        );
      else if (grade >= 79.5)
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            CustomThemeDark.of(context).b
          ],
          stops: [.65, 1],
        );
      else if (grade >= 69.5)
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            CustomThemeDark.of(context).c
          ],
          stops: [.65, 1],
        );
      else
        return LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            CustomThemeDark.of(context).f
          ],
          stops: [.65, 1],
        );
    }
  }
}
