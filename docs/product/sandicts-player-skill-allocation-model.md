---
title: Sandicts Player Skill Allocation Model
doc-type: product-feature-spec
role: source-of-truth
priority: medium
canonical: docs/product/sandicts-player-skill-allocation-model.md
related:
  - docs/product/sandicts-v2-backlog.md
  - docs/product/sandicts-mvp-scope.md
  - docs/business-rules/sandicts-business-rules.md
scope: product, v2, player-progression, levels, skills
read-when:
  - planning V2 player progression
  - defining sport levels, skill budgets, or player skill profiles
  - writing player progression Jira issues or acceptance criteria
do-not-read-when:
  - implementing the MVP simple player level
  - planning academy commercial plans
---

# Sandicts Player Skill Allocation Model

## Product Decision

V2 player progression uses a sport-specific level and a level-specific skill
point budget. It does not calculate or display a player overall.

Players at the same level in the same sport receive the same point budget, but
can distribute it differently across that sport's skills. This expresses
different play styles without ranking one player above another through a
single number.

The MVP remains unchanged: it stores only the simple self-declared level by
sport for matchmaking and filtering.

## Product Intent

Two players can both be advanced while having different strengths.

For example:

- one player can allocate more points to `chapa` and `ombro`, with fewer
  points in `peito`
- another can allocate more points to `shark` and `peito`, with fewer points
  in `chapa`

Both remain at the same level. Their skill profile describes how they play; it
does not produce a hidden overall ranking.

## Separate Concepts

### Level

Level is the coarse sport-specific matchmaking and identity tier, such as:

- beginner
- intermediate
- advanced

The final level catalog and labels remain a separate product decision.

### Skill Catalog

Each sport defines its own set of allocatable skills. Futevolei can include
base fundamentals, attack skills, defensive skills, and special or plastic
moves.

The catalog must be sport-specific. A budget cannot be reused blindly across
sports with different numbers of skills.

### Skill Point Budget

Each combination of sport and level defines a point budget.

Numbers such as 500 points for beginner and 750 for advanced are useful
examples, not final values. Final budgets must be balanced against:

- the number of allocatable skills in the sport
- the maximum score per skill
- any skills unavailable at lower levels
- the amount of differentiation expected inside one level

### Player Skill Allocation

A Player distributes the complete budget among eligible skills. Each skill has
an integer allocation from 0 to 100.

The sum is used only to validate the budget. It must not be presented as an
overall or used to compare players from different levels or sports.

## Core Rules

- skill allocation belongs to one Player, one Sport, and one Level
- every public allocation value is an integer from 0 to 100
- the sum of allocated points must equal the configured budget before the
  skill profile is complete and public
- all Players at the same Sport and Level receive the same budget version
- the UI shows strengths and differences, not a total score
- the product must not calculate card color, ranking, or matchmaking from an
  overall
- initial V2 allocations are self-assessments and must be labeled as such
- a Player can redistribute points, but each completed distribution should be
  stored as a dated snapshot so progression history is not silently rewritten

## Level Changes

When a Player moves to a level with a larger budget:

- existing allocations remain as the starting draft
- the additional points remain unallocated
- the new skill profile is incomplete until the Player distributes the full
  new budget

When a Player moves to a level with a smaller budget:

- the previous allocation remains in history
- the Player must create a new valid distribution within the smaller budget
- the outdated distribution must not be shown as valid for the new level

The profile can still show the current level while skill allocation is
incomplete.

## Why This Is Not An Objective Rating

The fixed budget creates a relative play-style profile. It does not prove
absolute ability.

A Player forced to spend the full budget may have real-world weaknesses in
every skill, while another Player at the same level may be broadly strong.
Their common level is the coarse comparison; the allocation only communicates
where each person believes their strengths are.

Future coach or Academy assessment can add trust without converting the model
into a single overall.

## V2 Delivery Cut

Initial V2 can include:

- sport-specific skill catalogs
- a configured budget for each Sport and Level
- self-allocation with validation
- a clear unallocated-points indicator
- a sport profile that visualizes the distribution
- historical allocation snapshots
- explicit self-assessment labeling

Later improvements can include:

- coach or Academy assessment
- verified skill profiles
- controlled cooldowns between reallocations
- evidence from training or match history
- recommendations based on weaker skills
- level-specific skill availability or prerequisites

## Open Product Decisions Before Implementation

- final level names and ordering
- final budgets for each Sport and Level
- which futevolei items are allocatable fundamentals, attacks, defense, or
  special moves
- whether special moves use points, unlocks, or both
- who can change a Player level in V2
- whether redistribution has a cooldown
- how self-assessment and future coach assessment appear together

## Acceptance Direction

The model is successful when two Players at the same Sport and Level can have
the same total budget and visibly different skill profiles, with neither
receiving a higher overall because of that distribution.
