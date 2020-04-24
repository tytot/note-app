import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:renote/modal_class/notes.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  static List<Note> fromQuery(QuerySnapshot snapshot) => snapshot != null ? toNotes(snapshot) : [];

  // Insert Operation: Insert a Note object to database
  Future<void> insertNote(Note note, String uid) async {
    Map<String, dynamic> data = {
      "title": note.title,
      "description": note.description,
      "priority": note.priority,
      "date": note.date,
    };
    if (note.meta != null) {
      data["meta"] = {
        "wordCount": note.meta["wordCount"],
        "characterCount": note.meta["characterCount"],
        "spaceCount": note.meta["spaceCount"],
        "polarity": note.meta["polarity"],
        "subjectivity": note.meta["subjectivity"],
      };
    }
    Firestore.instance
      .collection("users")
      .document(uid)
      .collection('note_table')
      .add(data)
      .then((result) => note.id = result.documentID)
      .catchError((err) => print(err));
  }

  // Update Operation: Update a Note object and save it to database
  Future<void> updateNote(Note note, String uid) async {
    Map<String, dynamic> data = {
      "title": note.title,
      "description": note.description,
      "priority": note.priority,
      "date": note.date,
    };
    if (note.meta != null) {
      note.meta = {
        "wordCount": note.meta["wordCount"],
        "characterCount": note.meta["characterCount"],
        "spaceCount": note.meta["spaceCount"],
        "polarity": note.meta["polarity"],
        "subjectivity": note.meta["subjectivity"],
      };
    }
    Firestore.instance
      .collection("users")
      .document(uid)
      .collection('note_table')
      .document(note.id)
      .setData(data)
      .catchError((err) => print(err));
  }

  // Delete Operation: Delete a Note object from database
  Future<void> deleteNote(String uid, String id) async {
    Firestore.instance
      .collection("users")
      .document(uid)
      .collection('note_table')
      .document(id)
      .delete()
      .catchError((err) => print(err));
  }
}

/// Transforms the query result into a list of notes.
List<Note> toNotes(QuerySnapshot query) => query.documents
  .map((d) => toNote(d))
  .where((n) => n != null)
  .toList();

/// Transforms a document into a single note.
Note toNote(DocumentSnapshot doc) => doc.exists
  ? doc.data['meta'] == null
    ? Note.withId(
        doc.documentID,
        doc.data['title'],
        doc.data['date'],
        doc.data['priority'],
        doc.data['description']
      )
    : Note.withId(
        doc.documentID,
        doc.data['title'],
        doc.data['date'],
        doc.data['priority'],
        doc.data['description'],
        doc.data['meta']
      )
  : null;