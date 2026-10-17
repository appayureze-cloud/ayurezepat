import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../theme.dart';

/// Matches the Stitch Splash screen's motion spec
/// (docs/stitch-ui-master-prompt.md): the leaf motif breathes in, the
/// wordmark fades/rises into place, then a thin progress underline fills
/// while the app initializes.
class SplashScreen extends HookWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    final leafScale = useMemoized(
        () => Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOut,
            )),
        [controller]);
    final wordmarkOpacity = useMemoized(
        () => Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: controller,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
            )),
        [controller]);
    final wordmarkOffset = useMemoized(
        () => Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
                .animate(CurvedAnimation(
              parent: controller,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
            )),
        [controller]);

    void checkUserLoginStatus() async {
      controller.forward();
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!context.mounted) return;
      if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
        Navigator.pushReplacementNamed(context, "Home");
      } else if (!SharedPreferenceHelper.getBoolean(
          Preferences.has_seen_onboarding)) {
        Navigator.pushReplacementNamed(context, "Onboarding");
      } else {
        Navigator.pushReplacementNamed(context, "SignIn");
      }
    }

    useEffect(() {
      checkUserLoginStatus();
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: leafScale,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.sagePrimaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.spa,
                    size: 48, color: AppColors.sagePrimary),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: wordmarkOpacity,
              child: SlideTransition(
                position: wordmarkOffset,
                child: Text('AyurEze',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: AppColors.sagePrimary)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 120,
              height: 3,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) => ClipRRect(
                  borderRadius: AppRadius.roundedPill,
                  child: LinearProgressIndicator(
                    value: controller.value,
                    backgroundColor: AppColors.slateBorderSubtle,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.sagePrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
