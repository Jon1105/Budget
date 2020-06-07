import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import '../theme.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/purchaseList.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import '../services/database.dart';
import 'dart:core';
import '../shops.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/userChart.dart';
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

class UserPage extends StatefulWidget {
  final String userID;
  UserPage(this.userID);
  @override
  _UserPageState createState() => _UserPageState(userID);
}

class _UserPageState extends State<UserPage> {
  final String userID;
  _UserPageState(this.userID);

  // String error = '';
  int showChart = 0;

  @override
  Widget build(BuildContext context) {
    var usersList = Provider.of<List<User>>(context);
    var user;
    usersList.forEach((User userI) {
      if (userI.id == userID) {
        user = userI;
      }
    });

    var spendable = Provider.of<List<int>>(context);

    return Scaffold(
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
                    // showChart
                    // ? FractionallySizedBox(
                    // ?
                    Container(
                      child: UserChart(user),
                      // heightFactor: 0.3,
                      height: 269,
                    ),
                    // : Container(),
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
                  icon: Icon(Icons.insert_chart,
                      size: 35, color: colors['accent-dark']),
                  onPressed: () {
                    setState(() {
                      // showChart += 1;
                    });
                    // print(showChart);
                  }),
              IconButton(
                  icon: Icon(Icons.add, size: 35, color: colors['accent-dark']),
                  onPressed: () {
                    createPurchase(context, user);
                  }),
              IconButton(
                  icon:
                      Icon(Icons.home, size: 35, color: colors['accent-dark']),
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
    final _autoCompleteTextKey =
        GlobalKey<AutoCompleteTextFieldState<String>>();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final shopController = TextEditingController();
    var _selectedCategory;

    bool showMore = false;

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

    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
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
                              DropdownButtonFormField(
                                hint: Text('Category'),
                                items: menuItems,
                                onChanged: (category) => setState(() {
                                  _selectedCategory = category;
                                  (category == 'other')
                                      ? showMore = true
                                      : showMore = showMore;
                                }),
                                value: _selectedCategory,
                                validator: (val) =>
                                    (val == null) ? 'Select a category' : null,
                              ),
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
                              !showMore
                                  ? Container()
                                  : Column(
                                      children: <Widget>[
                                        TextFormField(
                                          decoration: InputDecoration(
                                              hintText: 'Name*'),
                                          controller: descController,
                                        ),
                                        AutoCompleteTextField<String>(
                                          itemSubmitted: (item) =>
                                              shopController.text = item,
                                          controller: shopController,
                                          key: _autoCompleteTextKey,
                                          clearOnSubmit: false,
                                          submitOnSuggestionTap: true,
                                          suggestions: shops,
                                          itemSorter: (a, b) {
                                            return;
                                          },
                                          itemFilter: (item, query) {
                                            return (item != query)
                                                ? item.toLowerCase().contains(
                                                    query.toLowerCase())
                                                : null;
                                          },
                                          itemBuilder: (context, item) {
                                            return Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(item,
                                                  style: dropdownItemText),
                                            );
                                          },
                                          style: TextStyle(),
                                          decoration: InputDecoration(
                                              hintText: 'Shop*'),
                                        ),
                                      ],
                                    ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        showMore = !showMore;
                                      });
                                      print(showMore);
                                    },
                                    child: Text(
                                      showMore ? 'Less' : 'More',
                                      style: linkText.copyWith(fontSize: 12),
                                    ),
                                  ),
                                  FlatButton(
                                      child: Text('Continue',
                                          style: promptSubmitText),
                                      onPressed: () async {
                                        if (_formKey.currentState.validate()) {
                                          var account =
                                              Provider.of<FirebaseUser>(context,
                                                  listen: false);
                                          var dataservice =
                                              DatabaseService(account.uid);

                                          Navigator.of(context).pop(context);
                                          await dataservice
                                              .updateAccountPurchases(
                                                  id: userID,
                                                  purchase: {
                                                'category': _selectedCategory ??
                                                    'other',
                                                'price': (_selectedCategory ==
                                                        'gain')
                                                    ? (num.parse(priceController
                                                                    .text
                                                                    .replaceAll(
                                                                        ' ',
                                                                        ''))
                                                                .abs() *
                                                            -1)
                                                        .toString()
                                                    : priceController.text
                                                        .replaceAll(' ', ''),
                                                'name': descController.text,
                                                'shop': shopController.text,
                                                'date': Timestamp.now()
                                              });
                                          // if (result == null) {
                                          //   print('FAIL Create Purchase');
                                          // }
                                        }
                                      }),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ));
  }
}
