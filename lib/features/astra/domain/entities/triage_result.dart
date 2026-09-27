enum TriageRoute { tips, doctor, emergency }

class TriageResult {
  final TriageRoute route;
  final String? specialty;
  final List<String> redFlags;

  const TriageResult({
    required this.route,
    this.specialty,
    this.redFlags = const [],
  });
}
