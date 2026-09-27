# Prescriptions: structured items

## Why

`GET /get_appointment/{id}`'s embedded `prescription` object only ever
carried a PDF (`pdf`/`pdfPath`) and an untyped `medicines` free-text string.
There's no reliable way for the app (or Astra's smart order draft, Phase 2)
to know what was actually prescribed without OCR-ing a PDF. This adds
structured line items alongside the existing PDF, which keeps working
unchanged.

## Change to `GET /get_appointment/{id}` (and anywhere else `prescription` is embedded)

Add to the `prescription` object:

```json
{
  "id": 1,
  "appointment_id": 42,
  "doctor_id": 7,
  "user_id": 99,
  "medicines": "...(existing free text, keep for backwards compatibility)...",
  "pdf": "...",
  "pdfPath": "https://.../prescription.pdf",
  "items": [
    {
      "product_sku": "SKU123",
      "name": "Paracetamol 500mg",
      "dose": "1 tablet",
      "frequency": "Twice daily",
      "duration_days": 5,
      "timing": "After food",
      "instructions": "Stop if fever resolves before 5 days."
    }
  ],
  "treatment_recommendation": "Consider 3 sessions of Abhyanga therapy"
}
```

- `product_sku` should match a SKU in the `/products` catalog when the
  prescribed medicine is stocked, so the Phase 2 smart order draft
  (docs/backend/smart-orders.md) can link straight to a purchasable
  product. Null when it isn't (e.g. a compounded/external medicine).
- `duration_days` is an integer number of days, not a free-text string -
  the smart order draft and Phase 3 dose reminders both need to compute
  real dates from it.
- `treatment_recommendation` is free text; Phase 3's "book a treatment from
  the plan" flow reads it as a hint, not a structured booking - the patient
  still picks a centre/date themselves.
- Both fields are optional/nullable. The client (`lib/model/v2/prescription_response.dart`,
  `Prescription.items`/`Prescription.treatmentRecommendation`) already
  falls back gracefully - `items` null/empty just means the client shows
  "a structured breakdown isn't available yet, use the PDF" and keeps the
  PDF download working exactly as before.

## Validation

- `items[].name`, `dose`, `frequency`, `timing` required, non-empty.
- `items[].duration_days` required, positive integer.
- Keep generating the PDF exactly as before - `items` is additive, not a
  replacement for it, since it's the doctor's signed record of the
  consult.
