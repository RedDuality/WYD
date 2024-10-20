import 'package:flutter/material.dart';
import 'package:wyd_front/controller/auth_controller.dart';
import 'package:email_validator/email_validator.dart';
import 'package:wyd_front/controller/error_controller.dart';
import 'package:wyd_front/view/home_page.dart';

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
      body: SingleChildScrollView(
        child: Form(
          key: _registerKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Center(
                  child: LimitedBox(
                      maxHeight: 400,
                      /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                      child: Image.asset('assets/images/logo.jpg')),
                ),
              ),
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
                    validator: (value) => EmailValidator.validate(value!)
                        ? null
                        : "Please enter a valid email address",
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter valid email id as abc@mail.com'),
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
                //decoration: BoxDecoration( color: Colors.blue),

                child: ElevatedButton(
                  onPressed: () {
                    debugPrint(_mail);
                    if (_registerKey.currentState!.validate()) {
                      AuthController().register(_mail, _password).then(
                        (loginSuccessful) {
                          if (loginSuccessful) {
                            if (context.mounted) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                            }
                          }
                        },
                      ).catchError((error) {
                        ErrorController().showErrorSnackBar(context, error);
                      });
                    }
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
