import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PurchaseList extends StatelessWidget {
  final String userID;
  PurchaseList(this.userID);
  @override
  Widget build(BuildContext context) {
    List<User> usersList = Provider.of<List<User>>(context);
    User user;
    usersList.forEach((User userI) {
      if (userI.id == userID) {
        user = userI;
      }
    });
    for (var i in user.purchases) {
      i['price'] = num.parse(i['price']);
    }
    var account = Provider.of<FirebaseUser>(context);
    DatabaseService dataservice = DatabaseService(account.uid);

    return Expanded(
      child: Container(
          child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow();
          return;
        },
        child: ListView.builder(
            itemCount: user.purchases.length,
            reverse: false,
            itemBuilder: (BuildContext context, int index) {
              bool priceIsNegative = user.purchases[index]["price"] < 0;
              var _tapPosition;

              return GestureDetector(
                onTapDown: (details) {
                  _tapPosition = details.globalPosition;
                },
                onLongPress: () async {
                  final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject();
                  var result = await showMenu(
                      context: context,
                      position: RelativeRect.fromRect(
                          _tapPosition &
                              Size(10, 10), // smaller rect, the touch area
                          Offset.zero &
                              overlay.size // Bigger rect, the entire screen
                          ),
                      items: [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.edit),
                              SizedBox(width: 3),
                              Text('Edit')
                            ],
                          ),
                        )
                      ]);
                  if (result == 1) {
                    print('Editing');
                  }
                },
                child: Dismissible(
                  direction: DismissDirection.startToEnd,
                  onDismissed: (DismissDirection direction) async {
                    // user.purchases.removeAt(index);
                    var result = await dataservice.updateAccountPurchases(
                        id: userID,
                        del: true,
                        purchase: {
                          'price': user.purchases[index]["price"].toString(),
                          'name': user.purchases[index]["name"],
                          'shop': user.purchases[index]["shop"],
                          'date': user.purchases[index]["date"]
                        });
                    if (result == null) {
                      print('FAIL');
                    }
                  },
                  // background: ,
                  key: UniqueKey(),
                  background: Container(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(firstUpper(user.purchases[index]['name']),
                        style: cardTitle),
                    subtitle: Text(
                        DateFormat('MMM dd, KK:mm a')
                            .format(user.purchases[index]['date'].toDate()),
                        style: italicBodyText),
                    trailing: (user.purchases[index]['price'] == 0)
                        ? Text('\$0', style: mainPriceText)
                        : priceIsNegative
                            ? Row(children: <Widget>[
                                Icon(
                                  Icons.add_circle,
                                  color: Colors.green[300],
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  '\$${-user.purchases[index]["price"]}',
                                  style: mainPriceText.copyWith(
                                      color: Colors.green[300]),
                                )
                              ])
                            : Text('\$${user.purchases[index]["price"]}',
                                style: mainPriceText),
                  ),
                ),
              );
            }
            // }
            ),
      )),
    );
  }
}
