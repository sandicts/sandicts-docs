# Sandicts Shared Docs

This repository owns Sandicts documentation that must be shared by backend,
frontend, product planning, and AI-assisted work.

## Purpose

Use this repository as the single source of truth for:

- product context
- MVP and V2 scope
- business rules
- domain glossary
- cross-app product decisions
- cross-app deployment, environment, and browser integration decisions
- cross-repository development workstation onboarding
- Jira roadmap and issue-writing rules
- AI routing for shared Sandicts context

Do not put backend-only architecture, frontend-only UX/component rules, secrets,
or machine-specific credentials and state here.

## Local Workspace

Recommended sibling layout:

```txt
sandicts/
  apps/
    sandicts-docs/
    nodejs-sandicts-api/
    reactjs-sandicts-web/
```

Backend and frontend repositories should keep short local AI routers and point
to this repository only when shared product or business context is needed.

For a new or existing machine that must continue Sandicts development across
all repositories, follow:

- `docs/engineering/development-workstation-onboarding.md`

## AI Entry Point

Start with:

- `docs/ai/index.md`

Then read only the files selected by its `read-when` routing. Avoid loading
long roadmap or functional specs unless the task needs their details.

## Documentation Granularity

Simple and stable rules stay in the shared scope and business-rule documents.
Complex features that have interacting rules, states, examples, or independent
evolution receive a dedicated document under `docs/product/`.

The full decision is documented in:

- `docs/decisions/shared-documentation-strategy.md`

Current cross-app technical decisions include:

- `docs/decisions/api-contract-governance.md`
- `docs/decisions/frontend-deployment-target.md`
