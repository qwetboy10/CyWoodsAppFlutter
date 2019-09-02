import 'dart:convert';

import 'stateData.dart';

class AthleticsParser {
  List<Event> football;
  List<Event> volleyball;
  List<Event> mBasketball;
  List<Event> fBasketball;
  List<Event> mSoccer;
  List<Event> fSoccer;
  List<Event> all;
  List<Event> fromString(String s, int gender)
  {
    switch(s)
    {
      case "Football": return football;
      case "Volleyball": return volleyball;
      case "Basketball": return gender == 0 ? mBasketball : fBasketball;
      case "Soccer": return gender == 0 ? mSoccer : fBasketball;
    }
  }
  AthleticsParser(String rawData) {
    try {
      List<dynamic> data = json.decode(rawData)['games'];
      all = data.map((dynamic d) => Event(d)).toList();
      football = all.where((Event e) => e.sport == 'Football (M)').toList();
      volleyball = all.where((Event e) => e.sport == 'Volleyball (F)').toList();
      mBasketball =
          all.where((Event e) => e.sport == 'Basketball (M)').toList();
      fBasketball =
          all.where((Event e) => e.sport == 'Basketball (F)').toList();
      mSoccer = all.where((Event e) => e.sport == 'Soccer (M)').toList();
      fSoccer = all.where((Event e) => e.sport == 'Soccer (F)').toList();
    } catch (e, t) {
      StateData.logError('Athletics Parse Failed', error: e, trace: t);
    }
  }
}

class Event {
  /*
    {
      "sport": "Basketball (M)",
      "opponent": "Bryan",
      "score": "0 - 0",
      "date": "2/18/2020",
      "time": "7:00",
      "location": "Bryan HS",
      "mapLink": "http://maps.google.com/?q=3450 Campus Dr 77802 TX"
    }
    */
  String sport;
  String opponent;
  String score;
  String date;
  String time;
  String location;
  String mapLink;
  Event(Map<String, dynamic> data) {
    sport = data['sport'];
    opponent = data['opponent'];
    score = data['score'];
    date = data['date'];
    time = data['time'];
    location = data['location'];
    mapLink = data['mapLink'];
  }
}
