import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renote/screens/note_list.dart';
import 'package:renote/utils/widgets.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController nameInputController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;

  @override
  initState() {
    nameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email.';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Register", style: Theme.of(context).textTheme.headline),
          centerTitle: true,
          bottom: PreferredSize(child: Container(color: Theme.of(context).primaryColor, height: 4.0,), preferredSize: Size.fromHeight(4.0)),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
                child: Form(
              key: _registerFormKey,
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: Theme.of(context).textTheme.body2,
                    helperStyle: Theme.of(context).textTheme.subtitle,
                    hintStyle: Theme.of(context).textTheme.subtitle,
                    errorStyle: Theme.of(context).textTheme.subtitle.copyWith(color: Theme.of(context).primaryColor),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0)),
                  )
                ),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      controller: nameInputController,
                      validator: (value) {
                        if (value.length < 2) {
                          return "Please enter a valid name.";
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      controller: emailInputController,
                      keyboardType: TextInputType.emailAddress,
                      validator: emailValidator,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password'),
                      controller: pwdInputController,
                      obscureText: true,
                      validator: pwdValidator,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Confirm Password'),
                      controller: confirmPwdInputController,
                      obscureText: true,
                      validator: pwdValidator,
                    ),
                    SizedBox(height: 20),
                    Shadow(
                      child: RaisedButton(
                        child: Text("Register",
                            style: Theme.of(context).textTheme.body1),
                        color: Theme.of(context).buttonColor,
                        onPressed: () {
                          if (_registerFormKey.currentState.validate()) {
                            if (pwdInputController.text ==
                                confirmPwdInputController.text) {
                              FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: emailInputController.text,
                                      password: pwdInputController.text)
                                  .then((currentUser) => Firestore.instance
                                      .collection("users")
                                      .document(currentUser.user.uid)
                                      .setData({
                                        "uid": currentUser.user.uid,
                                        "name": nameInputController.text,
                                        "email": emailInputController.text,
                                      })
                                      .then((result) => {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => NoteList(
                                                          uid: currentUser.user.uid,
                                                        )),
                                                (_) => false),
                                            nameInputController.clear(),
                                            emailInputController.clear(),
                                            pwdInputController.clear(),
                                            confirmPwdInputController.clear()
                                          })
                                      .catchError((err) => showError("An error occurred.")))
                                  .catchError((err) => showError("A user already exists with that email."));
                            } else {
                              showError("The passwords do not match.");
                            }
                          }
                        },
                      ),
                      behind: RaisedButton(
                        child: Text("Register",
                            style: Theme.of(context).textTheme.body1),
                        color: Theme.of(context).accentColor,
                        onPressed: (){},
                      ),
                    ),
                    FlatButton(
                      child:
                          Text("Login", style: Theme.of(context).textTheme.body1),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              )
            ))));
  }

  void showError(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Shadow(
          child: AlertDialog(
            title: Text("Error"),
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Close",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(
                          color: Theme.of(context)
                              .accentColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          behind: AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("Error"),
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Close",
                  style: Theme.of(context)
                      .textTheme
                      .body1,
                ),
                onPressed: () {},
              )
            ],
          ),
        );
      });
  }
}