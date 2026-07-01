---
title: Sandicts V2 And Future Backlog
doc-type: product-backlog
role: source-of-truth
priority: medium
canonical: docs/product/sandicts-v2-backlog.md
related:
  - docs/product/sandicts-mvp-scope.md
  - docs/product/sandicts-player-skill-allocation-model.md
  - docs/product/sandicts-academy-plan-model.md
  - docs/product/sandicts-scope-checklist.md
  - docs/business-rules/sandicts-business-rules.md
scope: product, v2, future, player-progression, tournaments, b2b, social
read-when:
  - deciding whether a feature should wait until V2
  - planning player progression
  - planning tournaments, B2B management, or future community features
do-not-read-when:
  - implementing the MVP reservation or payment core
---

# Sandicts V2 And Future Backlog

## Purpose

This document separates confirmed V2 scope from later future ideas.

The MVP source of truth is `docs/product/sandicts-mvp-scope.md`.

## V2 Themes

V2 should deepen the product after the marketplace core works:

- geolocation and richer discovery
- player identity and evolution
- tournaments
- academy/student management
- better payments and monetization
- notifications and match coordination

## V2 Geolocation And Discovery

V2 scope:

- player can inform location
- player can list nearby places
- player can compare places with richer data
- local can have a photo gallery

Rules to define later:

- location precision and privacy
- whether Organization location is an address, coordinates, service area, or all three
- whether sorting uses distance, availability, price, rating, or sponsored ranking

## V2 Player Profile

V2 scope:

- public player profile
- player photo
- player bio
- player nationality
- player side of game: right, left, both
- richer sport profile

MVP dependency:

- keep MVP `Player`, `Sport`, `mainSport`, and simple level compatible with the V2 profile.

## V2 Player Evolution

V2 scope:

- player sport profile shows sport, photo, nationality, game side, and level
- player has sport-specific fundamentals
- each Sport and Level defines a skill point budget
- player distributes the complete budget across eligible sport-specific skills
- each skill allocation has a score from 0 to 100
- players at the same Sport and Level have the same budget but can express
  different strengths
- no player overall is calculated or displayed
- player can register monthly evolution
- player can compare historical evolution
- player can self-assess
- coach or Academy can assess player
- system can group fundamentals, attack, defense, and special/plastic skills
  without reducing them to one overall

Important product principle:

- evolution is a retention and identity layer, not a requirement for MVP reservations
- MVP simple level must not pretend to be a verified skill assessment
- skill allocation describes play style within a level; it is not an objective
  comparison of absolute ability

Detailed model:

- [`docs/product/sandicts-player-skill-allocation-model.md`](sandicts-player-skill-allocation-model.md)

Future after V2:

- coach confirmation requirement
- badges and achievements
- rankings based on evolution
- AI training suggestions

## V2 Futevolei Progression Model

Initial V2 backlog for futevolei:

- chapa direita
- chapa esquerda
- ombro direito
- ombro esquerdo
- peito
- coxa direita
- coxa esquerda
- cabeca para ataque
- cabeca para defesa
- lobby
- diagonal longa
- diagonal curta
- shark
- voo da aguia
- pingo
- pingo para tras
- pingo de ombro
- pingo de costas
- plastic resources as skill stars, similar to dribbles in football games

Open modeling questions:

- which items are core fundamentals
- which items are attack skills
- which items are defensive skills
- which items are plastic/resources
- whether plastic/resources use points, unlocks, or both
- final point budget for each futevolei level
- whether Academy/coach assessment should weigh more than self-assessment

## V2 Tournaments

V2 scope:

- Organization creates tournament
- tournament has sport
- tournament has date and local
- tournament has participant limit
- player can register
- duplicate registration is blocked
- registration is blocked when tournament is closed
- statuses: `open`, `in_progress`, `finalized`, `canceled`

Future after V2:

- bracket generation
- result entry
- tournament ranking
- advanced tournament reports

## V2 Academy And B2B Management

V2 scope:

- Academy can manage coaches
- Academy can manage classes/groups
- Academy can manage richer student records
- Academy can add recurring renewal and monthly tuition behavior to MVP plans
- Academy can see active students
- Academy can see overdue students
- Academy can see revenue by period
- Organization can see reservations by period
- Organization can create events

MVP dependency:

- evolve the MVP `AcademyPlan`, `AcademyPlanAccess`, `AcademyPlanUsage`, and
  manual Payment records without changing historical purchases.

## V2 Payments And Monetization

V2 scope:

- refunded payment state as an operational flow
- payment gateway integration
- Sandicts commission model by reservation
- Academy delinquency visibility for own students/customers

Future after V2:

- split or payout automation
- reconciliation
- Organization and Academy financial statements

## V2 Open Match Improvements

V2 scope:

- Organization can create open match
- notifications
- invites to matches

Future after V2:

- chat
- arena/community groups
- automatic matchmaking

## Future Backlog

Future ideas:

- Admin App when there is a real operational need
- reviews and ratings
- social follow/friends/feed
- local, sport, arena, and tournament rankings
- monthly highlights
- achievements
- Web3 tokens
- NFT achievements
- digital trophies
- collectible player card
- store
- coach marketplace
- intelligent recommendations
- automatic matchmaking
- AI training suggestions
- Organization and Academy system integrations
- `altinha` as an additional sport

## Do Not Pull Into MVP

Do not pull these into the MVP unless the product direction explicitly changes:

- geolocation
- player evolution
- tournaments
- full Academy ERP
- payment gateway
- rankings
- achievements
- Web3
- social feed
- AI recommendations
