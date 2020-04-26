import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:renote/screens/note_detail.dart';
import 'package:renote/modal_class/notes.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

// A screen that allows users to take a picture using a given camera.
class ProcessScreen extends StatefulWidget {
  final List<String> imgPaths;
  final String uid;

  const ProcessScreen(this.imgPaths, this.uid);

  @override
  ProcessScreenState createState() => ProcessScreenState();
}

class ProcessScreenState extends State<ProcessScreen> {

  Future<Map<String, dynamic>> processImage(imgPath) async {
    // final postURI = Uri.parse('url');
    // var request = new http.MultipartRequest('POST', postURI);
    // request.files.add(new http.MultipartFile.fromBytes('file', File.fromUri(Uri.parse(widget.imgPath)).readAsBytesSync(), contentType: new MediaType('image', 'jpeg')));
    //final response = await request.send();

    final response = await http.get('http://173.64.123.134:5000/');
    if (response.statusCode == 200) {
      Map<String, dynamic> meta = json.decode(response.body);
      return meta;
    } else {
      throw Exception('An error occurred while processing.');
    }
  }

  Future<void> process() async {
    Map<String, dynamic> cumulative = {
      "wordCount": 0,
      "characterCount": 0,
      "spaceCount": 0,
      "polarity": 0.0,
      "subjectivity": 0.0,
    };
    List<dynamic> texts = new List();
    for (String path in widget.imgPaths) {
      Map<String, dynamic> meta = await processImage(path);
      texts.add(meta["message"]);
      cumulative["wordCount"] += meta["wordCount"];
      cumulative["characterCount"] += meta["characterCount"];
      cumulative["spaceCount"] += meta["spaceCount"];
      cumulative["polarity"] += meta["polarity"];
      cumulative["subjectivity"] += meta["subjectivity"];
    }
    cumulative["polarity"] /= widget.imgPaths.length;
    cumulative["subjectivity"] /= widget.imgPaths.length;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NoteDetail(Note('', '', 3, texts, cumulative), 'Add Note', widget.uid)));
  }

  @override
  void initState() {
    super.initState();
    process();
  }

  @override
  Widget build(BuildContext context) {
    Widget myAppBar() {
      return AppBar(
        title: Text('Processing...', style: Theme.of(context).textTheme.headline),
        bottom: PreferredSize(child: Container(color: Theme.of(context).primaryColor, height: 4.0,), preferredSize: Size.fromHeight(4.0)),
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
          return Center(child: Loading(indicator: BallPulseIndicator(), size: 80.0, color: Theme.of(context).accentColor));
        },
      ),
    );
  }
}