---
name: jira-pr-commit-writer
description: Use when working in the Sandicts Docs repository and the user asks for a Jira task, issue text, PR title, PR description, commit message, release note, or delivery summary after planning or changing shared documentation.
---

# Jira PR Commit Writer

## Purpose

Generate consistent Jira comments, pull request descriptions, commit messages,
and delivery summaries for Sandicts shared documentation work.

Use repository evidence first: the user request, changed files, `git diff`,
`git status`, `docs/ai/index.md`, and any relevant source-of-truth document
under `docs/product/`, `docs/business-rules/`, `docs/glossary/`, or
`docs/decisions/`.

When finishing a task, preparing commits, opening a PR, updating a PR title, or
producing a delivery summary, read `docs/ai/task-finalization-workflow.md`
and `docs/ai/pull-request-standard.md` first.

## Output Contract

Default language:

- Use English for Jira titles, Jira descriptions, PR titles, PR descriptions,
  commit messages, release notes, and delivery summaries unless the user
  explicitly requests another language.
- Follow `docs/ai/task-finalization-workflow.md` and
  `docs/ai/pull-request-standard.md` for PR titles, PR bodies, validation, and
  commit messages.

## PR Title

Use this format:

```text
[KAN-123] <type>(<scope>): <short summary>
```

Rules:

- The primary Jira key must be the first characters in the PR title.
- Never use `[codex]`, a branch name, or a title without a Jira key.
- If a generic publishing tool suggests another title, override it with this
  Sandicts format before opening or updating the PR.
- Do not rely on `gh pr create --fill` or optional connector fields to infer a
  compliant PR title.
- Follow the same PR title format in every Sandicts repository.

## PR Description

Always inspect `.github/pull_request_template.md` and preserve the template
headings and order exactly.

Use the same PR body structure across Sandicts repositories. Repository-specific
differences belong in the `Validation` and `Notes` sections, not in a different
template shape.

Never create or leave a PR with a blank body, omitted body, raw template
placeholders, or a shortened alternative body.

Shared docs validation defaults:

- run `git diff --check`
- inspect changed Markdown frontmatter, links, and skill routing metadata when
  applicable
- do not mark lint, typecheck, tests, build, or dependency audit as complete
  unless those commands exist in this repository and actually ran

## Commit Message

Use Conventional Commits:

```text
<type>(<scope>): <imperative summary>
```

Types:

- `docs`: documentation-only change
- `fix`: correction to broken or misleading documentation
- `chore`: repository maintenance

Scopes:

- Prefer concrete scopes such as `process`, `product`, `business`, `glossary`,
  `planning`, `skills`, or `docs`.

Rules:

- Use imperative mood.
- Keep the first line under 72 characters when practical.
- The PR title carries the Jira key by default.
- Do not include a Jira key in the commit unless the user explicitly asks for
  it or the commit will be consumed outside PR context.

## Evidence Checklist

Before generating final text:

- Inspect `git status --short` and `git diff --stat` when changes exist.
- Inspect relevant file diffs when the task depends on exact documentation
  details.
- Read relevant `docs/ai/`, `docs/product/`, `docs/business-rules/`,
  `docs/glossary/`, or `docs/decisions/` context.
- Separate facts from assumptions. Label assumptions explicitly when needed.
