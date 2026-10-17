// lib/theme.dart
//
// AyurEze Patient App — "Serene Herbalist" modern calm healthcare design
// system, generated from the Google Stitch UI master prompt
// (docs/stitch-ui-master-prompt.md) and adapted to this codebase: Inter
// and Newsreader are loaded via google_fonts at runtime instead of
// bundling font assets, since no font files shipped with the Stitch
// export. See docs/stitch-ui-master-prompt.md for the design brief this
// implements.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// 1. RAW COLOR PALETTE CONSTANTS
// ============================================================================

abstract class AppColors {
  // Brand & Semantic Primary (Sage / Forest Green)
  static const Color sagePrimary = Color(0xFF3F6F5A);
  static const Color sageOnPrimary = Color(0xFFFFFFFF);
  static const Color sagePrimaryContainer = Color(0xFFC0EAD6);
  static const Color sageOnPrimaryContainer = Color(0xFF002116);
  static const Color sagePrimarySubtle = Color(0xFFE8F5EE);

  // Secondary Highlights & Attention (Turmeric Gold / Warm Terracotta)
  static const Color terracottaSecondary = Color(0xFFC98A3E);
  static const Color terracottaOnSecondary = Color(0xFFFFFFFF);
  static const Color terracottaContainer = Color(0xFFFFDDB8);
  static const Color terracottaOnContainer = Color(0xFF2B1700);

  // Gentle Alerts / Urgent Care Triage (Clay / Warm Amber / Red-Flag)
  static const Color clayAlert = Color(0xFFBA1A1A);
  static const Color clayAlertContainer = Color(0xFFFFDAD6);
  static const Color clayOnAlert = Color(0xFFFFFFFF);
  static const Color clayOnAlertContainer = Color(0xFF410002);
  static const Color amberWarning = Color(0xFFD97706);
  static const Color amberWarningContainer = Color(0xFFFEF3C7);

  // Success / Adherence (Botanical Leaf Green)
  static const Color adherenceSuccess = Color(0xFF2E7D32);
  static const Color adherenceSuccessContainer = Color(0xFFD7F0D8);

  // Surfaces & Backgrounds (Warm Cream & Serene Neutrals)
  static const Color creamSurface = Color(0xFFFBF9F4);
  static const Color creamSurfaceBright = Color(0xFFFBF9F4);
  static const Color creamSurfaceDim = Color(0xFFDCE5DD);
  static const Color creamSurfaceLow = Color(0xFFF1F7F2);
  static const Color creamSurfaceLowest = Color(0xFFFFFFFF);
  static const Color creamSurfaceHigh = Color(0xFFE4EDE5);
  static const Color creamSurfaceHighest = Color(0xFFDAE5DC);

  // Text & Content Slates (Never Pure Black)
  static const Color slateTextPrimary = Color(0xFF1B231F);
  static const Color slateTextSecondary = Color(0xFF4A5568);
  static const Color slateTextMuted = Color(0xFF718096);
  static const Color slateBorder = Color(0xFFDDE5DF);
  static const Color slateBorderSubtle = Color(0xFFEFF4F0);

  // Circadian Dark Mode Palettes (Calm Night Sanctuary)
  static const Color darkBackground = Color(0xFF131A16);
  static const Color darkSurface = Color(0xFF18221D);
  static const Color darkSurfaceContainer = Color(0xFF1E2B24);
  static const Color darkSurfaceHigh = Color(0xFF24332B);
  static const Color darkTextPrimary = Color(0xFFE6EFE9);
  static const Color darkTextSecondary = Color(0xFFA5B4AB);
  static const Color darkPrimary = Color(0xFF76BA9B);
  static const Color darkPrimaryContainer = Color(0xFF234C3C);
}

// ============================================================================
// 2. SHAPE & CORNER RADIUS TOKENS (16-24px Soft Health Language)
// ============================================================================

