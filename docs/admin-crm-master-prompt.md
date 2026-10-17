# Master Prompt: AyurEze Super Admin CRM ("Mother Console")

Use this prompt to brief a coding agent (or a dev team) to build the single
admin console that governs the entire AyurEze ecosystem. It is grounded in
the systems and endpoints already confirmed live during the Phase 4 /
Astra-migration audit of this repo — treat facts below as verified, not
assumed, unless marked `[VERIFY]`.

## 1. What this CRM is

A single internal web app ("AyurEze Command Center") that is the one place
staff use to see and control everything across the ecosystem: patients,
doctors, appointments, prescriptions, orders, payments, EHR documents,
WhatsApp messaging, and the AI companion/brain — instead of staff (or you)
having to separately open Supabase, Laravel's admin, Shopify, Razorpay,
Wasabi, and WhatsApp Business tooling.

It is **not** a new source of truth. Every system it touches already has
one (Supabase, Shopify, Razorpay, Wasabi, Laravel-synced-to-Supabase). The
CRM is a control/observability layer that reads and writes through each
system's real API — never a second copy of the data.

## 2. The systems it must integrate, and how

| System | Host / Access | Role | Status |
|---|---|---|---|
| **Astra AI brain** | `api.ayureze.in` | LLM chat, shop-assist, clinical-note tooling, safety analysis (`/api/v1/brain/*`) | Confirmed live, HTTPBearer |
| **Astra Companion** | `astra.ayureze.in` | Patient-facing AI companion journeys, case management, the unified `/api/v1/*` surface (auth, appointments, cart, finance, documents, reminders, admin-crm) | Confirmed live |
| **WhatsApp Companion** | `whatsapp.ayureze.in` `[VERIFY exact host vs. astra.ayureze.in/api/whatsapp-companion/*]` | Inbound/outbound WhatsApp messaging, proactive nudges, webhook | Confirmed live as a router; verify whether it is actually a separate deployment/host or a path on the Astra host |
| **Laravel legacy backend** | `ayureze.org/api` | Original patient/doctor app backend; being phased out app-side | Still the write path for anything not yet migrated (see `docs/backend` migration notes in this repo) |
| **Supabase** | via Astra backend only — the CRM should never hold its own Supabase service key if Astra already brokers it | Real `doctors`, `patient_profiles`, `consultations`, `doctor_wallets`, cases, EHR metadata | This is the system of record for everything Astra-migrated |
| **MySQL (Laravel's DB)** | via Laravel backend | Legacy system of record, hourly-synced into Supabase by Astra's sync service (`POST /api/admin/sync-now`, `X-Sync-Secret` header) | Being retired; do not build new CRM features against it — `admin_routes.py`'s MySQL-backed admin endpoints are explicitly dead-end per existing code comments |
| **Razorpay** | via Astra's `/api/v1/finance/*` and `/api/v1/cart/*` endpoints, not directly | Consultation payments, cart/medicine checkout payments, doctor payout wallet | Server-priced order creation + signature-verified confirmation already implemented |
| **Shopify** | via Astra's `/api/v1/shopify/*` endpoints | Medicine catalog, draft orders, smart-order auto-cart from prescriptions | Catalog search/availability confirmed live |
| **Wasabi (S3-compatible)** | via Astra's `/api/v1/documents/*` endpoints | EHR document storage (lab reports, prescriptions, x-rays), share-links, WhatsApp document sharing | Confirmed live |
| **Patient app** (Flutter, `ayurezepat` repo) | consumes Astra + (shrinking) Laravel | The CRM doesn't talk to the app directly — it manages the data/backend the app reads | — |
| **Doctor app** | `[VERIFY repo/stack]` | Same relationship as patient app | Confirm which backend endpoints the doctor app actually calls before assuming CRM parity |

**Golden rule: the CRM talks to Astra's backend (`api.ayureze.in` /
`astra.ayureze.in`), and Astra's backend is the only thing that talks to
Supabase, Shopify, Razorpay, and Wasabi directly.** Do not give the CRM
frontend or a new CRM-only backend direct credentials to Shopify/Razorpay/
Wasabi/Supabase unless a capability genuinely doesn't exist yet on the
Astra side — and if so, add it there first, not in a CRM-specific
side-channel, so the patient/doctor apps and the CRM never drift onto two
different code paths for the same data.

