import 'package:flutter/material.dart';
import 'services/app_store.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(SkillBridgeApp(store: store));
}

class SkillBridgeApp extends StatelessWidget {
  final AppStore store;

  const SkillBridgeApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SkillBridge',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: HomeScreen(store: store),
        );
      },
    );
  }
}
