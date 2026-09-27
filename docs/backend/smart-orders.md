# Smart order drafts

## Why

When a prescription is issued, the patient should be prompted to buy the
medicines without re-typing anything - "smart order draft" in the product
flow. This spec covers creating that draft server-side and the three
endpoints the client (`lib/features/smart_orders/...`) uses to show it,
mocked by default via `Env.useMockSmartOrders`.

## Draft creation (server-side, no new client call)

When a prescription with `items` (docs/backend/prescriptions.md) is saved,
create a `smart_orders` row:

- Match each `items[].product_sku` against the product catalog. Items with
  no match (no SKU, or SKU not stocked) are left out of the draft - it only
  ever contains purchasable items.
- If the resulting draft has zero items, don't create one and don't prompt.
- Send a push notification (`screen: "smart_order_draft"`, `draft_id`) so
  the client opens `SmartOrderDraftScreen` directly - reuse the existing
  push pipeline in `lib/main.dart`'s `FirebaseMessaging.onMessage` handler,
  same shape as the existing chat/video-call notifications.

## `GET /smart_orders/{id}`

```json
{
  "success": true,
  "data": {
    "id": "draft_123",
    "case_id": "case_456",
    "prescription_id": "presc_789",
    "status": "pending",
    "items": [
      {"product_id": 1, "variant_id": 1, "name": "Paracetamol 500mg", "quantity": 10, "price": 4.0}
    ]
  }
}
```

`quantity` should already reflect the prescription's `duration_days` /
dosing frequency (e.g. twice daily for 5 days = 10 tablets) - the client
doesn't recompute this.

## `POST /smart_orders/{id}/bought`

Marks the draft consumed. Called by the client after it has already added
every item to the cart via the existing `POST /addtocart` (one call per
item - no batch endpoint needed, this only happens once per draft).
Idempotent: calling it twice is a no-op, not an error.

## `POST /smart_orders/{id}/ignore`

Marks the draft ignored. The client separately schedules a **local**
24-hour re-prompt notification (`scheduleSmartOrderReprompt` in
`lib/features/smart_orders/presentation/smart_order_reprompt_scheduler.dart`)
so the re-nudge works even if the app is killed - the backend doesn't need
to send a second push for that specific re-prompt. The backend can still
use `ignored` status for its own follow-up logic (e.g. Astra mentioning it
in a later check-in, Phase 3).

## Validation

- `id` must belong to the authenticated patient's own case.
- `bought`/`ignore` on an already-`bought` or already-`ignored` draft:
  return success without changing state (idempotent), not an error - the
  client's local re-prompt notification firing after the patient already
  bought elsewhere is an expected race, not a bug to surface to them.
