import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/models/player.dart';
import '../../../core/services/game_controller.dart';
import '../../../core/widgets/game_ui.dart';
import 'prompt_type_screen.dart';

class PlayerPickerScreen extends StatefulWidget {
  const PlayerPickerScreen({super.key});

  @override
  State<PlayerPickerScreen> createState() => _PlayerPickerScreenState();
}

class _PlayerPickerScreenState extends State<PlayerPickerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  Player? _selectedPlayer;
  bool _isPicking = true;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _pick());
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    if (!mounted) return;
    final game = context.read<GameController>();
    setState(() {
      _isPicking = true;
      _selectedPlayer = null;
    });
    if (game.hapticsEnabled) HapticFeedback.lightImpact();
    await _animation.forward(from: 0);
    if (!mounted) return;
    final winner = game.pickNextPlayer();
    if (game.hapticsEnabled) HapticFeedback.heavyImpact();
    setState(() {
      _selectedPlayer = winner;
      _isPicking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final isBottle = game.selectionMode == PlayerSelectionMode.spinBottle;
    final displayName = _selectedPlayer?.name ?? _cyclingName(game.players);
    return GamePage(
      title: isBottle ? 'Spin the bottle' : 'Random player',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        child: Column(
          children: [
            const Text(
              'The next turn belongs to…',
              style: TextStyle(color: AppPalette.muted),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Center(
                child: isBottle
                    ? _BottlePicker(
                        players: game.players,
                        animation: _animation,
                        selected: _selectedPlayer,
                      )
                    : _RandomPicker(
                        players: game.players,
                        animation: _animation,
                        selected: _selectedPlayer,
                      ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: Text(
                displayName,
                key: ValueKey(displayName),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  color: _selectedPlayer == null
                      ? Colors.white
                      : AppPalette.cyan,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _isPicking ? 'Picking fairly…' : 'It is your turn!',
              style: const TextStyle(color: AppPalette.muted),
            ),
            const SizedBox(height: 22),
            if (_isPicking)
              const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              PrimaryButton(
                label: 'TRUTH OR DARE',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PromptTypeScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _pick,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('PICK AGAIN'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _cyclingName(List<Player> players) {
    if (players.isEmpty) return '';
    final index =
        (_animation.value * players.length * 7).floor() % players.length;
    return players[index].name;
  }
}

class _BottlePicker extends StatelessWidget {
  const _BottlePicker({
    required this.players,
    required this.animation,
    required this.selected,
  });

  final List<Player> players;
  final Animation<double> animation;
  final Player? selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const avatarSize = 50.0;
          final radius = constraints.maxWidth * 0.39;
          final center = constraints.maxWidth / 2;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppPalette.purple.withValues(alpha: 0.45),
                    width: 2,
                  ),
                  color: AppPalette.surface.withValues(alpha: 0.45),
                ),
              ),
              ...List.generate(players.length, (index) {
                final player = players[index];
                final angle =
                    (2 * math.pi * index / players.length) - math.pi / 2;
                final left = center + radius * math.cos(angle) - avatarSize / 2;
                final top = center + radius * math.sin(angle) - avatarSize / 2;
                final active = selected?.id == player.id;
                return Positioned(
                  left: left,
                  top: top,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: avatarSize,
                    width: avatarSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? AppPalette.cyan : AppPalette.surfaceLight,
                      border: Border.all(
                        color: active ? Colors.white : Colors.white24,
                        width: active ? 3 : 1,
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppPalette.cyan.withValues(alpha: 0.7),
                                blurRadius: 18,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      player.avatar,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                );
              }),
              Center(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Transform.rotate(
                    angle: animation.value * math.pi * 8,
                    child: child,
                  ),
                  child: Container(
                    height: 106,
                    width: 106,
                    decoration: BoxDecoration(
                      color: AppPalette.pink,
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.pink.withValues(alpha: 0.48),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.local_bar_rounded, size: 58),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RandomPicker extends StatelessWidget {
  const _RandomPicker({
    required this.players,
    required this.animation,
    required this.selected,
  });

  final List<Player> players;
  final Animation<double> animation;
  final Player? selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final index =
            (animation.value * players.length * 9).floor() % players.length;
        final player = selected ?? players[index];
        return GlassCard(
          color: selected == null
              ? AppPalette.surface.withValues(alpha: 0.94)
              : AppPalette.cyan.withValues(alpha: 0.15),
          child: SizedBox(
            height: 190,
            width: 230,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(player.avatar, style: const TextStyle(fontSize: 70)),
                const SizedBox(height: 14),
                const Icon(
                  Icons.casino_rounded,
                  color: AppPalette.cyan,
                  size: 30,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
