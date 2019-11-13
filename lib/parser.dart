import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'stateData.dart';
//this file parses all the data from the server
//most of it is kinda self explanatory

class Parser {
  Error error;
  StackTrace trace;
  DateTime lastUpdated;
  String rawData;
  List<Class> classes;
  Transcript transcript;
  List<Day> attendance;
  String toString() {
    String ret =
        '${error?.toString() ?? "NO ERROR"}\n${trace?.toString() ?? "NO TRACE"}';
    ret += '\nClasses: ${classes.length}';
    return ret;
  }

  String getLastUpdated() => lastUpdated == null
      ? 'Unknown'
      : DateFormat('EEEE, h:mm a').format(lastUpdated);

  Parser(this.rawData) {
    try {
      Map<String, dynamic> jsonData = json.decode(rawData);
      List<dynamic> classData = jsonData['classes'];
      classes = List<Class>();
      for (dynamic d in classData)
        classes.add(Class(d as Map<String, dynamic>));
      classes = classes.where((Class c) => c.name != 'Lunch').toList();
      transcript = Transcript(jsonData['transcript']);
      Map<String, dynamic> att = jsonData['attendance'];
      attendance = [];
      for (String s in att.keys) attendance.add(Day(s, att[s]));
      lastUpdated = DateTime.parse(jsonData['lastUpdated']);
      StateData.logVerbose(classes.toString());
      StateData.logVerbose(transcript.toString());
      StateData.logVerbose(attendance.toString());
      error = null;
      trace = null;
    } catch (e, t) {
      error = e;
      trace = t;
      StateData.logError('Parser Build Failed', error: e, trace: t);
    }
  }
  List<Assignment> gradesHasChanged(Parser old) {
    if (old == null ||
        old.error != null ||
        old.classes.length != classes.length) {
      return [];
    }
    List<Assignment> changes = [];
    for (int i = 0; i < classes.length; i++)
      changes.addAll(classes[i].assignmentChanges(old.classes[i]));
    return changes
        .where((Assignment a) => a.score != null && a.score.length != 0)
        .toList();
  }

  String graphSnaphot() =>
      "${DateTime.now().toIso8601String()}\n${classes.fold("", (String s, Class c) => '$s${c.name}:${c.grade.toString()}\n')}-----\n";
}

class Day {
  String date;
  String code;
  Day(this.date, this.code);
  String toString() => '$date:$code';
}

class Transcript {
  double gpa;
  String rank;
  List<Year> years;
  Transcript(Map<String, dynamic> data) {
    gpa = data['gpa'];
    rank = data['rank'];
    List<dynamic> yearData = data['years'];
    years = yearData.map((dynamic d) => Year(d)).toList();
  }
  String toString() => '$gpa\n$rank\n${years.toString()}';
}

class Year {
  String year;
  String building;
  String grade;
  double totalCredit;
  List<Course> courses;
  String toString() =>
      '$year - $building - $grade - $totalCredit - ${courses.toString()}';
  Year(Map<String, dynamic> data) {
    year = data['year'];
    building = data['building'];
    grade = data['grade'];
    totalCredit = data['totalCredit'];
    List<dynamic> courseData = data['courses'];
    courses = courseData.map((dynamic d) => Course(d)).toList();
    merge();
  }
  //courses are often stored weirdly where you get the two semesters as different courses
  //this merges any two courses with thr same name
  void merge() {
    List<Course> n = [];
    for (int i = 0; i < courses.length; i++) {
      bool flag = false;
      for (int j = 0; j < n.length; j++) {
        if (n[j].description == courses[i].description) {
          n[j].merge(courses[i]);
          flag = true;
        }
      }
      if (!flag) n.add(courses[i]);
    }
    courses = n;
  }
}