abstract class AppRadius {
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double pill = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedPill =
      BorderRadius.all(Radius.circular(pill));

  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: roundedMd,
    side: const BorderSide(color: AppColors.slateBorder, width: 0.8),
  );

  static const RoundedRectangleBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(xl)),
  );
}

// ============================================================================
// 3. ELEVATION & SHADOW TOKENS (Soft, Diffuse, Non-Jarring)
// ============================================================================

abstract class AppShadows {
  static const List<BoxShadow> subtleCard = [
    BoxShadow(
      color: Color(0x081B231F),
      blurRadius: 12.0,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> floatingNav = [
    BoxShadow(
      color: Color(0x0C1B231F),
      blurRadius: 20.0,
      offset: Offset(0, -4),
    ),
  ];

  static const List<BoxShadow> activePill = [
    BoxShadow(
      color: Color(0x203F6F5A),
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
  ];
}

// ============================================================================
// 4. CUSTOM THEME EXTENSION: AYUSH & CLINICAL METRICS
// ============================================================================

class AyurEzeColorsExtension extends ThemeExtension<AyurEzeColorsExtension> {
  final Color vataTone;
  final Color pittaTone;
  final Color kaphaTone;
  final Color agniActive;
  final Color quietHoursBanner;
  final Color verifiedBadge;

  const AyurEzeColorsExtension({
    required this.vataTone,
    required this.pittaTone,
    required this.kaphaTone,
    required this.agniActive,
    required this.quietHoursBanner,
    required this.verifiedBadge,
  });

  @override
  AyurEzeColorsExtension copyWith({
    Color? vataTone,
    Color? pittaTone,
    Color? kaphaTone,
    Color? agniActive,
    Color? quietHoursBanner,
    Color? verifiedBadge,
  }) {
    return AyurEzeColorsExtension(
      vataTone: vataTone ?? this.vataTone,
      pittaTone: pittaTone ?? this.pittaTone,
      kaphaTone: kaphaTone ?? this.kaphaTone,
      agniActive: agniActive ?? this.agniActive,
      quietHoursBanner: quietHoursBanner ?? this.quietHoursBanner,
      verifiedBadge: verifiedBadge ?? this.verifiedBadge,
    );
  }

  @override
  AyurEzeColorsExtension lerp(
    ThemeExtension<AyurEzeColorsExtension>? other,
    double t,
  ) {
    if (other is! AyurEzeColorsExtension) return this;
    return AyurEzeColorsExtension(
      vataTone: Color.lerp(vataTone, other.vataTone, t)!,
      pittaTone: Color.lerp(pittaTone, other.pittaTone, t)!,
      kaphaTone: Color.lerp(kaphaTone, other.kaphaTone, t)!,
      agniActive: Color.lerp(agniActive, other.agniActive, t)!,
      quietHoursBanner:
          Color.lerp(quietHoursBanner, other.quietHoursBanner, t)!,
      verifiedBadge: Color.lerp(verifiedBadge, other.verifiedBadge, t)!,
    );
  }

  static const light = AyurEzeColorsExtension(
    vataTone: Color(0xFF6B7280),
    pittaTone: Color(0xFFC98A3E),
    kaphaTone: Color(0xFF3F6F5A),
    agniActive: Color(0xFFE2725B),
    quietHoursBanner: Color(0xFFEBF3EE),
    verifiedBadge: Color(0xFF2E7D32),
  );

  static const dark = AyurEzeColorsExtension(
    vataTone: Color(0xFF9CA3AF),
    pittaTone: Color(0xFFE5A659),
    kaphaTone: Color(0xFF5BA487),
    agniActive: Color(0xFFF08C78),
    quietHoursBanner: Color(0xFF1E2B24),
    verifiedBadge: Color(0xFF4CAF50),
  );
}

// ============================================================================
// 5. TYPOGRAPHY HIERARCHY (Newsreader Serif + Inter Sans, via google_fonts)
// ============================================================================

abstract class AppTypography {
  static TextTheme textTheme(Color textColor, Color mutedColor) {
    final base = TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        height: 1.32,
        color: textColor,
      ),
    );
    final sansBase = TextTheme(
      headlineMedium: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: mutedColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: mutedColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: mutedColor,
      ),
    );

    // Newsreader for large greeting/display headlines, Inter for everything
    // else - matches the style brief ("a slightly warmer serif ... allowed
    // only for large greeting headlines").
    return GoogleFonts.interTextTheme(sansBase).merge(
      GoogleFonts.newsreaderTextTheme(base),
    );
  }
}

