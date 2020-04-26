import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renote/db_helper/db_helper.dart';
import 'package:renote/modal_class/notes.dart';
import 'package:renote/utils/widgets.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  final String uid;

  NoteDetail(this.note, this.appBarTitle, this.uid);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdited = false;
  int page = 0;
  int numPages;

  NoteDetailState(this.note, this.appBarTitle) {
    this.numPages = note.description.length;
  }

  void setPage(int newPage) {
    setState(() {
      if (newPage != null)
        page = newPage;
      numPages = note.description.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    descriptionController.text = note.description[page];
    return WillPopScope(
        onWillPop: () {
          isEdited ? showDiscardDialog(context) : moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            bottom: PreferredSize(child: Container(color: Theme.of(context).primaryColor, height: 4.0,), preferredSize: Size.fromHeight(4.0)),
            title: Text(
              appBarTitle,
              style: Theme.of(context).textTheme.headline,
            ),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  isEdited ? showDiscardDialog(context) : moveToLastScreen();
                }),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.save,
                ),
                onPressed: () {
                  titleController.text.length == 0
                      ? showEmptyTitleDialog(context)
                      : _save();
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDeleteDialog(context);
                },
              ),
              note.meta == null
                ? Container()
                : IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    showInfoDialog(context);
                  },
                )
            ],
          ),
          body: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: <Widget>[
                  PriorityPicker(
                    selectedIndex: 3 - note.priority,
                    onTap: (index) {
                      isEdited = true;
                      note.priority = 3 - index;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                      controller: titleController,
                      maxLength: 255,
                      style: Theme.of(context).textTheme.body1,
                      onChanged: (value) {
                        updateTitle();
                      },
                      decoration: InputDecoration.collapsed(
                        hintStyle: Theme.of(context).textTheme.subtitle,
                        hintText: 'Title',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        maxLength: 2047,
                        controller: descriptionController,
                        style: Theme.of(context).textTheme.body2,
                        onChanged: (value) {
                          updateDescription();
                        },
                        decoration: InputDecoration.collapsed(
                          hintStyle: Theme.of(context).textTheme.subtitle,
                          hintText: 'Body',
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).primaryColorDark,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: page == 0
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).scaffoldBackgroundColor),
                          onPressed: () {
                            if (page != 0) {
                              setPage(page - 1);
                              descriptionController.text = note.description[page];
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.remove,
                              color: page == 0
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).scaffoldBackgroundColor),
                          onPressed: () {
                            if (page != 0) {
                              showDeletePageDialog(context);
                              descriptionController.text = note.description[page];
                            }
                          }
                        ),
                        Text('Page ' + (page + 1).toString() + ' of ' + numPages.toString(),
                          style: Theme.of(context).textTheme.body2
                            .copyWith(color: Theme.of(context).scaffoldBackgroundColor)),
                        IconButton(
                          icon: Icon(Icons.add,
                              color: numPages == 8
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).scaffoldBackgroundColor),
                          onPressed: () {
                            if (numPages < 8) {
                              note.description.add('');
                            }
                            setPage(page);
                            descriptionController.text = note.description[page];
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward,
                              color: page == numPages - 1
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).scaffoldBackgroundColor),
                          onPressed: () {
                            if (page < numPages - 1) {
                              setPage(page + 1);
                              descriptionController.text = note.description[page];
                            }
                          },
                        ),
                      ],
                    )
                  )
                ],
              ),
          ),
        ));
  }

  void showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Shadow(
          child: AlertDialog(
            title: Text(
              "Discard Changes?",
            ),
            content: Text("Are you sure you want to discard changes?"),
            actions: <Widget>[
              FlatButton(
                child: Text("No",
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Yes",
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  moveToLastScreen();
                },
              ),
            ],
          ),
          behind: AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "Discard Changes?",
            ),
            content: Text("Are you sure you want to discard changes?"),
            actions: <Widget>[
              FlatButton(
                child: Text("No",
                    style: Theme.of(context)
                        .textTheme
                        .body1),
                onPressed: () {},
              ),
              FlatButton(
                child: Text("Yes",
                    style: Theme.of(context)
                        .textTheme
                        .body1),
                onPressed: () {},
              ),
            ],
          ),
          offset: Offset(-6.0, 6.0)
        );
      },
    );
  }

  void showEmptyTitleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Shadow(
          child: AlertDialog(
            title: Text(
              "Title is empty!",
            ),
            content: Text('The title of the note cannot be empty.'),
            actions: <Widget>[
              FlatButton(
                child: Text("Okay",
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          behind: AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "Title is empty!",
            ),
            content: Text('The title of the note cannot be empty.'),
            actions: <Widget>[
              FlatButton(
                child: Text("Okay",
                    style: Theme.of(context)
                        .textTheme
                        .body1),
                onPressed: () {},
              ),
            ],
          ),
          offset: Offset(-6.0, 6.0)
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Shadow(
          child: AlertDialog(
            title: Text(
              "Delete Note?",
            ),
            content: Text("Are you sure you want to delete this note?"),
            actions: <Widget>[
              FlatButton(
                child: Text("No",
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Yes",
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _delete();
                },
              ),
            ],
          ),
          behind: AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "Delete Note?",
            ),
            content: Text("Are you sure you want to delete this note?"),
            actions: <Widget>[
              FlatButton(
                child: Text("No",
                    style: Theme.of(context)
                        .textTheme
                        .body1),
                onPressed: () {},
              ),
              FlatButton(
                child: Text("Yes",
                    style: Theme.of(context)
                        .textTheme
                        .body1),
                onPressed: () {},
              ),
            ],
          ),
          offset: Offset(-6.0, 6.0)
        );
      },
    );
  }

  void showDeletePageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Shadow(
          child: AlertDialog(
            title: Text(
              "Delete Page?",
            ),
            content: Text("Are you sure you want to delete this page?"),
            actions: <Widget>[
              FlatButton(
                child: Text("No",
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Yes",
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _deletePage();
                },
              ),
            ],
          ),
          behind: AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "Delete Page?",
            ),
            content: Text("Are you sure you want to delete this page?"),
            actions: <Widget>[
              FlatButton(
                child: Text("No",
                    style: Theme.of(context)
                        .textTheme
                        .body1),
                onPressed: () {},
              ),
              FlatButton(
                child: Text("Yes",
                    style: Theme.of(context)
                        .textTheme
                        .body1),
                onPressed: () {},
              ),
            ],
          ),
          offset: Offset(-6.0, 6.0)
        );
      },
    );
  }

  void showInfoDialog(BuildContext context) {
    final Map<String, dynamic> meta = note.meta;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Shadow(
          child: AlertDialog(
            title: Text(
              "Metadata",
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.body2,
                    children: <TextSpan>[
                      TextSpan(text: "Words: "),
                      TextSpan(text: meta["wordCount"].toString(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.body2,
                    children: <TextSpan>[
                      TextSpan(text: "Characters: "),
                      TextSpan(text: meta["characterCount"].toString(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.body2,
                    children: <TextSpan>[
                      TextSpan(text: "Spaces: "),
                      TextSpan(text: meta["spaceCount"].toString(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.body2,
                    children: <TextSpan>[
                      TextSpan(text: "Polarity: "),
                      TextSpan(text: meta["polarity"].toStringAsFixed(2),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.body2,
                    children: <TextSpan>[
                      TextSpan(text: "Subjectivity: "),
                      TextSpan(text: meta["subjectivity"].toStringAsFixed(2),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Close",
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          behind: AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "Metadata",
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(" "),
                Text(" "),
                Text(" "),
                Text(" "),
                Text(" "),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Close",
                    style: Theme.of(context)
                        .textTheme
                        .body1),
                onPressed: () {},
              ),
            ],
          ),
          offset: Offset(-6.0, 6.0)
        );
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    isEdited = true;
    note.title = titleController.text;
  }

  void updateDescription() {
    isEdited = true;
    note.description[page] = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    note.date = DateFormat.yMd().format(DateTime.now());

    if (note.id != null) {
      await helper.updateNote(note, widget.uid);
    } else {
      await helper.insertNote(note, widget.uid);
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _delete() async {
    await helper.deleteNote(widget.uid, note.id);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _deletePage() {
    note.description.removeAt(page);
    setPage(page - 1);
  }
}
