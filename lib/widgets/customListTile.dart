import 'package:flutter/material.dart';
import '../models/user.dart';
import '../main.dart';

class CustomListTile extends StatelessWidget {
  final User user;
  CustomListTile(this.user);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
          margin: EdgeInsets.symmetric(
            vertical: 5,
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(5),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.person),
              SizedBox(
                width: 10,
              ),
              Text(
                user.name,
                style: TextStyle(fontFamily: 'UbuntuMed', fontSize: 20),
                textAlign: TextAlign.start,
              ),
            ],
          )),
      onTap: () {
        navUserPage(context, user);
      },
    );
  }
}
