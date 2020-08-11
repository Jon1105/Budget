import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user.dart';

class UserPageHeader extends StatelessWidget {
  final User user;
  final List<int> spendable;

  UserPageHeader(this.user, this.spendable);

  @override
  Widget build(BuildContext context) {
    int spendableVal = user.isAdmin ? spendable[0] : spendable[1];
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            // USER INFO
            child: Header(
                child: Column(
              children: <Widget>[
                Text(
                    user.total > 0
                        ? 'Total Spent (HKD)'.toUpperCase()
                        : 'Total Gained (HKD)'.toUpperCase(),
                    style: boldBodyText),
                Text(
                  user.total.abs().toString(),
                  style: bodyText.copyWith(),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ],
            )),
          ),
          SizedBox(width: 15),
          Expanded(
              child: Header(
            child: Column(
              children: <Widget>[
                Text(
                  'Remaining (HKD)'.toUpperCase(),
                  style: boldBodyText,
                ),
                (spendableVal != -1)
                    ? Text(
                        (spendableVal - user.total).toString(),
                        style: bodyText.copyWith(),
                      )
                    : Text('no limit set', style: italicBodyText),
              ],
            ),
          )),
        ]);
  }
}

class Header extends StatelessWidget {
  final Widget child;
  Header({this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 2), blurRadius: 2, color: Colors.grey[600])
          ]),
      child: child,
    );
  }
}
