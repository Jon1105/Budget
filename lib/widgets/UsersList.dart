import 'package:flutter/material.dart';
import 'customCard.dart';
import '../theme.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../main.dart';
import 'spentLineChart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database.dart';

class CustomUserList extends StatefulWidget {
  @override
  _CustomUserListState createState() => _CustomUserListState();
}

class _CustomUserListState extends State<CustomUserList> {
  @override
  Widget build(BuildContext context) {
    // var account = Provider.of<FirebaseUser>(context);
    var accountInfo = Provider.of<List<User>>(context);

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow();
          return;
        },
        child: ListView(
            children: accountInfo.map((user) => UserInfoCard(user)).toList()),
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final User user;
  UserInfoCard(this.user);

  @override
  Widget build(BuildContext context) {
    var account = Provider.of<FirebaseUser>(context);
    DatabaseService dataservice = DatabaseService(account.uid);
    var spendable = Provider.of<List<int>>(context);
    List<bool> spendablesHaveVal = [
      (spendable[0] == -1) ? false : true,
      (spendable[1] == -1) ? false : true
    ];
    var spendableIndex = (user.isAdmin) ? 0 : 1;
    return Dismissible(
      dismissThresholds: {DismissDirection.startToEnd: 0.5},
      direction: DismissDirection.startToEnd,
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) async {
        await dataservice.updateAccountInfo(id: user.id, del: true);
      },
      background: Container(
        child: Center(
          child: Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          navUserPage(context, user);
        },
        onLongPress: () {
          Scaffold.of(context).showBottomSheet((BuildContext context) {
            var ctrlr = TextEditingController();
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 25),
              decoration: BoxDecoration(
                  color: colors['primary'].withOpacity(0.8),
                  // boxShadow: [BoxShadow(offset: Offset(0, 2), color: Colors.grey[600])],
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(13),
              child: SizedBox(
                height: 32,
                child: Center(
                  child: TextField(
                    textInputAction: TextInputAction.unspecified,
                    controller: ctrlr,
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    onSubmitted: Navigator.of(context).pop,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Edit Name',
                        border: InputBorder.none,
                        suffixIcon: GestureDetector(
                          child: Icon(
                            Icons.check,
                            // size: 16,
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            await dataservice.editUserName(
                                id: user.id, newName: ctrlr.text);
                          },
                        )),
                  ),
                ),
              ),
              //
            );
          });
        },
        child: CustomCard(
            Column(children: <Widget>[
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(user.name, style: cardTitle),
                  user.isAdmin ? Icon(Icons.person) : Container()
                ],
              ),
              Column(
                // crossAxisAlignment: CrossAxisAlignment.spaceBetween,
                children: <Widget>[
                  (user.total < 0)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Total Gained:', style: boldBodyText),
                            Text(
                              '\$${-user.total}',
                              style:
                                  bodyText.copyWith(color: Colors.green[300]),
                            )
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Total Spent:', style: boldBodyText),
                            Text('\$${user.total}')
                          ],
                        ),
                  (spendablesHaveVal[spendableIndex])
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Available:', style: boldBodyText),
                            Text('\$${spendable[spendableIndex] - user.total}')
                          ],
                        )
                      : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  (spendablesHaveVal[spendableIndex])
                      ? RotatedBox(
                          quarterTurns: 3,
                          child: LineChart(
                              y: user.total,
                              total: spendable[spendableIndex] + 0.0))
                      : Container(),
                ],
              )
            ]),
            EdgeInsets.fromLTRB(15, 15, 15, 10)),
      ),
    );
  }
}
