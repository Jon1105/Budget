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

class UserPage extends StatefulWidget {
  final String userID;
  UserPage(this.userID);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void dispose() {
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<User> usersList = Provider.of<List<User>>(context);
    User user;
    for (User userI in usersList) {
      if (userI.id == widget.userID) {
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
            key: _scaffoldKey,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
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
                          PurchaseList(widget.userID),
                        ],
                      )),
            floatingActionButton: FloatingActionButton(
                backgroundColor: colors['accent-dark'],
                child: Icon(Icons.attach_money),
                onPressed: createUser),
          );
  }

  Future createUser() async {
    if (descController.text != '' || priceController.text != '') {
      try {
        if (_formKey.currentState.validate()) {
          var account = Provider.of<FirebaseUser>(context, listen: false);
          var dataservice = DatabaseService(account.uid);

          Navigator.of(context).pop();
          await dataservice
              .updateAccountPurchases(id: widget.userID, purchase: {
            'price': priceController.text.replaceAll(' ', ''),
            'name': descController.text,
            'date': Timestamp.now()
          });
        }
      } catch (_) {
        descController.text = '';
        priceController.text = '';
        createUser();
      }
    } else
      _scaffoldKey.currentState.showBottomSheet((BuildContext _) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 25),
          decoration: BoxDecoration(
              color: colors['primary'].withOpacity(0.8),
              // boxShadow: [BoxShadow(offset: Offset(0, 2), color: Colors.grey[600])],
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(13),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    validator: (val) {
                      if (val == '' || val == null) return 'Enter a name';
                      return null;
                    },
                    controller: descController,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Description'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15)),
                  width: 100,
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val != '' &&
                          (double.parse(val) >= 0.005 ||
                              double.parse(val) < 0)) {
                        return null;
                      }
                      return 'Invalid amount';
                    },
                    decoration: InputDecoration(
                        prefix: Text('\$'),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Price'),
                  ),
                ),
              ],
            ),
          ),
        );
      });
  }
}
