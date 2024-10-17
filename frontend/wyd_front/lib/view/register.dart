import 'package:flutter/material.dart';
import 'package:wyd_front/controller/auth_controller.dart';
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
  String _password2 = "";
  bool _credentialok = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                child: TextField(
                  controller: TextEditingController()..text = widget.mail,
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
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  onChanged: (text) {
                    _password = text;
                    if (_password.isNotEmpty && _password == _password2) {
                      setState(() => _credentialok = true);
                    } else {
                      setState(() => _credentialok = false);
                    }
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
                child: TextField(
                  onChanged: (text) {
                    _password2 = text;
                    if (_password2.isNotEmpty && _password == _password2) {
                      setState(() => _credentialok = true);
                    } else {
                      setState(() => _credentialok = false);
                    }
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
            if (_credentialok)
              SizedBox(
                height: 50,
                width: 250,
                //decoration: BoxDecoration( color: Colors.blue),

                child: ElevatedButton(
                  onPressed: _credentialok ? () async {
                    await AuthController().register(_mail, _password).then(
                      (loginSuccessful) {
                        if (loginSuccessful) {
                          if (context.mounted) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage(
                                        initialIndex: 3, uri: "")));
                          }
                        }
                      },
                    );
                  } : null,
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
    );
  }
}
