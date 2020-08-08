import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/purchaseList.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import '../services/database.dart';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/userPageHeader.dart';

class UserPageWithProvider extends StatelessWidget {
  final String userID;
  UserPageWithProvider(this.userID);
  @override
  Widget build(BuildContext context) {
    var account = Provider.of<FirebaseUser>(context);
    return MultiProvider(providers: [
      StreamProvider<List<User>>.value(
          initialData: [],
          value: DatabaseService(account.uid).accountUsers,
          // lazy: false,
          catchError: (ctx, obj) {
            return null;
          }),
      StreamProvider<List<int>>.value(
          value: DatabaseService(account.uid).spendable,
          // lazy: false,
          catchError: (ctx, obj) {
            print('Spendable Provider error:');
            print(obj);

            return null;
          })
    ], child: UserPage(userID));
  }
}

class UserPage extends StatelessWidget {
  final String userID;
  UserPage(this.userID);
  @override
  Widget build(BuildContext context) {
    List<User> usersList = Provider.of<List<User>>(context);
    User user;
    for (User userI in usersList) {
      if (userI.id == userID) {
        user = userI;
        break;
      }
    }

    List<int> spendable = Provider.of<List<int>>(context);

    return (user == null)
        ? Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: colors['primary-dark'],
              title: Text('loading', style: appBarText),
            ),
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: colors['primary-dark'],
              title: Text('${user.name}\'s Budget', style: appBarText),
            ),
            body: Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                // padding: EdgeInsets.all(8),
                child: (user.total == 0)
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          UserPageHeader(user, spendable),
                          Expanded(
                            child: Center(child: Text('No purchases')),
                          )
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          UserPageHeader(user, spendable),
                          // UserChart(user),
                          PurchaseList(userID),
                        ],
                      )),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.add,
                            size: 35, color: colors['accent-dark']),
                        onPressed: () {
                          createPurchase(context, user);
                        }),
                    IconButton(
                        icon: Icon(Icons.home,
                            size: 35, color: colors['accent-dark']),
                        onPressed: () {
                          navInfoPage(context);
                        }),
                  ],
                ),
              ),
            ),
          );
  }

  void createPurchase(BuildContext context, User user) {
    final _formKey = GlobalKey<FormState>();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              // height: dialogHeight,
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Add a purchase', style: promptTitle),
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
                          decoration: InputDecoration(hintText: 'Description'),
                          controller: descController,
                          validator: (val) {
                            if (val == '' || val == null) return 'Enter a name';
                            return null;
                          },
                        ),
                        FlatButton(
                            child: Text('Continue', style: promptSubmitText),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                var account = Provider.of<FirebaseUser>(context,
                                    listen: false);
                                var dataservice = DatabaseService(account.uid);

                                Navigator.of(context).pop(context);
                                await dataservice.updateAccountPurchases(
                                    id: userID,
                                    purchase: {
                                      'price': priceController.text
                                          .replaceAll(' ', ''),
                                      'name': descController.text,
                                      'date': Timestamp.now()
                                    });
                              }
                            }),
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
