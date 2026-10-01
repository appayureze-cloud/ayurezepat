# How Astra connects the patient app and the doctor app

This traces the real, live API flow that links a patient consultation to a
doctor, verified against the actual `astra.ayureze.in` source (found in the
`appayureze-cloud/astra-backup` repo's zip, under `astra/` - **not** the
`appayureze-cloud/aiastra` repo, which turned out to be a different, Auth0-based
backend for a separate `api.ayureze.in` deployment). File paths below are
relative to that `astra/` folder.

## 1. Shared identity - one login, two possible roles

Both apps authenticate the same user the same way:

```
POST /api/v1/auth/session
Authorization: Bearer <Firebase ID token>
```

`app/auth_routes.py::create_session` → `_resolve_identity()`:

1. Verifies the Firebase ID token (`app/security/auth.verify_firebase_token`).
2. Looks up that user's email/phone against the `doctors` table first. Match → `role: "doctor"`, `doctor_id` set.
3. Not a doctor → looks up `patient_profiles` then `patients`. Match → `role: "patient"`, `patient_id` set.
4. Neither → falls back to a bare `role: "patient"` identity keyed by the Firebase UID.

The `doctors`/`patients` tables aren't maintained by hand - `app/sync_service.py`
("the Ecosystem Bridge") runs hourly, pulling `doctor`/`users` straight out of
**Laravel's own MySQL** and upserting them into this Supabase table. So a
doctor who exists in the Laravel admin panel becomes resolvable here within an
hour of being added, with no separate Astra-side registration step.

The response is one JWT (`AuthSessionResponse.access_token`) carrying
`doctor_id` or `patient_id` plus role-based permissions. Every other endpoint
below is called with `Authorization: Bearer <that JWT>`, and the backend reads
`doctor_id`/`patient_id` off it rather than trusting a client-supplied id.

**Patient app today:** already does exactly this via `AstraGatewayAuth`
(`lib/features/astra/data/astra_gateway_auth.dart`) - nothing to change here.
**Doctor app:** needs to do the identical exchange; whichever table its user
resolves against determines what it gets back.

## 2. Patient starts a case - triage, then handoff to a specific doctor

```
POST /api/companion/chat                     # free-form Astra chat, no doctor involved yet
POST /api/companion/journey/start            # structured symptom journey
POST /api/companion/case/create              # { doctor_id, patient_id, ... } - explicit handoff
```

`app/companion_api.py::create_health_case` takes a `doctor_id` directly in the
request body - the case is bound to one doctor from the moment it's created
(chosen by the patient, or assigned by whatever triage logic picks a doctor;
that selection logic lives upstream of this endpoint and wasn't traced here).
From this point, both sides can read the same case:

```
GET /api/companion/case/{case_id}
PUT /api/companion/case/progress             # either side can append progress
```

## 3. Live consultation - video

```
POST /api/v1/video/generate-token     { to_id: <patient_id or doctor_id> }
GET  /api/v1/video/config             # Agora App ID
POST /api/v1/video/add-call-history   { doctor_id, patient_id, ... }
```

`app/agora_routes.py::generate_token` builds the Agora channel name
deterministically: `doc_{doctor_id}_pat_{patient_id}`. The doctor app and
patient app each call `generate-token` independently (reading their own
`doctor_id`/`patient_id` off their JWT), get a token scoped to the *same*
channel name, and Agora's SDK joins them into the same call. There's no
separate "invite" or signaling step on Astra's side - the channel name itself
is the handshake.

**Patient app today:** already wired to this exact contract
(`lib/features/video_calls/data/video_call_repository_impl.dart`).

## 4. Prescriptions - a shared queue, not a direct message

```
POST /api/v1/astra-fill/process-voice | process-text   # patient or doctor dictates
POST /api/v1/api/prescriptions/draft                    # lands in a pending queue
GET  /api/v1/api/prescriptions/queue/pending             # doctor-side worklist
POST /api/v1/api/prescriptions/{id}/approve | reject | process
```

A draft prescription doesn't go to a specific doctor's inbox directly - it
lands in a shared pending queue (`prescription_routes.py::get_pending_prescriptions`)
that doctor-side tooling polls. Approving one (`process_prescription`) runs
`prescription_automation.py`, which creates a Shopify cart, sets up medicine
reminders, and notifies the patient - all server-side, no extra app-to-app
call needed.

## 5. Documents - shared by patient_id, no doctor-side upload path found

```
POST /api/v1/documents/upload                    # patient uploads
GET  /api/v1/documents/patient/{patient_id}       # doctor reads the same list
```

Already wired on the patient side
(`lib/features/documents/data/document_repository_impl.dart`). A doctor-app
read of the same endpoint, scoped by `patient_id` from the shared case, is all
that's needed on that side - no new Astra endpoint required.

## What this means for "wiring a real consultation"

The plumbing already exists and matches what the patient app calls today.
Getting an actual doctor-app round trip working needs:

1. The doctor app doing the same Firebase → `/api/v1/auth/session` exchange
   (point 1) - confirms it gets `role: "doctor"` back for a real doctor
   account.
2. Something upstream of `/api/companion/case/create` to pick a `doctor_id`
   per patient (not traced in this audit - likely the `doctors/nearby/search`
   flow, but that endpoint currently returns seed/test data, not real synced
   doctors - see `docs/backend/astra.md`'s note on `dr_ayureze_001`).
3. Both apps calling `/api/v1/video/generate-token` with the same resolved
   `doctor_id`/`patient_id` pair for the channel names to match.

None of that requires new backend code - it requires a real doctor account
that's gone through the Laravel → sync_service → Astra pipeline, and a doctor
app build that performs the same session exchange the patient app already
does.
