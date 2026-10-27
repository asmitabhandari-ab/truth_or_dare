import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/services/game_controller.dart';
import '../../../core/widgets/game_ui.dart';
import 'player_picker_screen.dart';

class PlayerModeScreen extends StatelessWidget {
  const PlayerModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final category = game.selectedCategory == '18+'
        ? '18+'
        : game.selectedCategory.toUpperCase();
    return GamePage(
      title: 'Choose a picker',
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$category prompts · ${game.players.length} players',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppPalette.cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              game.players.length == 2
                  ? 'Two players? This is a great setup for a couples category.'
                  : 'How should the next player be picked?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPalette.muted),
            ),
            const SizedBox(height: 28),
            _ModeCard(
              icon: Icons.local_bar_rounded,
              title: 'Spin the bottle',
              subtitle: 'Watch the bottle choose the next player.',
              color: AppPalette.pink,
              onTap: () => _select(context, PlayerSelectionMode.spinBottle),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              icon: Icons.casino_rounded,
              title: 'Random player',
              subtitle: 'A fast shuffle picks someone at random.',
              color: AppPalette.cyan,
              onTap: () => _select(context, PlayerSelectionMode.random),
            ),
            const Spacer(),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(Icons.shuffle_rounded, color: AppPalette.purple),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The same player will not be picked twice in a row.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _select(BuildContext context, PlayerSelectionMode mode) {
    final game = context.read<GameController>();
    game.selectPlayerMode(mode);
    if (game.hapticsEnabled) HapticFeedback.selectionClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PlayerPickerScreen()));
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppPalette.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 31, color: color),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppPalette.muted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
