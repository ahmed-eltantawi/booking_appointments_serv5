# Appointment Booking — Mentor Issues

This document contains the mentor audit findings for the Flutter appointment-booking project.

The purpose of this file is to provide the AI agent with a clear specification of the issues that must be reviewed and fixed in the current codebase.

> **Important:** The status from the original mentor audit must NOT be trusted as the current implementation status. The current codebase is the source of truth.

## Current Implementation Status

According to the current project state:

- **ISSUE-004** → Already implemented. Verify and preserve it.
- **ISSUE-006** → Already implemented. Verify and preserve it.
- All other issues listed below → **Open and must be fixed.**

---

# Existing Functionality

The following functionality already exists and must continue working after all refactoring:

- Working day: **09:00–18:00**
- 18 half-hour slots
- Booking durations:
  - 30 minutes
  - 60 minutes
  - 90 minutes
  - 120 minutes
- Booked slots
- Unavailable slots
- Non-consecutive slot validation
- 6 PM working-hours boundary
- X-O-X rule
- Cubit-based state management
- get_it dependency injection
- Local seed data only
- Reset
- Confirm
- English / Arabic localization
- Light / Dark theme
- Drawer
- Invalid-start dimming

Do not regress any of these behaviors.

---

# Assumptions

These assumptions are part of the booking rules and should remain consistent throughout the implementation.

### A1 — Unavailable counts as blocked

`unavailable` counts as a blocked slot (`X`) for the X-O-X rule, the same as `booked`.

### A2 — X-O-X requires both sides

An isolated free slot is only considered an X-O-X violation when it has a blocked slot on both sides.

Therefore:

```text
X O X
```

is invalid.

But a free slot at the first or last position of the day is not an X-O-X violation because it has only one neighboring slot.

### A3 — A booking is responsible only for gaps it creates

If an isolated gap already existed before a booking, the new booking must not be rejected because of that pre-existing gap.

The validator must compare the schedule before and after the hypothetical booking.

### A4 — Confirm remains

The existing Confirm button should remain.

It makes the resulting booking/schedule observable to the user even though the task primarily requires Reset.

---

# Major Issues

## ISSUE-001 — X-O-X validation incorrectly checks all isolated gaps

### Problem

The X-O-X validation currently detects whether the simulated schedule contains any isolated free slot.

The problem is that it does not determine whether the new booking actually created that isolated gap.

For example, if the schedule already contains:

```text
X O X
```

and the user attempts an unrelated booking somewhere else, the unrelated booking must not be rejected because of the existing gap.

### Expected behavior

A booking should be rejected only when the booking itself creates a new:

```text
X O X
```

condition.

Existing isolated gaps must not be blamed on the new booking.

### Required implementation

The validator should:

1. Calculate isolated gaps in the schedule before the booking.
2. Simulate the booking.
3. Calculate isolated gaps after the booking.
4. Compare the two sets.
5. Reject the booking only if the "after" set contains an isolated gap that did not exist before.

Conceptually:

```text
isolatedBefore = getIsolatedGaps(schedule)

simulatedSchedule = applyBooking(schedule, booking)

isolatedAfter = getIsolatedGaps(simulatedSchedule)

newGaps = isolatedAfter - isolatedBefore

if newGaps.isNotEmpty:
    reject
```

### Required tests

Add tests covering:

- Pre-existing X-O-X elsewhere in the schedule
- Booking that does not create a new isolated gap
- Booking that creates X-O-X
- `X O O X`
- `X O O O X`
- Multiple blocked slots
- Unavailable slots participating as blocked slots
- X-O-X at the beginning/end of the schedule

---

## ISSUE-002 — Changing duration silently removes the selected start

### Problem

When a user selects a start time and then changes the duration, the current implementation can remove the selection if that start is no longer valid.

The user receives no clear explanation.

Example:

```text
Selected start: 5:00 PM
Old duration: 1 hour
New duration: 2 hours
```

The resulting booking would be:

```text
5:00 PM → 7:00 PM
```

which exceeds the 6 PM working-hour boundary.

The selection must not simply disappear.

### Expected behavior

When duration changes:

