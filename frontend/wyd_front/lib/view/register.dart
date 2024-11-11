import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:wyd_front/controller/error_controller.dart';
import 'package:wyd_front/state/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  final String mail;
  const RegisterPage({super.key, this.mail = ""});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _mail = "";
  String _password = "";

  final _registerKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _mail = widget.mail;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Form(
            key: _registerKey,
            child: Column(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: LimitedBox(
                        maxHeight: 400,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset('assets/images/logo.jpg'),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Padding(
                            //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              initialValue: widget.mail,
                              onChanged: (text) {
                                _mail = text;
                              },
                              validator: (value) =>
                                  EmailValidator.validate(value!)
                                      ? null
                                      : "Please enter a valid email address",
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Email',
                                  hintText:
                                      'Enter valid email id as abc@mail.com'),
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            //padding: EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                              onChanged: (text) {
                                _password = text;
                              },
                              obscureText: true,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Password',
                                  hintText: 'Enter secure password'),
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, bottom: 15.0, left: 15.0),
                            //padding: EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _password) {
                                  return 'The password doesn\'t match';
                                }
                                return null;
                              },
                              obscureText: true,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Confirm Password',
                                  hintText: 'Enter secure password'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              final authProvider =
                                  Provider.of<AuthenticationProvider>(context,
                                      listen: false);
                              authProvider
                                  .register(_mail, _password)
                                  .catchError((error) {
                                if (context.mounted) {
                                  ErrorController()
                                      .showErrorSnackBar(context, error.message);
                                }
                              });
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: 25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40, // Position the button near the top (adjust as necessary)
            left: 20, // Position the button near the left (adjust as necessary)
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous page
              },
              mini: true, // Makes the button smaller and round
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.primaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
