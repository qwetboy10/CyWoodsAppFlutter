import 'package:CyWoodsAppFlutter/profile.dart';
import 'package:flutter/material.dart';
import 'grades.dart';
import 'customExpansionTile.dart' as custom;
import 'parser.dart';

class PseudoDialog extends StatefulWidget {
  final Class clas;
  PseudoDialog(this.clas);
  PseudoDialogState createState() => PseudoDialogState();
}

class PseudoDialogState extends State<PseudoDialog> {
  bool validate = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  String category;
  Widget build(BuildContext context) {
    return buildPseudoGradeDialog(context, widget.clas);
  }

  Widget buildPseudoGradeDialog(context, Class clas) {
    return Builder(
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.only(
            left: 30.0,
            right: 30,
            top: (MediaQuery.of(context).size.height - 400) / 2,
            bottom: (MediaQuery.of(context).size.height - 400) / 2),
        child: Card(
          child: Container(
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Add Fake Grade',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textScaleFactor: 1.2,
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  'This grade is not real, and will dissapear when this screen is closed',
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Grade Name'),
                  textAlign: TextAlign.left,
                  controller: nameController,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: 'Grade',
                      errorText: (double.tryParse(gradeController.text) ??
                                      int.tryParse(gradeController.text)) !=
                                  null ||
                              gradeController.text == null ||
                              gradeController.text.length == 0
                          ? null
                          : "Please Enter A Number"),
                  textAlign: TextAlign.left,
                  controller: gradeController,
                ),
                DropdownButton(
                  isExpanded: true,
                  hint: Text('Category'),
                  items: clas.categories
                      .map((String s) => DropdownMenuItem<String>(
                            child: Text(s),
                            value: s,
                          ))
                      .toList(),
                  value: category,
                  onChanged: (String s) {
                    setState(() {
                      category = s;
                    });
                    setState(() {});
                  },
                ),
                Expanded(child: Container()),
                SimpleDialogOption(
                  child: Text(
                    'Done',
                    textScaleFactor: 1.2,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () => ((double.tryParse(gradeController.text) ??
                              int.tryParse(gradeController.text)) !=
                          null)
                      ? Navigator.of(context).pop(
                          [nameController.text, gradeController.text, category])
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    /*return Material(
          child: Container(
            width: 200,
        child: Column(
          children: <Widget>[
            Container(
              width: 200,
            ),
          ],
        ),
      ),
    );*/
  }
}

class GradeDetail extends StatefulWidget {
  final Class currentClass;
  final Profile profile;

  GradeDetail({this.currentClass, this.profile});
  GradeDetailState createState() => GradeDetailState();
}

class GradeDetailState extends State<GradeDetail> {
  Widget buildInfoDialog(context) {
    return SimpleDialog(
      title: Text(widget.currentClass.name),
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  'Grade: ${widget.currentClass.grade?.toStringAsFixed(2) ?? "None"}%'),
              Text('Name: ${widget.currentClass.teacherName}'),
              Text('Email: ${widget.currentClass.teacherEmail}'),
            ],
          ),
        )
      ],
    );
  }

  Widget buildGradeDialog(context, Assignment ass) {
    return SimpleDialog(
      title: Text(ass.name),
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              'Weight: ${ass.weight}',
              'Max Score: ${ass.maxScore}',
              'Date Assigned: ${ass.dateAssigned}',
              'Date Due: ${ass.dateDue}',
              'Extra Credit: ${ass.extraCredit ? "Yes" : "No"}',
              'Note: ${ass.note ?? "None"}',
            ].map((String s) => Text(s)).toList(),
          ),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(([0, 1, 2].any((int i) => widget.currentClass.modified(i))
            ? "EDIT MODE"
            : widget.currentClass.name)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                showDialog(
                        builder: (BuildContext context) =>
                            PseudoDialog(widget.currentClass),
                        context: context)
                    .then((dynamic d) {
                  if (d == null) return;
                  List<String> vals = d;
                  if (vals.any((String s) => s == null || s.length == 0))
                    return;
                  double grade = double.tryParse(vals[1]) ??
                      int.tryParse(vals[1])?.toDouble() ??
                      -1;
                  if (grade == null) return;
                  setState(() {
                    widget.currentClass
                        .addPseudoAssignment(vals[0], vals[2], grade);
                  });
                });
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => buildInfoDialog(context));
            },
          )
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            custom.ExpansionTile(
              initiallyExpanded: true,
              title: Text('Overall Grade'),
              trailing: Text(widget.currentClass?.getGradeString() ?? '---'),

              //decowidget.currentClass.modified(index) ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surface,
              headerBackgroundColor:
                  ([0, 1, 2].any((int i) => widget.currentClass.modified(i))
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.surface),

              children: widget.currentClass.categories
                  .asMap()
                  .map((int index, String name) => MapEntry(
                      index,
                      custom.ExpansionTile(
                        headerBackgroundColor:
                            widget.currentClass.modified(index)
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.surface,
                        title: Text(
                          widget.currentClass.categoryWeights[index] == null
                              ? '$name'
                              : '$name (${(widget.currentClass.categoryWeights[index] * 100).toStringAsFixed(0)}%)',
                        ),
                        trailing: Text(
                            widget.currentClass.getGrade(index)?.toString() ??
                                '---'),
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 8, bottom: 8),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: widget.currentClass.modified(index)
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.surface,
                            ),
                            width: double.infinity,
                            child: Text(
                              widget.currentClass.gradeToKeep(index).toString(),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          )
                        ],
                      )))
                  .values
                  .toList(),
            ),
            Expanded(
              flex: 10,
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(
                  height: 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  Assignment current;
                  if (index < widget.currentClass.pseudoAssignments.length)
                    current = widget.currentClass.pseudoAssignments[index];
                  else
                  {
                    widget.currentClass.assignments.sort((Assignment a, Assignment b) => widget.profile.newAssignments.contains(a) ? -1 : widget.profile.newAssignments.contains(b) ? 1 : 0);
                    current = widget.currentClass.assignments[
                        index - widget.currentClass.pseudoAssignments.length];}
                  return Container(
                    decoration: BoxDecoration(
                        gradient: GradesState.getGradientString(
                            context, current.score,
                            pseudo: current.psuedo)),
                    child: ListTile(
                      title: Text(current.name),
                      subtitle: Text(
                          '${current.category}${current.psuedo ? " (Fake Grade)" : ""}'),
                      trailing: Text(current.score),
                      leading: current.psuedo
                          ? IconButton(
                              icon: Icon(Icons.close),
                              iconSize: 12,
                              onPressed: () {
                                if (current.psuedo) {
                                  setState(() {
                                    widget.currentClass
                                        .removePseudoAssignment(current.name);
                                  });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          buildGradeDialog(context, current));
                                }
                              },
                            )
                          : widget.profile.newAssignments.contains(current)
                              ? Icon(Icons.new_releases)
                              : null,
                    ),
                  );
                },
                itemCount: widget.currentClass.assignments.length +
                    widget.currentClass.pseudoAssignments.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
