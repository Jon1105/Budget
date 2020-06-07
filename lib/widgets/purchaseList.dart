import 'package:flutter/material.dart';
import '../models/user.dart';
import 'customCard.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import '../shops.dart';

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
      // if (i['price'].toString().contains('.')) {
      //   i['price'] = num.parse(i['price']);
      // } else {
      //   i['price'] = num.parse(i['price']);
      // }
      i['price'] = num.parse(i['price']);
    }
    var account = Provider.of<FirebaseUser>(context);
    DatabaseService dataservice = DatabaseService(account.uid);

    var _selectedCategory;
    List<DropdownMenuItem> menuItems = [];
    for (var category in categories) {
      menuItems.add(DropdownMenuItem(
          value: category[0],
          child: Row(
            children: <Widget>[
              category[1],
              SizedBox(width: 5),
              Text(firstUpper(category[0])),
            ],
          )));
    }

    return Expanded(
      child: Container(
          // color: Colors.blue[100],
          // padding: EdgeInsets.all(5),
          child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow();
          return;
        },
        child: ListView.builder(
          itemCount: user.purchases.length,
          itemBuilder: (BuildContext context, int place) {
            var index = user.purchases.length - place - 1;
            bool priceIsNegative = user.purchases[index]["price"] < 0;
            var _tapPosition;
            bool someNameInvented = false;

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
                  // setState(() {
                  //   someNameInvented = true;
                  // });
                }
              },
              child: Dismissible(
                direction: DismissDirection.startToEnd,
                onDismissed: (DismissDirection direction) async {
                  // user.purchases.removeAt(index);
                  var result = await dataservice
                      .updateAccountPurchases(id: userID, del: true, purchase: {
                    'category': user.purchases[index]["category"],
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
                child: CustomCard(
                    Row(
                      children: <Widget>[
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              someNameInvented == true
                                  ? Text('Hois')
                                  : Container(),
                              (user.purchases[index]['name'] != '')
                                  ? Text(
                                      firstUpper(user.purchases[index]['name']),
                                      style: cardTitle)
                                  : Text(
                                      firstUpper(
                                          user.purchases[index]['category']),
                                      style: cardTitle),
                              (user.purchases[index]['name'] != '')
                                  ? Text(
                                      firstUpper(
                                          user.purchases[index]['category']),
                                      style: boldBodyText)
                                  : Container(),
                              Text(
                                  DateFormat('MMM dd, KK:mm a').format(
                                      user.purchases[index]['date'].toDate()),
                                  style: italicBodyText),
                              (user.purchases[index]['shop'] != '')
                                  ? Text(user.purchases[index]['shop'],
                                      style: bodyText)
                                  : Container()
                            ]),
                        Expanded(child: Container()),
                        // Price
                        (user.purchases[index]['price'] == 0)
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
                      ],
                    ),
                    EdgeInsets.fromLTRB(25, 15, 15, 15)),
              ),
            );
          },
        ),
      )),
    );
  }
}
