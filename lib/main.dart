import 'package:flutter/material.dart';
import 'package:renote/screens/login.dart';
import 'package:renote/screens/register.dart';
import 'package:renote/screens/splash.dart';

void main() {
  runApp(MyApp());
}

const Color whitish = Color(0xFFFFF8E6);
const Color creamsicle = Color(0xFFF2A365);
const Color creamlight = Color(0xFFFFC294);
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'reNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: creamsicle,
        buttonColor: creamlight,
        primaryColor: Color(0xFF5FFFEF),
        primaryColorDark: Color(0xFF34A69A),
        scaffoldBackgroundColor: whitish,
        appBarTheme: AppBarTheme(
          color: Color(0xFF43D8C9),
          iconTheme: IconThemeData(color: whitish),
          actionsIconTheme: IconThemeData(color: whitish),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: Theme.of(context).textTheme.body2,
          helperStyle: Theme.of(context).textTheme.subtitle,
          hintStyle: Theme.of(context).textTheme.subtitle,
          errorStyle: Theme.of(context).textTheme.subtitle.copyWith(color: creamsicle),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: creamsicle, width: 2.0)),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: creamsicle, width: 2.0)),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(color: Colors.black, width: 2.0)),
          titleTextStyle: Theme.of(context).textTheme.title,
          contentTextStyle: Theme.of(context).textTheme.body2,
        ),
        textTheme: TextTheme(
          headline: TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.bold,
              color: whitish,
              fontSize: 24),
          body1: TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20),
          body2: TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 18),
          subtitle: TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.normal,
              color: Colors.grey,
              fontSize: 14),
        ),
      ),
      home: SplashPage(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => LoginPage(),
        '/register': (BuildContext context) => RegisterPage(),
      },
    );
  }
}
