# Revenue ledger

Backend-only - nothing here is client-facing, but Phase 2's payment
verification (`docs/backend/payments.md`) is the right place to write these
entries, so it's specified now while that code is fresh.

## Ledger entry (one per revenue event)

```
ledger_entries
  id
  case_id
  source_type      enum: consult | medicine_order | treatment | subscription
  source_id         -- appointment id / order id / therapy booking id / subscription id
  gross_amount      -- what the patient paid, in the smallest currency unit
  platform_amount   -- platform's share (see per-type rules below)
  payee_type        enum: doctor | centre | none
  payee_id          -- doctor id / centre id, null for medicine orders
  payee_amount      -- payee's share
  gateway_fee
  coupon_amount     -- platform-funded discount, if any (comes out of platform_amount)
  currency
  status            enum: pending | settled | reversed
  created_at
  settled_at
```

`gross_amount = platform_amount + payee_amount + gateway_fee` should always
hold (coupon_amount is informational, already netted out of platform_amount
per the rule below) - a reconciliation job should flag any entry where it
doesn't.

## Per-type rules

**Consult** (doctor 70% / platform 30% of the listed fee):
- `payee_amount = gross_amount * 0.70`
- `platform_amount = gross_amount * 0.30 - gateway_fee - coupon_amount`
- Coupons and gateway fees are platform-funded per the product spec - they
  reduce the platform's 30%, never the doctor's 70%.
- `commission_rules` (below) can override the 70/30 split per doctor
  (e.g. a negotiated rate for a high-volume doctor).

**Medicine** (platform margin, no separate payee):
- `payee_type = none`, `payee_amount = 0`
- `platform_amount = sale_price - procurement_cost - courier_cost - gateway_fee`
- `procurement_cost` and `courier_cost` need their own columns (or a join
  to a fulfillment record) - they aren't known at order time, only once
  the order is actually fulfilled, so this entry's `platform_amount` is
  provisional until fulfillment closes it out (`status: pending` until
  then).

**Treatment** (centre share + platform commission):
- `payee_type = centre`
- `payee_amount = gross_amount * (1 - commission_rate)`
- `platform_amount = gross_amount * commission_rate - gateway_fee`
- `commission_rate` comes from `commission_rules` for that centre, not
  hardcoded - see below.

**Subscription**: entries follow the plan's own revenue split, same shape,
`source_type: subscription`. Out of scope for Phase 2's implementation
(Phase 4), specified here only so the schema doesn't need to change later.

## `commission_rules`

```
commission_rules
  id
  payee_type     enum: doctor | centre
  payee_id
  rate           -- e.g. 0.30 for the platform's consult share, or a
                    centre's commission_rate
  effective_from
  effective_to   -- null = current
```

Per-payee overrides of the default 70/30 (consult) or the default centre
commission rate. Look up the rule effective at the transaction's
`created_at`, not just the latest one - a rate change must not retroactively
alter already-settled entries when historical reports are re-run.

## Payouts via Razorpay Route

- Each doctor/centre needs a linked Razorpay Route account (`linked_account_id`)
  before their first payout - store it against the doctor/centre record.
- At payment verification time (`docs/backend/payments.md`), create the
  Razorpay transfer to the payee's linked account for `payee_amount`,
  tagged with the ledger entry id, so a transfer failure can be retried
  against the same ledger entry rather than double-paying.
- Reconcile Razorpay's transfer status back onto the ledger entry
  (`status: settled` once the transfer succeeds; `reversed` on a refund,
  with a matching negative entry rather than deleting the original).

## Reporting surface

Not building a dashboard in this phase - just get the schema and the
write-path right so `SUM(platform_amount) GROUP BY source_type` is a
correct query once someone needs a dashboard.
