---
title: Shared Documentation Strategy
doc-type: product-architecture-decision
role: source-of-truth
priority: high
canonical: docs/decisions/shared-documentation-strategy.md
related:
  - docs/ai/index.md
  - docs/product/sandicts-product-context.md
  - docs/product/sandicts-mvp-scope.md
  - docs/business-rules/sandicts-business-rules.md
  - docs/glossary/domain-glossary.md
scope: documentation, product-rules, frontend-backend-alignment, source-of-truth, codex
read-when:
  - deciding where product or business documentation should live
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
