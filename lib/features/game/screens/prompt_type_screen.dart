import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/services/game_controller.dart';
import '../../../core/widgets/game_ui.dart';
import 'question_screen.dart';

class PromptTypeScreen extends StatefulWidget {
  const PromptTypeScreen({super.key});

  @override
  State<PromptTypeScreen> createState() => _PromptTypeScreenState();
}

class _PromptTypeScreenState extends State<PromptTypeScreen> {
  bool _loading = false;

  Future<void> _choose(String type) async {
    setState(() => _loading = true);
    final game = context.read<GameController>();
    final chosenType = type == 'surprise'
        ? (Random().nextBool() ? 'truth' : 'dare')
        : type;
    final question = await game.chooseQuestion(chosenType);
    if (!mounted) return;
    setState(() => _loading = false);
    if (question == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There are no prompts for that choice yet.'),
        ),
      );
      return;
    }
    if (game.hapticsEnabled) HapticFeedback.mediumImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const QuestionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<GameController>().currentPlayer;
    if (player == null) return const SizedBox.shrink();
    return GamePage(
      title: 'Make your choice',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
        child: Column(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppPalette.purple.withValues(alpha: 0.25),
              child: Text(player.avatar, style: const TextStyle(fontSize: 42)),
            ),
            const SizedBox(height: 12),
            Text(
              '${player.name}, choose wisely.',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 38),
            _ChoiceButton(
              label: 'TRUTH',
              subtitle: 'Tell it like it is',
              icon: Icons.chat_bubble_rounded,
              color: AppPalette.cyan,
              onTap: _loading ? null : () => _choose('truth'),
            ),
            const SizedBox(height: 16),
            _ChoiceButton(
              label: 'DARE',
              subtitle: 'Do something unforgettable',
              icon: Icons.local_fire_department_rounded,
              color: AppPalette.pink,
              onTap: _loading ? null : () => _choose('dare'),
            ),
            const SizedBox(height: 16),
            _ChoiceButton(
              label: 'SURPRISE ME',
              subtitle: 'Let fate decide',
              icon: Icons.casino_rounded,
              color: AppPalette.purple,
              onTap: _loading ? null : () => _choose('surprise'),
            ),
            if (_loading) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
            const Spacer(),
            const Text(
              'A skip is always okay.',
              style: TextStyle(color: AppPalette.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.7)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 35),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppPalette.muted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
