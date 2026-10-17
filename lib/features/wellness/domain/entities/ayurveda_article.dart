/// A single piece of general Ayurveda educational content. All content is
/// static, bundled with the app (see ayurveda_education_content.dart) -
/// there is no backend content API. [safetyNote] is shown on every detail
/// page so this is never mistaken for clinician-approved advice.
class AyurvedaArticle {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String body;

  const AyurvedaArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
  });
}
