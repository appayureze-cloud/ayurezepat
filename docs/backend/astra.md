# Astra: AI health assistant

The client is fully written against the contract documented below
(`lib/features/astra/{domain,data,presentation}`), mocked by default via
`Env.useMockAstra`. The LLM itself lives only on the backend - the client
never calls an LLM provider directly and never carries an LLM API key
(`google_generative_ai` is not used by the client for this reason; keep it
that way even once these endpoints ship).

## Update: a real Astra backend exists, at a different host and contract

A Phase 4 connectivity audit found that a real, live "Astra AI Unified
Engine" backend is already deployed at **`https://astra.ayureze.in`**
(confirmed via its published OpenAPI spec at
`https://astra.ayureze.in/openapi.json`, 138 endpoints) - a **separate host
and separate auth domain** from `Apis.baseUrl` (`ayureze.org`, the main app
backend). Everything below this note describes the contract this client was
originally written against, which does **not** match that real backend.

What's now wired to the real, confirmed contract (see
`lib/features/astra/data/astra_gateway_*.dart` and
`AstraRepositoryImpl`'s class doc comment):

- **Auth**: `POST /api/v1/auth/session` exchanges a Firebase ID token (the
  same FirebaseAuth session `RetroApi` already uses for the main backend)
  for an Astra-gateway JWT + refresh token. Cached locally
  (`Preferences.astraGateway*`) and refreshed via `POST /api/v1/auth/refresh`
  on a 401, mirroring `RetroApi.dioData`'s pattern for the main backend.
- **`createSession`** → `POST /api/companion/journey/start` (the "AI
  Wellness Companion" API's journey model maps onto this client's
  session/case concept). Requires `user_id` (from the exchanged JWT's
  `patient_id`) and `health_concern` - this client doesn't collect a concern
  upfront, so it starts a generic journey and expects the patient's first
  chat message to state it. Worth revisiting once real conversations show
  whether that's good enough.
- **`sendMessage`** → `POST /api/companion/chat`. Not streaming (the
  original SSE contract below was never real) - the real API returns one
  full response per call, wrapped here as a single-chunk stream to keep the
  existing `Stream<AstraReplyEvent>` interface. Its `intervention_type`
  field is logged but not acted on: the safety gate remains the client-side
  `RedFlagDetector`, unconditionally, regardless of what this field means.
- **`resolveCase`** → `PUT /api/companion/journey/{id}/status?status=resolved`
  (query params, not a JSON body).

What's **not** wired - either unused by any screen today, or the real
gateway has no confirmed match (see per-method doc comments in
`AstraRepositoryImpl` for the closest real candidate found): `getSession`,
`triage`, `recommendations`, `plan`, `checkin`, `ackReminder`,
`medicineInfo`. These still call the speculative contract documented below,
which was never confirmed against a real backend.

### Medicine reminders (`/api/v1/api/reminders/*`) - wired, additive

The Supabase-backed reminders API is now wired
(`lib/features/medicine_reminders/`, `Env.useMockServerReminders`, mocked by
default) - but **additively**, alongside the existing fully local
`flutter_local_notifications`-based dose reminders
(`dose_reminder_scheduler.dart`), not as a replacement:

