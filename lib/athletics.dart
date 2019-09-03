import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:CyWoodsAppFlutter/stateData.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'athleticsParser.dart';

class Athletics extends StatefulWidget {
  final Future<http.Response> data = http.get('${StateData.url}/Athletics');
  State<Athletics> createState() {
    return AthleticsState();
  }
}

class AthleticsState extends State<Athletics> {
  List<int> q = [];
  String sport = "Football";
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.data,
        builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
          switch (snapshot.connectionState) {
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
              if (snapshot.hasError || snapshot.data == null) {
                return Center(child: Text('Network Error'));
              }
              AthleticsParser parser = AthleticsParser(snapshot.data.body);
              return Container(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                width: double.infinity,
                child: Column(
                  children: buildControls(context)
                    ..addAll([
                      Expanded(
                        child: parser
                                    .fromString(sport, StateData.gender)
                                    .length ==
                                0
                            ? Center(
                                child: Text('Schedules Have Not Been Released'))
                            : ListView.separated(
                                itemCount: parser
                                    .fromString(sport, StateData.gender)
                                    .length,
                                separatorBuilder:
                                    (BuildContext context, int i) => Divider(
                                  height: 1,
                                ),
                                itemBuilder: (BuildContext context, int i) =>
                                    buildGame(
                                        parser.fromString(
                                            sport, StateData.gender)[i],
                                        context),
                              ),
                      )
                    ]),
                ),
              );
          }
        });
  }

  void launchUrl(String url) async {
    StateData.logInfo('Launching $url');
    if (url == null) return;
    String uri = Uri.encodeFull(url);
    if (await canLaunch(uri)) {
      await launch(uri);
    } else
      StateData.logError('Cant Launch $url');
  }

  Widget buildGame(Event e, BuildContext context) => Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: ListTile(
          title: Text(e.opponent),
          trailing: Text(e.score),
          subtitle: Text('${e.date}, ${e.time}'),
          onLongPress: () => launchUrl(e.mapLink),
        ),
      );
  List<Widget> buildControls(BuildContext context) {
    if (StateData.sport == 1 || StateData.sport == 2)
      return [
        buildSegmentedControl(context),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
          child: buildGengerSegmented(context),
        )
      ];
    else
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: buildSegmentedControl(context),
        )
      ];
  }

  Widget buildSegmentedControl(BuildContext context) {
    Map<int, Text> data = {
      0: Text('Football'),
      1: Text('Basketball'),
      2: Text('Soccer'),
      3: Text('Volleyball'),
    };
    return Container(
      width: double.infinity,
      child: CupertinoSegmentedControl(
        borderColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).primaryColor,
        pressedColor: Theme.of(context).primaryColor,
        unselectedColor: Theme.of(context).colorScheme.surface,
        groupValue: StateData.sport,
        children: data,
        onValueChanged: (int index) {
          setState(() {
            StateData.sport = index;
            q.add(index);
            sport = data[index].data;
          });
          if (ListEquality().equals(q, [1, 2, 3, 0, 1, 2, 0, 1, 0])) {
            StateData.logInfo("Theme 5 Unlocked");
            StateData.unlockTheme(5);
            Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('Unlocked Patriot Theme')));
          }
        },
      ),
    );
  }

  Widget buildGengerSegmented(BuildContext context) {
    Map<int, Text> data = {
      0: Text('Men\'s'),
      1: Text('Women\'s'),
    };
    return Container(
      width: double.infinity,
      child: CupertinoSegmentedControl(
        borderColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).primaryColor,
        pressedColor: Theme.of(context).primaryColor,
        unselectedColor: Theme.of(context).colorScheme.surface,
        groupValue: StateData.gender,
        children: data,
        onValueChanged: (int index) {
          setState(() {
            StateData.gender = index;
          });
        },
      ),
    );
  }
}
