import 'entities/medicine_availability.dart';

abstract class ShopifyRepository {
  Future<MedicineAvailability> checkAvailability(String medicineName);
}
