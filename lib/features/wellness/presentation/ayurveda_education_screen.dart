import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../data/ayurveda_education_content.dart';
import '../domain/entities/ayurveda_article.dart';

const _kSafetyNote =
    'General wellness information, not medical advice. It does not '
    'replace guidance from your doctor, and is not reviewed for any '
    'specific health condition.';

/// Static, bundled Ayurveda lifestyle content. No backend content API
/// exists, so this list is fixed in the app itself - see
/// ayurveda_education_content.dart.
class AyurvedaEducationScreen extends StatelessWidget {
  const AyurvedaEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Ayurveda basics'),
          Container(
            width: double.infinity,
            color: AppColors.sagePrimarySubtle,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              _kSafetyNote,
              style:
                  TextStyle(fontSize: 12, color: AppColors.slateTextSecondary),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: kAyurvedaArticles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final article = kAyurvedaArticles[index];
                return Card(
                  child: ListTile(
                    title: Text(article.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(article.summary),
                    trailing: Chip(
                      label: Text(article.category,
                          style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.sagePrimarySubtle,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            _AyurvedaArticleScreen(article: article),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AyurvedaArticleScreen extends StatelessWidget {
  final AyurvedaArticle article;

  const _AyurvedaArticleScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          Header_v2(title: article.category),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(article.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                Text(article.body,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.creamSurfaceLow,
                    borderRadius: AppRadius.roundedMd,
                  ),
                  child: const Text(
                    _kSafetyNote,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.slateTextMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