1. Keep the selected start.
2. Recalculate the booking using the new duration.
3. Revalidate the selected start.
4. Keep the selection even if it becomes invalid.
5. Expose the specific validation reason.
6. Let the UI clearly explain why the selection is invalid.

### Required tests

Test:

- Valid selection becoming invalid after duration change
- Invalid selection becoming valid after duration change
- Selected start remains visible
- Correct validation reason is emitted
- Working-hours violation after duration change

---

## ISSUE-003 — Validation messages are duplicated and hardcoded

### Problem

Validation feedback is currently generated in multiple places.

Some snackbar messages are hardcoded in English while the application supports Arabic localization.

This can result in:

- English snackbar while Arabic is selected
- Different messages between the snackbar and validation banner
- Duplicated `switch` statements mapping validation reasons to messages

### Expected behavior

There must be one centralized mapping:

```text
BookingInvalidReason → localized String
```

The same mapping should be used by:

- Validation banner
- Snackbar
- Other booking validation feedback

### Requirements

- No hardcoded user-facing English validation strings
- No duplicated reason-to-message switches
- English localization supported
- Arabic localization supported
- Existing localization architecture must be respected

---

# ISSUE-004 — Invalid reasons are too coarse

## Current Status

**Already implemented.**

This issue must be verified and preserved.

### Expected validation reasons

The booking system should distinguish between:

```text
exceedsWorkingHours
startSlotBooked
startSlotUnavailable
overlapsBooking
insufficientConsecutiveSlots
createsIsolatedGap
```

Different failure reasons should produce specific user-facing messages.

### Verification

Confirm that:

- All required reasons exist
- They are correctly generated by the validator
- They are localized
- They are used consistently by the presentation layer

Do not unnecessarily rewrite an already-correct implementation.

---

## ISSUE-005 — Invalid selection hides booked/unavailable slots

### Problem

The selection overlay can visually overwrite the original status of booked/unavailable slots.

Example:

```text
09:30 → available
10:00 → booked
10:30 → booked
```

If the user selects 09:30 for 90 minutes, the selected range includes the booked slots.

The UI must not make those booked slots look like normal valid selected slots.

### Expected behavior

The underlying slot status must remain:

```text
available
booked
unavailable
```

Selection and validation should be presentation states layered on top of the original slot status.

The UI should distinguish:

- Available
- Booked
- Unavailable
- Selected
- Invalid
- Invalid selected range

### Required implementation

Do not mutate the domain slot status to represent selection.

Instead, derive the visual state in presentation.

For example:

```text
Domain status:
booked

Presentation state:
booked + invalid selection
```

The booked/unavailable identity must remain visible.

The legend should also explain the invalid state.

### Required tests

Add widget tests verifying:

- Booked slot remains visually identifiable inside an invalid range
- Unavailable slot remains visually identifiable
- Invalid selection has its own visual treatment
- Valid selected slots remain visually distinct

---

# Architecture Issues

## ISSUE-006 — Repository

## Current Status

**Already implemented.**

Verify and preserve the existing repository implementation.

### Expected architecture

The dependency direction should be:

```text
BookingCubit
      ↓
BookingRepository
      ↓
BookingRepositoryImpl
      ↓
Local Schedule / Data Source
```

The Cubit should not directly depend on the local schedule constant.

### Verification

Confirm that:

- `BookingRepository` exists
- `BookingRepositoryImpl` exists
- The repository provides the local schedule
- The Cubit receives the repository through dependency injection
- The Cubit does not directly read the local schedule

Do not unnecessarily rewrite a correct implementation.

---

## ISSUE-007 — Slot model does not represent actual time

### Problem

The current slot representation is based on an index and status.

Time is derived using calculations such as:

```text
9 * 60 + index * 30
```

This creates unnecessary coupling to:

- a specific starting hour
- a 30-minute slot size
- list position

The current domain status also includes UI state such as `selected`.

### Expected model

Use a time-based model conceptually equivalent to:

```text
TimeSlot(
    start,
    end,
    status
)
```

Where status represents domain states such as:

```text
available
booked
unavailable
```

### Important

`selected` is a presentation/UI state.

It should not be part of the domain slot status.

### Requirements

- Remove unnecessary index-based time calculations
- Represent actual start/end times
- Keep domain status limited to domain concepts
- Format time in presentation
- Respect localization
- Do not hardcode English AM/PM formatting
- Update affected Cubit/UI/validator/tests

