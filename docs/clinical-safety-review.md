# Clinical safety review — not yet signed off

**Status: no clinician has reviewed this. Do not launch to real patients
until one has.** This document exists to make that review fast and
complete — everything a reviewer needs is linked or quoted below, so
reviewing this doesn't require reading the app's source.

## What this covers

The one piece of client-side logic that decides, synchronously and before
any network call, whether a patient's message to the Astra companion chat
triggers a hardcoded emergency redirect instead of a normal AI reply.

- Detection: `lib/features/astra/domain/red_flag_detector.dart`
- Routing: `lib/features/astra/presentation/astra_chat_notifier.dart`
  (`sendUserMessage`)
- UI shown: `lib/features/astra/presentation/widgets/emergency_card_widget.dart`
- Tests: `test/features/astra/red_flag_detector_test.dart` (13 cases)

## How it behaves today

1. Every outgoing chat message is checked against a fixed keyword list
   **before** it's sent to the backend/LLM. This is deliberate: no
   network round trip, no model call, no chance of the LLM talking a
   patient out of calling emergency services.
2. If any category matches, the chat **never calls the backend for that
   message**. It immediately shows a fixed card and returns.
3. The card's English copy (`lib/localization/languages/astra_en.json`,
   key `astra_emergency_body`):
   > "What you've described could be a medical emergency. Please call 112
   > (or your local emergency number) or go to the nearest emergency room
   > right now. This is not something Astra can help with in chat."

   Hindi translation exists (`astra_hi.json`); no other languages yet.
4. The card has one button: **"Call 112 now"**, which dials 112 directly
   (`tel:112` via `url_launcher`). 112 is India's unified emergency
   number — correct for this app's current market, but hardcoded, so it
   would need to change (or become locale-aware) before any non-India
   launch.
5. Matching is case-insensitive substring matching, nothing more (no NLP,
   no LLM-assisted interpretation). The code's own comment states the
   design intent explicitly: *"false positives... are an acceptable
   cost; false negatives are not."*

## The full keyword list (verbatim from source)

| Category | Keywords |
|---|---|
| Chest pain | chest pain, chest pressure, chest tightness, pain in my chest, crushing pain |
| Stroke signs | face drooping, facial droop, slurred speech, can't speak, cannot speak properly, one side of my body, sudden numbness, sudden weakness, sudden confusion |
| Breathing difficulty | can't breathe, cannot breathe, difficulty breathing, shortness of breath, gasping for air, choking |
| Suicidal thoughts | kill myself, suicide, suicidal, end my life, want to die, harm myself |
| Heavy bleeding | heavy bleeding, won't stop bleeding, bleeding heavily, blood everywhere, severe blood loss |
| Anaphylaxis | throat closing, throat is closing, tongue swelling, face swelling, swelling of my face, allergic reaction, anaphylaxis, hives and difficulty |
| Seizure | seizure, having a seizure, convulsion, convulsing, fit and unconscious |
| Severe abdominal pain | severe abdominal pain, severe stomach pain, worst stomach pain, unbearable stomach pain, rigid abdomen |
| Pediatric high fever | baby has a high fever, infant has a high fever, baby won't wake up, baby is unresponsive, infant is unresponsive, baby is limp |

## What a reviewer should actually judge

1. **Coverage**: are there other textbook emergency presentations missing
   (e.g. overdose/poisoning, severe head injury, diabetic emergency
   signs)? The current nine categories were drafted against standard
   triage red flags, not against this product's actual user base or
   presenting complaints.
2. **Phrasing**: do these keyword phrasings actually match how real
   patients describe these symptoms in this population (including code-
   switched Hindi/English, which the detector does NOT currently handle -
   it only matches English phrases, even though the chat itself supports
   Hindi).
3. **False-negative risk from substring matching**: e.g. "my chest doesn't
   hurt but I'm worried about chest pain in general" would still match
   `chest pain` and route to the emergency card (an acceptable false
   positive per the design intent above) - the real question is whether
   there's a realistic true emergency phrasing this list would miss.
4. **The suicidal-thoughts category specifically** deserves its own
   review against established crisis-line protocols (e.g. whether "Call
   112" is the right routing vs. a dedicated crisis line number, and
   whether the message copy is appropriate for that specific category
   rather than generic emergency copy).
5. **112 as the only number offered** - confirm this is acceptable for
   every region the app will actually be used in.

## What is NOT in scope of this document

This only covers the *client-side, pre-send* gate. The backend's own
`POST /astra/cases/{id}/triage` (Astra's safety middleware, confirmed to
exist server-side) is a second, independent screening layer with more
context, but it runs *after* a message reaches the backend - it cannot be
the only safeguard, which is exactly why the client-side gate above
exists as a synchronous first line. This document does not assess that
backend layer's logic, since its source isn't available to this client
codebase.
