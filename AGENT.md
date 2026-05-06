# Agent instructions

This repository requires tasking, review, and remediation documents to treat
primary goals as enforceable lock items, not as descriptive intent only.

When writing or revising PRDs, tranche documents, tasking documents, review
scopes, audit scopes, or remediation plans:

- read and follow the repo governance documents, especially
  `STYLE-workflow-docs.md` and `STYLE-verification.md`
- convert every user-stated primary goal, explicit non-negotiable, review
  finding, compatibility boundary, and migration boundary into a separate lock
  item
- for each lock item, state:
  - the non-completion condition: "the work is not complete if..."
  - the direct red-state repro, historical failure mode, or equivalent current
    bad behavior
  - the task, task group, or owner that closes it
  - the verification artifact that fails the current bad implementation or
    fake-fix shape

Tasking is incomplete if a fresh implementing agent could plausibly declare
success while any lock item still survives behind a green suite, docs build, or
source-text audit.

Do not treat passing tests, passing docs builds, grep results, or helper-level
checks as sufficient proof by themselves when a more direct contract-level
artifact exists.

If a derivable design decision is still open, resolve it in the workflow
document or convert it into an explicit `REVIEW` task. Do not leave it as
implicit implementer judgment.
