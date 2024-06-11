import 'package:flutter/material.dart';
import 'package:wyd_front/controller/auth_controller.dart';
import 'package:wyd_front/service/test_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset('../assets/test.jpg')),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child:  Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  onChanged: (text){ _mail = text;},
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
                  onChanged: (text){ _password = text;},
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
                  AuthController().login(context, _mail, _password);
                  

                 
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
