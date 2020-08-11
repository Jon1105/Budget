import '../services/auth.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import 'customListTile.dart';
import '../theme.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

class CustomDrawer extends StatelessWidget {
  // var u = DataBaseService(rUID);
  final bool infoCurrentPage;
  CustomDrawer(this.infoCurrentPage);

  @override
  Widget build(BuildContext context) {
    var accountInfo = Provider.of<List<User>>(context);
    // var account = Provider.of<FirebaseUser>(context);
    final AuthService _auth = AuthService();
    return SizedBox(
      width: 200,
      child: Drawer(
          child: ListView(
        // padding: EdgeInsets.all(10),
        children: <Widget>[
          DrawerHeader(
            child: Icon(
              Icons.monetization_on,
              size: 100,
            ),
            decoration: BoxDecoration(
                color: Colors.blue,
                gradient: LinearGradient(
                  colors: <Color>[Colors.pink[600], Colors.purple[400]],
                )),
          ),
          Column(
              children: accountInfo.map((user) {
            return CustomListTile(user);
          }).toList()),
          // Container(
          //   height: double.infinity,
          // ),
          InkWell(
            child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: 5,
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.info),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Information',
                      style: drawerItemText,
                      textAlign: TextAlign.start,
                    ),
                  ],
                )),
            onTap: () {
              Navigator.of(context).pop();
              navInfoPage(context);
              //! Get user from auth and return user.isAdmin instead of true
              // navInfoPage(context, true);
            },
          ),
          InkWell(
            child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: 5,
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.exit_to_app),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Sign Out',
                      style: drawerItemText,
                      textAlign: TextAlign.start,
                    ),
                  ],
                )),
            onTap: () async {
              await _auth.signOut();
            },
          ),
        ],
      )),
    );
  }
}
