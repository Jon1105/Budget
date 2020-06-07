import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth.dart';

class SignInPage extends StatefulWidget {
  final Function toggleView;
  SignInPage(this.toggleView);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String error = '';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var _auth = AuthService();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sign in to Budget',
          style: appBarText,
        ),
        backgroundColor: colors['primary-dark'],
        elevation: 0,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings), onPressed: null),
          IconButton(icon: Icon(Icons.info), onPressed: null),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(hintText: 'email'),
                      validator: (val) {
                        return (RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val))
                            ? null
                            : 'Please enter a valid email';
                      },
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextFormField(
                      decoration: InputDecoration(hintText: 'password'),
                      validator: (val) {
                        return (val == null) ? 'Enter a password' : null;
                      },
                      controller: passwordController,
                      obscureText: true,
                    ),
                    FlatButton(
                      child: Text(
                        'Don\'t have an account? Sign Up Here',
                        style: linkText,
                      ),
                      onPressed: widget.toggleView,
                    ),
                    FlatButton(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: colors['accent-light'],
                        ),
                        padding: EdgeInsets.all(12),
                        child: Text('Sign In'),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          var result = await _auth.signIn(
                              emailController.text, passwordController.text);
                          if (result == null) {
                            setState(() {
                              loading = false;
                              error =
                                  'Email and password do not match. Try again';
                              passwordController.text = '';
                            });
                          }
                        }
                      },
                    ),
                    Text(
                      error,
                      style: errorText,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
