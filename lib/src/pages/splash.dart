import 'package:flutter/material.dart';
import 'package:pembs_produce/src/helpers/constants/colors.dart';
import 'package:pembs_produce/src/pages/shop_map.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    requestPermission();
    _redirect();
  }

  Future<void> requestPermission() async {
    await Permission.location.request();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const ShopMapPage(),
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, a, __, c) => FadeTransition(
        opacity: a,
        child: c,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primaryBackground,
      body: Center(
          child: CircularProgressIndicator(
        color: AppColors.primary,
      )),
    );
  }
}
