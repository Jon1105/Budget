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
  var i;
  var b = true;
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Info', style: appBarText),
        elevation: 0,
        backgroundColor: colors['primary-dark'],
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.exit_to_app,
              ),
              onPressed: () async {
                await _auth.signOut();
              })
        ],
      ),
      body: b
          ? Padding(padding: EdgeInsets.all(8), child: CustomUserList())
          : Center(child: Text('Noob')),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.person_add,
                        size: 35, color: colors['accent-dark']),
                    onPressed: () {
                      createUser(context);
                    }),
                IconButton(
                    icon: Icon(Icons.insert_chart,
                        size: 35, color: colors['accent-dark']),
                    onPressed: () {
                      print(b);
                      setState(() {
                        b = !b;
                      });
                    }),
                // IconButton(
                //     icon: Icon(Icons.monetization_on,
                //         size: 35, color: colors['accent-dark']),
                //     ),
                IconButton(
                    icon: Icon(Icons.edit,
                        size: 35, color: colors['accent-dark']),
                    onPressed: () {
                      updateSpendable(context);
                    }),
              ]),
        ),
      ),
    );
  }

  void createUser(BuildContext context) {
    final nameController = TextEditingController();
    var account = Provider.of<FirebaseUser>(context, listen: false);
    i = DatabaseService(account.uid);
    bool checkBoxVal = false;

    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Add a member', style: promptTitle),
                        TextField(
                            decoration: InputDecoration(hintText: 'name'),
                            controller: nameController),
                        Row(
                          children: <Widget>[
                            Checkbox(
                                value: checkBoxVal,
                                onChanged: (val) {
                                  setState(() {
                                    checkBoxVal = val;
                                  });
                                }),
                            Text('Parent')
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(
                                child:
                                    Text('Continue', style: promptSubmitText),
                                onPressed: () async {
                                  Navigator.of(context).pop(context);
                                  await i.newAccountUser(
                                      name: nameController.text,
                                      isAdmin: checkBoxVal);

                                  //     .updateUserData(User('Unnamed', true));
                                }),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ));
  }

  void updateSpendable(BuildContext context) {
    var spendable = Provider.of<List<int>>(context, listen: false);
    var account = Provider.of<FirebaseUser>(context, listen: false);

    final _formKey = GlobalKey<FormState>();

    i = DatabaseService(account.uid);
    List<bool> spendablesHaveVal = [
      (spendable[0] == -1) ? false : true,
      (spendable[1] == -1) ? false : true
    ];

    var childController = TextEditingController();
    childController.text = spendable[1].toString();
    bool childHasVal = spendablesHaveVal[1];

    var parentController = TextEditingController();
    parentController.text = spendable[0].toString();
    bool parentHasVal = spendablesHaveVal[0];

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

                                    i.setSpendable(parentRet, childRet);
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
