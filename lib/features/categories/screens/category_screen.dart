import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/services/game_controller.dart';
import '../../../core/widgets/game_ui.dart';
import '../../game/screens/player_mode_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const _categories = <_CategoryData>[
    _CategoryData(
      'all',
      'All',
      Icons.auto_awesome_rounded,
      AppPalette.cyan,
      'A little of everything',
    ),
    _CategoryData(
      'funny',
      'Funny',
      Icons.sentiment_very_satisfied_rounded,
      Color(0xFFFFC95C),
      'Silly stories & laughs',
    ),
    _CategoryData(
      'friends',
      'Friends',
      Icons.people_alt_rounded,
      Color(0xFF8AD8FF),
      'For the group chat',
    ),
    _CategoryData(
      'icebreaker',
      'Icebreaker',
      Icons.ac_unit_rounded,
      Color(0xFFA9F5E2),
      'Warm up the room',
    ),
    _CategoryData(
      'deep',
      'Deep',
      Icons.psychology_alt_rounded,
      Color(0xFFAFA0FF),
      'Get real',
    ),
    _CategoryData(
      'party',
      'Party',
      Icons.celebration_rounded,
      Color(0xFFFFA5C1),
      'Turn it up',
    ),
    _CategoryData(
      'romantic',
      'Romantic',
      Icons.favorite_rounded,
      Color(0xFFFF7297),
      'Sweet and flirty',
    ),
    _CategoryData(
      'couples',
      'Couples',
      Icons.favorite_border_rounded,
      Color(0xFFE7A3FF),
      'For two',
    ),
    _CategoryData(
      'bold',
      'Bold',
      Icons.local_fire_department_rounded,
      Color(0xFFFF8E58),
      'Brave choices',
    ),
    _CategoryData(
      'family',
      'Family',
      Icons.home_rounded,
      Color(0xFF9FE37E),
      'Everyone friendly',
    ),
    _CategoryData(
      '18+',
      '18+',
      Icons.lock_rounded,
      Color(0xFFFF5C8A),
      'Adults only',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GamePage(
      title: 'Pick a vibe',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            const Text(
              'Choose the kind of prompts your group is in the mood for.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.muted),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.14,
                ),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _CategoryCard(
                    category: category,
                    onTap: () => _select(context, category),
                  );
                },
              ),
            ),
            const Text(
              'ALL keeps 18+ prompts off unless you explicitly enable them.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppPalette.muted),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _select(BuildContext context, _CategoryData category) async {
    var allowsMature = false;
    if (category.id == '18+') {
      allowsMature = await _confirmMatureContent(context) ?? false;
      if (!allowsMature || !context.mounted) return;
    }
    if (!context.mounted) return;
    final game = context.read<GameController>();
    game.selectCategory(category.id, allow18Plus: allowsMature);
    if (game.hapticsEnabled) HapticFeedback.selectionClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PlayerModeScreen()));
  }

  Future<bool?> _confirmMatureContent(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adults only'),
        content: const Text(
          'This category is for consenting adults. Keep it respectful, private, and easy to skip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NOT NOW'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('I AM 18+'),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final _CategoryData category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: AppPalette.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: category.color.withValues(alpha: 0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(category.icon, color: category.color, size: 28),
                const Spacer(),
                Text(
                  category.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category.subtitle,
                  style: const TextStyle(fontSize: 11, color: AppPalette.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryData {
  const _CategoryData(
    this.id,
    this.label,
    this.icon,
    this.color,
    this.subtitle,
  );

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String subtitle;
}
