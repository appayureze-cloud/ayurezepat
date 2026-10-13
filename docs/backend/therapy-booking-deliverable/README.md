# Therapy Booking — Backend Deliverable (Review Before Deploying)

## Why this exists

The patient app's therapy booking flow (`v2/ui/therapy/*`) is the one
remaining feature with no Astra backend equivalent at all — confirmed by
checking every available backend repo and the published OpenAPI spec.
`/api/v1/api/treatment-centers/*` only gives directory data (name,
location, services); there's no concept of a bookable slot, a booking
record, or payment tied to one.

**I do not have access to the real deployed backend's source** (every
candidate GitHub repo checked is either stale, empty, or a raw backup zip
with live secrets in it — see the session notes if you need the full
audit trail). This code is written to match the *contract* the live app
already relies on elsewhere (same auth model, same Razorpay flow, same
response shapes as the confirmed-live `appointments`/`finance` routers in
the OpenAPI spec), but it has **never run against the real database,
real auth dependency, or real Supabase client**. Treat it as a detailed
starting point for whoever maintains the live server, not a drop-in patch.

## What you need to adapt before this will run

1. **Imports at the top of `therapy_routes.py`** — `get_current_user`,
   `require_patient`, `require_doctor_or_admin`, and the `supabase` client
   are placeholder names. Replace them with whatever your actual codebase
   calls its JWT-auth dependency and Supabase client (the published spec's
   `appointments`/`finance` routers already use something equivalent —
   match that, not what's written here).
2. **Table names** — `therapy_availability` and `therapy_bookings` are
   new tables (migration below). `treatment_centers` is assumed to
   already exist with at least `center_id`, `name`, `type`, `services`
   columns (per the existing `/api/v1/api/treatment-centers/*` routes) —
   confirm the exact column names match what's already there.
3. **Razorpay client/keys** — reuses whatever `finance_routes.py` already
   initializes Razorpay with. Don't create a second Razorpay client; wire
   this to the same one.
4. **Router registration** — add `app.include_router(therapy_router)` to
   `main.py` alongside the other `/api/v1/*` routers.

## Request/response shapes (for the Flutter side to match)

See the docstrings in `therapy_routes.py` — each endpoint's Pydantic
models are the contract. These were designed to mirror
`appointment_routes.py`'s shapes as closely as possible (same
`AvailabilityRule`/slot-generation approach, same pending→paid booking
lifecycle, same Razorpay create-order/verify split) so the Flutter client
code ends up looking like `AppointmentService`/`AppointmentRepositoryImpl`
almost exactly — once this is live, the Flutter-side migration should be
small.

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/v1/therapy/centers` | List bookable centers (optional `service` filter), no GPS required — same gap `appointments/doctors` filled for doctors vs. the GPS-only `nearby/search`. |
| POST | `/api/v1/therapy/centers/{center_id}/availability` | Admin/center sets weekly slot rules. |
| GET | `/api/v1/therapy/centers/{center_id}/slots?date=YYYY-MM-DD` | Real open slots for that date (generated from availability, minus already-booked ones). |
| POST | `/api/v1/therapy/book` | Creates a pending, unpaid booking for a real open slot. |
| GET | `/api/v1/therapy/my` | Patient's own bookings. |
| POST | `/api/v1/therapy/{booking_id}/cancel` | Cancel a booking. |
| POST | `/api/v1/therapy/{booking_id}/payments/create-order` | Server-priced Razorpay order tied to this booking. |
| POST | `/api/v1/therapy/{booking_id}/payments/verify` | Verify signature, mark booking paid+confirmed. |

## Files

- `therapy_routes.py` — the FastAPI router.
- `migration.sql` — the two new tables.
