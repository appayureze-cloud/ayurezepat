import '../../../model/v2/prescription_response.dart';
import 'entities/prescription_item.dart';

/// Resolves the structured items to show for a prescription. The backend
/// doesn't populate `Prescription.items` yet (see
/// docs/backend/prescriptions.md) - until it does, [Env.useMockPrescriptionItems]
/// (default on) shows canned demo items instead of an empty screen.
abstract class PrescriptionItemsSource {
  List<PrescriptionItem> itemsFor(Prescription prescription);
}

class RealPrescriptionItemsSource implements PrescriptionItemsSource {
  @override
  List<PrescriptionItem> itemsFor(Prescription prescription) =>
      prescription.items ?? const [];
}

class MockPrescriptionItemsSource implements PrescriptionItemsSource {
  @override
  List<PrescriptionItem> itemsFor(Prescription prescription) {
    if (prescription.items != null && prescription.items!.isNotEmpty) {
      return prescription.items!;
    }
    return const [
      PrescriptionItem(
        name: 'Paracetamol 500mg',
        dose: '1 tablet',
        frequency: 'Twice daily',
        durationDays: 5,
        timing: 'After food',
        instructions: 'Stop if fever resolves before 5 days.',
      ),
      PrescriptionItem(
        name: 'Ashwagandha Churna',
        dose: '1 teaspoon',
        frequency: 'Once daily',
        durationDays: 14,
        timing: 'Morning, with warm milk',
      ),
    ];
  }
}
