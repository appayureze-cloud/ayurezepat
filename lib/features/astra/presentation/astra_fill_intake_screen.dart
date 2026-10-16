import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../data/astra_fill_dtos.dart';
import '../data/astra_fill_service.dart';
import '../data/astra_gateway_client.dart';

enum _Step { describe, review, done }

/// Patient-facing structured health intake (Astra Fill) - describe a
/// concern in your own words, Astra extracts the structured fields
/// (primary complaint, duration, severity, timing, prior treatment), you
/// review/correct them, then confirm. This never existed on the patient
/// side before - only the doctor app called Astra Fill. Text-only for
/// now: `process-voice` is marked deprecated in the live OpenAPI spec (in
/// favour of a separate transcribe-voice + confirm-transcript flow not
/// built here yet).
class AstraFillIntakeScreen extends HookWidget {
  const AstraFillIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = useMemoized(() => AstraFillService());
    final step = useState(_Step.describe);
    final loading = useState(false);
    final error = useState<String?>(null);
    final textController = useTextEditingController();
    final extraction = useState<AstraFillExtraction?>(null);
    final intake = useState<HealthIntake?>(null);

    Future<void> extract() async {
      final text = textController.text.trim();
      if (text.isEmpty) return;
      loading.value = true;
      error.value = null;
      try {
        final gateway = AstraGatewayClient();
        await gateway.dio(); // populates cachedUserId
        final userId = gateway.cachedUserId;
        if (userId == null || userId.isEmpty) {
          throw Exception('Not signed in');
        }
        final result = await service.processText(userId, text);
        extraction.value = result;
        intake.value = result.data;
        step.value = _Step.review;
      } catch (e) {
        logger.e('AstraFill process-text failed: $e');
        error.value = 'Could not process that. Please try again.';
      } finally {
        loading.value = false;
      }
    }

    Future<void> confirm() async {
      if (extraction.value == null || intake.value == null) return;
      loading.value = true;
      error.value = null;
      try {
        final gateway = AstraGatewayClient();
        await gateway.dio();
        final userId = gateway.cachedUserId;
        if (userId == null || userId.isEmpty) {
          throw Exception('Not signed in');
        }
        await service.confirm(
          userId: userId,
          extractionId: extraction.value!.extractionId,
          confirmedData: intake.value!,
        );
        step.value = _Step.done;
        Fluttertoast.showToast(msg: 'Health details saved');
      } catch (e) {
        logger.e('AstraFill confirm failed: $e');
        error.value = 'Could not save your confirmation. Please try again.';
      } finally {
        loading.value = false;
      }
    }

    Widget body;
    switch (step.value) {
      case _Step.describe:
        body = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Describe what you\'re experiencing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'In your own words: what\'s bothering you, how long it\'s '
                'been going on, and anything you\'ve already tried.',
                style: TextStyle(fontSize: 13, color: AppColors.slateTextMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'e.g. I\'ve had a mild headache and fatigue for '
                      'about 3 days, worse in the evenings...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (error.value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(error.value!,
                      style: const TextStyle(color: AppColors.clayAlert)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading.value ? null : extract,
                  child: loading.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        );
        break;
      case _Step.review:
        final data = intake.value!;
        body = ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Review what Astra understood',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Correct anything that\'s wrong before confirming.',
              style: TextStyle(fontSize: 13, color: AppColors.slateTextMuted),
            ),
            const SizedBox(height: 16),
            _ReviewField(
              label: 'Primary complaint',
              value: data.primaryComplaint,
              onChanged: (v) =>
                  intake.value = data.copyWith(primaryComplaint: v),
            ),
            _ReviewField(
              label: 'Duration',
              value: data.duration,
              onChanged: (v) => intake.value = data.copyWith(duration: v),
            ),
            _ReviewField(
              label: 'Severity',
              value: data.severityClues,
              onChanged: (v) =>
                  intake.value = data.copyWith(severityClues: v),
            ),
            _ReviewField(
              label: 'Pattern / timing',
              value: data.patternOrTiming,
              onChanged: (v) =>
                  intake.value = data.copyWith(patternOrTiming: v),
            ),
            _ReviewField(
              label: 'Previous treatment tried',
              value: data.previousTreatment,
              onChanged: (v) =>
                  intake.value = data.copyWith(previousTreatment: v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('This is a follow-up to a previous issue'),
              value: data.isFollowUp,
              onChanged: (v) => intake.value = data.copyWith(isFollowUp: v),
            ),
            const SizedBox(height: 16),
            if (error.value != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(error.value!,
                    style: const TextStyle(color: AppColors.clayAlert)),
              ),
            ElevatedButton(
              onPressed: loading.value ? null : confirm,
              child: loading.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Confirm and save'),
            ),
          ],
        );
        break;
      case _Step.done:
        body = const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 56, color: AppColors.sagePrimary),
                SizedBox(height: 14),
                Text('Your health details have been saved.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        );
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Health Intake'),
          Expanded(
            child: loading.value && step.value == _Step.describe
                ? const Center(
                    child: SpinKitFadingCircle(
                        color: AppColors.sagePrimary, size: 36),
                  )
                : body,
          ),
        ],
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _ReviewField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
