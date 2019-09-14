import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'stateData.dart';
import 'package:intl/intl.dart';

class ScheduleData {
  DateTime start;
  DateTime end;
  String name;
  ScheduleData({this.start, this.end, this.name});
  ScheduleData.from24Time(String n, String s, String e) {
    name = n;
    DateTime now = DateTime.now();
    int shour = int.parse(s.split(':')[0]);
    int smin = int.parse(s.split(':')[1]);
    int ehour = int.parse(e.split(':')[0]);
    int emin = int.parse(e.split(':')[1]);
    start = DateTime(now.year, now.month, now.day, shour, smin);
    end = DateTime(now.year, now.month, now.day, ehour, emin);
  }
  bool current() {
    return start.isBefore(DateTime.now()) && end.isAfter(DateTime.now());
  }

  String timeString() {
    DateFormat format = DateFormat('jm');
    return '${format.format(start)} - ${format.format(end)}';
  }

  @override
  String toString() {
    return '$name ${timeString()}';
  }
}

class Schedule extends StatefulWidget {
  Future<http.Response> scheduleData =
      http.get('${StateData.url}/Schedule?day=${getCurrentMonthDay()}');
  static String getCurrentMonthDay() =>
      '${DateTime.now().month.toString().padLeft(2, "0")}-${DateTime.now().day.toString().padLeft(2, "0")}';
  Schedule({Key key}) : super(key: key);
  @override
  ScheduleState createState() => ScheduleState();
}

