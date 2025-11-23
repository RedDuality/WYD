import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _mail = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                child: TextField(
                  onChanged: (text) {
                    _mail = text;
                  },
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'abc@mail.com',
                      helperText: ' '),
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                child: TextField(
                  onChanged: (text) {
                    _password = text;
                  },
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter secure password',
                      helperText: ' '),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
                  authProvider.signIn(_mail, _password).catchError((error) {
                    if (context.mounted) {
                      InformationService().showErrorSnackBar(context, error);
                    }
                  });
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Theme.of(context).colorScheme.primaryContainer, fontSize: 25),
                ),
              ),
            ),
            const SizedBox(height: 3),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage(mail: _mail)),
                );
              },
              child: const HoverText(
                text: 'New user? Create account',
                hoverColor: Colors.black,
                defaultColor: Colors.blue,
                fontSize: 18.0,
              ),
            ),
            // Add the version number text box here
            VersionDetail(),
          ],
        ),
      ),
    );
  }
}
