import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_screen.dart';
import 'services/progress.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await ProgressService.load();
  runApp(IraqiSweetsApp(progress: progress));
}

class IraqiSweetsApp extends StatelessWidget {
  const IraqiSweetsApp({required this.progress, super.key});

  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حلويات عراقية',
      debugShowCheckedModeBanner: false,
      theme: SweetsTheme.theme,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: HomeScreen(progress: progress),
    );
  }
}
