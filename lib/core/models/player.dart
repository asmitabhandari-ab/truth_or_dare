class Player {
  Player({
    required this.id,
    required this.name,
    required this.avatar,
    this.score = 0,
    this.completed = 0,
    this.skipped = 0,
  });

  final String id;
  final String name;
  final String avatar;
  int score;
  int completed;
  int skipped;
}
