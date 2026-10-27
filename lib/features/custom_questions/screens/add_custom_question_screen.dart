import 'package:flutter/material.dart';

import '../../../core/models/question.dart';
import '../../../core/services/database_helper.dart';
import '../../../core/widgets/game_ui.dart';

class AddCustomQuestionScreen extends StatefulWidget {
  const AddCustomQuestionScreen({super.key});

  @override
  State<AddCustomQuestionScreen> createState() =>
      _AddCustomQuestionScreenState();
}

class _AddCustomQuestionScreenState extends State<AddCustomQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  String _type = 'truth';
  String _category = 'funny';
  bool _saving = false;

  static const _categories = <String>[
    'funny',
    'friends',
    'icebreaker',
    'deep',
    'party',
    'romantic',
    'couples',
    'bold',
    '18+',
    'family',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final isMature = _category == '18+';
    final question = Question(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      category: _category,
      intensity: isMature ? 'hard' : 'easy',
      text: _textController.text.trim(),
      players: 'single',
      ageRating: isMature ? '18+' : '13+',
      isCustom: true,
    );

    try {
      await DatabaseHelper.instance.insertQuestion(question);
      if (!mounted) return;
      _textController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom prompt saved for your next game.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save that prompt on this device.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GamePage(
      title: 'Custom prompt',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Make the game yours.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Prompts are saved locally on this device.',
                style: TextStyle(color: AppPalette.muted),
              ),
              const SizedBox(height: 28),
              const Text(
                'Prompt type',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'truth',
                    label: Text('Truth'),
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  ButtonSegment(
                    value: 'dare',
                    label: Text('Dare'),
                    icon: Icon(Icons.local_fire_department_outlined),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) =>
                    setState(() => _type = selection.first),
              ),
              const SizedBox(height: 25),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category == '18+'
                              ? '18+ (adults only)'
                              : category.toUpperCase(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    value == null ? null : setState(() => _category = value),
              ),
              const SizedBox(height: 25),
              const Text(
                'Your prompt',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _textController,
                maxLines: 5,
                maxLength: 280,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Write a kind, fun Truth or Dare...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Write a prompt first.';
                  }
                  if (value.trim().length < 8) {
                    return 'Give players a little more to work with.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              GlassCard(
                padding: const EdgeInsets.all(14),
                color: AppPalette.cyan.withValues(alpha: 0.1),
                child: const Row(
                  children: [
                    Icon(
                      Icons.favorite_outline_rounded,
                      color: AppPalette.cyan,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Keep it safe, consensual, and easy to skip.',
                        style: TextStyle(color: AppPalette.muted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: _saving ? 'SAVING…' : 'SAVE PROMPT',
                icon: Icons.bookmark_add_outlined,
                onPressed: _saving ? null : _saveQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
