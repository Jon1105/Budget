import 'package:firebase_auth/firebase_auth.dart';
import 'screens/authPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/InfoPage.dart';
import 'screens/userPage.dart';
import 'package:flutter/services.dart';

String firstUpper(String string) {
  return string[0].toUpperCase() + string.substring(1);
}

List<List> categories = [
  ['food', Icon(Icons.fastfood), Color.fromRGBO(230, 158, 34, 1)],
  ['clothing', Icon(Icons.shopping_basket), Color.fromRGBO(225, 197, 240, 1)],
  ['electronic', Icon(Icons.computer), Color.fromRGBO(79, 224, 173, 1)],
  ['accessory', Icon(Icons.blur_circular), Color.fromRGBO(206, 212, 106, 1)],
  ['transportation', Icon(Icons.local_taxi), Color.fromRGBO(114, 180, 242, 1)],
  ['entertainement', Icon(Icons.movie), Color.fromRGBO(153, 31, 143, 1)],
  ['toy', Icon(Icons.toys), Color.fromRGBO(199, 115, 74, 1)],
  ['gain', Icon(Icons.attach_money), Color.fromRGBO(119, 230, 34, 1)],
  [
    'other',
    Icon(Icons.radio_button_unchecked),
    Color.fromRGBO(143, 165, 176, 1)
  ]
];

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
    if (account == null) {
      return AuthPage();
    } else {
      // var dataservice = DatabaseService(accountInfo.uid);
      return InfoPageWithProvider();
    }
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
            // primarySwatch: MaterialColor(1, {
            //   50: Color(),
            //   100: Color(),
            //   200: Color(),
            //   300: Color(),
            //   400: Color(0xFF40cfcf),
            //   500: Color(0xFF33a3a3),
            //   600: Color(0xFF2c8a8a),
            //   700: Color(),
            //   800: Color(),
            //   900: Color(),
            // }),
          ),
        ));
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}
