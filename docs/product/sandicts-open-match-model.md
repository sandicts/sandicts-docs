---
title: Sandicts Open Match Model
doc-type: product-domain-model
role: source-of-truth
priority: high
canonical: docs/product/sandicts-open-match-model.md
related:
  - docs/product/sandicts-mvp-scope.md
  - docs/product/sandicts-mvp-functional-spec.md
  - docs/product/sandicts-open-match-implementation-roadmap.md
  - docs/product/sandicts-v2-backlog.md
  - docs/product/tweener-competitive-analysis.md
  - docs/business-rules/sandicts-business-rules.md
scope: product, mvp, open-matches, reservations, participants, sharing, retention
read-when:
  - implementing or designing open matches
  - writing open-match API contracts or user flows
  - deciding whether a match feature belongs in MVP or later
  - planning open-match Jira work
do-not-read-when:
  - changing only technical configuration
  - implementing tournaments without open-match impact
---

# Sandicts Open Match Model

## Purpose

This document is the source of truth for the Sandicts open-match domain. It
turns the accepted product direction and the useful lessons from Tweener into
implementable MVP rules while preserving explicit V2 and future boundaries.

The product loop to prove is:

`discover court -> reserve -> open spots -> fill players -> confirm -> play -> rebook`

Sandicts must connect community demand to real court inventory. It should not
start as a generic social network for athletes.

## MVP Outcome

The MVP is successful when a player can:

1. create an open match linked to a real reservation or a manual place
2. describe the match purpose, visibility, sport, time, capacity, and expected
   level
3. share a stable link through WhatsApp or another native share target
4. fill available spots with registered players or organizer-managed guests
5. understand who is confirmed, waiting, or awaiting approval
6. receive essential operational updates
7. complete the match and return to reservation or rematch actions

## MVP Scope

### Match Classification

Every match must define:

- `intent`: `social`, `competitive`, or `training`
- `visibility`: `public` or `invite_only`
- `levelPolicy`: `open`, `similar`, or `range`
- `sportId`
- start and end date-time
- participant capacity

Meaning:

- `social`: prioritizes finding people and playing without competitive stakes
- `competitive`: communicates that the organizer expects a more competitive
  session; it does not produce a ranking in the MVP
- `training`: communicates a practice-oriented session; it does not create a
  coach or class relationship
- `public`: discoverable in the Sandicts open-match list
- `invite_only`: excluded from public discovery but accessible through its
  stable shared link
- `open`: no level restriction beyond sport compatibility
- `similar`: uses the creator's simple self-declared sport level as an
  expectation
- `range`: uses a minimum and maximum simple self-declared level

Simple level is a discovery signal, not verified proof of ability. A level
mismatch may warn the player, but must not silently change profile data.

Visibility for a specific group is not part of MVP because it depends on the
V2 community-group model.

### Place And Reservation

Every match uses exactly one place mode:

- `reservation`: references a Sandicts reservation and its court
- `manual_place`: stores a display place entered by the creator

Reservation-linked rules:

- the creator must control the referenced reservation
- the reservation may be `pending_payment` or `confirmed`
- sport, court, start, and end come from the reservation and cannot diverge
- only one active open match may be linked to the same reservation
- if the reservation expires or is canceled before play, the linked open match
  is canceled automatically
- canceling the open match does not cancel the reservation
- the match must show when its reservation is still awaiting payment or
  confirmation

Manual-place rules:

- the match stores a human-readable place and optional instructions
- a manual place does not prove court availability and does not block a
  Sandicts availability slot
- the UI must not present it as a confirmed Sandicts reservation

This resolves the previous place-model decision while keeping informal games
possible during marketplace cold start.

### Match Lifecycle

MVP match statuses:

- `open`: accepting participation or approval requests
- `full`: confirmed registered players and guests reached capacity
- `canceled`: organizer or reservation lifecycle canceled the match
- `completed`: match time passed and completion was recorded

Transitions:

- creation -> `open`, unless initial confirmed capacity already fills the match
- `open` -> `full` when the last confirmed spot is occupied
- `full` -> `open` when a confirmed participant leaves or is removed before the
  applicable cutoff
- `open` or `full` -> `canceled` by the creator
- `open` or `full` -> `canceled` when the linked reservation is canceled or
  expires before play
- `open` or `full` -> `completed` after the scheduled time according to the
  completion policy

Canceled and completed matches do not accept new participants. Historical
participant data must remain available for audit and product metrics.

### Participant Lifecycle

MVP participant statuses:

- `requested`: registered player is waiting for organizer approval
- `confirmed`: player or guest occupies one match spot
- `waitlisted`: registered player is waiting for capacity
- `declined`: organizer rejected a participation request
- `left`: participant left or organizer removed the participant before play
- `no_show`: confirmed participant was recorded as absent after the match

Rules:

- the creator enters as the first `confirmed` registered participant
- the creator cannot leave an active match; without an MVP ownership-transfer
  flow, the creator must cancel it
- a registered player may have only one active participation record per match
- public match participation becomes `confirmed` while capacity exists
- invite-only match participation starts as `requested`; only the creator can
  confirm or decline it
- when capacity is full and the waitlist is enabled, a public join becomes
  `waitlisted`; otherwise the join fails as a business-rule violation
- only `confirmed` registered players and confirmed guests consume capacity
- `requested` and `waitlisted` records do not consume capacity
- leaving or removal releases capacity and may return `full` to `open`
- a player promoted from the waitlist must receive an operational update
- participation changes are forbidden after the applicable cancellation or
  completion cutoff

An in-app `invited` participant status is intentionally reserved for V2. In the
MVP, `invite_only` means link-gated discovery plus organizer approval; it is not
a full invitation subsystem.

