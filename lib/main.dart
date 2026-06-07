import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/storage_service.dart';
import 'services/settings_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await StorageService.init();
  await SettingsService.init();
  runApp(const BlackPadApp());
}

class BlackPadApp extends StatelessWidget {
  const BlackPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder — هر تغییر تنظیمات فوری theme رو آپدیت میکنه
    return ValueListenableBuilder(
      valueListenable: SettingsService.listenable(),
      builder: (context, Box box, _) {
        final accentColor = SettingsService.accentColor;
        final isDark = SettingsService.isDarkMode;

        return MaterialApp(
          title: 'blackPad',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            useMaterial3: true,
            fontFamily: 'Sodark',
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: Colors.black,
              surface: const Color(0xFF1A1A1A),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              contentTextStyle: TextStyle(
                  color: Colors.white, fontFamily: 'Sodark'),
            ),
            sliderTheme: SliderThemeData(
              thumbColor: accentColor,
              activeTrackColor: accentColor,
              overlayColor: accentColor.withOpacity(0.15),
            ),
          ),
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            fontFamily: 'Sodark',
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: const Color(0xFFF5F5F5),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                  color: Colors.black, fontFamily: 'Sodark'),
            ),
            sliderTheme: SliderThemeData(
              thumbColor: accentColor,
              activeTrackColor: accentColor,
              overlayColor: accentColor.withOpacity(0.15),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}