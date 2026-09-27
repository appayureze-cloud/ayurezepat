# Booking endpoint changes: address_id, case_id, payment_reference

Applies to `POST /book_appointment`, `POST /book_session`, `POST /orders`
(place order).

## `case_id` (all three)

Add a required `case_id` field, validated to belong to the authenticated
patient (see docs/backend/case.md). Store it on the created
appointment/session/order row so later phases (prescriptions, smart order
drafts, follow-ups) can join back to the case.

## `payment_reference` (all three, replaces `payment_token`/`amount`/`discount_price`/`payment_status`)

The client no longer sends a price, a discount amount, a payment-completed
flag, or a raw Razorpay payment id. For a paid booking, it sends the
`payment_reference` returned by `POST /payments/verify` (see
docs/backend/payments.md). The endpoint should:

1. Look up the payment record by `payment_reference`.
2. Confirm it is verified and not already consumed by another booking.
3. Use the amount/discount already stored on that payment record (computed
   by `/payments/orders`) as the authoritative price - never re-derive it
   from anything the client sends here.
4. Mark it consumed.

For COD (`payment_type: "cod"`), `payment_reference` is omitted/null and the
endpoint proceeds as before (unpaid, collected on delivery).

`discount_id` (a coupon id, not a price) is still sent by the client and is
fine to keep - it's an identifier the backend re-validates and re-prices
from, not a trusted price.

## `POST /orders`: `address_id` replaces `shipping_address`

Old body sent a `shipping_address` object whose `city`/`state`/`zip` the
client extracted by splitting the saved address string on commas - fragile
and wrong for addresses with a different number of comma-separated parts.

New body sends:

```json
{ "address_id": 42, ... }
```

`address_id` is one of the ids returned by `GET /address` for this patient.
The backend should look up that address record and use its own
structured fields (or an internal geocode/parse step, not a client-side
comma split) to build the shipping address for the courier when this Phase
0 change lands. If the `addresses` table doesn't yet store structured
city/state/zip/country, this is the moment to add those columns and backfill
them, rather than parsing the free-text `address` string at order time.
