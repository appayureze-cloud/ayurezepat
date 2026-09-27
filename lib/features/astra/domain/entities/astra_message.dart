import 'astra_card.dart';

enum AstraMessageRole { user, assistant }

class AstraMessage {
  final String id;
  final AstraMessageRole role;
  final String text;
  final List<AstraCard> cards;
  final DateTime createdAt;

  AstraMessage({
    required this.id,
    required this.role,
    required this.text,
    DateTime? createdAt,
    this.cards = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  AstraMessage copyWith({String? text, List<AstraCard>? cards}) => AstraMessage(
        id: id,
        role: role,
        text: text ?? this.text,
        createdAt: createdAt,
        cards: cards ?? this.cards,
      );
}