Do not maintain two competing slot models.

---

## ISSUE-008 — Validator relies on free functions and index-based magic numbers

### Problem

Booking validation is currently tightly coupled to list indexes and hardcoded working-day assumptions.

Examples include assumptions such as:

```text
18 slots
17 as the final index
9 AM start
```

The validator should not depend on the seed data's exact list shape.

### Expected architecture

Create a dedicated domain service:

```text
BookingValidator
```

It should encapsulate booking business rules.

It should provide behavior equivalent to:

```text
getRequiredSlots
isWithinWorkingHours
hasConflict
areSlotsConsecutive
wouldCreateIsolatedGap
getValidStartTimes
validateBooking
```

### Requirements

The validator should:

- Work with `TimeSlot`
- Use actual time information
- Derive working boundaries from the schedule where appropriate
- Avoid magic constants tied to the seed schedule
- Be independently unit-testable
- Remain independent from Flutter UI code

Do not put presentation logic inside the validator.

---

# State Management

## ISSUE-010 — Booking state is overly flat and contains nullable fields

### Problem

The current state structure contains multiple nullable values and a status enum representing different concepts.

This can create impossible states such as:

```text
status = selected
selectedStart = null
```

A confirmation action may also be represented as persistent state even though it is effectively a one-time UI event.

### Expected behavior

Use a clean immutable state model that represents valid states clearly.

A suitable concept is:

```text
BookingLoading

BookingLoaded(
    slots,
    duration,
    selectedStart,
    validation,
    validStartTimes,
    confirmedBooking
)
```

The exact implementation should follow the project's existing Cubit conventions.

### Requirements

- Immutable state
- Value equality where appropriate
- Avoid unrelated nullable flags
- Avoid impossible state combinations
- Do not duplicate derived data unnecessarily
- Derive the selected end from selected start + duration where appropriate
- Review listener logic
- Do not rely on fragile `listenWhen` behavior
- Keep one-shot UI events separate from persistent state where appropriate

Follow the project's state-management conventions.

---

# UX Issues

## ISSUE-011 — Booking summary is incomplete

### Problem

The summary does not clearly provide all required booking information.

### Expected information

The summary should display:

```text
Start Time
End Time
Selected Duration
Total Booking Duration
```

### Important

If the calculated booking exceeds 6 PM, do not replace the end time with:

```text
—
```

Instead show the actual calculated end time.

Example:

```text
Start: 5:00 PM
End: 6:30 PM
Duration: 1h 30m
Total: 1h 30m
```

Then show the validation error explaining that the booking exceeds working hours.

All text must be localized.

---

## ISSUE-012 — Accessibility problems

### Problems

The booking UI has several accessibility concerns:

- Status is primarily communicated through color
- Slot cells lack semantic information
- Duration controls have small touch targets
- Selected state is not exposed semantically
- Unavailable/dimmed states have low contrast
- Invalid states are not sufficiently distinguishable

### Required improvements

Implement appropriate:

- `Semantics`
- Semantic labels
- Selected semantics
- Status icons
- At least approximately 48dp interactive targets
- Material interaction feedback such as `InkWell`
- Improved contrast
- Non-color indicators for status

### Slot semantics should communicate

At minimum:

- Time
- Available/booked/unavailable status
- Selected state
- Invalid state when applicable

Users should not need to rely only on color.

---

# Minor Issues

## ISSUE-013 — `handleSlotTap` duplicates `selectStartTime`

### Problem

If `handleSlotTap` is only a forwarding alias to `selectStartTime`, it creates two public APIs for the same action.

### Expected behavior

Keep one clear public entry point.

Remove the redundant alias.

Update all usages and tests.

---

## ISSUE-014 — Validator accepts an invalid start

### Problem

The validator can potentially receive a start that does not exist in the schedule.

Examples:

```text
negative index
out-of-range index
nonexistent time
```

The current implementation can incorrectly treat such a request as valid or later crash during booking application.

### Expected behavior

Invalid starts must be rejected safely.

The validator must never:

- Return valid for a nonexistent start
- Generate an empty valid booking
- Cause a null-check crash

