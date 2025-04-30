import 'package:dashboard_template/pages/home.dart';
import 'package:dashboard_template/pages/transaction.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

ThemeData createTheme([Brightness? brightness]) {
  return ThemeData(
    brightness: brightness,
    fontFamily: "Quicksand",
    primarySwatch: Colors.indigo,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.indigo,
      brightness: brightness ?? Brightness.light,
    ).copyWith(
      secondary: Colors.deepOrangeAccent,
    ),
    // This makes the visual density adapt to the platform that you run
    // the app on. For desktop platforms, the controls will be smaller and
    // closer together (more dense) than on mobile platforms.
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: createTheme(),
      darkTheme: createTheme(Brightness.dark),
      routes: {
        "/": (context) => const HomePage(),
        "/transaction": (context) => const TransactionPage(),
      },
    );
  }
}
