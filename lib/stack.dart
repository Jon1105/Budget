import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database.dart';
import 'models/user.dart';
import 'widgets/userChart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamProvider<List<User>>.value(
          initialData: [],
          value: DatabaseService('AuthenticaionUID').accountUsers,
          lazy: false,
          child: UserPage(1)),
    );
  }
}

class UserPage extends StatefulWidget {
  final int userID;
  UserPage(this.userID);
  @override
  _UserPageState createState() => _UserPageState(userID);
}

class _UserPageState extends State<UserPage> {
  final int userID;
  _UserPageState(this.userID);

  // String error = '';
  bool showChart = true;

  @override
  Widget build(BuildContext context) {
    var usersList = Provider.of<List<User>>(context);
    var user;
    usersList.forEach((User userI) {
      if (userI.id == userID) {
        user = userI;
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        title: Text('${user.name}\'s Budget'),
      ),
      body: Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          // padding: EdgeInsets.all(8),
          child: (user.total == 0)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Center(child: Text('No purchases')),
                    )
                  ],
                )
              : Column(
                  children: <Widget>[
                    showChart
                        ? Container(
                            child: UserChart(user),
                            height: 269,
                          )
                        : Container(),
                    PurchaseList(userID),
                  ],
                )),
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
            icon: Icon(Icons.insert_chart),
            onPressed: () {
              setState(() {
                showChart = !showChart;
              });
            }),
      ),
    );
  }
}

class PurchaseList extends StatelessWidget {
  final int userID;
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
    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: user.purchases.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Row(
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(user.purchases[index]['name']),
                        Text(user.purchases[index]['category']),
                        Text(user.purchases[index]['date']),
                        Text(user.purchases[index]['shop'])
                      ]),
                  // Price
                  Text('\$${user.purchases[index]["price"]}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
