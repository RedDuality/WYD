import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  final String mail;
  const RegisterPage({super.key, this.mail = ""});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerKey = GlobalKey<FormState>();
  final _mailController = TextEditingController();

  String _password = "";

  @override
  void initState() {
    super.initState();
    _mailController.text = widget.mail;
  }

  @override
  void dispose() {
    _mailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Form(
            key: _registerKey,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: <Widget>[
                  // Logo
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
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
              
                  // Email field
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                      child: TextFormField(
                        controller: _mailController,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: (value) =>
                            EmailValidator.validate(value ?? "") ? null : "Please enter a valid email address",
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'Enter valid email id as abc@mail.com',
                          helperText: ' ',
                        ),
                      ),
                    ),
                  ),
              
                  // Password field
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                      child: TextFormField(
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUnfocus,
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter secure password',
                          helperText: ' ',
                        ),
                      ),
                    ),
                  ),
              
                  // Confirm password field
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                      child: TextFormField(
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _password) {
                            return 'The password doesn\'t match';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Confirm Password',
                          hintText: 'Enter secure password',
                          helperText: ' ',
                        ),
                      ),
                    ),
                  ),
              
                  // Register button
                  SizedBox(
                    height: 50,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_registerKey.currentState!.validate()) {
                          final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
                          authProvider.register(_mailController.text, _password).catchError((error) {
                            if (context.mounted) {
                              InformationService().showErrorSnackBar(context, error);
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,)
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 30,
            left: 30,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
