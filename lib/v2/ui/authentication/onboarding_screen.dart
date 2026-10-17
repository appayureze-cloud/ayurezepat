import 'package:flutter/material.dart';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../theme.dart';

class _OnboardingSlide {
  final IconData icon;
  final String headline;
  final String body;

  const _OnboardingSlide(
      {required this.icon, required this.headline, required this.body});
}

const _slides = [
  _OnboardingSlide(
    icon: Icons.spa_outlined,
    headline: 'Your Ayurvedic care,\nin your pocket',
    body:
        'Talk to Astra, our AI health companion, and get guidance rooted in classical Ayurvedic practice.',
  ),
  _OnboardingSlide(
    icon: Icons.medical_services_outlined,
    headline: 'Book verified\nAyurvedic doctors',
    body:
        'Find and consult certified Vaidyas by video, right from the app, whenever you need them.',
  ),
  _OnboardingSlide(
    icon: Icons.medication_outlined,
    headline: 'Never miss\na dose',
    body:
        'Keep your prescriptions, reminders, and health records together in one calm place.',
  ),
];

/// Matches the Stitch Onboarding screen (ayureze_onboarding/code.html):
/// 3 calm full-bleed slides with a page-dot indicator and skip/next
/// controls. Shown once, on first launch, before Sign in / Sign up.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _finish() {
    SharedPreferenceHelper.setBoolean(Preferences.has_seen_onboarding, true);
    Navigator.pushReplacementNamed(context, 'SignIn');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: AppColors.sagePrimaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(slide.icon,
                              size: 64, color: AppColors.sagePrimary),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide.headline,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppColors.sagePrimary
                        : AppColors.slateBorder,
                    borderRadius: AppRadius.roundedPill,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_page == _slides.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: Text(
                      _page == _slides.length - 1 ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
