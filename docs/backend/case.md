# Case: lifecycle endpoints (Phase 0 foundation)

## Why

Every booking/order/therapy plan needs to hang off one Case (see the
product flow). Astra (Phase 1) creates a case as a side effect of
`POST /astra/sessions`. Before Astra ships, and for any flow that doesn't
go through Astra (e.g. a patient booking a doctor directly from search), the
app needs a lightweight way to get a case id. `CaseRepository`
(`lib/features/case/domain/case_repository.dart`) is written against this
contract, mocked by default via `Env.useMockCases`.

## `POST /cases`

Creates a new case for the authenticated patient with status `open`.

Response:

```json
{
  "success": true,
  "data": {
    "id": "case_123",
    "status": "open",
    "created_at": "2026-09-27T10:00:00Z",
    "specialty": null
  }
}
```

## `GET /cases/{id}`

Returns the case if it belongs to the authenticated patient, 404 otherwise.
Same response shape as above.

## Status values

`open -> consulting -> treating -> following_up -> resolved -> closed`
(matches `CaseStatus` in `lib/features/case/domain/entities/case.dart`).
Transitions are driven by other endpoints (booking a consult moves it to
`consulting`, a prescription being issued moves it to `treating`, etc.) -
out of scope for this Phase 0 spec, covered as each later phase's flows are
built.

## Client behavior

`CaseRepository.ensureActiveCase()` caches the last case id locally
(SharedPreferences) and reuses it as long as `GET /cases/{id}` reports it
still active (not `resolved`/`closed`); otherwise it calls `POST /cases`
for a fresh one. Every booking/order request in this phase sends the
resulting `case_id` alongside its existing fields.
