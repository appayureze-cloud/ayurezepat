import 'package:doctro_patient/const/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google Maps key has no hardcoded fallback baked into the client', () {
    // Regression guard for the hardcoded-API-key finding from the Phase 0
    // security audit: Env.googleMapsApiKey must only ever come from
    // --dart-define, never from a string literal default.
    expect(Env.googleMapsApiKey, isEmpty);
  });
}
