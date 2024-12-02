import 'package:flutter/material.dart';
import 'package:wyd_front/service/information_service.dart';
import 'package:wyd_front/API/test_api.dart';
import 'package:wyd_front/state/authentication_provider.dart';
import 'package:wyd_front/view/register.dart';
import 'package:wyd_front/widget/util/hover_text.dart';

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
                padding: const EdgeInsets.only(
                    top: 15.0), // Riduce lo spazio sopra l'immagine
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit
                          .cover, // Modifica il fit per adattare l'immagine
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
                  //TODO FORGOT PASSWORD SCREEN GOES HERE
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
              const SizedBox(
                  height: 30), // Aggiunge spazio tra "Login" e "New user?"
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
              const SizedBox(
                  height:
                      15), // Aggiunge più spazio tra "New user?" e il bordo inferiore
            ],
          ),
        ),
      ),
    );
  }
}