//a course is a class that you finished and got the credit from
//courses are part of your transcript, not your current grades
class Course {
  String course;
  String description;
  String sem1;
  String sem2;
  double credit;
  String toString() => '$course $description $sem1 $sem2 $credit';
  Course(Map<String, dynamic> data) {
    course = data['course'];
    description = data['description'];
    sem1 = data['sem1'];
    sem2 = data['sem2'];
    credit = data['credit'];
  }
  void merge(Course o) {
    if (description != o.description)
      throw ErrorDescription('Tried to merge non identical courses');
    if (sem1 == null || sem1.length == 0) sem1 = o.sem1;
    if (sem2 == null || sem2.length == 0) sem2 = o.sem2;
    credit += o.credit;
  }

  String getSemesters() =>
      '${sem1 == null || sem1.length == 0 ? "--" : sem1} ${sem2 == null || sem2.length == 0 ? "--" : sem2}';
}

//a class ur taking rn
class Class {
  String name;
  double grade;
  List<double> categoryWeights;
  //remember to change this if they ever rename anything
  List<double> categoryPoints;
  List<double> categoryTotals;
  String getGrade(int category) {
    return pseudoCategoryPoints[category] == null ||
            pseudoCategoryTotals[category] == 0
        ? null
        : (pseudoCategoryPoints[category] /
                pseudoCategoryTotals[category] *
                100)
            .toStringAsFixed(2);
  }

  List<Assignment> assignmentChanges(Class old) {
    List<Assignment> n = []..addAll(assignments);
    for (Assignment a in old.assignments) if (n.contains(a)) n.remove(a);
    return n.where((Assignment a) => a.score != null).toList();
  }

  List<String> categories;
  String teacherName;
  String teacherEmail;
  List<Assignment> assignments;
  List<Assignment> pseudoAssignments = [];
  List<double> pseudoCategoryPoints;
  List<double> pseudoCategoryTotals;
  String toString() =>
      '$name - $grade - $teacherName - $teacherEmail -  ${categoryPoints.toString()} - ${categoryTotals.toString()} - ${categoryWeights.toString()}';

  bool modified(int category) =>
      (categoryTotals[category] ?? 0) != pseudoCategoryTotals[category];
  //the grades you see will always be based of these two pseudo category totals
  //if you dont have any pseudogrades they will be equal to the normal categoey totals tho
  void addPseudoAssignment(String name, String category, double score) {
    pseudoAssignments.add(Assignment.pseudo(name, category, score.toString()));
    refreshPseudoCategories();
  }

  void removePseudoAssignment(String name) {
    pseudoAssignments.removeAt(
        pseudoAssignments.indexWhere((Assignment a) => a.name == name));
    refreshPseudoCategories();
  }

  void removeAllPseudoAssignments() {
    pseudoAssignments = [];
    refreshPseudoCategories();
  }

  void refreshPseudoCategories() {
    pseudoCategoryPoints = []..addAll(categoryPoints);
    pseudoCategoryTotals = []..addAll(categoryTotals);
    for (int i = 0; i < 3; i++) {
      if (pseudoCategoryPoints[i] == null) pseudoCategoryPoints[i] = 0;
      if (pseudoCategoryTotals[i] == null) pseudoCategoryTotals[i] = 0;
    }
    for (Assignment a in pseudoAssignments) {
      int cat = categories.indexOf(a.category);
      if (cat == -1) throw Exception('Category not found');
      pseudoCategoryPoints[cat] == null
          ? pseudoCategoryPoints[cat] = double.parse(a.score)
          : pseudoCategoryPoints[cat] += double.parse(a.score);
      pseudoCategoryTotals[cat] == null
          ? pseudoCategoryTotals[cat] = 100
          : pseudoCategoryTotals[cat] += 100;
    }
  }

