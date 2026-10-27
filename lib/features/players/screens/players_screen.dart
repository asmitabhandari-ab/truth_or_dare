import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/game_controller.dart';
import '../../../core/widgets/game_ui.dart';
import '../../categories/screens/category_screen.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final error = context.read<GameController>().addPlayer(_controller.text);
    setState(() => _error = error);
    if (error == null) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    return GamePage(
      title: 'Who is playing?',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add 2–12 players, then drag the handles to set the order.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.muted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addPlayer(),
                    decoration: const InputDecoration(hintText: 'Player name'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(56, 56),
                    backgroundColor: AppPalette.pink,
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Color(0xFFFFA8B9))),
            ],
            const SizedBox(height: 18),
            Expanded(
              child: game.players.isEmpty
                  ? const _EmptyPlayers()
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: game.players.length,
                      onReorderItem: game.reorderPlayers,
                      itemBuilder: (context, index) {
                        final player = game.players[index];
                        return Padding(
                          key: ValueKey(player.id),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppPalette.purple.withValues(
                                    alpha: 0.25,
                                  ),
                                  child: Text(
                                    player.avatar,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    player.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove ${player.name}',
                                  onPressed: () => game.removePlayer(index),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFFFFA8B9),
                                  ),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      color: AppPalette.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: game.players.length < 2
                  ? 'ADD ${2 - game.players.length} MORE PLAYER${game.players.isEmpty ? 'S' : ''}'
                  : 'CHOOSE A CATEGORY',
              icon: Icons.arrow_forward_rounded,
              onPressed: game.players.length >= 2
                  ? () {
                      game.startSession();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CategoryScreen(),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPlayers extends StatelessWidget {
  const _EmptyPlayers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.group_add_outlined, size: 44, color: AppPalette.cyan),
            SizedBox(height: 12),
            Text(
              'Your party is waiting.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'Start with two names.',
              style: TextStyle(color: AppPalette.muted),
            ),
          ],
        ),
      ),
    );
  }
}
