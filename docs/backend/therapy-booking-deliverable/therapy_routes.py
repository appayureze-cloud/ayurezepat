"""
Therapy booking routes - a drop-in-SHAPED but NOT drop-in-TESTED deliverable.

This was written without access to the real deployed backend's source
(every candidate repo checked was either stale, empty, or a raw secrets-
bearing backup zip - see docs/backend/therapy-booking-deliverable/README.md).
It mirrors the confirmed-live appointments/finance routers' contract and
conventions as closely as possible from the published OpenAPI spec, but
the auth dependency, Supabase client, and Razorpay client below are named
placeholders. Read the README before wiring this in.
"""

from datetime import date, datetime, time, timedelta
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

# --- Placeholders: replace with your actual imports ------------------------
# from .auth import get_current_user, require_patient
# from .database import supabase
# from .finance_routes import razorpay_client, verify_razorpay_signature
# -----------------------------------------------------------------------------

therapy_router = APIRouter(prefix="/api/v1/therapy", tags=["Therapy Bookings"])


# ---------------------------------------------------------------------------
# Request/response models
# ---------------------------------------------------------------------------

class TherapyCenterSummary(BaseModel):
    center_id: str
    name: str
    type: Optional[str] = None
    services: List[str] = []


class AvailabilityRule(BaseModel):
    day_of_week: int  # 0=Monday .. 6=Sunday, matching appointments' convention
    start_time: str   # "HH:MM"
    end_time: str      # "HH:MM"
    slot_duration_minutes: int = 60


class SetAvailabilityRequest(BaseModel):
    rules: List[AvailabilityRule]


class BookTherapyRequest(BaseModel):
    center_id: str
    service: Optional[str] = None
    date: str   # "YYYY-MM-DD"
    time: str   # "HH:MM"


class TherapyBooking(BaseModel):
    booking_id: str
    patient_id: str
    center_id: str
    service: Optional[str] = None
    booking_date: str
    booking_time: str
    status: str
    payment_status: str


class CreateTherapyOrderRequest(BaseModel):
    amount_rupees: int


class VerifyTherapyPaymentRequest(BaseModel):
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str


# ---------------------------------------------------------------------------
# Centers + availability + slots
# ---------------------------------------------------------------------------

@therapy_router.get("/centers", response_model=List[TherapyCenterSummary])
async def list_therapy_centers(service: Optional[str] = None):
    """
    Patient-facing center directory, no GPS required - same gap
    GET /api/v1/appointments/doctors filled for doctors vs. the GPS-only
    GET /api/v1/api/treatment-centers/nearby/search.
    """
    # query = supabase.table("treatment_centers").select(
    #     "center_id, name, type, services"
    # )
    # if service:
    #     query = query.contains("services", [service])
    # rows = query.execute().data
    # return [TherapyCenterSummary(**row) for row in rows]
    raise NotImplementedError("Wire up the Supabase query above")


@therapy_router.post("/centers/{center_id}/availability")
async def set_therapy_availability(
    center_id: str,
    body: SetAvailabilityRequest,
    # current_user = Depends(require_doctor_or_admin),  # or a center-specific role
):
    """Replaces a center's weekly availability with the given rules."""
    # supabase.table("therapy_availability").delete().eq("center_id", center_id).execute()
    # rows = [
    #     {
    #         "center_id": center_id,
    #         "day_of_week": r.day_of_week,
    #         "start_time": r.start_time,
    #         "end_time": r.end_time,
    #         "slot_duration_minutes": r.slot_duration_minutes,
    #     }
    #     for r in body.rules
    # ]
    # supabase.table("therapy_availability").insert(rows).execute()
    # return {"success": True}
    raise NotImplementedError("Wire up the Supabase writes above")


@therapy_router.get("/centers/{center_id}/slots")
async def get_therapy_slots(center_id: str, date: str):
    """
    Real open slots for a center on a given date: generates candidate
    slots from therapy_availability for that weekday, then removes any
    slot already booked by a non-cancelled booking - same approach as
    GET /api/v1/appointments/doctors/{doctor_id}/slots.
    """
    target_date = datetime.strptime(date, "%Y-%m-%d").date()
    weekday = target_date.weekday()  # 0=Monday, matches AvailabilityRule

    # availability_rows = supabase.table("therapy_availability") \
    #     .select("start_time, end_time, slot_duration_minutes") \
    #     .eq("center_id", center_id).eq("day_of_week", weekday).execute().data
    availability_rows: List[dict] = []  # placeholder

    candidate_slots: List[str] = []
    for rule in availability_rows:
        start = datetime.strptime(rule["start_time"], "%H:%M:%S").time()
        end = datetime.strptime(rule["end_time"], "%H:%M:%S").time()
        duration = timedelta(minutes=rule["slot_duration_minutes"])
        current = datetime.combine(target_date, start)
        end_dt = datetime.combine(target_date, end)
        while current + duration <= end_dt:
            candidate_slots.append(current.strftime("%H:%M"))
            current += duration

    # booked_rows = supabase.table("therapy_bookings") \
    #     .select("booking_time") \
    #     .eq("center_id", center_id).eq("booking_date", date) \
    #     .neq("status", "cancelled").execute().data
    booked_times: set = set()  # placeholder - {row["booking_time"] for row in booked_rows}

    open_slots = [s for s in candidate_slots if s not in booked_times]
    return {"date": date, "center_id": center_id, "slots": open_slots}


