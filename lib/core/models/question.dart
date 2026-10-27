class Question {
  final String id;
  final String type;
  final String category;
  final String intensity;
  final String text;
  final int? timer;
  final String players;
  final String ageRating;
  final bool isCustom;

  Question({
    required this.id,
    required this.type,
    required this.category,
    required this.intensity,
    required this.text,
    this.timer,
    required this.players,
    required this.ageRating,
    this.isCustom = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      intensity: json['intensity'] as String,
      text: json['text'] as String,
      timer: json['timer'] as int?,
      players: json['players'] as String,
      ageRating: json['ageRating'] as String,
      isCustom: json['isCustom'] == 1 || json['isCustom'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'intensity': intensity,
      'text': text,
      'timer': timer,
      'players': players,
      'ageRating': ageRating,
      'isCustom': isCustom ? 1 : 0,
    };
  }
}
