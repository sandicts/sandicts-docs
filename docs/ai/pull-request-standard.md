---
title: Sandicts Pull Request Standard
doc-type: delivery-standard
role: source-of-truth
priority: high
canonical: docs/ai/pull-request-standard.md
related:
  - docs/ai/task-finalization-workflow.md
  - .github/pull_request_template.md
  - sandicts/reactjs-sandicts-web:.github/pull_request_template.md
  - sandicts/nodejs-sandicts-api:.github/pull_request_template.md
scope: github, pull-requests, pr-title, pr-description, validation
read-when:
  - writing, opening, or updating a Sandicts pull request
  - auditing PR title or body conventions
  - updating a repository PR template, delivery workflow, or PR-writing skill
do-not-read-when:
  - planning Jira backlog without preparing delivery text
  - changing implementation without committing or opening a PR
---

# Sandicts Pull Request Standard

## Purpose

Keep pull request titles and descriptions consistent across
`sandicts/nodejs-sandicts-api`, `sandicts/reactjs-sandicts-web`, and
`sandicts/sandicts-docs`.

Repository-specific differences belong in validation details and notes, not in
a different PR body shape.

## Title

Use:

```text
[KAN-123] <type>(<scope>): <short summary>
```

Rules:

- the primary Jira key must be the first characters in the PR title
- never use `[codex]`, only a branch name, or a title without a Jira key
- if multiple Jira tasks are delivered, put the primary Jira key in the title
  and list related keys under `Notes`
- override any generic publishing helper, GitHub UI default, or branch-derived
  suggestion before creating or updating the PR
- do not rely on `gh pr create --fill` or a connector's optional title field to
  infer the Sandicts title

## Body

Every Sandicts repository must use this section order:

```md
## Summary

Describe clearly what this pull request changes and the intended scope.

## Problem

Explain the issue, need, or workflow gap this pull request addresses.

## Root cause

Explain the cause identified in code, flow, documentation, or configuration.
For docs-only or setup work, describe why the repository needed this change.

## Changes

- item 1
- item 2
- item 3

## Files added or updated

- `path/to/file`
- `path/to/file`

## Impact

### Fixed

- item
- item

### Not changed

- item
- item

## Validation

- [ ] branch governance (CI: Governance)
- [ ] lint (CI: Quality)
- [ ] typecheck (CI: Quality)
- [ ] tests (CI: Test)
- [ ] build (CI: Build)
- [ ] dependency audit (CI: Dependency audit)
- [ ] manual validation completed

## Notes

- Primary Jira: `KAN-123`
- Related Jira: none
- Jira status: move delivered issue(s) to `In Review` after opening this PR
- Branch cleanup: delete branch after merge enabled
- Known gaps or skipped validation: none
```

Rules:

- fill every section with current PR evidence before opening or updating the PR
- do not create or leave a PR with a blank body, omitted body, raw template
  placeholders, or a shortened alternative such as `What changed` / `Why`
- preserve the headings and order from the local `.github/pull_request_template.md`
- keep skipped validation and repo-specific rationale under `Validation` or
  `Notes`
- for docs-only changes, mention `git diff --check` under
  `Known gaps or skipped validation` instead of adding a custom checkbox
- update the PR body if the scope changes after opening the PR

## Repository Validation

For `sandicts/nodejs-sandicts-api`:

- docs-only: run `git diff --check`
- backend app, API, auth, persistence, config, or startup-sensitive changes:
  run `npm run typecheck`, `npm run test:ci`, `npm run lint:ci`, and
  `npm run build`
- public API, Swagger/OpenAPI, auth/session, or startup-sensitive changes: add
  a smoke check when practical
- dependency or security changes: run the repository dependency audit command
  or document why it was not applicable

For `sandicts/reactjs-sandicts-web`:

- docs-only: run `git diff --check`
- frontend app, configuration, or setup changes: run `npm run lint`,
  `npm run typecheck`, and `npm run build`
- dependency or security changes: run `npm audit --audit-level=moderate`
- tests: run when test tooling exists and the change touches covered behavior

For `sandicts/sandicts-docs`:

- run `git diff --check`
- inspect changed Markdown frontmatter, links, source-of-truth routing, and
  skill metadata when applicable
- do not mark lint, typecheck, tests, build, or dependency audit complete unless
  those commands exist in this repository and actually ran

Do not mark a validation checkbox complete unless that command, manual review,
or CI check actually ran and passed.
