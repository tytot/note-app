import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:renote/modal_class/notes.dart';
import 'package:renote/screens/note_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:renote/screens/search_note.dart';
import 'package:renote/screens/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:renote/utils/widgets.dart';

class NoteList extends StatefulWidget {
  NoteList({Key key, this.uid}) : super(key: key);
  final String uid; //include this

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> with TickerProviderStateMixin {
  int count = 0;
  int axisCount = 2;
  List<Note> notes = List<Note>();
  static const List<IconData> icons = const [ Icons.camera_alt, Icons.create ];
  AnimationController _controller;

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget myAppBar() {
    return AppBar(
      title: Text("Your Notes", style: Theme.of(context).textTheme.headline),
      bottom: PreferredSize(child: Container(color: Theme.of(context).primaryColor, height: 4.0,), preferredSize: Size.fromHeight(4.0)),
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.search,
        ),
        onPressed: () async {
          final Note result = await showSearch(
              context: context, delegate: NotesSearch(notes: notes));
          if (result != null) {
            navigateToDetail(result, 'Search');
          }
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            axisCount == 2 ? Icons.list : Icons.grid_on,
          ),
          onPressed: () {
            setState(() {
              axisCount = axisCount == 2 ? 4 : 2;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.account_box),
          onPressed: () {
            signOut();
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(),
      body: buildNotesView(context),
      floatingActionButton: new Column(
        mainAxisSize: MainAxisSize.min,
        children: new List.generate(icons.length, (int index) {
          Widget child = new Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: new ScaleTransition(
              scale: new CurvedAnimation(
                parent: _controller,
                curve: new Interval(
                  0.0,
                  1.0 - index / icons.length / 2.0,
                  curve: Curves.easeOut
                ),
              ),
              child: new FloatingActionButton(
                heroTag: null,
                shape: CircleBorder(side: BorderSide(color: Theme.of(context).primaryColorDark, width: 3.0)),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                mini: true,
                child: new Icon(icons[index], color: Theme.of(context).primaryColorDark),
                onPressed: () {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TakePictureScreen(widget.uid))
                    );
                  } else {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => NoteDetail(Note('', '', 2), 'Add Note', widget.uid))
                    );
                  }
                },
              ),
            ),
          );
          return child;
        }).toList()..add(
          new FloatingActionButton(
            heroTag: null,
            tooltip: 'Add Note',
            shape: CircleBorder(side: BorderSide(color: Theme.of(context).primaryColorDark, width: 3.0)),
            child: new AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                return new Transform(
                  transform: new Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: new Icon(_controller.isDismissed ? Icons.add : Icons.close, color: Theme.of(context).primaryColorDark),
                );
              },
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
          ),
        ),
      ),
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.redAccent;
        break;
      case 2:
        return Colors.yellow[700];
        break;
      case 3:
        return Colors.greenAccent;
        break;

      default:
        return Colors.yellow[700];
    }
  }

  // Returns the priority icon
  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '!!!';
        break;
      case 2:
        return '!!';
        break;
      case 3:
        return '!';
        break;

      default:
        return '!';
    }
  }

  // void _delete(BuildContext context, Note note) async {
  //   int result = await databaseHelper.deleteNote(note.id);
  //   if (result != 0) {
  //     _showSnackBar(context, 'Note Deleted Successfully');
  //     updateListView();
  //   }
  // }

  // void _showSnackBar(BuildContext context, String message) {
  //   final snackBar = SnackBar(content: Text(message));
  //   Scaffold.of(context).showSnackBar(snackBar);
  // }

  void navigateToDetail(Note note, String title) async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) => NoteDetail(note, title, widget.uid)));
  }

  /// A grid/list view to display notes
  Widget buildNotesView(BuildContext context) {
    return Container(
      color: Theme.of(context).buttonColor,
      child: StreamBuilder<QuerySnapshot> (
        stream: Firestore.instance
          .collection('users')
          .document(widget.uid)
          .collection('note_table')
          .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return new Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('An error occurred.',
                    style: Theme.of(context).textTheme.body1),
              ),
            );
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Center(
                child: Loading(indicator: BallPulseIndicator(), size: 80.0, color: Theme.of(context).accentColor)
              );
            default: {
              var docs = snapshot.data.documents;
              if (docs.length == 0) {
                return new Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('You have no notes.',
                      style: Theme.of(context).textTheme.body1),
                  ),
                );
              }
              this.notes = docs.map((DocumentSnapshot document) {
                  return new Note.withId(
                    document.documentID,
                    document['title'],
                    document['date'],
                    document['priority'],
                    document['description'],
                  );
              }).toList();
              this.count = notes.length;
              return getNotesList();
            }
          }
        }
      )
    );
  }

  Widget getNotesList() {
    return StaggeredGridView.countBuilder(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
            onTap: () {
              navigateToDetail(notes[index], 'Edit Note');
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
              child: Shadow(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                notes[index].title,
                                style: Theme.of(context).textTheme.body1,
                              ),
                            ),
                          ),
                          Text(
                            getPriorityText(notes[index].priority),
                            style: TextStyle(
                                color: getPriorityColor(
                                    notes[index].priority)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                  notes[index].description == null
                                      ? ''
                                      : notes[index].description,
                                  style: Theme.of(context).textTheme.body2),
                            )
                          ],
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(notes[index].date,
                                style: Theme.of(context).textTheme.subtitle),
                          ])
                    ],
                  ),
                ),
                behind: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                notes[index].title,
                                style: Theme.of(context).textTheme.body1,
                              ),
                            ),
                          ),
                          Text(
                            getPriorityText(notes[index].priority),
                            style: TextStyle(
                                color: getPriorityColor(
                                    notes[index].priority)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                  notes[index].description == null
                                      ? ''
                                      : notes[index].description.length <= 63
                                        ? notes[index].description
                                        : notes[index].description.substring(0, 64) + '...',
                                  style: Theme.of(context).textTheme.body2),
                            )
                          ],
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(notes[index].date,
                                style: Theme.of(context).textTheme.subtitle),
                          ])
                    ],
                  ),
                ),
              ),
            ),
          ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
