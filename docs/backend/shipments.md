# Shipment tracking: push on status change

## What already exists

Order tracking itself is already built: `GET /order/{id}`
(`lib/model/v2/medicine/order_details_response.dart`) already returns
`tracking: [{step, status, happened_at}]` and `active_step`, and
`lib/v2/ui/medicine/order_details.dart` already renders it as a stepper.
Nothing needed there.

## What's missing: push when status changes

When a shipment's tracking status changes server-side (procured, shipped,
out for delivery, delivered), send a push notification through the
existing pipeline so the app opens straight to that order:

```json
{
  "notification": {
    "title": "Your order is out for delivery",
    "body": "Order #1234 - AWB XXXXXXX"
  },
  "data": {
    "screen": "order_tracking",
    "order_id": "1234"
  }
}
```

This is the same shape `main.dart`'s `FirebaseMessaging.onMessage` handler
already expects for the chat/video-call notifications - `screen` picks the
in-app destination, this just adds a new value for it. The client side is
already wired: `lib/main.dart`'s `_processNotificationResponse` opens
`OrderDetails(id: order_id)` on `screen == 'order_tracking'`.

## Validation

- Only send this to the order's own patient (device token on file for
  their account), not broadcast.
- Debounce: a shipment status can flap (carrier API retries); don't send a
  push for the same `(order_id, status)` pair twice.
