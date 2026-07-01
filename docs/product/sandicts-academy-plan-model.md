---
title: Sandicts Academy Plan Model
doc-type: product-feature-spec
role: source-of-truth
priority: high
canonical: docs/product/sandicts-academy-plan-model.md
related:
  - docs/product/sandicts-mvp-scope.md
  - docs/business-rules/sandicts-business-rules.md
  - docs/glossary/domain-glossary.md
scope: product, mvp, academy, plans, access, payments
read-when:
  - planning or implementing academy plans
  - defining plan validity, usage limits, sales, or expiration
  - writing Academy plan Jira issues or acceptance criteria
do-not-read-when:
  - changing only Organization court reservations
  - implementing V2 player progression
---

# Sandicts Academy Plan Model

## Product Decision

Academies can create and manually sell or grant configurable plans in the MVP.

This is a deliberate expansion of the Academy MVP scope. It introduces the
minimum student access and usage control required for plans, but it does not
bring full class, coach, attendance, billing, or school ERP management into the
MVP.

The model must support plans named by the Academy rather than fixed product
labels. A plan called "Monthly" can be valid for 28 calendar days; its name does
not determine its duration.

## User Problem

Academies sell access in different ways:

- unlimited access for a fixed number of calendar days
- a limited number of uses per week during a validity period
- a fixed package of classes that expires if not consumed in time
- a combination of a total class allowance and a weekly usage limit

A fixed `monthly` plan type cannot represent these offers accurately.

## Domain Vocabulary

- `AcademyPlan`: reusable commercial offer configured by an Academy.
- `AcademyPlanAccess`: individual access sold or granted to a Player from an
  AcademyPlan.
- `AcademyPlanUsage`: auditable consumption or restoration of one class/use
  from an AcademyPlanAccess.

`AcademyPlan` is a template. `AcademyPlanAccess` must snapshot the commercial
and usage rules that applied when the access was created.

Do not use `Membership` as the generic name for every plan. A class package
with eight uses is not necessarily recurring membership.

## Academy Plan Configuration

Each plan has:

- Academy owner
- Academy-defined name
- optional public description
- price and currency
- validity in positive whole calendar days
- optional total use allowance
- optional weekly use limit
- active or inactive availability

Usage configuration is intentionally composable:

- no total allowance and no weekly limit means unlimited use while valid
- a weekly limit caps use in each seven-day access cycle
- a total allowance caps use during the entire access
- when both limits exist, both must be respected

The product UI may present friendly presets such as `Unlimited`,
`Times per week`, and `Class package`, while the underlying rules remain
composable.

## Examples

| Academy offer | Validity | Total uses | Weekly limit |
| --- | ---: | ---: | ---: |
| 15 days unlimited | 15 days | none | none |
| 15 days, up to twice per week | 15 days | optional | 2 |
| Monthly plan with a 28-day cycle | 28 days | none | none |
| Package of 8 classes valid for 45 days | 45 days | 8 | none |
| Package of 8 classes, at most twice per week | Academy-defined | 8 | 2 |

For the 15-day twice-per-week example, the Academy can also define a total
allowance when it wants to guarantee an exact maximum across the complete
period.

## Validity And Weekly Windows

MVP rules:

- validity uses calendar days, not a calendar-month calculation
- the activation date is day one
- access expires at the end of the last valid day in the Academy timezone
- for example, access activated on July 1 with 28 validity days remains valid
  through July 28 and is expired on July 29
- weekly limits use consecutive seven-day windows anchored to the access
  activation date
- a final partial seven-day window keeps the configured weekly limit
- a total allowance can additionally cap usage across all windows
- unused uses expire with the access and do not roll over

## MVP Flows

An Academy owner or admin can:

- create a plan
- edit the offer used for future sales
- activate or deactivate a plan
- list active and inactive plans
- manually sell or grant a plan to an existing Player
- choose the access activation date
- see the access expiration date and remaining uses
- manually register one use
- reverse an incorrectly registered use with an auditable correction
- see whether access is scheduled, active, exhausted, expired, or canceled
- manually update the related payment status

A Player can:

- see their Academy plan name
- see the Academy
- see activation and expiration dates
- see total and remaining uses when a total allowance exists
- see the current weekly limit and usage when a weekly limit exists
- see the payment and access statuses

## Access And Usage Rules

- Creating access snapshots the plan name, price, currency, validity, total
  allowance, and weekly limit.
- Editing a plan affects only future access.
- Deactivating a plan prevents new sales or grants but does not cancel existing
  access.
- Only active access can consume a use.
- A use is blocked when access is expired, exhausted, canceled, or over its
  current weekly limit.
- A total allowance is exhausted when its remaining uses reach zero.
- Usage corrections must preserve history; they must not silently delete the
  original record.
- Price can be zero for a trial or complimentary plan.
- MVP access belongs to an existing Sandicts Player; external or guest student
  records remain outside this cut.
- An Academy controls only its own plans, access records, usages, and payments.

Recommended access statuses:

- `scheduled`
- `active`
- `exhausted`
- `expired`
- `canceled`

## Payment Boundary

MVP payment remains manual:

- creating plan access can create or reference a manual Payment record
- the Academy controls the recorded payment status for its own customer
- free access does not require a paid Payment
- gateway checkout, automatic charge, renewal, split, and payout are not part
  of this feature

Access activation and payment are explicit states. An Academy may grant or
activate access while payment is pending, but the pending state must remain
visible.

## Explicitly Outside This MVP Feature

- automatic recurring renewal
- payment gateway checkout
- subscription pause or freeze
- proration
- coupons and promotion engines
- refunds as an automated financial flow
- transferring or sharing uses between Players
- rolling unused uses into a new access
- full student CRM
- class schedules and booking
- coach assignment
- automatic attendance or check-in
- automated delinquency workflows
- advanced revenue reports

## Acceptance Direction

The feature is successful when an Academy can represent each example in this
document without relying on the plan name for behavior, and when the system can
determine whether one more use is allowed at a given time.
