import 'astra_card.dart';

/// One SSE event from `POST /astra/sessions/{id}/messages`: either a text
/// chunk to append to the assistant's in-progress reply, or a card to show
/// once it's ready. A stream of these ends when the connection closes.
sealed class AstraReplyEvent {
  const AstraReplyEvent();
}

class AstraTextChunk extends AstraReplyEvent {
  final String text;
  const AstraTextChunk(this.text);
}

class AstraCardEvent extends AstraReplyEvent {
  final AstraCard card;
  const AstraCardEvent(this.card);
}
