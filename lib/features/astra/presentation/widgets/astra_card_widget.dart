import 'package:flutter/material.dart';

import '../../domain/entities/astra_card.dart';
import 'doctor_recommendation_card_widget.dart';
import 'emergency_card_widget.dart';
import 'placeholder_card_widget.dart';
import 'tip_card_widget.dart';

/// Renders whichever concrete [AstraCard] subtype it's given.
class AstraCardWidget extends StatelessWidget {
  final AstraCard card;

  const AstraCardWidget({required this.card, super.key});

  @override
  Widget build(BuildContext context) {
    return switch (card) {
      TipCard c => TipCardWidget(card: c),
      DoctorRecommendationCard c => DoctorRecommendationCardWidget(card: c),
      EmergencyCard c => EmergencyCardWidget(card: c),
      OrderCard c => PlaceholderCardWidget.forOrder(c),
      ReminderCard c => PlaceholderCardWidget.forReminder(c),
    };
  }
}