// ============================================================================
// 6. MAIN THEME DEFINITION BUILDER
// ============================================================================

class AppTheme {
  // --------------------------------------------------------------------------
  // Light Theme (Official Serene Herbalist Spec) - the only theme wired up
  // for now; dark mode is left for a later pass (see
  // docs/stitch-ui-master-prompt.md, Language & App Preferences screen,
  // which intentionally keeps Light as the only real option today).
  // --------------------------------------------------------------------------
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.sagePrimary,
      onPrimary: AppColors.sageOnPrimary,
      primaryContainer: AppColors.sagePrimaryContainer,
      onPrimaryContainer: AppColors.sageOnPrimaryContainer,
      secondary: AppColors.terracottaSecondary,
      onSecondary: AppColors.terracottaOnSecondary,
      secondaryContainer: AppColors.terracottaContainer,
      onSecondaryContainer: AppColors.terracottaOnContainer,
      error: AppColors.clayAlert,
      onError: AppColors.clayOnAlert,
      errorContainer: AppColors.clayAlertContainer,
      onErrorContainer: AppColors.clayOnAlertContainer,
      surface: AppColors.creamSurface,
      onSurface: AppColors.slateTextPrimary,
      surfaceContainerLowest: AppColors.creamSurfaceLowest,
      surfaceContainerLow: AppColors.creamSurfaceLow,
      surfaceContainer: AppColors.creamSurface,
      surfaceContainerHigh: AppColors.creamSurfaceHigh,
      surfaceContainerHighest: AppColors.creamSurfaceHighest,
      onSurfaceVariant: AppColors.slateTextSecondary,
      outline: AppColors.slateBorder,
      outlineVariant: AppColors.slateBorderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.creamSurface,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: AppTypography.textTheme(
        AppColors.slateTextPrimary,
        AppColors.slateTextSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.creamSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.sagePrimary),
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.slateTextPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.creamSurfaceLowest,
        elevation: 0,
        shape: AppRadius.cardShape,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.sagePrimary,
          foregroundColor: AppColors.sageOnPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sagePrimary,
          side: const BorderSide(color: AppColors.slateBorder, width: 1.2),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sagePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamSurfaceLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.slateBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.slateBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide:
              const BorderSide(color: AppColors.sagePrimary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.clayAlert, width: 1.2),
        ),
        hintStyle:
            const TextStyle(color: AppColors.slateTextMuted, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.creamSurfaceLow,
        disabledColor: AppColors.creamSurfaceDim,
        selectedColor: AppColors.sagePrimary,
        secondarySelectedColor: AppColors.terracottaSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.slateTextPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.sageOnPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.slateBorder, width: 0.8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.creamSurfaceLowest,
        elevation: 8,
        selectedItemColor: AppColors.sagePrimary,
        unselectedItemColor: AppColors.slateTextSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.slateBorderSubtle,
        thickness: 1.0,
        space: 24,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _CalmFadeSlidePageTransitionsBuilder(),
          TargetPlatform.iOS: _CalmFadeSlidePageTransitionsBuilder(),
        },
      ),
      extensions: const [AyurEzeColorsExtension.light],
    );
  }
}

/// Gentle fade + 4%-nudge slide, replacing the OS default slide/pop so
/// every existing Navigator.push/named route keeps the "Serene Herbalist"
/// calm motion feel without any per-screen navigation changes. See
/// docs/stitch-ui-master-prompt.md's motion-feel brief.
class _CalmFadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _CalmFadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0.0),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }
}
