import 'package:flutter/material.dart';
import 'package:renote/screens/splash.dart';

void main() {
  runApp(MyApp());
}

const Color whitish = Color(0xFFf1f3f4);
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteKeeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Color(0xFF512b58),
        primaryColor: Color(0xFF79bac1),
        scaffoldBackgroundColor: whitish,
        appBarTheme: AppBarTheme(
          color: Color(0xFF2a7886),
          iconTheme: IconThemeData(color: whitish),
          actionsIconTheme: IconThemeData(color: whitish),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: Theme.of(context).textTheme.body2,
          helperStyle: Theme.of(context).textTheme.subtitle,
          hintStyle: Theme.of(context).textTheme.subtitle,
          errorStyle: Theme.of(context).textTheme.subtitle.copyWith(color: Theme.of(context).accentColor),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(color: Colors.black, width: 2.0)),
          titleTextStyle: Theme.of(context).textTheme.body1,
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
        '/': (BuildContext context) => new SplashPage(),
      },
    );
  }
}
