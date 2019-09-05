import 'dart:convert';

import 'stateData.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Event {
//shown as a horizontal scrolling list above news items
//examples include prom or red ribbon week

  String title;
  String dates;
  Event(Map<String, dynamic> data)
  {
    title = data['title'];
    dates = data['dates'];
  }
}

class NewsItem {
//shown as vertical scrolling list
//includes app news, school news, district news
  String title;
  String date;
  String category;
  String url;
  //if there is no link url should be left as null
  NewsItem({this.title, this.category, this.date, this.url});
  NewsItem.fromMap(Map<String, dynamic> data)
  {
    title = data['title'];
    category = data['type'];
    date = data['date'];
    url = data['url'];
  }
}

class Home extends StatelessWidget {
  final Future<http.Response> data = http.get('${StateData.url}/News');
  static final List<Event> events = [];
  //static List<Event> events = [];

  static final List<NewsItem> news = [];
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return loadingImage(context, Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ));
          case ConnectionState.done:
            if (snapshot.hasError || snapshot.data == null) {
              return loadingImage(context,Center(
                child: Text('Network Error'),
              ));
            }
            StateData.logInfo(utf8.decode(snapshot.data.bodyBytes));
            return buildHome(context, utf8.decode(snapshot.data.bodyBytes));
        }
        return null;
      },
    );
  }

  Column loadingImage(BuildContext context, Widget bottom) {
    return Column(
      children: <Widget>[
        Image.asset(
          'assets/home_art.png',
        ),
        Expanded(child: bottom),
      ],
    );
  }
  void loadJSON(String data)
  {
    Map<String, dynamic> root = jsonDecode(data);
    List<dynamic> n = root['news'];
    List<dynamic> e = root['events'];
    news.clear();
    news.addAll( n.map((dynamic d) => NewsItem.fromMap(d)).toList());
    events.clear();
    events.addAll(e.map((dynamic d) => Event(d)).toList());
  }
  Column buildHome(BuildContext context, String data) {
    loadJSON(data);
    return Column(
      children: <Widget>[
      //amals art
        Image.asset(
          'assets/home_art.png',
        ),
	//hide events id theres none going on
        events.length > 0
            ? Container(
                height: 65,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: events
                      .map((Event e) => buildEventBox(e, context))
                      .toList(),
                ),
              )
            : Divider(
                height: 1,
              ),
	      //list of news items
	      //the expanded is needed whenever you put a list inside of a column so it knows how much of the column to take up
        Expanded(
          flex: 3,
          child: ListView.separated(
            itemCount: news.length,
            itemBuilder: buildNewsItem,
            separatorBuilder: (BuildContext context, int index) => Divider(
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNewsItem(BuildContext context, int index) {
    NewsItem n = news[index];
    return Container(
      child: ListTile(
        title: Text(n.title),
        subtitle: Text('${n.category} - ${n.date}'),
        onTap: () {
	//does nothing if url is null / invalid
          launchNewsItem(n);
        },
      ),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
    );
  }
//uses url-launcher package
  void launchNewsItem(NewsItem n) async {
    if(n.url == null) return;
    String uri = Uri.encodeFull(n.url);
    if (await canLaunch(uri)) {
      await launch(uri);
    }
  }

//event box
  Widget buildEventBox(Event e, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 8, top: 8, bottom: 8),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Text(
              e.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(height: 4),
            Text(
              e.dates,
              textScaleFactor: .75,
            ),
          ],
        ),
        alignment: Alignment.center,
      ),
    );
  }
}
