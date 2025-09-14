import 'package:flutter/material.dart';
import 'package:wyd_front/service/util/information_service.dart';
import 'package:wyd_front/API/Test/test_api.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';
import 'package:wyd_front/view/authentication/register.dart';
import 'package:wyd_front/view/widget/util/hover_text.dart';
import 'package:wyd_front/view/widget/util/version_detail.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _mail = "prova@mail.com";
  String _password = "password";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    onChanged: (text) {
                      _mail = text;
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter valid email id as abc@gmail.com'),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
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
              ElevatedButton(
                onPressed: () {
                  TestAPI().ping();
                },
                child: const Text(
                  'Forgot Password',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    final authProvider = AuthenticationProvider();
                    authProvider.signIn(_mail, _password).catchError((error) {
                      if (context.mounted) {
                        InformationService().showErrorSnackBar(context, error);
                      }
                    });
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        fontSize: 25),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterPage(mail: _mail)),
                  );
                },
                child: const HoverText(
                  text: 'New user? Create account',
                  hoverColor: Colors.blue,
                  defaultColor: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 15),
              // Add the version number text box here
              VersionDetail(),
            ],
          ),
        ),
      ),
    );
  }
}
