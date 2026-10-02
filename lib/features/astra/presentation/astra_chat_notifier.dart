import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../v2/utils/logger.dart';
import '../data/astra_gateway_auth.dart';
import '../data/astra_gateway_notifications.dart';
import '../domain/astra_repository.dart';
import '../domain/entities/astra_card.dart';
import '../domain/entities/astra_message.dart';
import '../domain/entities/astra_reply_event.dart';
import '../domain/entities/astra_session.dart';
import '../domain/red_flag_detector.dart';
import 'astra_localization.dart';
import 'daily_checkin_reminder_scheduler.dart';

/// Drives the Astra chat screen. Every outgoing user message is screened by
/// [RedFlagDetector] before it ever reaches [repository] - a match short
/// circuits straight to a hardcoded [EmergencyCard], no network call, no
/// LLM. That check cannot be removed or made conditional on backend
/// availability: it is the whole point of having it client-side.
class AstraChatNotifier extends ChangeNotifier {
  final AstraRepository repository;
  AstraLocalization loc;

  AstraChatNotifier(this.repository, this.loc);

  AstraSession? _session;
  AstraSession? get session => _session;

  final List<AstraMessage> _messages = [];
  List<AstraMessage> get messages => List.unmodifiable(_messages);

  bool _initializing = true;
  bool get initializing => _initializing;

  bool _sending = false;
  bool get sending => _sending;

  String? _error;
  String? get error => _error;

  int _messageCounter = 0;
  String _nextId() => 'm${_messageCounter++}';

  Future<void> init() async {
    _initializing = true;
    _error = null;
    notifyListeners();
    try {
      _session = await repository.createSession();
      _messages.add(AstraMessage(
        id: _nextId(),
        role: AstraMessageRole.assistant,
        text: _session!.greeting,
      ));
      // Best-effort: a missed daily reminder isn't worth failing the whole
      // session bootstrap over, and the local-notifications plugin isn't
      // available in plain unit tests.
      unawaited(scheduleDailyCheckinReminder().catchError((e) {
        logger.e('Failed to schedule daily check-in reminder: $e');
      }));
      // Best-effort: register this device for the Astra gateway's own
      // push notifications, independent of the main backend.
      final patientId = AstraGatewayAuth().cachedUserId;
      if (patientId != null && patientId.isNotEmpty) {
        unawaited(storeFcmTokenWithGateway(patientId).catchError((e) {
          logger.e('Failed to register FCM token with Astra gateway: $e');
        }));
      }
    } catch (e) {
      logger.e('Astra session init failed: $e');
      _error = "Astra couldn't start right now. Please try again.";
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<void> sendUserMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending || _session == null) return;

    _messages.add(AstraMessage(
      id: _nextId(),
      role: AstraMessageRole.user,
      text: trimmed,
    ));
    notifyListeners();

    final redFlags = RedFlagDetector.detect(trimmed);
    if (redFlags.isNotEmpty) {
      _messages.add(AstraMessage(
        id: _nextId(),
        role: AstraMessageRole.assistant,
        text: '',
        cards: [
          EmergencyCard(
            message: loc.t('astra_emergency_body'),
            redFlags: redFlags.map((f) => f.name).toList(),
          ),
        ],
      ));
      notifyListeners();
      return;
    }

    _sending = true;
    _error = null;
    final replyId = _nextId();
    _messages.add(AstraMessage(
      id: replyId,
      role: AstraMessageRole.assistant,
      text: '',
    ));
    notifyListeners();

    try {
      await for (final event
          in repository.sendMessage(_session!.sessionId, trimmed)) {
        final index = _messages.indexWhere((m) => m.id == replyId);
        if (index == -1) continue;
        final current = _messages[index];
        switch (event) {
          case AstraTextChunk(:final text):
            _messages[index] = current.copyWith(text: current.text + text);
          case AstraCardEvent(:final card):
            _messages[index] =
                current.copyWith(cards: [...current.cards, card]);
        }
        notifyListeners();
      }
    } catch (e) {
      logger.e('Astra sendMessage failed: $e');
      _error = "Astra couldn't reply right now. Please try again.";
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