  Class(Map<String, dynamic> data) {
    name = data['name'];
    grade = data['grade'];
    Map<String, dynamic> teacher = data['teacher'];
    teacherName = teacher['name'];
    teacherEmail = teacher['email'];
    assignments = List<Assignment>();
    List<dynamic> assignmentData = data['assignments'];
    for (dynamic d in assignmentData)
      assignments.add(Assignment(d as Map<String, dynamic>));
    //just ignore lunch
    //the server sends it but its useless
    if (name == 'Lunch') return;
    Map<String, dynamic> weights = data['weights'];
    categories = weights.keys.toList();

    categoryWeights =
        categories.map((String s) => weights[s] as double).toList();
    int nulls = categoryWeights.where((double d) => d == null).toList().length;
    if (nulls == 1) {
      double sum = categoryWeights
          .where((double d) => d != null)
          .reduce((double a, double b) => a + b);
      for (int i = 0; i < 3; i++)
        if (categoryWeights[i] == null) categoryWeights[i] = 1.0 - sum;
    }
    Map<String, dynamic> points = data['categoryPoints'];
    categoryPoints = [];
    categoryTotals = [];
    for (String cat in categories) {
      if (points[cat] == null) {
        categoryPoints.add(null);
        categoryTotals.add(null);
      } else {
        categoryPoints.add(double.parse(points[cat].toString().split('/')[0]));
        categoryTotals.add(double.parse(points[cat].toString().split('/')[1]));
      }
    }
    refreshPseudoCategories();
  }
  //hope this works
  String gradeToKeep(int category) {
    try {
    if (categoryWeights[category] == null || getGradeDouble() == null) return '---';
    if (getGradeDouble() < 89.5) {
      int nulls =
          categoryWeights.where((double d) => d == null).toList().length;
      double gradeRequired = [89.5, 79.5, 69.5]
          .lastWhere((double d) => getGradeDouble() < d, orElse: () => 89.5);
      String current =
          gradeRequired == 89.5 ? 'A' : gradeRequired == 79.5 ? 'B' : 'C';
      double points = gradeRequired;
      double categoryWeightSum = categoryWeights
          .where((double d) => d != null)
          .fold(0, (num a, double b) => a + b)
          .toDouble();
      if (nulls == 2) {
        points /= 100;
        points *= pseudoCategoryTotals[category] + 100;
        points -= pseudoCategoryPoints[category];
      } else {
        for (int i = 0; i < 3; i++) {
          if (i != category) {
            if (pseudoCategoryTotals[i] == 0)
              continue;
            else
              points -= 100 *
                  (categoryWeights[i] / categoryWeightSum) *
                  pseudoCategoryPoints[i] /
                  pseudoCategoryTotals[i];
          }
        }
        points /= 100;
        points /= (categoryWeights[category] / categoryWeightSum);
        points *= (pseudoCategoryTotals[category] + 100);
        points -= pseudoCategoryPoints[category];
      }
      if (points <= 105 && points >= 0)
        return 'Get at least a ${points.toStringAsFixed(2)} on your next assignment to get a${current == "A" ? "n" : ""} $current';
    }
    int nulls = categoryWeights.where((double d) => d == null).toList().length;
    double gradeRequired = [89.5, 79.5, 69.5]
        .firstWhere((double d) => getGradeDouble() > d, orElse: () => 69.5);
    if (gradeRequired == null) gradeRequired = 69.5;
    String current =
        gradeRequired == 89.5 ? 'A' : gradeRequired == 79.5 ? 'B' : 'C';
    double points = gradeRequired;
    if (nulls == 2) {
      points /= 100;
      points *= pseudoCategoryTotals[category] + 100;
      points -= pseudoCategoryPoints[category];
      return 'Get at least a ${points.toStringAsFixed(2)} on your next assignment to keep a${current == "A" ? "n" : ""} $current';
    } else {
      for (int i = 0; i < 3; i++) {
        if (i != category) {
          if (pseudoCategoryTotals[i] == 0)
            points -= 100 * categoryWeights[i];
          else
            points -= 100 *
                categoryWeights[i] *
                pseudoCategoryPoints[i] /
                pseudoCategoryTotals[i];
        }
      }
      points /= 100;
      points /= categoryWeights[category];
      points *= (pseudoCategoryTotals[category] + 100);
      points -= pseudoCategoryPoints[category];
      if (points < 0) points = 0;
      return 'Get at least a ${points.toStringAsFixed(2)} on your next assignment to keep a${current == "A" ? "n" : ""} $current';
    }
    /*
    if (categoryWeights[category] == null) return '---';
    double gradeRequired =
        [89.5, 79.5, 69.5].firstWhere((double d) => grade > d);
    String current =
        gradeRequired == 89.5 ? 'A' : gradeRequired == 79.5 ? 'B' : 'C';
    double points = gradeRequired;
    double weightSum = 0;
    for(int i=0;i<3;i++) if(pseudoCategoryTotals[i] != 0 && categoryWeights[i] != null) weightSum += categoryWeights[i];
    [0, 1, 2]
        .where((int i) => i != category && categoryWeights[i] != null)
        .forEach((int i) => points -= (categoryWeights[i] / weightSum) *
            (pseudoCategoryTotals[i] == 0
                ? 0
                : pseudoCategoryPoints[i] / pseudoCategoryTotals[i] * 100));
    points /= (categoryWeights[category] / weightSum);
    //category average must be at least equal to points
    double tempCategoryPoints = pseudoCategoryPoints[category];
    double tempCategoryTotals = pseudoCategoryTotals[category];
    tempCategoryTotals += 100;
    points *= tempCategoryTotals / 100;
    points -= tempCategoryPoints;
    if (points < 0) points = 0;
    return 'Get at least a ${points.toStringAsFixed(2)} on your next assignment to keep a${current == "A" ? "n" : ""} $current';*/
    }
    catch(e, t)
    {
      StateData.logError('Get next grade failed', error: e, trace: t);
    }
    return '---';
  }