# ---------------------------------------------------------------------------
# Booking
# ---------------------------------------------------------------------------

@therapy_router.post("/book", response_model=TherapyBooking)
async def book_therapy(
    body: BookTherapyRequest,
    # current_user = Depends(require_patient),
):
    """
    Creates a pending, unpaid booking for a real open slot - mirrors
    POST /api/v1/appointments/book's lifecycle (explicit booking step,
    payment is a separate follow-up call against the returned booking_id).
    """
    # patient_id = current_user.patient_id
    # TODO: re-validate the slot is still open (same race-condition guard
    # appointment_routes.book_appointment presumably has) before inserting.
    # row = supabase.table("therapy_bookings").insert({
    #     "patient_id": patient_id,
    #     "center_id": body.center_id,
    #     "service": body.service,
    #     "booking_date": body.date,
    #     "booking_time": body.time,
    #     "status": "pending",
    #     "payment_status": "unpaid",
    # }).execute().data[0]
    # return TherapyBooking(
    #     booking_id=row["id"], patient_id=patient_id, center_id=body.center_id,
    #     service=body.service, booking_date=body.date, booking_time=body.time,
    #     status="pending", payment_status="unpaid",
    # )
    raise NotImplementedError("Wire up the Supabase insert above")


@therapy_router.get("/my", response_model=List[TherapyBooking])
async def my_therapy_bookings(
    # current_user = Depends(require_patient),
):
    # rows = supabase.table("therapy_bookings") \
    #     .select("*").eq("patient_id", current_user.patient_id) \
    #     .order("booking_date", desc=True).execute().data
    # return [TherapyBooking(booking_id=r["id"], ...) for r in rows]
    raise NotImplementedError("Wire up the Supabase query above")


@therapy_router.post("/{booking_id}/cancel")
async def cancel_therapy_booking(
    booking_id: str,
    # current_user = Depends(require_patient),
):
    # supabase.table("therapy_bookings").update({"status": "cancelled"}) \
    #     .eq("id", booking_id).eq("patient_id", current_user.patient_id).execute()
    # return {"success": True}
    raise NotImplementedError("Wire up the Supabase update above")


# ---------------------------------------------------------------------------
# Payment - reuses whatever Razorpay client finance_routes.py already has
# ---------------------------------------------------------------------------

@therapy_router.post("/{booking_id}/payments/create-order")
async def create_therapy_payment_order(
    booking_id: str,
    body: CreateTherapyOrderRequest,
    # current_user = Depends(require_patient),
):
    """
    Server-priced Razorpay order tied to this booking - same split as
    POST /api/v1/finance/payments/create-order (price server-side, open
    Razorpay client-side, verify server-side via the endpoint below).
    """
    # amount_paise = body.amount_rupees * 100
    # order = razorpay_client.order.create({
    #     "amount": amount_paise, "currency": "INR",
    #     "notes": {"booking_id": booking_id, "type": "therapy"},
    # })
    # supabase.table("therapy_bookings").update({
    #     "amount_paise": amount_paise, "razorpay_order_id": order["id"],
    # }).eq("id", booking_id).execute()
    # return {"order_id": order["id"], "amount": amount_paise, "currency": "INR"}
    raise NotImplementedError("Wire up the Razorpay order creation above")


@therapy_router.post("/{booking_id}/payments/verify")
async def verify_therapy_payment(
    booking_id: str,
    body: VerifyTherapyPaymentRequest,
    # current_user = Depends(require_patient),
):
    """
    Verifies the Razorpay signature, marks the booking paid+confirmed -
    the step that must never be skipped, same as finance_routes.py's
    verify_payment() comment already flags for consultations.
    """
    # verify_razorpay_signature(
    #     body.razorpay_order_id, body.razorpay_payment_id, body.razorpay_signature
    # )  # raises on mismatch
    # supabase.table("therapy_bookings").update({
    #     "status": "confirmed", "payment_status": "paid",
    #     "razorpay_payment_id": body.razorpay_payment_id,
    # }).eq("id", booking_id).execute()
    # return {"success": True}
    raise NotImplementedError("Wire up the signature verification above")
