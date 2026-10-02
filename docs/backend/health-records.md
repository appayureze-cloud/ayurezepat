# Health record timeline

## `GET /cases/{caseId}/health_records`

Returns a flat, newest-first (or any order - the client sorts by `at`)
list of the patient's encounters, prescriptions and reports for that case.
Mocked by default via `Env.useMockHealthRecords` until this ships.

```json
{
  "success": true,
  "data": [
    {
      "type": "encounter",
      "at": "2026-09-20T10:00:00Z",
      "appointment_id": 1,
      "doctor_name": "Dr. Anita Rao",
      "specialty": "General Medicine"
    },
    {
      "type": "prescription",
      "at": "2026-09-20T10:20:00Z",
      "prescription_id": 1,
      "appointment_id": 1,
      "doctor_name": "Dr. Anita Rao"
    },
    {
      "type": "report",
      "at": "2026-09-18T09:00:00Z",
      "title": "Blood test - CBC",
      "url": "https://.../report.pdf"
    }
  ]
}
```

`type` is required and must be one of `encounter | prescription | report` -
the client (`lib/features/health_records/data/health_record_parser.dart`)
silently drops any entry with an unrecognized type rather than crash, so
new types can be added without an app update, but they won't render until
the client is updated to handle them.

## Validation

- Scoped to the authenticated patient's own case - never another patient's.
- `report` entries require a real, patient-accessible `url` (signed URL
  with a reasonable expiry, not a permanent public link, since these are
  medical documents).