Return an appropriate validation failure.

After the TimeSlot refactor, prefer validating actual slot/time identity rather than relying on raw indexes.

### Required tests

Add tests for:

- Start before schedule
- Start after schedule
- Nonexistent start
- Invalid/out-of-range input

---

# Code Quality Issues

## ISSUE-015 — `pubspec.yaml` configuration

### Problems

Build-time tools such as:

```text
flutter_launcher_icons
flutter_native_splash
```

must not be treated as normal runtime dependencies.

Also verify that asset declarations are correctly placed under the Flutter configuration.

### Required changes

- Place build-time tooling in the appropriate dependency section
- Correct the Flutter asset configuration
- Remove ineffective configuration
- Run `flutter pub get`
- Verify dependency resolution

Do not add unnecessary packages.

---

## ISSUE-016 — README is default/corrupted

### Problems

The README contains default Flutter boilerplate and has encoding corruption.

### Required changes

Replace it with a concise project README containing:

- Project purpose
- Setup instructions
- How to run
- Architecture overview
- Booking rules
- Working hours
- Duration options
- Validation behavior
- Localization
- Testing instructions

Fix the file encoding.

---

## ISSUE-017 — Tests are coupled to implementation details

### Problems

Existing tests rely heavily on index-based implementation details.

Tests should survive an internal refactor from index-based slots to time-based `TimeSlot`.

Important behavior is also missing from test coverage.

### Required test coverage

Add/update tests for:

#### Working hours

- Valid booking inside working hours
- Booking exceeding 6 PM

#### Conflicts

- Start slot booked
- Start slot unavailable
- Booking overlaps booked slot
- Insufficient consecutive slots

#### X-O-X

```text
X O X
X O O X
X O O O X
```

Also cover:

- Pre-existing isolated gaps
- Newly created isolated gaps
- Multiple blocked slots
- Unavailable slots as blocked slots

#### Duration changes

- Selection remains after duration change
- Selection becomes invalid
- Correct validation reason is preserved

#### Invalid input

- Start outside schedule
- Invalid start
- Nonexistent slot

#### Repository

- Repository returns the expected local schedule

### Test naming

Tests should describe behavior.

Prefer:

```text
rejects booking that exceeds working hours
```

instead of:

```text
T01
```

Do not make tests pass artificially.

Do not delete tests simply because the implementation changed.

---

## ISSUE-018 — Snackbar survives Reset

### Problem

After an invalid booking attempt, a snackbar may remain visible after the user presses Reset.

This causes the UI to show an error describing a selection that no longer exists.

### Expected behavior

When Reset is pressed:

1. Booking state is reset.
2. Selection is cleared.
3. Validation banner is cleared.
4. Existing booking-related snackbar feedback is dismissed.
5. The screen returns to its initial state.

### Architecture requirement

Snackbar/Scaffold behavior belongs to the presentation layer.

The Cubit must remain independent of UI-specific concerns.

### Required test

Add a widget test verifying:

```text
Invalid booking
    ↓
Snackbar appears
    ↓
Reset
    ↓
Snackbar dismissed
    ↓
Initial state restored
```

---

# Final Acceptance Criteria

The implementation is considered complete only when:

- ISSUE-001 is fixed
- ISSUE-002 is fixed
- ISSUE-003 is fixed
- ISSUE-004 is verified and preserved
- ISSUE-005 is fixed
- ISSUE-006 is verified and preserved
- ISSUE-007 is fixed
- ISSUE-008 is fixed
- ISSUE-010 is fixed
- ISSUE-011 is fixed
- ISSUE-012 is fixed
- ISSUE-013 is fixed
- ISSUE-014 is fixed
- ISSUE-015 is fixed
- ISSUE-016 is fixed
- ISSUE-017 is fixed
- ISSUE-018 is fixed

The implementation must also preserve all existing booking functionality.

---

# Verification

After implementation, run:

```bash
flutter analyze
```

and:

```bash
flutter test
```

If possible, also run:

```bash
flutter test --coverage
```

The agent must report:

1. Files changed
2. Changes made for each issue
3. Tests added/updated
4. `flutter analyze` result
5. `flutter test` result
6. Any remaining issues

Do not claim an issue is fixed without verifying the current implementation.