### Guest Participants

The creator may reserve a spot for a person who does not yet have a Sandicts
account.

MVP guest rules:

- the creator provides only a display name
- the guest occupies one confirmed spot
- the guest lifecycle is `confirmed`, `removed`, or `no_show`
- only the creator can add, edit, or remove the guest
- the public landing page must not expose private contact data
- the guest has no public profile, rating, ranking, or match history
- creating a guest must not silently create a `User` or `Player`
- guest and registered-participant identifiers must remain distinct so a safe
  claim/link flow can be added later

Claiming a historical guest record is V2 and requires explicit account-owner
confirmation.

### Sharing And Entry

Every match receives a stable shareable URL at creation. Canceled and completed
matches keep the URL so visitors see a safe terminal state instead of a broken
invitation.

MVP rules:

- the detail experience provides copy-link and native sharing, with WhatsApp as
  a primary target
- a public or unlisted landing page may be read without authentication
- crawler and preview requests are read-only and never join a match
- authentication is required before creating a participation record
- after authentication, the user returns to the intended match
- preview metadata contains only privacy-safe match data
- full, canceled, and completed states remain understandable from a shared link

The MVP does not import contacts, integrate with the WhatsApp API, send direct
in-app invitations, or treat link clicks as accepted invitations.

### Operational Updates

The MVP includes only updates required to complete the real-world activity:

- participation requested, confirmed, declined, promoted, left, or removed
- match became full, reopened, canceled, or completed
- linked reservation was confirmed, expired, or canceled
- a configurable pre-match reminder
- a lightweight post-time prompt asking whether the match happened

The delivery channel and exact timing remain implementation decisions. A broad
notification center, social notifications, and marketing campaigns are V2 or
later.

### Simple Player Suggestions

The MVP may show a small, rules-based candidate list after match creation. This
is an incremental MVP enhancement, not a launch gate for the core flow.

Rules:

- candidates must have opted into being discoverable
- candidates must share the sport and have a compatible simple level
- MVP suggestions do not use precise live location
- suggestions never auto-enroll, auto-message, or reveal private contact data
- ranking is deterministic and explainable; no AI or behavioral scoring is
  required
- the primary action remains sharing the match link

AI recommendations and automatic matchmaking remain future scope.

### Completion And Return Loop

After the scheduled time, the creator receives a lightweight completion prompt.
The MVP records whether the match occurred and may record `no_show` status.

The completed view should offer:

- rebook the same court when the match has a reservation
- create a similar match or rematch
- view the final participant list

Ratings, rankings, badges, skill changes, and public reputation do not belong in
the MVP completion flow.

## Authorities

- creator: edit allowed match fields, approve or decline requests, manage
  guests, remove participants when policy permits, cancel, and confirm outcome
- registered participant: request/join, leave when policy permits, and view the
  participant information allowed by match visibility
- Organization operator: controls the underlying reservation and court but does
  not become match creator by default
- system: enforces capacity, uniqueness, reservation synchronization, status
  transitions, and operational updates

Organization-created matches are V2.

## Business Failures

Use `validation_error` for malformed fields or invalid date ranges.

Use `business_rule_violation` for:

- duplicate active participation
- confirming beyond capacity
- joining without an available spot when waitlist is disabled
- changing a canceled or completed match
- linking a reservation whose sport or schedule is incompatible
- linking a reservation already used by another active match
- changing reservation-derived place or schedule fields
- acting after a participation cutoff

Use `resource_not_found` when the match, participant, reservation, sport, or
court does not exist in the caller-visible context.

Use `forbidden` when a user attempts creator-only actions, references another
player's reservation, or accesses an invite-only match without a valid route to
it.

## MVP Delivery Increments

Implement in this order:

1. core model, reservation/manual place, lifecycle, and public discovery
2. participation, creator approval, capacity, guests, and waitlist
3. shareable landing page, authentication return, and WhatsApp/native sharing
4. reservation synchronization and operational updates
5. completion prompt, rematch/rebook actions, and metrics
6. rules-based suggestions if core validation supports the increment

The first five increments form the recommended MVP. Increment 6 can ship during
MVP validation without blocking the first controlled release.

## Metrics

Track at minimum:

- percentage of created matches that reach full capacity
- median time from creation to full capacity
- shared-link views and authenticated participation conversion
- cancellation and no-show rates
- percentage of matches linked to Sandicts reservations
- repeat reservation or rematch rate after completion
- waitlist promotion rate
- number of guest spots used

Guest-to-account claim conversion becomes measurable only after the V2 claim
flow exists.

## V2

V2 may add:

- community groups and `group` visibility
- directed in-app invitations and an `invited` participant status
- guest-record claiming with explicit consent
- calendar subscription and richer availability preferences
- geolocation-aware discovery and suggestions
- Organization-created open matches
- richer player profiles per sport and verified assessments
- match ratings, narrow reputation signals, and carefully scoped badges
- coach/class association where it uses the Academy model

## Future

Keep these outside V2 unless validated demand changes priorities:

- chat, activity feed, and broad social graph
- rankings, leaderboards, challenges, and public competitive history
- automatic matchmaking
- AI coach, scouting, or training recommendations
- wearable integrations
- news or media feed

## Open Decisions Before Implementation

- define leave, removal, and cancellation cutoffs
- define who can record or dispute `no_show`
- decide whether the waitlist is always enabled or configurable by the creator
- choose update channels and reminder timing
- define public versus unlisted indexation and preview fields
- define how cost responsibility or future payment splitting appears to
  participants
- define completion timing and whether the creator alone confirms the outcome
- define discoverability opt-in for rules-based suggestions