  String getGradeString() => anyModified()
      ? [0, 1, 2]
          .fold(
              0.00,
              (double d, int i) =>
                  categoryWeights[i] != null && pseudoCategoryTotals[i] != 0
                      ? d +
                          pseudoCategoryPoints[i] /
                              pseudoCategoryTotals[i] *
                              100 *
                              categoryWeights[i] /
                              [0, 1, 2]
                                  .map((int i) => categoryWeights[i] != null &&
                                          pseudoCategoryTotals[i] != null &&
                                          pseudoCategoryTotals[i] != 0
                                      ? categoryWeights[i]
                                      : 0.0)
                                  .reduce((double a, double b) => a + b)
                      : d)
          .toStringAsFixed(2)
      : grade?.toStringAsFixed(2) ?? '---';
  double getGradeDouble() => anyModified()
      ? ([0, 1, 2]
              .map((int i) => categoryWeights[i] != null
                  ? pseudoCategoryPoints[i] /
                      pseudoCategoryTotals[i] *
                      categoryWeights[i] *
                      100
                  : 0)
              .reduce((a, b) => a + b) /
          categoryWeights
              .where((double d) => d != null)
              .reduce((double a, double b) => a + b))
      : grade;
  bool anyModified() => [0, 1, 2].any((int i) => modified(i));
}

class Assignment {
  bool isNew;
  bool operator ==(o) => name == o.name && score == o.score;
  int get hashCode => ((17 * 31) + name.hashCode) * 31 + score.hashCode;
  Assignment(Map<String, dynamic> data) {
    name = data['name'];
    category = data['category'];
    dateAssigned = data['dateAssigned'];
    dateDue = data['dateDue'];
    score = data['score'];
    weight = data['weight'];
    maxScore = data['maxScore'];
    extraCredit = data['extraCredit'];
    note = data['note'];
    psuedo = false;
    isNew = false;
  }
  Assignment.pseudo(this.name, this.category, this.score) {
    psuedo = true;
  }
  List<double> getPoints() {
    if (score.toLowerCase() == 'z') score = '0.0';
    try {
      return [(double.parse(score) / maxScore) * weight * 100, 100];
    } catch (e) {
      return [0, 0];
    }
  }

  String toString() => '$name - $category $score';
  String name;
  String category;
  String dateAssigned;
  String dateDue;
  String score;
  double weight;
  double maxScore;
  bool extraCredit;
  String note;
  bool psuedo;
}
