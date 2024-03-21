import 'package:flutter/material.dart';

import 'login.dart';

class SignInHelpPage extends StatelessWidget {
  const SignInHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const LoginPage(),
                  transitionDuration: const Duration(seconds: 1),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                ));
              },
              icon: const Icon(Icons.navigate_before)),
          title: const Text("Sign In Help"),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: const SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              // TODO: Add login faq/assistance text
              Center(),
            ])));
  }
}
