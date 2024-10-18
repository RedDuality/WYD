import 'package:flutter/material.dart';
import 'package:wyd_front/controller/auth_controller.dart';
import 'package:wyd_front/view/home_page.dart';
import 'package:email_validator/email_validator.dart';

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
                  child: SizedBox(
                      width: 300,
                      height: 400,
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
                    controller: TextEditingController()..text = widget.mail,
                    onChanged: (text) {
                      _mail = text;
                    },
                    validator: (value) => EmailValidator.validate(value!) ? null : "Please enter a valid email",
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
                    validator: (value) => value!.length < 5 ? null : "Password must be at least 6 characters long",
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
                    validator: (value) => value!.isNotEmpty && _password == value ? null : "The passwords must match",
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm Password',
                        hintText: 'Enter secure password'),
                  ),
                ),
              ),
              const SizedBox(height: 10),


              if (_registerKey.currentState!.validate())
                SizedBox(
                  height: 50,
                  width: 250,
                  //decoration: BoxDecoration( color: Colors.blue),

                  child: ElevatedButton(
                    onPressed: _registerKey.currentState!.validate()
                        ? () async {
                            await AuthController()
                                .register(_mail, _password)
                                .then(
                              (loginSuccessful) {
                                if (loginSuccessful) {
                                  if (context.mounted) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage(
                                                    initialIndex: 3, uri: "")));
                                  }
                                }
                              },
                            ).catchError((error) {
                              debugPrint("ciadofiadsfa$error");
                            });
                          }
                        : null,
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
