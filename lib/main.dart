import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/details_screen.dart';
import 'screens/liked_cats_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'di/di.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CachedNetworkImage.evictFromCache('');
  initDI();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ru');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(primarySwatch: Colors.blue),
      locale: _locale,
      supportedLocales: [Locale('ru'), Locale('en')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(onLocaleChange: _setLocale),
        '/details': (context) => DetailsScreen(),
        '/liked': (context) => const LikedCatsScreen(), // Новый экран
      },
    );
  }
}