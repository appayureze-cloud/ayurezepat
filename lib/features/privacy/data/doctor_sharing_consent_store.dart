import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/doctor_sharing_consent.dart';

/// Local store for [DoctorSharingConsent] rows, one per doctor the patient
/// has set a preference for. See DoctorSharingConsent's doc comment for why
/// this is local-only.
class DoctorSharingConsentStore {
  DoctorSharingConsentStore._();

  static const _key = 'doctor_sharing_consents';

  static Future<List<DoctorSharingConsent>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final consents = <DoctorSharingConsent>[];
    for (final item in raw) {
      try {
        consents.add(DoctorSharingConsent.fromJson(jsonDecode(item)));
      } catch (_) {
        // Skip malformed entries.
      }
    }
    return consents;
  }

  static Future<DoctorSharingConsent?> getFor(String doctorId) async {
    final all = await getAll();
    for (final c in all) {
      if (c.doctorId == doctorId) return c;
    }
    return null;
  }

  /// Defaults a newly-seen doctor to [shareFullRecord]=true (matches this
  /// app's existing behavior before this feature existed - a doctor you've
  /// booked with already sees your consultation/prescription history, so
  /// "off by default" would silently change existing behavior) - this
  /// screen is for actively opting a specific doctor out, not opting in.
  static Future<void> setFor(
    String doctorId,
    String doctorName,
    bool shareFullRecord,
  ) async {
    final all = await getAll();
    final withoutThisDoctor = all.where((c) => c.doctorId != doctorId).toList();
    withoutThisDoctor.add(DoctorSharingConsent(
      doctorId: doctorId,
      doctorName: doctorName,
      shareFullRecord: shareFullRecord,
      updatedAt: DateTime.now().toIso8601String(),
    ));
    await _save(withoutThisDoctor);
  }

  static Future<void> _save(List<DoctorSharingConsent> consents) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, consents.map((c) => jsonEncode(c.toJson())).toList());
  }
}