## 3. What already exists — build on this, don't re-architect it

The Astra backend already ships a `/api/v1/admin-crm/*` router purpose-built
for this CRM, explicitly designed to replace the older, disconnected
MySQL-only `/api/v1/admin/*` and `/api/v1/api/doctors/*` admin surfaces.
Confirmed existing endpoints:

- `GET /admin-crm/overview` — top-line KPIs (patients, doctors, revenue, pending work)
- `GET /admin-crm/patients/{id}` + `PATCH` — unified patient record (profile + consultations + prescriptions + smart orders)
- `POST /admin-crm/patients` — manual/walk-in patient creation
- `GET /admin-crm/doctors` + `GET /{id}` + `POST` + `PATCH` — doctor directory sourced from the real Supabase `doctors` table (not the dead MySQL pair)
- `POST /admin-crm/doctors/{id}/verify` — flips the real `is_face_verified` flag
- `POST /admin-crm/doctors/{id}/wallet-adjustment` — manual wallet credit/debit, every adjustment logged to `wallet_adjustments` (doctor_id, admin_id, amount, reason, created_at)
- `GET /admin-crm/finance/consultations` + `PATCH /{id}/payment-status` — revenue view + manual payment-status override with a reason, for refund/webhook-miss edge cases
- `GET /admin-crm/finance/withdrawals` — full withdrawal history (distinct from `/finance/admin/withdrawals`, which is just the pending approve/reject queue)
- `PATCH /admin-crm/consultations/{id}` — full consultation edit (date, type, status, diagnosis, notes, fee)

Also already live and reusable, outside the admin-crm router specifically:
- `/api/v1/finance/admin/withdrawals` (+ `/approve`, `/reject`) — the payout approval queue
- `/api/v1/appointments/doctors/{id}/availability` — admin/superadmin can set any doctor's slots
- `/api/companion/case/by-doctor/{doctor_id}`, `/api/companion/case/{id}/health_records` — case + EHR timeline lookups
- `/api/admin/stats`, `/api/admin/config`, `/api/admin/logs`, `/api/admin/sync-now` — system health/ops panel material
- `/admin/dashboard` — an existing server-rendered "Astra Admin Command Center" HTML page `[VERIFY what this currently covers before deciding whether the new CRM replaces or embeds it]`

**Action for the build:** audit `admin-crm` thoroughly before writing new
endpoints. Several modules below ("Shopify ops", "Wasabi/EHR ops",
"WhatsApp ops") likely need *new* Astra-side endpoints, since the admin-crm
router as audited is patient/doctor/finance-focused only.

## 4. Feature modules to build (frontend) and their backend status

For each module, the prompt to the implementing agent should specify:
exact existing endpoint(s) to call, or explicitly flag "new Astra endpoint
required" before any frontend work starts on it.

1. **Dashboard / Overview** — `admin-crm/overview`. Exists.
2. **Patients** — directory, detail, edit, manual creation. Exists
   (`admin-crm/patients*`).
3. **Doctors** — directory, detail, edit, verification toggle, wallet
   adjustments, availability management. Exists, except a bulk/calendar view
   of availability across all doctors — `[NEW]`.
4. **Appointments / Consultations** — list, edit, cancel, reassign doctor.
   Partial: single-consultation edit exists; a cross-doctor appointments
   calendar/queue view is `[NEW]`.
5. **Prescriptions** — view, approve/reject doctor-submitted drafts
   (`/api/v1/api/prescriptions/queue/pending`, `/approve`, `/reject` already
   exist), manual creation, PDF/"catchy prescription" generation
   (`/api/v1/prescriptions/*` exists).
6. **Orders / Shopify** — this needs real scoping: a CRM view of draft
   orders, catalog availability, and smart-order status
   (`shopify/products/available`, `shopify/smart-orders/{id}` exist for
   *reading*) but there is no confirmed admin-crm endpoint for searching all
   orders across patients, issuing refunds, or editing catalog mappings —
   treat as `[NEW]` and design it as an Astra-side Shopify-admin module, not
   a CRM-direct Shopify Admin API integration.
7. **Payments / Finance** — consultation revenue, withdrawal approval
   queue + full history, manual payment-status override, wallet
   adjustments. Exists. Add: a Razorpay settlement/refund action — `[NEW]`,
   since nothing in the audited surface issues a refund.
