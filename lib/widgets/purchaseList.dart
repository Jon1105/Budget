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
            reverse: true,
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
                    editPurchase(context, user.purchases[index]);
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
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                    Icon(
                                      Icons.add_circle,
                                      color: Colors.green[300],
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

  void editPurchase(BuildContext context, Map purchase) {
    final _formKey = GlobalKey<FormState>();
    final descController = TextEditingController();
    final priceController = TextEditingController();

    descController.text = purchase['name'];
    priceController.text = purchase['price'].toString();

    showDialog(
        context: context,
        builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) =>
                  Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                // height: dialogHeight,
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Edit purchase', style: promptTitle),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(hintText: 'Amount'),
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val != '' &&
                                  (double.parse(val) >= 0.005 ||
                                      double.parse(val) < 0)) {
                                return null;
                              }
                              return 'Enter a valid amount';
                            },
                          ),
                          TextFormField(
                            decoration:
                                InputDecoration(hintText: 'Description'),
                            controller: descController,
                            validator: (val) {
                              if (val == '' || val == null)
                                return 'Enter a name';
                              return null;
                            },
                          ),
                          FlatButton(
                              child: Text('Continue', style: promptSubmitText),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  var account = Provider.of<FirebaseUser>(
                                      context,
                                      listen: false);
                                  var dataservice =
                                      DatabaseService(account.uid);

                                  Navigator.of(context).pop(context);
                                  await dataservice.updateAccountPurchases(
                                      id: userID,
                                      purchase: {
                                        'name': purchase['name'],
                                        'price': purchase['price'].toString(),
                                        'date': purchase['date']
                                      },
                                      del: true);
                                  await dataservice.updateAccountPurchases(
                                      id: userID,
                                      purchase: {
                                        'price': priceController.text
                                            .replaceAll(' ', ''),
                                        'name': descController.text,
                                        'date': purchase['date']
                                      });
                                }
                              }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )));
  }
}
