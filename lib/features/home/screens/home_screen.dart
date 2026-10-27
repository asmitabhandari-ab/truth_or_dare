import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/game_controller.dart';
import '../../../core/widgets/game_ui.dart';
import '../../custom_questions/screens/add_custom_question_screen.dart';
import '../../players/screens/players_screen.dart';
import '../../settings/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GamePage(
      showBackButton: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Settings',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome, color: AppPalette.cyan, size: 44),
              const SizedBox(height: 16),
              const Text(
                'TRUTH\nOR DARE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'The party starts with one brave choice.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppPalette.muted, fontSize: 16),
              ),
              const SizedBox(height: 38),
              PrimaryButton(
                label: 'START A GAME',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  context.read<GameController>().resetGame();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PlayersScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AddCustomQuestionScreen(),
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('ADD A CUSTOM PROMPT'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  foregroundColor: AppPalette.cyan,
                  side: const BorderSide(color: AppPalette.cyan),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _showHowToPlay(context),
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('HOW TO PLAY'),
              ),
              const Spacer(),
              const Text(
                'Play kind. Everyone can skip.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppPalette.muted, fontSize: 12),
              ),
              const SizedBox(height: 6),
              const Text(
                'Developed by Asmita Bhandari and Sandesh Ghimire ❣️',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppPalette.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppPalette.surface,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to play',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 16),
            Text(
              '1. Add at least two players.\n2. Pick a category and player picker.\n3. Spin, choose Truth, Dare, or let the app surprise you.\n4. Complete it, or skip any prompt — no explanation needed.',
            ),
            SizedBox(height: 16),
            Text(
              'Keep every challenge safe, consensual, and fun for the whole group.',
              style: TextStyle(color: AppPalette.cyan),
            ),
          ],
        ),
      ),
    );
  }
}
