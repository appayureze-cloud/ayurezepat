# AyurEze — Google Stitch UI Master Prompt (Modern Calm Healthcare)

A sequenced set of prompts for [Google Stitch](https://stitch.google.com/) to
regenerate every screen in the AyurEze patient app under one consistent,
modern, calm healthcare design system — replacing the current (legacy,
inconsistent) UI. Follow the batching workflow: run Prompt 1 first to lock
the design system, then feed the remaining batches in order on the same
canvas so every later screen inherits the same tokens.

## Design direction (applies to every prompt below)

> **Style brief**: A modern, calm, trustworthy Ayurvedic healthcare app for
> patients booking doctors, chatting with an AI health companion, ordering
> medicines, and tracking their care journey. Avoid clinical/cold hospital
> aesthetics and avoid loud, busy commerce-app aesthetics. The feeling should
> be "a knowledgeable, gentle guide," not "a sterile clinic" or "a flash
> sale."
>
> - **Palette**: a calm, muted base — warm off-white / cream background
>   (#FBF9F4-ish), a primary sage/forest green (#3F6F5A-ish) for actions and
>   brand accents, a secondary warm terracotta/turmeric gold (#C98A3E-ish)
>   used sparingly for highlights (badges, streaks, CTAs that need to pop),
>   soft clay/blush for gentle alerts, and a muted slate for body text
>   (never pure black). No neon, no saturated reds except for genuine
>   medical urgency (emergency/red-flag states).
> - **Typography**: one humanist sans-serif for UI text (e.g. Inter/Manrope
>   feel) with generous line-height; a slightly warmer serif or rounded
>   display face allowed only for large greeting headlines ("Good morning,
>   Asha"). Clear type-scale hierarchy, nothing condensed or tight.
> - **Shape language**: soft, consistent corner radius (16–24px) on cards,
>   buttons, and sheets; pill-shaped primary buttons; generous whitespace;
>   avoid hard-edged rectangles and dense data tables.
> - **Imagery/icons**: simple line icons (not filled/glossy), soft
>   botanical/leaf motifs used as subtle background texture (never busy or
>   literal clip-art), real-feeling human photography for doctor
>   avatars/testimonials rather than cartoon illustration.
> - **Motion feel** (describe even though Stitch is static): gentle
>   fade/slide transitions, no abrupt pops — describe this in each prompt so
>   generated states look like they belong to a calm, settled product.
> - **Accessibility**: minimum AA contrast even with the muted palette;
>   never rely on color alone for status (always pair with icon/label) —
>   this matters a lot for medication/appointment status chips.
> - **Tone of copy**: warm, plain-language, reassuring. Avoid medical
>   jargon and avoid aggressive commerce language ("BUY NOW!", "LIMITED
>   OFFER") anywhere in the care-related flows.

Save this style brief into Stitch's `DESIGN.md` immediately after Prompt 1
generates it, and re-paste it at the top of any later session if Stitch
seems to drift.

---

## Prompt 1 — Core batch: lock the design system

Paste this first. This is the only prompt that should also establish the
design system.

```
Design a modern, calm, trustworthy Ayurvedic healthcare app for patients
called "AyurEze". [PASTE THE FULL "Design direction" STYLE BRIEF ABOVE HERE]

Generate these 4 screens as the first batch, and lock in a shared design
system (colors, typography, spacing scale, corner radius, button/card/chip
styles) that every later screen must reuse:

1. Home — a greeting header ("Good morning, [Name]"), a prominent "Talk to
   Astra" card (our AI Ayurvedic health companion, with a soft chat-bubble
   icon) as the hero action, a horizontal "Popular Doctors" card carousel
   (doctor photo, name, specialization, a verified badge, a pill "Book"
   button), a "Continue your care" section showing an active prescription
   or reminder as a calm progress card, and a bottom tab bar with 5 tabs:
   Astra, Home, Shop, Appointments, Profile.

2. Astra AI Chat — a chat screen with the AI's avatar as a soft circular
   leaf/lotus mark, chat bubbles (AI bubble: cream background; patient
   bubble: sage green), a push-to-talk microphone button docked at the
   bottom next to a text input, and an example "doctor recommendation card"
   rendered inline in the chat (doctor photo, name, specialization, a
   "Book appointment" button) and an example "emergency/red-flag" inline
   card in a clearly distinct but non-alarming clay/amber tone with a
   "Call for help" button.

3. Doctor Detail / Booking — doctor photo, name, specialization, verified
   badge, a calm bio section, a horizontal date strip, a grid of time-slot
   chips (available vs. unavailable states), consultation type toggle
   (video / in-person), and a sticky bottom "Book appointment" pill button
   showing the fee.

4. Profile — patient avatar, name, patient code, a calm list of settings
   rows (My Appointments, My Orders, Documents, Medication Reminders,
   WhatsApp Updates, Address Book, Help & Support, Logout), each row with a
   soft leading icon and trailing chevron.

Output a DESIGN.md summarizing the locked tokens (palette hex values, font
choices, spacing scale, radius scale, button/card/chip component specs) so
every future screen on this canvas reuses them exactly.
```

---

## Prompt 2 — Onboarding & auth (3–4 screens)

```
Using the exact same design system from DESIGN.md, add an onboarding and
auth flow:

1. Splash — app wordmark centered on the cream background with a subtle
   leaf motif behind it. Describe the animation even though Stitch renders
   it as a static frame, so it can be handed to engineering as a motion
   spec: the leaf motif slowly breathes/scales in from 90% to 100% opacity
   over ~1.2s, the wordmark fades and gently rises 8px into place after a
   short delay, then a thin sage progress underline fills left-to-right
   while the app initializes — no spinner, no logo bounce, nothing abrupt.
2. Onboarding (3 slides in one screen set) — each slide: a calm full-bleed
   illustration (not literal clip-art, soft botanical/abstract), a short
   reassuring headline ("Your Ayurvedic care, in your pocket"), body copy,
   page-dot indicator, skip + next controls.
3. Sign up / Log in — toggle between email+password and phone OTP, Google
   sign-in button styled to match our palette (not Google's default blue
   pill), calm form fields with soft labels, a single pill primary button.
4. OTP verification — 6-box OTP input, resend-timer text, calm illustration
   of a phone/message at the top.
5. Permission requests — a reusable single-screen pattern (one instance
   each for Camera, Microphone, Notifications, Location) used right before
   the OS permission dialog: a large soft line-icon for the specific
   permission, a one-sentence plain-language reason ("We use your camera
   so your doctor can see you during video consults"), and a single
   "Continue" pill button — never a wall of legal text.
```

---

## Prompt 3 — Appointments flow (3 screens)

```
Using the same design system, add:

1. Doctor Discovery / List — a search bar, specialization filter chips in a
   horizontal scroll, and a vertical list of doctor cards (photo, name,
   specialization, verified badge, "Book" pill button) — same card style as
   the Home carousel, just in a scrollable list.
2. My Appointments — segmented control (Upcoming / Past), each appointment
   as a card: doctor photo, name, date/time, consultation type icon
   (video/in-person), a status chip (Booked / Awaiting payment / Completed
   / Cancelled) using icon+label not just color, and action buttons (Join
   call, Pay now, Cancel) shown contextually per status.
3. Appointment Detail — doctor info header, appointment date/time, a calm
   payment summary card (fee, pay button that opens Razorpay), and once
   paid, a prominent "Join video call" pill button.
```

---

## Prompt 4 — Video consultation (1 screen)

```
Using the same design system, add a Video Call screen: full-screen remote
video feed, small draggable self-video thumbnail in a corner with a soft
rounded-rect mask, a translucent bottom control bar (mute, camera toggle,
end-call in clay/red, chat toggle) floating over the video with enough
contrast to stay legible over any footage.
```

---

## Prompt 5 — Shop & checkout (4 screens)

```
Using the same design system, add a shopping flow for Ayurvedic medicines:

1. Shop / Medicine Catalog — search bar, category chips, a grid of product
   cards (product photo, name, price, an "Add to cart" circular icon
   button in the corner), empty/loading states styled calmly.
2. Product Detail — product photo, name, price, description, quantity
   stepper, sticky bottom "Add to cart" pill button.
3. Cart — line items (photo, name, price, quantity stepper, remove), order
   summary card (subtotal, shipping, total), sticky bottom "Checkout" pill
   button; include an empty-cart state (soft illustration + "Browse
   medicines" button).
4. Order History — list of past orders as cards (order id, date, item
   thumbnails row, total, status chip), tapping opens an order detail with
   tracking status as a calm horizontal stepper (Placed → Packed →
   Shipped → Delivered).
```

---

## Prompt 6 — Care journey: prescriptions, reminders, records (4 screens)

```
Using the same design system, add the ongoing-care screens:

1. Structured Prescription — doctor's prescribed items as a clean list
   (medicine name, dosage, duration, instructions icon), with a "Smart
   order" callout card suggesting a one-tap reorder when supplies are
   running low.
2. Medication Reminders — a day timeline of dose cards (medicine name,
   time, a soft icon per dose type), each with three equal-weight actions:
   Taken (sage check), Skip (muted outline), Snooze (amber outline) —
   avoid making Skip look punitive.
3. Health Record Timeline — a vertical timeline (dot + connecting line) of
   care events (consultation, prescription issued, lab report, dose log),
   each entry as a compact card with a date label and icon per event type.
4. Daily Check-in — a calm single-screen form: a 1–5 symptom-severity
   selector using soft circular face/intensity icons (not harsh emoji), an
   optional note field, and a single "Submit check-in" pill button; include
   a gentle escalation banner state ("Based on your answer, we recommend
   speaking with your doctor") in the clay/amber tone, non-alarming.
```

---

## Prompt 7 — Documents, consent, and case closure (3 screens)

```
Using the same design system, add:

1. Documents — a list of uploaded documents (lab reports, prescriptions,
   x-rays) as cards with a file-type icon, name, upload date, and a
   download/view action; include an upload button as a floating pill
   action.
2. WhatsApp Consent — a single calm screen explaining what updates will be
   sent over WhatsApp, with a toggle switch and a short privacy note below
   it.
3. Case Closure — a calm "wrap-up" screen summarizing the care episode
   (diagnosis, duration, outcome note from the doctor) with a closing
   confirmation button and a short feedback/rating prompt (soft star
   icons, not harsh yellow).
```

---

## Prompt 8 — Therapy booking & address (2 screens)

```
Using the same design system, add:

1. Therapy Booking — a list of therapy packages as cards (name, duration,
   price, a short description), each with a "Book" pill button; a detail
   screen variant showing a date/time picker and a sticky bottom booking
   button.
2. Address Book — a list of saved addresses as cards (label chip like
   Home/Work, address text, edit/delete icons) and an add/edit address
   form with a map preview card at the top using our palette for the map
   pin.
```

---

## Prompt 9 — Empty, error, and loading states (1 batch)

```
Using the same design system, generate a shared set of state screens that
should be reused across the app: a generic empty-state (soft illustration
+ headline + short body + optional action button), a generic error-state
(same layout, calm clay-toned icon, "Try again" button — never red error
text on white), a generic loading-state (branded skeleton shimmer using
our cream/sage tones, not a generic spinner), and a "no internet"
full-screen state.
```

---

## Prompt 10 — EHR Vault: secure health records (4 screens)

```
Using the same design system, add a dedicated "Health Vault" section —
this is distinct from the simple Documents list in an earlier batch: it's
the patient's full secure electronic health record, organized and locked.

1. Vault Lock Screen — shown every time the vault is opened: a centered
   soft shield/lock line-icon, "Unlock your Health Vault" headline, a
   biometric (fingerprint/face) button as the primary action and a PIN
   fallback link below it; calm, reassuring tone, not an alarming
   "security" aesthetic.
2. Vault Home — a grid of category folders (Lab Reports, Prescriptions,
   Imaging & Scans, Vaccination Records, Insurance, Discharge Summaries),
   each as a soft rounded tile with a category line-icon, a document
   count, and last-updated date; a search bar pinned at the top; a
   floating "Scan or upload" pill action.
3. Vault Category List — inside a folder: a vertical list of document
   cards (thumbnail/preview, title, date, issuing doctor/lab name, a
   small "shared with doctor" indicator chip when relevant) with sort and
   filter controls at the top.
4. Document Viewer — full-screen document/image viewer with pinch-zoom,
   a minimal top bar (back, title, overflow menu), and a bottom action
   bar (Share, Download, Delete) that stays translucent over the document
   but never obscures content; include a state for a multi-page PDF with
   page dots at the bottom.
```

---

## Prompt 11 — Companion Mode: the full Astra AI experience (4 screens)

```
Using the same design system, expand Astra beyond the basic chat screen
into a full "Companion Mode" — an ongoing AI-guided care journey, not just
a chatbot:

1. Companion Journey Dashboard — opened from the "Talk to Astra" card on
   Home: a calm progress visualization of the patient's current care
   journey as connected soft nodes/stages (e.g. Symptom Check-in →
   Guidance → Doctor Case Opened → Treatment Plan → Follow-up), the
   current stage highlighted in sage with a short status line beneath it,
   and a "Continue conversation" pill button below that re-enters the chat
   where it left off.
2. Companion Voice Mode (full-screen) — a large centered soft animated
   orb/blob (sage-to-cream gradient) that represents Astra listening or
   speaking, a waveform ring around it that pulses gently while listening,
   a live transcript caption fading in at the bottom, and a bottom bar
   with mute/end-voice-mode controls; describe the orb's idle state as a
   slow breathing pulse and its listening state as a slightly faster,
   amplitude-reactive pulse, so it reads as alive but never frantic.
3. Companion Chat History — a list of past conversations/journeys as
   cards (date, a one-line AI-generated summary of what was discussed, an
   icon indicating outcome: guidance given / doctor referred / case
   closed), tapping reopens that conversation in read-only chat view.
4. Companion Case Summary — a calm read-only recap shown at the end of a
   journey: presenting symptom, AI guidance given, whether a doctor was
   involved, any prescribed plan, and a closing note — styled like the
   Case Closure screen from an earlier batch so the two feel like the same
   family of "wrap-up" screens.
```

---

## Prompt 12 — Settings & account (6 screens)

```
Using the same design system, add a full Settings section, reached from
Profile → Settings:

1. Settings Home — grouped list sections (Account, Notifications,
   Privacy & Data, App Preferences, Support, About), each row with a soft
   leading icon and trailing chevron or inline control, matching the
   Profile screen's row style exactly.
2. Account Settings — edit name/email/phone/photo, a "Change password"
   row, a "Linked sign-in methods" row showing Google/phone/email badges,
   and a clearly separated, calmly-styled "Delete account" row at the
   bottom (muted red text, no button, requires confirmation on tap).
3. Notification Preferences — grouped toggles (Appointment reminders,
   Medication reminders, Daily check-in nudges, Order & shipping updates,
   WhatsApp updates, Promotional messages), each with a one-line
   description under the toggle.
4. Privacy & Data — a plain-language summary of what data is collected
   and why, a "Download my data" row, a "Manage WhatsApp consent" row
   (links to the WhatsApp Consent screen from an earlier batch), and a
   link to the full privacy policy.
5. Language & App Preferences — a language picker (English/Hindi shown as
   radio rows with native-script labels), a text-size stepper preview,
   and a theme row (System / Light) — keep Light as the only real option
   given the calm palette, but show the row for completeness.
6. Help & Support / About — an FAQ accordion list, a "Contact support"
   row (chat/call/email icons), and an About screen with app version,
   terms of service, privacy policy, and open-source licenses links.
```

---

## Prompt 13 — Notifications inbox & global search (2 screens)

```
Using the same design system, add:

1. Notifications Inbox — a chronological list of notification cards
   (icon per type: appointment, medication, order, companion/AI, system),
   title, short body, relative timestamp, with unread items marked by a
   small sage dot rather than bold/loud styling; include a calm empty
   state ("You're all caught up").
2. Global Search — a search bar at the top with recent searches as
   chips below it when empty, and grouped results (Doctors, Medicines,
   Documents, Past conversations) once a query is entered, each group
   showing up to 3 results with a "See all" link.
```

---

## Prompt 14 — Doctor profile & feedback (2 screens)

```
Using the same design system, add:

1. Doctor Full Profile — expands on the Doctor Detail/Booking card: large
   photo header, name, specialization, verified badge, years of
   experience and consultation-count stats as calm pill chips, a bio
   section, a qualifications list, and a patient reviews section (star
   rating summary + a few review cards) — the booking controls from the
   earlier Doctor Detail screen stay reachable via a sticky bottom "Book
   appointment" button.
2. Feedback & Rating — shown after a completed appointment or order: a
   soft star-rating row (not harsh yellow, use the terracotta accent), an
   optional comment field, and a single "Submit feedback" pill button;
   include a brief "Thank you" confirmation state.
```

---

## After all batches: linking

Once every screen above exists on the canvas, use Stitch's screen-linking
feature to wire:
- Home → Companion Journey Dashboard (not the bare chat) → Companion Voice
  Mode / Companion Chat History / Companion Case Summary
- Home doctor cards → Doctor Detail → Doctor Full Profile; "Book" →
  My Appointments → Appointment Detail → Video Call → Feedback & Rating
- Bottom tabs across all 5 primary screens
- Shop → Product Detail → Cart → Order History
- Profile → Documents, Reminders, Address Book, My Orders, My
  Appointments, and Settings Home
- Settings Home → Account Settings, Notification Preferences, Privacy &
  Data (→ WhatsApp Consent), Language & App Preferences, Help & Support
- Profile/Home bell icon → Notifications Inbox; search icon → Global
  Search
- Documents row (or a new Vault entry point on Home/Profile) → Vault Lock
  Screen → Vault Home → Vault Category List → Document Viewer
- Splash → Onboarding (first launch only) → Sign up/Log in → OTP
  verification → relevant Permission request screens → Home

This turns the canvas into a clickable prototype of the full replacement
UI, which can then be handed to engineering as the visual spec for
restyling the existing Flutter screens (`lib/v2/ui/**`, `lib/features/**`)
without changing their underlying data/business logic.
