import 'package:firebase_auth/firebase_auth.dart';
import 'screens/authPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/InfoPage.dart';
import 'screens/userPage.dart';
import 'package:flutter/services.dart';
import 'dart:math';

String firstUpper(String string) {
  return string[0].toUpperCase() + string.substring(1);
}

double toDecimalPlaces(double number, int decimalPlaces) =>
    (number * (pow(10, decimalPlaces))).round() / pow(10, decimalPlaces);

void navUserPage(context, user) {
  Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          UserPageWithProvider(user.id),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: Offset(1, 0), end: Offset.zero);
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      }));
}

void navInfoPage(context) {
  Navigator.of(context).pop();
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final account = Provider.of<FirebaseUser>(context);
    if (account == null)
      return AuthPage();
    else
      return InfoPageWithProvider();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
        value: FirebaseAuth.instance.onAuthStateChanged,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Wrapper(), //Link to user auth (return user.isAdmin)
          theme: ThemeData(
            fontFamily: 'Ubuntu',
            buttonTheme: ButtonThemeData(
              minWidth: 20,
            ),
          ),
        ));
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}
