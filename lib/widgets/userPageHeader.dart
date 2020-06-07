import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user.dart';

class UserPageHeader extends StatelessWidget {
  final User user;
  final List<int> spendable;

  UserPageHeader(this.user, this.spendable);

  @override
  Widget build(BuildContext context) {
    List<bool> spendablesHaveVal = [
      (spendable[0] == -1) ? false : true,
      (spendable[1] == -1) ? false : true
    ];
    var spendableIndex = (user.isAdmin) ? 0 : 1;
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            // USER INFO
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colors['accent-light'],
              ),
              child: !(user.total < 0)
                  ? Column(
                      children: <Widget>[
                        Text('Total Spent:', style: boldBodyText),
                        Text(
                          'HK\$ ${user.total}',
                          style: bodyText.copyWith(color: Colors.white),
                        ),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        Text('Total Gained', style: boldBodyText),
                        Text(
                          'HK\$ ${-user.total}',
                          style: bodyText.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colors['accent-light'],
              // border: Border.all()
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Text(
                  'Left to Spend:',
                  style: boldBodyText,
                ),
                (spendablesHaveVal[spendableIndex])
                    ? Text(
                        'HK\$ ${spendable[spendableIndex] - user.total}',
                        style: bodyText.copyWith(color: Colors.white),
                      )
                    : Text('no limit set', style: italicBodyText),
              ],
            ),
          )),
        ]);
  }
}
