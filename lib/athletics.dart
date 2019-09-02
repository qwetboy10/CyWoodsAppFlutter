import 'package:CyWoodsAppFlutter/stateData.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Event {}

class Athletics extends StatefulWidget {
  State<Athletics> createState() => AthleticsState();
}

class AthleticsState extends State<Athletics> {
  List<int> q = [];
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        width: double.infinity,
        child: Column(children: <Widget>[
          buildSegmentedControl(context),
          Expanded(
            child: Center(
                child: Text('Athletics Schedule has not yet been released')),
          )
        ]));
  }

  Widget buildSegmentedControl(BuildContext context) {
    return Container(
      width: double.infinity,
      child: CupertinoSegmentedControl(
        borderColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).primaryColor,
        pressedColor: Theme.of(context).primaryColor,
        unselectedColor: Theme.of(context).colorScheme.surface,
        groupValue: StateData.sport,
        children: {
          0: Text('Football'),
          1: Text('Basketball'),
          2: Text('Soccer'),
          3: Text('Volleyball'),
        },
        onValueChanged: (int index) {
          setState(() {
            StateData.sport = index;
            q.add(index);
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
}
