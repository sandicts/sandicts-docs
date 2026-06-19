---
name: sandicts-shared-context
description: Use when a Sandicts task needs shared product context, business rules, entity naming, MVP/V2 scope, Jira planning, or frontend-backend alignment.
---

# Sandicts Shared Context

## Purpose

Route Codex to the smallest shared Sandicts documentation set needed for a
task. This skill does not own backend or frontend implementation rules.

## Workflow

1. Start with `docs/ai/index.md`.
2. Read only the shared docs whose `read-when` entries match the task.
3. Prefer concise source-of-truth docs before long working drafts.
4. Use `docs/glossary/domain-glossary.md` for entity names.
5. Use `docs/business-rules/sandicts-business-rules.md` for domain behavior.
6. Use app repository docs for backend-only or frontend-only implementation.
7. If shared docs and app docs disagree about product rules, surface the
   conflict and update the shared source of truth when the rule changes.

## Boundaries

- Do not store secrets, tokens, local paths, or personal preferences here.
- Do not duplicate backend architecture docs here.
- Do not duplicate frontend implementation docs here.
- Do not load long specs unless the task needs detailed flows, screens, or Jira
  roadmap sequencing.
