---
title: Shared Documentation Strategy
doc-type: product-architecture-decision
role: source-of-truth
priority: high
canonical: docs/decisions/shared-documentation-strategy.md
related:
  - docs/ai/index.md
  - docs/decisions/api-contract-governance.md
  - docs/product/sandicts-product-context.md
  - docs/product/sandicts-mvp-scope.md
  - docs/business-rules/sandicts-business-rules.md
  - docs/glossary/domain-glossary.md
scope: documentation, product-rules, frontend-backend-alignment, source-of-truth, codex
read-when:
  - deciding where product or business documentation should live
  - deciding whether a complex feature needs its own document
  - moving docs between shared, backend, and frontend repositories
  - preventing duplicated frontend/backend product rules
  - optimizing Sandicts docs for Codex token usage
do-not-read-when:
  - changing only backend implementation details with no product-rule impact
  - changing only frontend styling or component internals
---

# Shared Documentation Strategy

## Decision

Sandicts shared product and business-rule documentation lives in the dedicated
`sandicts-docs` repository.

Backend and frontend repositories keep only app-specific documentation plus
short pointers to this repository when shared product context is needed.

## Why

Rules such as these must have one source of truth:

- a confirmed reservation blocks a court slot
- a player cannot join the same open match twice
- tournament registration is allowed only while the tournament is open
- Organization users must not access another Organization's data
- academy coaches can manage only assigned classes

The backend enforces many of these rules, but the frontend needs the same
meaning to build the right UX. Duplicating them in both app repositories creates
drift and makes Codex spend tokens reconciling conflicting documents.

## Ownership Rules

Shared docs own:

- product context
- MVP and V2 scope
- business rules
- domain glossary
- product decisions
- Jira roadmap and issue-writing rules
- cross-app API behavior expectations

Backend repo owns:

- backend architecture
- backend implementation patterns
- backend configuration
- backend logging and error handling
- backend CI/CD and testing rules
- generated OpenAPI source and backend API implementation

Frontend repo owns:

- frontend architecture
- app shell and route implementation
- UI/component decisions
- page-level UX implementation notes
- client state, cache, and form patterns

## Document Granularity Rule

Sandicts uses a hybrid documentation model.

Simple, stable rules remain consolidated in the shared overview documents,
especially:

- `docs/business-rules/sandicts-business-rules.md`
- `docs/product/sandicts-mvp-scope.md`
- `docs/product/sandicts-v2-backlog.md`

A complex feature should receive its own document under `docs/product/` when
one or more of these conditions apply:

- it has multiple interacting rules, limits, states, or lifecycle transitions
- it needs examples and edge-case behavior to be understood correctly
- it has important product decisions or open questions of its own
- it is expected to change or grow independently
- keeping its complete behavior in an overview document would make that
  document hard to navigate

Do not create a separate file for every isolated rule. A small group of stable
bullets should remain in the relevant overview document.

When a dedicated feature document exists:

- it owns the detailed behavior for that feature
- overview, scope, and business-rule documents keep only the summary needed for
  routing and decision-making
- overview documents link to the dedicated feature document instead of copying
  all details
- the feature document includes durable frontmatter with `read-when`,
  `do-not-read-when`, `related`, and `scope`
- `docs/ai/index.md` is updated so Codex can load the feature document only
  when relevant
- related scope, glossary, and planning documents are updated when the feature
  changes their decisions

Current examples:

- `docs/product/sandicts-academy-plan-model.md`
- `docs/product/sandicts-player-skill-allocation-model.md`

This separation lets complex rules evolve without turning the general business
rules file into an ever-growing specification for every feature.

## Codex Routing Rules

- Each app repository keeps a small local `.codex/skills` entry point.
- Local skills should point to shared docs only when product, entity, scope, or
  business-rule context is needed.
- Shared skills should not copy backend or frontend implementation rules.
- Long functional specs are on-demand context, not default context.
- Every durable shared doc should include frontmatter with `read-when` and
  `do-not-read-when`.

## API Contract Rule

API contracts should come from backend implementation whenever possible:

- Zod schemas define request and response contracts.
- Swagger/OpenAPI is generated from those schemas.
- The frontend should consume or reference generated contracts rather than
  manually copying request/response shapes.

Shared docs can describe expected product behavior, but generated contracts own
exact request/response shapes.

Cross-app compatibility, deprecation, and delivery expectations live in
`docs/decisions/api-contract-governance.md`. Exact statuses, fields, and codes
remain backend-owned and generated into frontend adapters.

## Local Workspace Rule

Recommended local layout:

```txt
sandicts/
  apps/
    sandicts-docs/
    nodejs-sandicts-api/
    reactjs-sandicts-web/
```

Do not make `sandicts-docs` pretend to be a monorepo that owns the app
repositories. Keep the repositories separate and colocated as siblings.
