import 'dart:async';
import 'package:flutter/material.dart';
import 'package:renote/modal_class/notes.dart';
import 'package:renote/screens/note_detail.dart';
import 'package:renote/db_helper/db_helper.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:renote/screens/search_note.dart';
import 'package:renote/screens/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class NoteList extends StatefulWidget {
  NoteList({Key key, this.title, this.uid}) : super(key: key);
  final String title;
  final String uid; //include this

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  int count = 0;
  int axisCount = 2;
  List<Note> noteCache = List<Note>();

  @override
  Widget build(BuildContext context) => StreamProvider.value(
    value: createNoteStream(context),
    child: Scaffold(
      appBar: myAppBar(),
      body: buildNotesView(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TakePictureScreen(widget.uid))
          );
        },
        tooltip: 'Add Note',
        shape: CircleBorder(side: BorderSide(color: Colors.black, width: 2.0)),
        child: Icon(Icons.add, color: Theme.of(context).scaffoldBackgroundColor,),
        backgroundColor: Theme.of(context).accentColor,
      ),
    )
  );

  Widget myAppBar() {
    return AppBar(
      title: Text(widget.title, style: Theme.of(context).textTheme.headline),
      centerTitle: true,
      elevation: 0,
      leading: noteCache.length == 0
          ? Container()
          : IconButton(
              icon: Icon(
                Icons.search,
              ),
              onPressed: () async {
                final Note result = await showSearch(
                    context: context, delegate: NotesSearch(notes: noteCache));
                if (result != null) {
                  navigateToDetail(result, 'Search');
                }
              },
            ),
      actions: <Widget>[
        noteCache.length == 0
            ? Container(
        )
            : IconButton(
                icon: Icon(
                  axisCount == 2 ? Icons.list : Icons.grid_on,
                ),
                onPressed: () {
                  setState(() {
                    axisCount = axisCount == 2 ? 4 : 2;
                  });
                },
              )
      ],
    );
  }

  Widget getNotesList(notes) {
    return StaggeredGridView.countBuilder(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
            onTap: () {
              navigateToDetail(notes[index], 'Edit Note');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border.all(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0)),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
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
            ),
          ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      case 3:
        return Colors.green;
        break;

      default:
        return Colors.yellow;
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

  Stream<List<Note>> createNoteStream(BuildContext context) {
    return Firestore.instance.collection('users').document(widget.uid).collection('note_table')
      .snapshots()
      .handleError((e) => debugPrint('Query failed: $e'))
      .map((snapshot) => DatabaseHelper.fromQuery(snapshot));
  }

  /// A grid/list view to display notes
  Widget buildNotesView(BuildContext context) => Consumer<List<Note>>(
    builder: (context, notes, _) {
      noteCache = notes;
      if (notes?.isNotEmpty != true) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('You have no notes.',
                  style: Theme.of(context).textTheme.body1),
            ),
          ),
        );
      }
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: getNotesList(notes),
      );
    },
  );
}
