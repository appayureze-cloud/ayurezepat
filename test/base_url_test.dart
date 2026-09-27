import 'package:doctro_patient/api/apis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Apis.baseUrl points at the production API over HTTPS', () {
    final pattern = RegExp(r'^https://.*/api/$');
    expect(
      pattern.hasMatch(Apis.baseUrl),
      isTrue,
      reason:
          'Apis.baseUrl must be an HTTPS URL ending in /api/, got: ${Apis.baseUrl}',
    );
  });
}
