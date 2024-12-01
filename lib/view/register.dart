import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:wyd_front/service/information_service.dart';
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
  bool _isFormValid = false; // Variabile di stato per la validità del form

  final _registerKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mail = widget.mail;
  }
  
  @override
  Widget build(BuildContext context) {

    // Funzione per aggiornare la validità del form
    void updateFormValidity() {
      setState(() {
        _isFormValid = _registerKey.currentState?.validate() ?? false;
      });
    }

    // Funzione per ottenere il colore del testo del bottone
    Color getButtonTextColor() {
      return _isFormValid ? Colors.lightBlue : Theme.of(context).colorScheme.primaryContainer;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Form(
            key: _registerKey,
            onChanged: updateFormValidity, // Chiama questa funzione ogni volta che il form cambia
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
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              initialValue: widget.mail,
                              onChanged: (text) {
                                setState(() {
                                  _mail = text;
                                });
                                updateFormValidity();
                              },
                              validator: (value) =>
                                  EmailValidator.validate(value!)
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
                                setState(() {
                                  _password = text;
                                });
                                updateFormValidity();
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
                              onChanged: (text) {
                                updateFormValidity();
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
                              if (_registerKey.currentState!.validate()) {
                                final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
                                authProvider
                                    .register(_mail, _password)
                                    .catchError((error) {
                                  if (context.mounted) {
                                    InformationService().showErrorSnackBar(context, error);
                                  }
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: getButtonTextColor(),
                                fontSize: 25,
                              ),
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
            top: 30, // Posiziona il pulsante vicino alla parte superiore (regola se necessario)
            left: 30, // Posiziona il pulsante vicino alla sinistra (regola se necessario)
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context); // Torna alla pagina precedente
              },
              mini: true, // Rende il pulsante più piccolo e rotondo
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
