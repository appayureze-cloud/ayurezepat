-- Therapy booking - new Supabase tables.
-- Mirrors the shape of doctor_availability/consultations (see the
-- appointments backend) so the same slot-generation and booking-lifecycle
-- logic applies. Adjust column types/names to match your actual
-- `treatment_centers` table's primary key type before running.

CREATE TABLE IF NOT EXISTS therapy_availability (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    center_id       TEXT NOT NULL REFERENCES treatment_centers(center_id),
    day_of_week     INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    slot_duration_minutes INTEGER NOT NULL DEFAULT 60,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_therapy_availability_center
    ON therapy_availability (center_id);

CREATE TABLE IF NOT EXISTS therapy_bookings (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id          TEXT NOT NULL,
    center_id           TEXT NOT NULL REFERENCES treatment_centers(center_id),
    service             TEXT,
    booking_date        DATE NOT NULL,
    booking_time        TIME NOT NULL,
    status              TEXT NOT NULL DEFAULT 'pending'
                            CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    payment_status      TEXT NOT NULL DEFAULT 'unpaid'
                            CHECK (payment_status IN ('unpaid', 'paid', 'refunded')),
    amount_paise        INTEGER,
    razorpay_order_id   TEXT,
    razorpay_payment_id TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_therapy_bookings_patient
    ON therapy_bookings (patient_id);
CREATE INDEX IF NOT EXISTS idx_therapy_bookings_center_date
    ON therapy_bookings (center_id, booking_date)
    WHERE status != 'cancelled';
