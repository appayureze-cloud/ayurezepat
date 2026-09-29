# Launch checklist

Findings from a Phase 4 audit of the client for pre-launch gaps. Items are
either fixed in this pass, or flagged here because they need a decision,
device testing, or backend work this client can't do on its own.

## Fixed in this pass

- **Crash reporting.** Added `firebase_crashlytics`, wired in `main.dart`:
  `FlutterError.onError` and `PlatformDispatcher.instance.onError` both
  report to Crashlytics, collection is disabled in debug builds
  (`setCrashlyticsCollectionEnabled(!kDebugMode)`) so local dev noise never
  reaches the dashboard. Before this, a crash in production had no signal
  beyond a user complaint.
- **Case closure flow** (see the Phase 4 commit) was silently broken in
  mock mode - `MockCaseRepository` always reported `CaseStatus.open`
  regardless of what happened to a case, so resolving one had no visible
  effect. Fixed as part of wiring up the closure screen.

## Needs a real device/emulator build to verify (can't be done in this
   sandboxed container - no Android SDK/emulator)

- **ProGuard/R8 is off for release** (`minifyEnabled false`,
  `shrinkResources false` in `android/app/build.gradle`). This means a
  larger APK and no code obfuscation. `proguard-rules.pro` already has
  rules for Flutter, Retrofit/Gson/OkHttp, Razorpay, Google Play Services
  and Play Core, so turning minification on is plausible, but should only
  be flipped after a full release-mode build + smoke test on a real
  device/emulator (reflection-heavy plugins like Firebase and
  flutter_local_notifications are exactly the kind of thing R8 silently
  breaks if a rule is missing). Don't flip this from source alone.
- **Crashlytics NDK/native crash reporting** and the Firebase Crashlytics
  Gradle plugin (`com.google.firebase.crashlytics`) may need to be added
  to `android/build.gradle`/`android/app/build.gradle` for full native
  crash symbolication - the Dart-level wiring in `main.dart` covers Flutter
  errors either way, but verify the Gradle plugin is applied when this is
  next built for release.

## Backend must ship before flipping (all already documented per-feature)

Every `Env.useMockX` flag defaults to `true` (mock) so the app demos fully
without a backend. Each has its contract written up; flip to `false` via
`--dart-define` only once the matching backend endpoint exists and has been
tested against this client:

| Flag | Doc |
|---|---|
| `useMockPayments` | `docs/backend/payments.md` |
| `useMockCases` | `docs/backend/case.md` |
| `useMockAstra` | `docs/backend/astra.md` |
| `useMockPrescriptionItems` | `docs/backend/prescriptions.md` |
| `useMockSmartOrders` | `docs/backend/smart-orders.md` |
| `useMockHealthRecords` | `docs/backend/health-records.md` |
| `useMockWhatsappConsent` | `docs/backend/whatsapp.md` |

**`useMockCases` and `useMockAstra` are independent flags but the case
closure flow (Phase 4) assumes they agree** - see the comment in
`lib/features/case/data/mock_case_repository.dart`. If the backend ships
Astra before Cases (or vice versa), re-verify the closure flow doesn't
silently desync.

## Needs a business/clinical decision, not code

- **Doctor review of Astra's red-flag/emergency content** (Phase 1) is
  still outstanding - this is a clinical sign-off, not something fixable
  from the client. See `lib/features/astra/domain/red_flag_detector.dart`.
- **Store listing content** (screenshots, description, privacy policy URL,
  data-safety form answers). The app already links to in-app About/Terms/
  Privacy pages (`HtmlContentPage` with `apiKey: 'about'` /
  `'terms_and_conditions'` / `'privacy_policy'` in `profile.dart`) - that
  content is backend-managed HTML this client just renders, so someone
  needs to confirm it's current (and mentions Astra, WhatsApp messaging,
  and the health data this app now collects) before store submission.
- **WhatsApp BSP contract** (`docs/backend/whatsapp.md`) needs an actual
  BSP account (Gupshup/Twilio/360dialog/etc.) provisioned and approved
  message templates before the backend can send anything - this is a
  vendor/business setup step outside the codebase.

## Confirmed clean (no action needed)

- No stray `print()` calls in `lib/` - logging goes through
  `lib/v2/utils/logger.dart`, which is already disabled in release builds
  (`kReleaseMode ? Level.off : Level.debug`).
- No TLS-bypass / cleartext-traffic / bad-certificate-callback code
  remaining (removed in Phase 0, re-verified here).
- No hardcoded secrets, API keys, or the release keystore/`key.properties`
  in the repo (re-ran the secret scan used throughout this project).
- `applicationId`, `minSdkVersion` (24) and `targetSdkVersion`/
  `compileSdkVersion` (36) in `android/app/build.gradle` are current.
- Only one pre-existing `TODO` in the whole `lib/` tree
  (`lib/v2/ui/widgets/payment_card.dart:30`, a cosmetic icon swap,
  unrelated to this work).
