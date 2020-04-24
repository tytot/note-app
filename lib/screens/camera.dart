import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:renote/screens/process.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final String uid;
  const TakePictureScreen(this.uid);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  Future<void> setup() async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    _controller = new CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget myAppBar() {
      return AppBar(
        title: Text('Note Capture', style: Theme.of(context).textTheme.headline),
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
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: Loading(indicator: BallPulseIndicator(), size: 80.0, color: Theme.of(context).accentColor));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path, uid: widget.uid),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        tooltip: 'Take Picture',
        shape: CircleBorder(side: BorderSide(color: Theme.of(context).primaryColorDark, width: 3.0)),
        child: Icon(Icons.camera, color: Theme.of(context).primaryColorDark),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String uid;

  const DisplayPictureScreen({Key key, this.imagePath, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget myAppBar() {
      return AppBar(
        title: Text('Confirm', style: Theme.of(context).textTheme.headline),
        bottom: PreferredSize(child: Container(color: Theme.of(context).primaryColor, height: 4.0,), preferredSize: Size.fromHeight(4.0)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context, true);
            }),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
            ),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProcessScreen(imagePath, uid))
          );
            },
          )
        ],
      );
    }
    return Scaffold(
      appBar: myAppBar(),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
        child: Image.file(File(imagePath), 
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,)
      ),
    );
  }
}