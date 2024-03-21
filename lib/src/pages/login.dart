import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'shop_map.dart';
import 'sign_in_help.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _redirecting = false;
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ShopMapPage(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
            opacity: a,
            child: c,
          ),
        ));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Placeholder(fallbackHeight: 150.0),
            const SizedBox(height: 64.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                    child: Column(
                  children: [
                    Text("Login Page",
                        style: TextStyle(
                          color: Color(0xFFFFD1F8),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      height: 8,
                    ),
                    Text("Choose an account to use with PembsProduce",
                        style: TextStyle(
                          color: Color(0xFFFFD1F8),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      height: 36,
                    ),
                  ],
                )),
                SupaSocialsAuth(
                  socialProviders: const [
                    OAuthProvider.google,
                  ],
                  onSuccess: (Session session) {
                    setState(() {
                      if (mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const ShopMapPage(),
                          transitionDuration: const Duration(milliseconds: 300),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(
                            opacity: a,
                            child: c,
                          ),
                        ));
                      }
                    });
                  },
                  onError: (error) {},
                  colored: true,
                  redirectUrl:
                      kIsWeb ? null : 'com.pembsproduce://login-callback',
                ),
                const SizedBox(height: 12.0),
                TextButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const SignInHelpPage(),
                          transitionDuration: const Duration(seconds: 1),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(
                            opacity: a,
                            child: c,
                          ),
                        ));
                      }
                    },
                    child: const Text("Need some help? Tap here"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
