# Astra: AI health assistant

The client is fully written against this contract
(`lib/features/astra/{domain,data,presentation}`), mocked by default via
`Env.useMockAstra` until these endpoints exist. The LLM itself lives only on
the backend - the client never calls an LLM provider directly and never
carries an LLM API key (`google_generative_ai` is not used by the client for
this reason; keep it that way even once these endpoints ship).

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
