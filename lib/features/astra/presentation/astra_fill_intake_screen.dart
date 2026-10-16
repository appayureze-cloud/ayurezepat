import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../data/astra_fill_dtos.dart';
import '../data/astra_fill_service.dart';
import '../data/astra_gateway_client.dart';

enum _Step { describe, confirmTranscript, review, done }

/// Patient-facing structured health intake (Astra Fill) - describe a
/// concern by typing or speaking, Astra extracts the structured fields
/// (primary complaint, duration, severity, timing, prior treatment), you
/// review/correct them, then confirm. This never existed on the patient
/// side before - only the doctor app called Astra Fill.
///
/// Voice goes through the real "voice safety gate" (`transcribe-voice` +
/// `confirm-transcript`, confirmed live - not the deprecated
/// `process-voice`): Phase 1 runs speech-to-text only and returns a raw
/// transcript the patient must confirm or edit; AI extraction only runs
/// after that confirmation, in Phase 2. The `_Step.confirmTranscript`
/// screen below is that required confirmation card.
class AstraFillIntakeScreen extends HookWidget {
  const AstraFillIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = useMemoized(() => AstraFillService());
    final recorder = useMemoized(() => AudioRecorder());
    final step = useState(_Step.describe);
    final loading = useState(false);
    final isRecording = useState(false);
    final error = useState<String?>(null);
    final textController = useTextEditingController();
    final transcriptController = useTextEditingController();
    final extraction = useState<AstraFillExtraction?>(null);
    final intake = useState<HealthIntake?>(null);
    final pendingId = useState<String?>(null);

    useEffect(() {
      return () => recorder.dispose();
    }, const []);

    Future<String?> currentUserId() async {
      final gateway = AstraGatewayClient();
      await gateway.dio(); // populates cachedUserId
      final userId = gateway.cachedUserId;
      return (userId == null || userId.isEmpty) ? null : userId;
    }

    Future<void> extract() async {
      final text = textController.text.trim();
      if (text.isEmpty) return;
      loading.value = true;
      error.value = null;
      try {
        final userId = await currentUserId();
        if (userId == null) throw Exception('Not signed in');
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

    Future<void> startRecording() async {
      error.value = null;
      try {
        if (!await recorder.hasPermission()) {
          error.value = 'Microphone permission is needed to record.';
          return;
        }
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/astra_fill_intake_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await recorder.start(const RecordConfig(), path: path);
        isRecording.value = true;
      } catch (e) {
        logger.e('Failed to start recording: $e');
        error.value = 'Could not start recording. Please try again.';
      }
    }

    Future<void> stopRecordingAndTranscribe() async {
      isRecording.value = false;
      loading.value = true;
      error.value = null;
      try {
        final path = await recorder.stop();
        if (path == null) throw Exception('No recording captured');
        final userId = await currentUserId();
        if (userId == null) throw Exception('Not signed in');
        final pending = await service.transcribeVoice(userId, File(path));
        pendingId.value = pending.pendingId;
        transcriptController.text = pending.rawTranscript;
        step.value = _Step.confirmTranscript;
      } catch (e) {
        logger.e('AstraFill transcribe-voice failed: $e');
        error.value = 'Could not understand that recording. '
            'Please try again or type instead.';
      } finally {
        loading.value = false;
      }
    }

    Future<void> confirmTranscriptAndExtract() async {
      final transcript = transcriptController.text.trim();
      if (transcript.isEmpty || pendingId.value == null) return;
      loading.value = true;
      error.value = null;
      try {
        final userId = await currentUserId();
        if (userId == null) throw Exception('Not signed in');
        final result = await service.confirmTranscript(
          pendingId: pendingId.value!,
          userId: userId,
          confirmedTranscript: transcript,
        );
        extraction.value = result;
        intake.value = result.data;
        step.value = _Step.review;
      } catch (e) {
        logger.e('AstraFill confirm-transcript failed: $e');
        error.value = 'Could not process that. Please try again or type '
            'your concern instead.';
        step.value = _Step.describe;
      } finally {
        loading.value = false;
      }
    }

    Future<void> confirm() async {
      if (extraction.value == null || intake.value == null) return;
      loading.value = true;
      error.value = null;
      try {
        final userId = await currentUserId();
        if (userId == null) throw Exception('Not signed in');
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
                'Type it, or tap the microphone to speak. Include what\'s '
                'bothering you, how long it\'s been going on, and anything '
                'you\'ve already tried.',
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
              Row(
                children: [
                  GestureDetector(
                    onTap: loading.value
                        ? null
                        : () => isRecording.value
                            ? stopRecordingAndTranscribe()
                            : startRecording(),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: isRecording.value
                          ? AppColors.clayAlert
                          : AppColors.sagePrimaryContainer,
                      child: Icon(
                        isRecording.value ? Icons.stop : Icons.mic,
                        color: isRecording.value
                            ? AppColors.clayOnAlert
                            : AppColors.sageOnPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (loading.value || isRecording.value) ? null : extract,
                      child: loading.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Continue'),
                    ),
                  ),
                ],
              ),
              if (isRecording.value)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Recording... tap the microphone to stop.',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.clayAlert)),
                ),
            ],
          ),
        );
        break;
      case _Step.confirmTranscript:
        body = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Is this what you said?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Correct anything the microphone got wrong before '
                'continuing.',
                style: TextStyle(fontSize: 13, color: AppColors.slateTextMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: transcriptController,
                maxLines: 6,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              if (error.value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(error.value!,
                      style: const TextStyle(color: AppColors.clayAlert)),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: loading.value
                          ? null
                          : () => step.value = _Step.describe,
                      child: const Text('Try again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          loading.value ? null : confirmTranscriptAndExtract,
                      child: loading.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Yes, that\'s right'),
                    ),
                  ),
                ],
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
              onChanged: (v) => intake.value = data.copyWith(severityClues: v),
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
            child: loading.value &&
                    (step.value == _Step.describe ||
                        step.value == _Step.confirmTranscript)
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
