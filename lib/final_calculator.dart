import 'package:flutter/material.dart';
import 'stateData.dart';
import 'profile.dart';
import 'parser.dart';

class FinalCalculator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FinalCalculatorState();
}

class FinalCalculatorState extends State<FinalCalculator> {
  //no one has more than 20 classes, right?
  static List<List<double>> hint =
      List.generate(20, (int i) => List.filled(4, null));
  static List<List<TextEditingController>> controllers = List.generate(
      20, (int i) => List.generate(4, (int i) => TextEditingController()));

  Future<Profile> profile = Profile.getDefaultProfile();

  Widget build(BuildContext context) {
    profile.then((Profile p) => p == null ? null : p.updateParser());
    return Scaffold(
      appBar: AppBar(
        title: Text('Final Calculator'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: profile,
          builder: (BuildContext context, AsyncSnapshot<Profile> snap) {
            switch (snap.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                //loading indicator
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                );
              case ConnectionState.done:
                if (snap.hasError) {
                  StateData.logError("Final Calculator Error",
                      error: snap.data?.parser?.error,
                      trace: snap.data?.parser?.trace);
                  return Text('Error');
                } else if (snap.data == null) {
                  return Center(
                    child: Text('Not Logged In'),
                  );
                }
                return buildCalculator(context, snap.data);
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget buildCalculator(BuildContext context, Profile profile) {
    try {
      List<Class> classes = profile.parser.classes;
      return Container(
        child: classes.length == 0
            ? Center(child: Text('No Classes Found'))
            : ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(
                  height: 1,
                ),
                itemBuilder: (BuildContext context, int index) => index == 0
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          " Quarter 1 ",
                          " Quarter 2 ",
                          "   Final   ",
                          "Final Grade"
                        ].map((String s) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(s),
                        )).toList(),
                      )
                    : buildFinalWidget(context, index, classes[index]),
                itemCount: classes.length,
              ),
      );
    } catch (e, t) {
      StateData.logError("Final Calculator Build Error", error: e, trace: t);
      return Text('Error');
    }
  }

  Widget buildFinalWidget(BuildContext context, int index, Class c) {
    return ListTile(
      title: Container(
        child: Row(
          //main axis size is needed when you put a row inside or a list
          //this just makes it take up all available room
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (int i) => buildText(index, i)),
        ),
      ),
      subtitle: Text(c.name),
    );
  }

  Widget buildText(int i, int j) => Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controllers[i][j],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              focusColor: Colors.red,
              border: UnderlineInputBorder(),
              hintText: hint[i][j] == null
                  ? '0.00'
                  : hint[i][j] < 0 ? '0.00' : hint[i][j].toStringAsFixed(2),
            ),
            onChanged: (String s) {
              try {
                hint = List.generate(20, (int i) => List.filled(4, null));
                setState(() {
                  getMissing(i);
                });
              } catch (e) {}
            },
          ),
        ),
      );
//sphaghetti incoming
//fills in thr hint text of whichever of the 4 fields is missing a number
  static void getMissing(int i) {
    List<double> grades = controllers[i]
        .map((TextEditingController edit) =>
            edit.text == null || edit.text.length == 0
                ? null
                : double.parse(edit.text))
        .toList();
    if (grades.where((double d) => d == null).toList().length != 1)
      throw ErrorDescription(
          'getMissing called with an amount of nulls other than 1');
    if (grades[3] != null) {
      double val = grades[3] * 7;
      if (grades[0] != null) val -= grades[0] * 3;
      if (grades[1] != null) val -= grades[1] * 3;
      if (grades[2] != null) val -= grades[2];
      if (grades[0] == null) hint[i][0] = val / 3;
      if (grades[1] == null) hint[i][1] = val / 3;
      if (grades[2] == null) hint[i][2] = val;
    } else
      hint[i][3] = (grades[0] * 3 + grades[1] * 3 + grades[2]) / 7;
  }
}
