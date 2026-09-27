# Payments: server-priced Razorpay orders

## Why

All three payment screens (appointment, therapy, medicine checkout) used to
compute the amount client-side and hand it straight to Razorpay and then to
the booking endpoint (`amount`, `discount_price`, `payment_status: 1`), with
only the raw Razorpay `payment_id` sent back - no `order_id`, no signature
check. A modified client can book anything for any price. This spec replaces
that with the standard Razorpay Orders flow: the backend prices and creates
the order, the backend verifies the signature after payment.

The client-side `PaymentService`
(`lib/features/payments/presentation/payment_service.dart`) and
`PaymentRepository` (`lib/features/payments/domain/payment_repository.dart`)
are already written against this contract, with a mock implementation
(`Env.useMockPayments`, default on) standing in until these endpoints exist.

## `POST /payments/orders`

Creates a Razorpay order priced entirely server-side.

Request:

```json
{
  "purpose": "appointment" | "therapy" | "medicine_order",
  "case_id": "case_123",
  "reference": {
    // purpose == appointment
    "doctor_id": 12,
    "hospital_id": 3,
    "discount_id": 7

    // purpose == therapy
    "package_id": 4,
    "service_id": null,
    "discount_id": null

    // purpose == medicine_order
    "line_items": [{ "variant_id": 55, "quantity": 2 }]
  }
}
```

Validation:
- `purpose` must be one of the three values; anything else -> 422.
- `reference` ids must belong to the authenticated user's context (e.g. the
  doctor/package/variant must exist and be bookable/purchasable) - re-derive
  price, don't trust anything from the client beyond which items.
- Apply `discount_id` server-side (validate the coupon is active/eligible)
  to compute the final amount - never accept a discount amount from the
  client.

Response:

```json
{
  "success": true,
  "order_id": "order_9A33XWu170gUtm",
  "key_id": "rzp_live_xxx",
  "amount": 150000,
  "currency": "INR"
}
```

`amount` is in the smallest currency unit (paise for INR), matching what
Razorpay's SDK expects. `key_id` is the Razorpay key id (not secret) safe to
hand to the client for this one checkout.

Persist the order (purpose, reference, computed amount, case_id, user_id,
status=created) so `/payments/verify` and the booking endpoint can look it
up and cross-check instead of trusting the client again.

## `POST /payments/verify`

Request:

```json
{
  "order_id": "order_9A33XWu170gUtm",
  "razorpay_payment_id": "pay_9A33XWu170gUtm",
  "razorpay_order_id": "order_9A33XWu170gUtm",
  "razorpay_signature": "9ef4dffbfd..."
}
```

Validation:
- Recompute `hmac_sha256(razorpay_order_id + "|" + razorpay_payment_id, key_secret)`
  and compare to `razorpay_signature`. Reject on mismatch.
- Look up the stored order by `order_id`, confirm it's not already
  verified/consumed (idempotency - a retried verify call must not double
  credit).
- Optionally call Razorpay's Payments API to double check `captured`status.

Response:

```json
{
  "success": true,
  "payment_reference": "verified_order_9A33XWu170gUtm"
}
```

`payment_reference` is an opaque token the client then sends on the actual
booking call (`book_appointment`, `book_session`, `orders`) as
`payment_reference` instead of `payment_token`/`amount`/`discount_price`/
`payment_status`. The booking endpoint should look up this reference,
confirm it's verified and unconsumed, and mark it consumed once the booking
is created (so it can't be replayed against a second booking).

## Events / ledger hook

Once `/payments/verify` succeeds, this is also the point to write the
revenue-ledger entry described in the Phase 2 spec (doctor 70% / platform
30% for consults, platform margin for medicine, centre share + commission
for therapy) - the amount and purpose are already known at this point and
don't need to be re-derived from the booking record.