8. **EHR / Documents (Wasabi)** — per-patient document list, download,
   share-link generation, WhatsApp share. Exists at the single-document
   level (`/api/v1/documents/*`); a CRM-wide document search/audit view
   across all patients is `[NEW]`.
9. **WhatsApp Companion** — stats exist (`/api/whatsapp-companion/stats`),
   proactive send exists but is API-key-gated, not role-gated — decide
   whether the CRM calls it as-is or whether it needs a proper
   admin-crm-style endpoint with audit logging like the wallet adjustments
   have. Treat "campaign/broadcast" tooling as `[NEW]`.
10. **AI Companion / Brain monitoring** — case-by-doctor listing, case
    health-records aggregation exist. A live view of brain health
    (`/api/v1/brain/health`), model status, and conversation
    inspection/safety-flag review across users is `[NEW]` — don't expose
    raw patient conversations without a clear access-control decision.
11. **System ops** — `/api/admin/stats`, `/config`, `/logs`, `/sync-now`
    (shared-secret header, not JWT — flag this inconsistency and decide
    whether to bring it under the same admin-crm auth model).
12. **Audit log** — the wallet-adjustment and payment-status-override
    endpoints already write audit trails into existing tables/notes. There
    is no single, queryable cross-system audit log endpoint yet — `[NEW]`,
    and arguably the most important module to get right early, since this
    CRM is a blast-radius-large tool (one admin can edit any patient,
    doctor, payment, or wallet).

## 5. Cross-cutting requirements

- **Auth**: Astra JWT via the existing Firebase→Astra session exchange
  (`POST /api/v1/auth/session`), restricted to `admin`/`superadmin` roles
  (`AuthUser.role` enum already includes both). Do not build a parallel
  login system for the CRM.
- **RBAC**: decide now whether `admin` and `superadmin` get the same
  capability set, or whether destructive actions (wallet adjustments,
  payment-status overrides, doctor verification) are `superadmin`-only.
  The backend doesn't appear to distinguish yet — this is a design decision
  to make explicit before building, not to leave implicit.
- **Audit everything mutating**: every write the CRM makes (not just
  wallet adjustments) should be logged with admin_id, action, before/after,
  and reason where the action is a correction (matches the pattern already
  set by `wallet_adjustments` and the payment-status-override's "reason
  appended to notes").
- **Never let the CRM bypass Astra's business logic.** E.g., never let it
  write `doctors.available_balance` directly instead of going through the
  wallet-adjustment endpoint, even though both end up touching the same row
  — the endpoint is what keeps the ledger trail intact.
- **Secrets**: the CRM frontend never embeds Razorpay/Shopify/Wasabi/
  WhatsApp credentials. It only ever holds the Astra JWT. The `/api/admin/
  sync-now` shared-secret model is an exception worth fixing, not copying
  — bring it under the same JWT auth before this CRM depends on it.
- **No direct MySQL/Laravel admin surface.** Anything the CRM needs that
  currently only exists on the Laravel side should be added to the Astra
  `admin-crm` router against Supabase, continuing the migration already in
  progress — not re-implemented against Laravel.

## 6. Suggested build order

1. Confirm/`[VERIFY]` every item flagged above against the live backend
   source (don't take this document's endpoint list as exhaustive — it's
   accurate as of the last audit, re-check for drift).
2. Stand up auth (JWT + role gate) and the audit-log table/endpoint first —
   everything else writes through it.
3. Dashboard + Patients + Doctors + Finance modules (fully covered by
   existing endpoints — fastest path to a useful tool).
4. Appointments calendar view, Prescriptions queue.
5. The genuinely new modules: Shopify-ops, Wasabi/EHR-wide view,
   WhatsApp-ops, AI/brain monitoring — each needs new Astra-side endpoints
   designed and built *before* CRM frontend work starts on them.
6. Decide the fate of the existing server-rendered `/admin/dashboard` page
   (retire, or keep as a quick/legacy view while the new CRM is being
   built).

## 7. What to hand the implementing agent

Give it: this document, read access to the Astra backend source (the
actual router files, not just the OpenAPI spec, since several `[NEW]`
items may turn out partially built), and explicit instruction to produce a
written gap list (confirmed-existing vs. needs-building) for every module
in Section 4 *before* writing any CRM frontend code.
