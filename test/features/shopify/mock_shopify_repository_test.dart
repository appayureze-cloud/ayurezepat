import 'package:doctro_patient/features/shopify/data/mock_shopify_repository.dart';
import 'package:doctro_patient/features/shopify/domain/shopify_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockShopifyRepository', () {
    late ShopifyRepository repository;

    setUp(() {
      repository = MockShopifyRepository();
    });

    test('checkAvailability always reports available for a frictionless demo',
        () async {
      final result = await repository.checkAvailability('Ashwagandha');

      expect(result.medicineName, 'Ashwagandha');
      expect(result.isAvailable, isTrue);
    });
  });
}
