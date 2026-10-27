import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/game_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TruthOrDareApp());
}

class TruthOrDareApp extends StatelessWidget {
  const TruthOrDareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = GameController();
        controller.initialise();
        return controller;
      },
      child: MaterialApp(
        title: 'Truth or Dare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
