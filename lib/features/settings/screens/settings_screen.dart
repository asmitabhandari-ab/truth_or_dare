import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/game_controller.dart';
import '../../../core/widgets/game_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    return GamePage(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Game feel',
            style: TextStyle(
              color: AppPalette.cyan,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: game.soundEnabled,
                    onChanged: game.setSoundEnabled,
                    secondary: const Icon(Icons.volume_up_rounded),
                    title: const Text('Sound effects'),
                    subtitle: const Text('Ready for future game sounds'),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: game.hapticsEnabled,
                    onChanged: game.setHapticsEnabled,
                    secondary: const Icon(Icons.vibration_rounded),
                    title: const Text('Haptic feedback'),
                    subtitle: const Text(
                      'Vibrate on picks, prompts, and timers',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'About',
            style: TextStyle(
              color: AppPalette.cyan,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Truth or Dare',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'An offline party game with 1,000 built-in prompts and room for your own.',
                  style: TextStyle(color: AppPalette.muted),
                ),
                SizedBox(height: 14),
                Text(
                  'No accounts. No network. Just your group.',
                  style: TextStyle(color: AppPalette.cyan),
                ),
                SizedBox(height: 14),
                Divider(),
                SizedBox(height: 10),
                Text(
                  'Developed by Asmita Bhandari and Sandesh Ghimire ❣️',
                  style: TextStyle(color: AppPalette.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
