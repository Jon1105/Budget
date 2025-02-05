import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth.dart';

class SignUpPage extends StatefulWidget {
  final Function toggleView;
  SignUpPage(this.toggleView);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String error = '';

  final TextEditingController emailInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final TextEditingController passwordVerifyController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    var _auth = AuthService();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sign up to Budget',
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: colors['primary-light'].withOpacity(0.7),
                    //     borderRadius: BorderRadius.circular(15),
                    //   ),
                    //   child: TextFormField(
                    //     decoration: InputDecoration(
                    //         hintText: 'username',
                    //         border: InputBorder.none,
                    //         contentPadding:
                    //             EdgeInsets.symmetric(horizontal: 10)),
                    //     controller: usernameInputController,
                    //   ),
                    // ),
                    // SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: colors['primary-light'].withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: 'email',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10)),
                        validator: (val) {
                          return (RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val))
                              ? null
                              : 'Please enter a valid email';
                        },
                        controller: emailInputController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: colors['primary-light'].withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: 'password',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10)),
                        validator: (val) {
                          return (val.length < 6)
                              ? 'Password should contain 6 or more characters'
                              : null;
                        },
                        controller: passwordInputController,
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: colors['primary-light'].withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        controller: passwordVerifyController,
                        decoration: InputDecoration(
                            hintText: 'Verify Password',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10)),
                        validator: (val) {
                          return !(val == passwordInputController.text)
                              ? 'Passwords do not match'
                              : null;
                        },
                        obscureText: true,
                      ),
                    ),
                    FlatButton(
                      child: Text(
                        'Already have an account? Sign in Here',
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
                        child: Text('Sign Up'),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          var result = await _auth.signUp(
                              emailInputController.text,
                              passwordInputController.text);
                          if (result == null) {
                            setState(() {
                              loading = false;
                              error = 'Invalid Credentials';
                              emailInputController.text = '';
                              passwordInputController.text = '';
                              passwordVerifyController.text = '';
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
