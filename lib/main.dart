import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:in_app_update/in_app_update.dart';

import 'package:resend/resend.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/helpers/constants/colors.dart';
import 'src/helpers/constants/strings.dart';

import 'src/pages/splash.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await checkForUpdates();
  await dotenv.load(fileName: 'assets/.env');

  String dbApiUrl = dotenv.env['SUPABASE_API_URL'] ?? '';
  String dbApiKey = dotenv.env['SUPABASE_KEY'] ?? '';

  String resendKey = dotenv.env['RESEND_API_KEY'] ?? '';

  Resend(apiKey: resendKey);

  await Supabase.initialize(url: dbApiUrl, anonKey: dbApiKey, debug: true);

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
    initializeMapRenderer();
  }

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;
final resend = Resend.instance;

Completer<AndroidMapRenderer?>? _initializedRendererCompleter;

/// Initializes map renderer to the `latest` renderer type for Android platform.
///
/// The renderer must be requested before creating GoogleMap instances,
/// as the renderer can be initialized only once per application context.
Future<AndroidMapRenderer?> initializeMapRenderer() async {
  if (_initializedRendererCompleter != null) {
    return _initializedRendererCompleter!.future;
  }

  final Completer<AndroidMapRenderer?> completer =
      Completer<AndroidMapRenderer?>();
  _initializedRendererCompleter = completer;

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    unawaited(mapsImplementation
        .initializeWithRenderer(AndroidMapRenderer.latest)
        .then((AndroidMapRenderer initializedRenderer) =>
            completer.complete(initializedRenderer))
        .onError((error, stackTrace) => throw Exception(error)));
  } else {
    completer.complete(null);
  }

  return completer.future;
}

Future<void> checkForUpdates() async {
  InAppUpdate.checkForUpdate().then((info) {
    if (info.updateAvailability == UpdateAvailability.updateAvailable) {
      InAppUpdate.performImmediateUpdate();
    }
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: kDebugMode ? true : false,
      title: AppStrings.appTitle,
      theme: ThemeData.dark().copyWith(
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryText,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary,
            ),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          })),
      home: const SplashPage(),
    );
  }
}
