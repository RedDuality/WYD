import 'package:flutter/material.dart';
import 'package:wyd_front/controller/auth_controller.dart';
import 'package:wyd_front/service/test_service.dart';
import 'package:wyd_front/view/home_page.dart';

class LoginPage extends StatefulWidget {
  final int desiredPage;
  final String uri;
  const LoginPage({super.key, this.desiredPage = 0, this.uri = ""});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String _mail = "second@mail.com";
  String _password = "password";

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
                    child: Image.asset('../assets/test.jpg')),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
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
                //padding: EdgeInsets.symmetric(horizontal: 15),
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
                TestService().ping();
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
              //decoration: BoxDecoration( color: Colors.blue),
              child: ElevatedButton(
                onPressed: () async {
                  await AuthController().login(_mail, _password).then(
                    (loginSuccessful) {

                      if (loginSuccessful) {
                        if (context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(
                                      initialIndex: widget.desiredPage, uri: widget.uri)));
                        }
                      }
                    },
                  );

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
              height: 130,
            ),
            const Text('New User? Create Account')
          ],
        ),
      ),
    );
  }
}