- `scheduleDoseReminders()` still schedules the local notifications exactly
  as before (that's the reminder mechanism this app actually depends on),
  and now also best-effort calls `POST /api/v1/api/reminders/create` once
  per medicine (not per dose - the request covers the whole course via a
  `times` array and `start_date`/`end_date`), caching the returned id
  locally. This call is skipped silently if no Astra session has been
  started yet (no patient id to register against), and any failure is
  logged, never surfaced to the patient or allowed to block the local
  reminders.
- `main.dart`'s Taken/Skip/Snooze handler now also best-effort calls
  `POST /api/v1/api/reminders/adherence/log` or
  `POST /api/v1/api/reminders/snooze` against that cached server reminder
  id, alongside the existing (unconfirmed-contract) `ackReminder` call.
- These routes are marked `security: none` in the published spec - no
  bearer token required, unlike the companion chat API.
- **The create endpoint's response has no fixed schema** in the published
  OpenAPI spec. `MedicineReminderRepositoryImpl._extractReminderId` guesses
  at `reminder_id`/`id`/`data.reminder_id` and logs a warning if none are
  found - confirm the actual key with the backend before relying on this.
- Not wired: `GET .../patient/{id}`, `GET .../pending/now`,
  `PUT/DELETE .../{id}` - no current screen needs them.

## Found live but not yet wired to any feature

A documents/health-records API (`/api/v1/documents/*`), a Shopify-backed
smart auto-cart (`/api/v1/shopify/*`), video-consultation token generation
(`/api/v1/video/*`), and a WhatsApp companion webhook/proactive-messaging
API (`/api/whatsapp-companion/*`). Doctor/admin/superadmin endpoints on the
same gateway are out of scope for this patient app entirely.

## Original (unconfirmed) contract

## Safety (read before changing anything here)

The client screens every outgoing message for red-flag symptoms (chest
pain, stroke signs, breathing difficulty, suicidal thoughts, heavy
bleeding) with a keyword match **before** calling
`POST /astra/sessions/{id}/messages` - see
`lib/features/astra/domain/red_flag_detector.dart`. A match short-circuits
to a hardcoded emergency card and never reaches the backend/LLM at all.

The backend must still screen independently, for two reasons: (1) the
client's keyword list is deliberately blunt and will miss phrasings it
doesn't recognize; (2) `POST /astra/cases/{id}/triage` and any card in a
`messages` response can also carry `route: emergency` / a `kind: emergency`
card - the client always renders those as the same hardcoded emergency UI
regardless of what LLM-generated text accompanies them. Never let LLM
output alone decide the emergency card's text or CTA - the client ignores
any `message` text `type: chunk` events would have already streamed before
an emergency determination and always uses its own hardcoded copy for
`kind: emergency` cards (see `lib/features/astra/data/astra_card_parser.dart`,
`kind: 'emergency'` branch, and the client-side path in
`AstraChatNotifier.sendUserMessage`).

Astra must never phrase a reply as a diagnosis or a prescription. This is a
prompt/backend responsibility - the client cannot enforce wording, only the
emergency short-circuit above.

## `POST /astra/sessions`

Starts a new Astra session and case.

Response:

```json
{
  "success": true,
  "data": {
    "session_id": "sess_123",
    "case_id": "case_456",
    "greeting": "Hi, I'm Astra..."
  }
}
```

## `GET /astra/sessions/{id}`

Same response shape as above, for resuming an existing session (e.g. after
an app restart).

## `POST /astra/sessions/{id}/messages` (SSE)

Request: `{"text": "I have a headache"}`

Response: `text/event-stream`, one JSON object per `data:` line:

```
data: {"type":"chunk","text":"That "}
data: {"type":"chunk","text":"sounds "}
data: {"type":"card","card":{"kind":"tip","title":"Rest and fluids","body":"..."}}
```

`card.kind` is one of `tip | doctor | order | reminder | emergency`:

- `tip`: `{title, body}`
- `doctor`: `{doctor: <same shape as GET /doctors item>, reason}`
- `order`: `{order_id, summary}`
- `reminder`: `{reminder_id, medicine_name, time}`
- `emergency`: `{message, red_flags: string[]}`

Validation: `text` required, non-empty, reasonable max length (e.g. 2000
chars) to bound LLM cost per turn. Close the stream when the turn is done;
the client stops listening on stream close.

## `POST /astra/sessions/{id}/voice`

Request: multipart form, field `audio` (recorded utterance).

Response:

```json
{
  "success": true,
  "transcript": "I have a headache",
  "reply": "...",
  "tts_url": "https://.../reply.mp3"
}
```

`tts_url` is optional; the client falls back to on-device flutter_tts if
absent or unreachable.

## `POST /astra/cases/{id}/triage`

Response:

```json
{
  "success": true,
  "data": {
    "route": "tips" | "doctor" | "emergency",
    "specialty": "General Medicine",
    "red_flags": []
  }
}
```

## `GET /astra/cases/{id}/recommendations`

Response carries either `tips` or `doctors`, never both:

```json
{
  "success": true,
  "data": {
    "tips": [{"title": "...", "body": "..."}],
    "doctors": [ /* same shape as GET /doctors items, incl. slots/fee */ ]
  }
}
```

Reusing the existing `/doctors` item shape lets the client open the
existing booking flow (`MakeAppointment(doctor: doctor)`) directly from a
recommended doctor with no extra mapping.

## `GET /astra/cases/{id}/plan`, `POST /astra/cases/{id}/checkins`, `POST /astra/reminders/{id}/ack`, `GET /astra/medicines/{id}/info`, `POST /astra/cases/{id}/resolve`

Modeled in the client's `AstraRepository` interface now (so it matches the
full contract), not yet called from any Phase 1 screen - `plan` and
`checkins`/reminders drive Phase 3's daily follow-up and dose-reminder
screens; `resolve` drives Phase 4's case-closure flow.

## Events (backend-only, no client involvement)

`POST /webhooks/whatsapp` and `POST /webhooks/prescription-created` are
backend-to-backend; the client never calls or receives these directly.

## case_id

Every Astra endpoint above operates on a `case_id` created by
`POST /astra/sessions`. The client caches this in the same local slot
(`Preferences.activeCaseId`) that `CaseRepository`
(`lib/features/case/...`, Phase 0) uses, so once Astra starts a case, any
booking/order flow entered from a doctor card automatically attaches to
that same case with no extra plumbing.
