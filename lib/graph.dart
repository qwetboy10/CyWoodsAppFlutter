import 'stateData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'profile.dart';

class Graph extends StatefulWidget {
  State createState() => GraphState();
}

class GraphState extends State<Graph> {
  Future<String> getData() async {
    Profile prof = await Profile.getDefaultProfile();
    return prof.readGraph();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Graph'),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
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
              if (snapshot.hasError) {
                StateData.logError('Graph Fetch Failed', error: snapshot.error);
                return Center(
                  child: Text('Network Error'),
                );
              }
              return buildGraph(context, snapshot.data);

          }
          return null;
        },
      ),
    );
  }

  Widget buildGraph(BuildContext context, String data) {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: charts.TimeSeriesChart(
        buildSeries(data),
        animate: false,
        primaryMeasureAxis: charts.NumericAxisSpec(
          viewport: charts.NumericExtents(70, 100),
        ),
      ),
    );
  }

  List<charts.Series> buildSeries(String data) {
    List<charts.Series<GraphPoint, DateTime>> ret = [];
    List<List<GraphPoint>> points = [];
    List<String> names = [];
    List<String> lines = data.split("\n");
    lines.removeLast();
    print(lines.toString());
    int inc = 0;
    for (int i = 0; i < lines.length; i++, inc++) {
      if (lines[i] == '-----') break;
    }
    inc++;
    for (int i = 0; i < lines.length; i += inc) {
      DateTime time = DateTime.parse(lines[i]);
      for (int j = i + 1; j < i + inc; j++) {
        List<String> line = lines[j].split(":");
        if (line[0] == '-----') continue;
        while (j - i >= points.length) points.add(List<GraphPoint>());
        while (j - i >= names.length) names.add(line[0]);
        if (line[1] != null && line[1] != 'null')
          points[j - i].add(GraphPoint(time, double.parse(line[1])));
      }
    }
    List<charts.Color> pallete = [
      charts.MaterialPalette.red.shadeDefault,
      charts.MaterialPalette.deepOrange.shadeDefault,
      charts.MaterialPalette.yellow.shadeDefault,
      charts.MaterialPalette.green.shadeDefault,
      charts.MaterialPalette.blue.shadeDefault,
      charts.MaterialPalette.purple.shadeDefault,
      charts.MaterialPalette.pink.shadeDefault,
    ];
    List<charts.Color> colors = List.generate(100, (int i) => pallete[i % 7]);
    for (int i = 0; i < names.length; i++) {
      ret.add(charts.Series<GraphPoint, DateTime>(
        id: names[i],
        colorFn: (GraphPoint g, __) => colors[i],
        domainFn: (GraphPoint g, _) => g.time,
        measureFn: (GraphPoint g, _) => g.score,
        data: points[i],
      ));
    }
    return ret;
  }
}

class GraphPoint {
  final DateTime time;
  final double score;
  GraphPoint(this.time, this.score);
  String toString() => '$time $score';
}
