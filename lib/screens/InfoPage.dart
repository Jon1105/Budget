import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'package:flutter/material.dart';
import '../services/database.dart';
import 'package:provider/provider.dart';
import '../widgets/UsersList.dart';
import '../models/user.dart';
import '../services/auth.dart';

class InfoPageWithProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var account = Provider.of<FirebaseUser>(context);
    return MultiProvider(providers: [
      StreamProvider<List<User>>.value(
          initialData: [],
          value: DatabaseService(account.uid).accountUsers,
          lazy: false,
          catchError: (ctx, obj) {
            return null;
          }),
      StreamProvider<List<int>>.value(
          value: DatabaseService(account.uid).spendable,
          lazy: false,
          catchError: (ctx, obj) {
            return null;
          })
    ], child: InfoPage());
  }
}

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool checkBoxVal = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  var accountData;
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Budget Info', style: appBarText),
          elevation: 0,
          backgroundColor: colors['primary-dark'],
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  updateSpendable(context);
                }),
            IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                ),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Sign Out"),
                          content: Text('Are you sure you want to sign out?'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            FlatButton(
                              child: Text('Sign Out',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await _auth.signOut();
                              },
                            )
                          ],
                        );
                      });
                })
          ],
        ),
        body: Padding(padding: EdgeInsets.all(8), child: CustomUserList()),
        floatingActionButton: FloatingActionButton(
            backgroundColor: colors['accent-dark'],
            onPressed: createUser,
            child: Icon(Icons.person_add)));
  }

  Future createUser() async {
    if (nameController.text != '') {
      if (_formKey.currentState.validate()) {
        var account = Provider.of<FirebaseUser>(context, listen: false);
        var dataservice = DatabaseService(account.uid);

        Navigator.of(context).pop();
        await dataservice.newAccountUser(
            name: nameController.text, isAdmin: checkBoxVal);
        nameController.text = '';
      }
    } else
      _scaffoldKey.currentState.showBottomSheet((context) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
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
                        controller: nameController,
                        autofocus: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 5),
                            hintText: 'Name'),
                      ),
                    ),
                    Text('Parent'),
                    Checkbox(
                        value: checkBoxVal,
                        onChanged: (bool val) =>
                            setState(() => checkBoxVal = val))
                  ],
                ),
              ),
            );
          },
        );
      });
  }

  void updateSpendable(BuildContext context) {
    var spendable = Provider.of<List<int>>(context, listen: false);
    var account = Provider.of<FirebaseUser>(context, listen: false);

    final _formKey = GlobalKey<FormState>();

    accountData = DatabaseService(account.uid);
    List<bool> spendablesHaveVal = [
      (spendable[0] == -1) ? false : true,
      (spendable[1] == -1) ? false : true
    ];

    var childController = TextEditingController();
    var parentController = TextEditingController();
    bool childHasVal = spendablesHaveVal[1];
    bool parentHasVal = spendablesHaveVal[0];
    if (childHasVal) {
      childController.text = spendable[1].toString();
    }
    if (parentHasVal) {
      parentController.text = spendable[0].toString();
    }

    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Edit Spendable Values', style: promptTitle),
                          Row(children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: spendablesHaveVal[0]
                                        ? '\$${spendable[0]}'
                                        : 'no limit set',
                                    labelText: 'Parent spending limit'),
                                keyboardType: TextInputType.number,
                                controller: parentController,
                                enabled: parentHasVal,
                                validator: (val) {
                                  return (val == '' && parentHasVal)
                                      ? 'Enter a value'
                                      : null;
                                },
                              ),
                            ),
                            Checkbox(
                                value: parentHasVal,
                                onChanged: (val) {
                                  setState(() {
                                    parentHasVal = val;
                                    if (!parentHasVal) {
                                      parentController.text = '';
                                    }
                                  });
                                })
                          ]),
                          Row(children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: spendablesHaveVal[1]
                                        ? '\$${spendable[1]}'
                                        : 'no limit set',
                                    labelText: 'Child spending limit'),
                                keyboardType: TextInputType.number,
                                controller: childController,
                                enabled: childHasVal,
                                validator: (val) {
                                  return (val == '' && childHasVal)
                                      ? 'Enter a value'
                                      : null;
                                },
                              ),
                            ),
                            Checkbox(
                                value: childHasVal,
                                onChanged: (val) {
                                  setState(() {
                                    childHasVal = val;
                                    if (!childHasVal) {
                                      childController.text = '';
                                    }
                                  });
                                })
                          ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              FlatButton(
                                child: Text(
                                  'Cancel',
                                  style: promptSubmitText,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              FlatButton(
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    Navigator.of(context).pop();
                                    int parentRet;
                                    int childRet;
                                    if (parentController.text != '' &&
                                        parentHasVal) {
                                      parentRet = int.parse(parentController
                                          .text
                                          .replaceAll(' ', ''));
                                    } else {
                                      parentRet = -1;
                                    }
                                    if (childController.text != '' &&
                                        childHasVal) {
                                      childRet = int.parse(childController.text
                                          .replaceAll(' ', ''));
                                    } else {
                                      childRet = -1;
                                    }

                                    accountData.setSpendable(
                                        parentRet, childRet);
                                  }
                                },
                                child: Text(
                                  'Update',
                                  style: promptSubmitText,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ));
  }
}
