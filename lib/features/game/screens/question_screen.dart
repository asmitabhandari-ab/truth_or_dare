import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/services/game_controller.dart';
import '../../../core/widgets/game_ui.dart';
import 'player_picker_screen.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final question = game.currentQuestion;
    final player = game.currentPlayer;
    if (question == null || player == null) return const SizedBox.shrink();

    final isDare = question.type == 'dare';
    final accent = isDare ? AppPalette.pink : AppPalette.cyan;
    return GamePage(
      title: 'Round ${game.rounds + 1}',
      actions: [
        IconButton(
          tooltip: 'Game summary',
          onPressed: () => _showSummary(context),
          icon: const Icon(Icons.bar_chart_rounded),
        ),
        IconButton(
          tooltip: 'End game',
          onPressed: () => _confirmEnd(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            children: [
              _PlayerHeading(name: player.name, avatar: player.avatar),
              const SizedBox(height: 18),
              Expanded(
                child: GlassCard(
                  color: accent.withValues(alpha: 0.12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          isDare ? 'DARE' : 'TRUTH',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        question.category == '18+'
                            ? '18+ PROMPT'
                            : question.category.toUpperCase(),
                        style: const TextStyle(
                          color: AppPalette.muted,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        question.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          height: 1.26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (question.timer != null) ...[
                        const SizedBox(height: 30),
                        CountdownTimer(
                          seconds: question.timer!,
                          accent: accent,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _finishRound(context, skipped: true),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('SKIP'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        foregroundColor: AppPalette.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'COMPLETED +1',
                      icon: Icons.check_rounded,
                      color: AppPalette.green,
                      onPressed: () => _finishRound(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Only do what feels safe and consensual.',
                style: TextStyle(color: AppPalette.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishRound(BuildContext context, {bool skipped = false}) {
    final game = context.read<GameController>();
    if (skipped) {
      game.skipQuestion();
    } else {
      game.completeQuestion();
    }
    if (game.hapticsEnabled) HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const PlayerPickerScreen()),
    );
  }

  void _showSummary(BuildContext context) {
    final game = context.read<GameController>();
    final leader = [...game.players]
      ..sort((a, b) => b.score.compareTo(a.score));
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppPalette.surface,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game so far',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(label: 'ROUNDS', value: '${game.rounds}'),
                _Stat(label: 'DONE', value: '${game.completed}'),
                _Stat(label: 'SKIPPED', value: '${game.skipped}'),
              ],
            ),
            const SizedBox(height: 20),
            ...leader.map(
              (player) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(
                  player.avatar,
                  style: const TextStyle(fontSize: 26),
                ),
                title: Text(player.name),
                subtitle: Text(
                  '${player.completed} completed · ${player.skipped} skipped',
                ),
                trailing: Text(
                  '${player.score}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppPalette.cyan,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmEnd(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End this game?'),
        content: const Text(
          'Your current score will stay visible only until you start the next game.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('KEEP PLAYING'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('END GAME'),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

class _PlayerHeading extends StatelessWidget {
  const _PlayerHeading({required this.name, required this.avatar});

  final String name;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: AppPalette.purple.withValues(alpha: 0.26),
          child: Text(avatar, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 10),
        Text(
          name.toUpperCase(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppPalette.cyan,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppPalette.muted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.seconds,
    required this.accent,
  });

  final int seconds;
  final Color accent;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  late int _remaining;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_remaining == 0) setState(() => _remaining = widget.seconds);
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        if (mounted) {
          if (context.read<GameController>().hapticsEnabled) {
            HapticFeedback.heavyImpact();
          }
          setState(() {
            _remaining = 0;
            _running = false;
          });
        }
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _toggle,
      icon: Icon(_running ? Icons.pause_rounded : Icons.timer_outlined),
      label: Text('$_remaining s ${_running ? 'PAUSE' : 'START TIMER'}'),
      style: OutlinedButton.styleFrom(foregroundColor: widget.accent),
    );
  }
}