class ScheduleState extends State<Schedule> {
  SharedPreferences prefs;
  static bool manual = false;
  bool seconds = false;
  Timer t;
  @override
  initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences p)
    {
      setState(() {
        
      seconds = p.getBool("SECONDS");
      StateData.lunch = p.getInt("DEFAULTLUNCH");
      });
    });
  t = new Timer.periodic(Duration(seconds: 10), (_) {
     setState(() {
    });
  });
  }
  @override
  dispose() {
    super.dispose();
    t.cancel();
  }
  static String schedule;
  static List<List<ScheduleData>> data;
  static String scheduleName = 'Regular Bell Schedule';
  static List<List<String>> names = [
    [
      'Period 1',
      'Period 2',
      'Period 3',
      'Lunch',
      'Period 4',
      'Period 5',
      'Period 6',
      'Period 7'
    ],
    [
      'Period 1',
      'Period 2',
      'Period 3',
      'Period 4',
      'Lunch',
      'Period 5',
      'Period 6',
      'Period 7'
    ],
    [
      'Period 1',
      'Period 2',
      'Period 3',
      'Period 4',
      'Period 5',
      'Lunch',
      'Period 6',
      'Period 7'
    ]
  ];
  void setScheduleData(String jsonData) {
    String sv;
    bool custom = false;
    if (schedule != null)
      sv = schedule;
    else {
      Map<String, dynamic> json = jsonDecode(jsonData);
      sv = json['type'];
    }
    List<List<List<String>>> localData;
    switch (sv) {
      case 'second':
        localData = [
          [
            ['7:20', '8:10'],
            ['8:16', '9:27'],
            ['9:33', '10:23'],
            ['10:23', '10:53'],
            ['10:59', '11:49'],
            ['11:55', '12:46'],
            ['12:52', '13:43'],
            ['13:49', '14:40']
          ],
          [
            ['7:20', '8:10'],
            ['8:16', '9:27'],
            ['9:33', '10:23'],
            ['10:29', '11:19'],
            ['11:19', '11:49'],
            ['11:55', '12:46'],
            ['12:52', '13:43'],
            ['13:49', '14:40']
          ],
          [
            ['7:20', '8:10'],
            ['8:16', '9:27'],
            ['9:33', '10:23'],
            ['10:29', '11:19'],
            ['11:25', '12:16'],
            ['12:16', '12:46'],
            ['12:52', '13:43'],
            ['13:49', '14:40']
          ]
        ];
        scheduleName = 'Extended Second';
        break;

      case 'seventh':
        localData = [
          [
            ['7:20', '8:12'],
            ['8:18', '9:14'],
            ['9:20', '10:06'],
            ['10:06', '10:36'],
            ['10:42', '11:28'],
            ['11:34', '12:20'],
            ['12:26', '13:12'],
            ['13:19', '14:40']
          ],
          [
            ['7:20', '8:12'],
            ['8:18', '9:14'],
            ['9:20', '10:06'],
            ['10:12', '10:58'],
            ['10:58', '11:28'],
            ['11:34', '12:20'],
            ['12:26', '13:12'],
            ['13:19', '14:40']
          ],
          [
            ['7:20', '8:12'],
            ['8:18', '9:14'],
            ['9:20', '10:06'],
            ['10:12', '10:58'],
            ['11:04', '11:50'],
            ['11:50', '12:20'],
            ['12:26', '13:12'],
            ['13:19', '14:40']
          ]
        ];
        scheduleName = 'Extended Seventh';

        break;
      case 'custom':
        data = List<List<ScheduleData>>();
        custom = true;
        Map<String, dynamic> json = jsonDecode(jsonData);
        scheduleName = json['name'];
        Map<String, dynamic> sc = json['schedule'];
        ['A', 'B', 'C'].map((String lunch) {
          List<List<String>> local = List<List<String>>();
          for (String name in sc[lunch].keys) {
            local.add([name, sc[lunch][name][0], sc[lunch][name][1]]);
          }
          data.add(local
              .map(
                  (List<String> s) => ScheduleData.from24Time(s[0], s[1], s[2]))
              .toList());
        }).toList();
        break;
      case 'standard':
      default:
        localData = [
          [
            ['7:20', '8:12'],
            ['8:18', '9:20'],
            ['9:26', '10:18'],
            ['10:18', '10:48'],
            ['10:54', '11:46'],
            ['11:52', '12:44'],
            ['12:50', '13:42'],
            ['13:48', '14:40']
          ],
          [
            ['7:20', '8:12'],
            ['8:18', '9:20'],
            ['9:26', '10:18'],
            ['10:24', '11:16'],
            ['11:16', '11:46'],
            ['11:52', '12:44'],
            ['12:50', '13:42'],
            ['13:48', '14:40']
          ],
          [
            ['7:20', '8:12'],
            ['8:18', '9:20'],
            ['9:26', '10:18'],
            ['10:24', '11:16'],
            ['11:22', '12:14'],
            ['12:14', '12:44'],
            ['12:50', '13:42'],
            ['13:48', '14:40']
          ]
        ];
        scheduleName = 'Regular Bell Schedule';
    }
    if (!custom) {
      localData = localData
          .asMap()
          .map((int index, List<List<String>> e) {
            return MapEntry<int, List<List<String>>>(
                index,
                e
                    .asMap()
                    .map((int ind, List<String> s) =>
                        MapEntry<int, List<String>>(
                            ind, []..addAll([names[index][ind]])..addAll(s)))
                    .values
                    .toList());
          })
          .values
          .toList();
      data = localData.map((List<List<String>> schedule) {
        return schedule
            .map((List<String> ts) =>
                ScheduleData.from24Time(ts[0], ts[1], ts[2]))
            .toList();
      }).toList();
    }
  }

  void updateSchedule() {
    setState(() {});
  }

  //'${DateTime.now().month.toString().padLeft(2, "0")}-11';
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.scheduleData,
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            if (schedule != null) {
              setScheduleData(schedule);
              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                              height: 1,
                            ),
                        itemCount: data[0].length + 1,
                        itemBuilder: listItemBuilder),
                  ),
                ],
              );
            }
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              StateData.logError('Schedule Fetch Failed',
                  error: snapshot.error);
              return Center(
                child: Text('Network Error'),
              );
            }
            if (snapshot.data != null && snapshot.data.statusCode == 200) {
              try {
                setScheduleData(snapshot.data.body);
              } catch (e, t) {
                StateData.logError('Schedule Fetch Failed', error: e, trace: t);
                return Center(child: Text('Network Error'));
              }
              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                              height: 1,
                            ),
                        itemCount: data[0].length + 1,
                        itemBuilder: listItemBuilder),
                  ),
                ],
              );
            } else {
              StateData.logError(
                  'Schedule Fetch Failed: ${snapshot.data.toString()}');
              return Center(
                child: Text('Network Error'),
              );
            }
        }
        return null;
      },
    );
  }

  Widget listItemBuilder(context, index) {
    if (index == 0) {
      return Container(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        width: double.infinity,
        child: Column(children: <Widget>[
          buildSegmentedControl(context),
          Container(
            padding: const EdgeInsets.only(top: 8.0, left: 16),
            alignment: Alignment.centerLeft,
            child:
                Text('$scheduleName${schedule == null ? "" : " (Override)"}'),
          )
        ]),
      );
    } else {
      return buildSlot(data[StateData.lunch][index - 1], context);
    }
  }

  Widget buildSegmentedControl(BuildContext context) {
    return Container(
      width: double.infinity,
      child: CupertinoSegmentedControl(
        borderColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).primaryColor,
        pressedColor: Theme.of(context).primaryColor,
        unselectedColor: Theme.of(context).colorScheme.surface,
        groupValue: StateData.lunch,
        children: {
          0: Text('A Lunch'),
          1: Text('B Lunch'),
          2: Text('C Lunch'),
        },
        onValueChanged: (int index) {
          setState(() {
            StateData.lunch = index;
          });
        },
      ),
    );
  }

  Widget buildSlot(ScheduleData data, BuildContext context) {
    return Container(
        child: ListTile(
          dense: false,
          title: Text(
            data.name ?? 'name',
          ),
          subtitle: Text(
            data.timeString() +
                (data.current()
                    ? ' (${data.end.difference(DateTime.now()).inMinutes.toString()} Minute${data.end.difference(DateTime.now()).inMinutes != 1 ? 's' : ''} ${seconds && secondsRemaining(data.end) < 60?"And "+secondsRemaining(data.end).toString() + " seconds":""} Remaining)'
                    : ""),
          ),
        ),
        decoration: data.current()
            ? BoxDecoration(color: Theme.of(context).colorScheme.secondary)
            : BoxDecoration(color: Theme.of(context).colorScheme.surface));
  }
  int secondsRemaining(DateTime end) => end.difference(DateTime.now()).inSeconds;
}
