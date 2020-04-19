import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:renote/screens/note_detail.dart';
import 'package:renote/modal_class/notes.dart';

// A screen that allows users to take a picture using a given camera.
class ProcessScreen extends StatefulWidget {
  final String imgPath;
  final String uid;

  const ProcessScreen(this.imgPath, this.uid);

  @override
  ProcessScreenState createState() => ProcessScreenState();
}

class ProcessScreenState extends State<ProcessScreen> {
  var res = {'text': ''};

  Future<void> processImage() async {
    final postURI = Uri.parse('url');
    var request = new http.MultipartRequest('POST', postURI);
    request.files.add(new http.MultipartFile.fromBytes('file', File.fromUri(Uri.parse(widget.imgPath)).readAsBytesSync(), contentType: new MediaType('image', 'jpeg')));
  
    final response = await request.send();
    if (response.statusCode == 200) {
      res = json.decode(await response.stream.bytesToString());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => NoteDetail(Note('', '', 3, res['text']), 'Add Note', widget.uid)), ModalRoute.withName('/'));
    } else {
      throw Exception('An error occurred while processing.');
    }
  }

  @override
  void initState() {
    super.initState();
    processImage();
  }

  @override
  Widget build(BuildContext context) {
    Widget myAppBar() {
      return AppBar(
        title: Text('Processing...', style: Theme.of(context).textTheme.headline),
        bottom: PreferredSize(child: Container(color: Theme.of(context).primaryColorDark, height: 2.0,), preferredSize: Size.fromHeight(2.0)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context, true);
            }),
      );
    }
    return Scaffold(
      appBar: myAppBar(),
      body: FutureBuilder<void>(
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}