---
date-created: 2026-05-06T00:58:27-07:00
date-revised: 2026-05-06T00:58:27-07:00
status: proposed
---

# Tasks for Tranche 3 remediation: honest ratification, handoff repair, and vocabulary synchronization

Tasking identifier: `20260506T005827--tranche-3-remediation-tasking`

Parent tranche: Tranche 3
Parent PRD: `01_prd.md`
Parent tasking: `03_tranche-3--tasking.md`
Parent decision artifact under remediation:
`.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`

## Settled user decisions and environment baseline

- Treat `FileIO.load(...)` as a compatibility wrapper, not as the canonical
  package-owned owner of LineagesIO load semantics.
- Preserve authoritative table construction as the canonical parse output and
  preserve the typed-core and compatibility-boundary decisions already settled
  by the parent PRD and earlier tranche work.
- No repo-owned public API removal, rename, export change, deprecation, or
  signature break is authorized unless the user ratifies it explicitly through
  the reserved Tranche 3 review gate.
- No final exported package-owned public load verb has been honestly ratified
  yet in a recorded user review artifact.
- No final exported public builder-surface spelling has been honestly ratified
  yet in a recorded user review artifact.
- The long-term public role of `load_alife_table(...)` still requires explicit
  review or explicit deferral. Current export status is not itself a decision.
- The current decision record exists, but it is not safe to treat as the
  authoritative Tranche 3 outcome until the review-derived findings below are
  repaired.
- Tranche 4 remains blocked until the decision record contains an actual
  recorded user review outcome and any ratified public identifiers are either
  synchronized into `STYLE-vocabulary.md` with explicit approval or the block
  remains in place.
- Use the existing root environment and the existing `test/Project.toml`,
  `docs/Project.toml`, and `examples/Project.toml` environments. Do not add
  dependencies or edit dependency declarations directly without user review.
- Use the approved upstream workspace at
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`
  for `FileIO` and `Tables` primary-source reading.
- This remediation is workflow-scoped. It may revise
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  and, if and only if the user explicitly approves exact public identifiers,
  `STYLE-vocabulary.md`. It must not implement Tranche 4 rollout work in
  `src/*`, `README.md`, `docs/src/*`, `examples/*`, or `test/*`.

## Governance

Explicit line-by-line reading is mandatory before implementation. All
downstream work must read and conform to:

- `AGENTS.md`
- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-makie.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-3a--remediation-tasking.md`

The bundled governance baseline under
`/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/`
was also read for this remediation run. Repo-local `AGENTS.md`,
`CONTRIBUTING.md`, and `STYLE*.md` files remain the active authorities for this
repository when they are more specific.

Workflow authorities used to produce this tasking were `development-policies`
and `devflow-architecture-03--tranche-to-tasks`. Downstream execution must
preserve their pass-forward mandates, especially active-authority restatement,
exact upstream-source naming, controlled vocabulary, exact authorization
boundaries, primary-goal lock items, direct red-state repros, and
failure-oriented verification.

Upstream primary sources that must be read line by line for this remediation
are:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/src/Tables.jl`

These sources constrain the work as follows:

- `FileIO` owns the host-framework `load(...)` surface, format inference,
  ambiguity handling, `File{fmt}` wrappers, `Stream{fmt}` wrappers, and
  formatted dispatch.
- `Tables` owns the in-memory table contract used by `load_alife_table(...)`,
  including `Tables.istable`, `Tables.columns`, `Tables.columnnames`,
  `Tables.getcolumn`, and the optional typed `getcolumn` entrypoint.
- Local inference from those verified upstream facts: a package-owned
  first-class public surface must remain classified separately from `FileIO`
  host dispatch, and the decision record cannot honestly unblock Tranche 4 on
  guessed public identifiers or a guessed compatibility story.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use
`basenode`, `compatibility wrapper`, `package-owned public surface`,
`authoritative tables`, `materialized graph or basenode result`,
`source descriptor`, `materialization descriptor`, `ownership boundary`,
`lock item`, `red-state repro`, `handoff packet`, and `verification artifact`
consistently. Do not treat candidate names such as `LineagesIO.read_lineages`
or `LineagesIO.BuilderDescriptor` as canonical vocabulary unless the user
approves them explicitly and `STYLE-vocabulary.md` is updated accordingly.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, rebase, reset, and branch creation remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Review-derived current-state diagnosis

This remediation exists because the completed Tranche 3 artifact currently
fails review in three separate contract-level ways:

- The decision record self-ratifies public names and Tranche 4 unblocking
  without any recorded user review evidence or explicit deferral language.
- The decision record's handoff packet is still Tranche-3-scoped workflow-only
  scope while simultaneously claiming that Tranche 4 is unblocked for rollout.
- The decision record coins exact public identifiers that are not synchronized
  into the authoritative vocabulary file, even though `STYLE-vocabulary.md`
  requires explicit approval and in-file amendment before new canonical terms
  are implemented.

These are not style-only issues. A fresh implementing agent could use the
current artifact to ship an unreviewed public naming decision, skip the real
Tranche 4 rollout surfaces and gates, and implement identifiers that are not
yet authorized by the vocabulary authority.

## Primary-goal lock

### Lock 1: the decision record must stop inventing ratification and unblock status

- The work is not complete if
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  still claims `status: ratified`, "user-ratified" decisions, or "Tranche 4
  unblocked" without an actual recorded user review outcome or an explicit
  deferral statement.
- Direct red-state repro: the current decision record claims ratified
  `LineagesIO.read_lineages`, ratified `LineagesIO.BuilderDescriptor`, and
  "Current status: unblocked" even though no user-reviewed approval artifact is
  recorded in the workflow documents.
- Closing tasks: 1, 2, and 4.
- Verification artifact that must fail the old implementation or fake-fix
  shape: the final decision record itself, containing either an actual recorded
  user review outcome or an explicit deferral that keeps Tranche 4 blocked. The
  current file fails this artifact because it asserts ratification without
  recorded review evidence.

### Lock 2: the Tranche 4 handoff must match actual rollout scope and gates

- The work is not complete if a fresh Tranche 4 implementing agent could still
  read the decision record and conclude that rollout scope excludes `src/*`,
  `README.md`, `docs/src/*`, `examples/*`, `test/*`, and exports while Tranche
  4 is supposedly unblocked.
- Direct red-state repro: the current handoff packet says "Exact scope in: this
  decision record", "Exact scope out: `src/*`, `README.md`, `docs/src/*`,
  `examples/*`, `test/*`, export lists, deprecations, migration behavior", and
  "Green-state gates: inherit the repository's prior green state" while also
  claiming Tranche 4 is unblocked.
- Closing tasks: 1 and 4.
- Verification artifact that must fail the old implementation or fake-fix
  shape: a final handoff packet in the decision record that either names the
  real Tranche 4 rollout surfaces and gates from
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md` or states
  explicitly that Tranche 4 remains blocked and why. The current handoff fails
  because it is still workflow-only while claiming rollout authorization.

### Lock 3: the vocabulary authority must agree with any ratified public names

- The work is not complete if the decision record unblocks implementation of
  exact public identifiers that are absent from `STYLE-vocabulary.md`, or if
  `STYLE-vocabulary.md` is changed without explicit user approval for those
  exact names.
- Direct red-state repro: the current decision record names
  `LineagesIO.read_lineages` and `LineagesIO.BuilderDescriptor` as ratified
  public identifiers, but `STYLE-vocabulary.md` contains neither term.
- Closing tasks: 2, 3, and 4.
- Verification artifact that must fail the old implementation or fake-fix
  shape: either an updated `STYLE-vocabulary.md` containing the user-approved
  exact identifiers and explicit approval note, or a final decision record that
  says Tranche 4 remains blocked pending vocabulary approval. The current state
  fails because the identifiers appear only in the decision record.

## Handoff packet

- Active authorities:
  `AGENTS.md`, `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`,
  `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`,
  `STYLE-workflow-docs.md`, `STYLE-writing.md`,
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  and this remediation tasking file
- Parent documents:
  `01_prd.md`, `02_tranches.md`, `03_tranche-3--tasking.md`, and the current
  `00_tranche3-public-surface-decision.md`
- Settled decisions and non-negotiables:
  `FileIO.load(...)` remains compatibility-only; no repo-owned public API
  breakage is authorized without explicit user ratification; no public name is
  honestly ratified yet merely because it appears in the current decision
  record; `load_alife_table(...)` still requires explicit classification or
  explicit deferral; typed-core and authoritative-table semantics are not being
  reopened here
- Authorization boundary:
  this remediation may revise the Tranche 3 decision record and, if explicitly
  approved by the user, `STYLE-vocabulary.md`; it must not implement Tranche 4
  rollout in code, user docs, examples, tests, or exports
- Current-state diagnosis:
  the decision record currently self-ratifies names and unblocking without
  recorded review evidence, carries a workflow-only handoff while claiming
  rollout readiness, and leaves vocabulary authority out of sync with candidate
  public identifiers
- Primary-goal lock:
  Locks 1 through 3 above are mandatory and separate
- Direct red-state repros:
  self-ratified `read_lineages` and `BuilderDescriptor`; Tranche 4 marked
  unblocked on workflow-only scope; candidate names absent from
  `STYLE-vocabulary.md`
- Owner and invariant under repair:
  the review-gated public-contract decision artifact and the governance rule
  that public names and rollout authorization must be supported by recorded user
  review and synchronized vocabulary authority
- Exact files or surfaces in scope:
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  and, if explicitly approved by the user, `STYLE-vocabulary.md`
- Exact files or surfaces out of scope:
  `src/*`, `README.md`, `docs/src/*`, `examples/*`, `test/*`, `Project.toml`,
  exports, deprecations, and public rollout implementation
- Required upstream primary sources:
  the six `FileIO` and `Tables` sources listed in the Governance section above
- Green-state gates:
  if this remediation touches only
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  and, if explicitly approved, `STYLE-vocabulary.md`, inherit the prior
  repository code-and-user-doc green state; if any `src/*`, `README.md`,
  `docs/src/*`, `examples/*`, or `test/*` file changes, stop for scope drift
  because the work has crossed into Tranche 4
- Stop conditions:
  stop and revise this remediation if a local workflow artifact already records
  actual user approval for the disputed names or if the decision record has
  already been repaired; stop and escalate if execution would need code, docs,
  examples, test, export, deprecation, or migration rollout work

## Required revalidation before implementation

- Read `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`,
  and the current
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  in full.
- Read `STYLE-vocabulary.md` in full.
- Read `src/LineagesIO.jl`, `src/load_owner.jl`, `src/load_compat.jl`,
  `README.md`, `docs/src/index.md`, and `docs/src/phylonetworks.md` in full.
- Re-read the upstream `FileIO` and `Tables` primary sources listed above in
  full before preserving or rewriting any claimed contract conclusion.
- Re-check that the current decision record still claims `status: ratified`,
  still names exact public identifiers as ratified decisions, and still marks
  Tranche 4 unblocked.
- Re-check that the current handoff packet still says "Exact scope in: this
  decision record" and still excludes rollout files and gates while claiming
  unblocked status.
- Re-check that `STYLE-vocabulary.md` still does not contain the currently
  claimed public identifiers.
- Re-check that no other local workflow artifact records actual user approval
  for those exact names. If such an artifact exists, stop and revise this
  remediation tasking before proceeding.
- If any of these revalidation points no longer hold, stop and revise this
  remediation tasking before proceeding.

## Tranche execution rule

This remediation repairs the honesty and downstream safety of the Tranche 3
decision artifact. It is not a public rollout tranche.

When this remediation is complete:

- the decision record must no longer claim ratification or Tranche 4
  unblocking without a real recorded review outcome
- every public-surface decision cluster reserved by Tranche 3 must be either
  explicitly ratified by the user or explicitly deferred with a block condition
- any ratified public identifier must either be synchronized into
  `STYLE-vocabulary.md` with explicit approval or leave Tranche 4 blocked
- the final handoff packet must either be genuinely Tranche-4-scoped or must
  say plainly that Tranche 4 remains blocked
- repo-owned code, user docs, examples, tests, exports, and deprecations must
  remain untouched

## Non-negotiable execution rules

- Do not turn silence, prior assistant prose, or current decision-record text
  into approval.
- Do not leave `status: ratified`, "user-ratified", or "Current status:
  unblocked" in the decision record unless the file also records the actual
  user review outcome that supports those claims.
- Do not keep a workflow-only handoff packet in any artifact that claims
  Tranche 4 is ready for rollout.
- Do not add candidate identifiers to `STYLE-vocabulary.md` unilaterally.
- Do not treat the current decision record as a substitute for vocabulary
  approval.
- Do not backfill `.workflow-docs/log.20260418T2301--vocabulary.md` or invent a
  separate vocabulary workflow unless a higher-priority authority explicitly
  requires it for this remediation.
- Do not implement `LineagesIO.read_lineages`, `LineagesIO.BuilderDescriptor`,
  export changes, docs repositioning, examples, or tests in this remediation.
- Do not reopen the settled `FileIO` compatibility-wrapper boundary, the
  typed-core owner, authoritative tables, retention semantics, or stable asset
  destructuring order under the label of workflow repair.

## Concrete anti-patterns or removal targets

- decision-record sentences such as "The user has now ratified..." when no
  recorded user review artifact exists
- front matter or status prose that marks the file `ratified` while review
  evidence is absent
- "Current status: unblocked" while the handoff packet still scopes work to the
  decision record only
- handoff packets that exclude rollout surfaces and gates while claiming
  additive rollout is authorized
- decision artifacts that treat current candidate names as canonical
  vocabulary before `STYLE-vocabulary.md` is amended
- any attempt to repair the review by changing code, docs, examples, tests, or
  exports instead of fixing the decision artifact and its governing boundary

## Failure-oriented verification

- The final decision record must contain explicit recorded user answers, or
  explicit recorded deferrals, for:
  - the first-class package-owned public verb
  - the builder public spelling
  - the `load_alife_table(...)` role
  - migration and deprecation policy
  - vocabulary approval for any exact public identifiers chosen above
- A fake fix fails if any one of those five decision clusters remains implicit,
  is answered only by current code or docs reality, or is answered only by
  inherited prose from the old decision record.
- If the user defers any required cluster, the final decision record must state
  plainly that Tranche 4 remains blocked and must name the exact block reason.
- If the user ratifies the public-surface path fully and also approves exact
  identifiers, the final handoff packet must align with the Tranche 4 scope in
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`: repo-owned
  API, docs, README, examples, direct public-surface tests, and the documented
  test and docs gates.
- If the user ratifies public names but does not approve their entry into
  `STYLE-vocabulary.md`, the decision record must remain blocked on that
  governance reason. Unblocking anyway fails verification.
- If `STYLE-vocabulary.md` is updated, it must contain the exact user-approved
  identifier spellings and an explicit approval note. Adding guessed or inferred
  names fails verification.
- If this remediation touches only the decision record and, if approved,
  `STYLE-vocabulary.md`, inherit the prior repository code-and-user-doc green
  state. If any code, user docs, examples, tests, or exports change, stop for
  scope drift instead of claiming success.

## Tasks

### 1. Reopen the decision record to an honest pre-review state

**Type**: WRITE  
**Output**: `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
is revised from an unsafe self-ratified artifact into an honest review-gated
draft or deferred-state document that no longer claims unsupported ratification
or unsupported Tranche 4 unblocking.  
**Depends on**: none  
**Positive contract**: The revised file must preserve the verified current-state
inventory and upstream contract facts, but it must remove or rewrite invented
ratification claims, invented user-approval prose, and unsupported unblock
status. It must restate the reserved review questions explicitly and mark
Tranche 4 blocked until a real review outcome is recorded.  
**Negative contract**: Do not keep `status: ratified`, "user-ratified", or
"Current status: unblocked" without review evidence. Do not change
`STYLE-vocabulary.md` in this task. Do not implement or document rollout.  
**Files**:
`.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`  
**Out of scope**: `STYLE-vocabulary.md`, `src/*`, `README.md`, `docs/src/*`,
`examples/*`, `test/*`, exports, deprecations, rollout implementation  
**Verification**: The revised decision record must no longer assert unsupported
ratification or unsupported unblocking. The old artifact must fail this task
because it currently claims ratified `LineagesIO.read_lineages`, ratified
`LineagesIO.BuilderDescriptor`, and unblocked Tranche 4 without recorded user
review evidence.

Repair the artifact to the last honest state before the real review gate. Keep
the inventory, guarantee matrix, and migration note strong enough that the next
REVIEW step chooses among explicit options rather than rediscovering the load
surfaces.

### 2. Run the actual user-review and approval gate

**Type**: REVIEW  
**Output**: The decision record contains explicit user-reviewed answers, or
explicit user-reviewed deferrals, for the public-verb decision, the builder
public-spelling decision, the `load_alife_table(...)` role decision, the
migration-and-deprecation decision, and the vocabulary-approval decision for
any exact public identifiers chosen.  
**Depends on**: 1  
**Positive contract**: Each of the five decision clusters above must be
resolved separately or explicitly deferred separately. If the user chooses a
distinct public name, the record must capture the exact spelling approved. If
the user declines to choose or declines vocabulary approval, the record must
say so explicitly and preserve the resulting block condition.  
**Negative contract**: Do not turn silence into approval. Do not let current
candidate names answer the review by inertia. Do not broaden additive-only
authorization into general public breakage approval. Do not treat vocabulary
silence as permission to implement new canonical names.  
**Files**:
`.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`  
**Out of scope**: `STYLE-vocabulary.md`, `src/*`, `README.md`, `docs/src/*`,
`examples/*`, `test/*`, exports, deprecations, rollout implementation  
**Verification**: The reviewed artifact must record explicit answers or
explicit deferrals for all five decision clusters. A fake fix fails if any one
cluster remains implicit or if the only evidence is the old decision record's
unsupported prose.

The review must resolve or defer, explicitly and separately:

- whether the first-class package-owned public verb is `LineagesIO.load`, a
  distinct exported name, or deferred
- what public spelling, if any, should represent the builder-driven typed
  surface
- whether `load_alife_table(...)` is first-class, convenience, transitional, or
  compatibility-only
- whether any deprecations, renames, removals, or explicit migration notes are
  approved
- whether any exact chosen public identifiers are approved for canonical entry
  into `STYLE-vocabulary.md`

### 3. Synchronize the vocabulary authority or preserve the block

**Type**: WRITE  
**Output**: `STYLE-vocabulary.md` is updated with exact user-approved public
identifiers and explicit approval if such approval was given, or the decision
record states explicitly that Tranche 4 remains blocked because vocabulary
approval was not granted or naming was deferred.  
**Depends on**: 2  
**Positive contract**: If the user approves exact public identifiers and
approves their vocabulary entry, `STYLE-vocabulary.md` must become the
authoritative home of those canonical names. If the user defers naming or
declines vocabulary approval, `STYLE-vocabulary.md` must remain unchanged and
the decision record must preserve the block explicitly.  
**Negative contract**: Do not add names to `STYLE-vocabulary.md` unilaterally.
Do not leave Tranche 4 unblocked while the vocabulary file lacks the
user-approved identifiers. Do not create or backfill
`.workflow-docs/log.20260418T2301--vocabulary.md` in this remediation unless a
higher-priority authority explicitly requires it.  
**Files**: `STYLE-vocabulary.md`,
`.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`  
**Out of scope**: `.workflow-docs/log.20260418T2301--vocabulary.md`, `src/*`,
`README.md`, `docs/src/*`, `examples/*`, `test/*`, exports, rollout
implementation  
**Verification**: If names are approved for vocabulary entry, `STYLE-vocabulary.md`
must contain the exact approved spellings and an explicit approval note. If
names are not approved or are deferred, the final decision record must say that
Tranche 4 remains blocked on that reason. The old state must fail because the
candidate names appear only in the decision record and not in
`STYLE-vocabulary.md`.

This task closes the vocabulary finding either by synchronizing the authority or
by preserving the block honestly. It must not leave a half-ratified middle
state.

### 4. Finalize the decision record and the Tranche 4 handoff boundary

**Type**: WRITE  
**Output**: `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
is complete, internally consistent, and safe for downstream use because its
status, decisions, vocabulary state, and Tranche 4 handoff all match the actual
review outcome.  
**Depends on**: 2, 3  
**Positive contract**: If the user ratifies a path fully and vocabulary
authority is synchronized, the final decision record may mark Tranche 4
unblocked and must provide a genuinely Tranche-4-scoped handoff packet using
the rollout surfaces, gates, and additive-only boundary from
`.workflow-docs/202605040131_type-stable-parse/02_tranches.md`. If any review
cluster is deferred or vocabulary authority remains pending, the file must mark
Tranche 4 blocked and name the exact remaining stop condition.  
**Negative contract**: Do not keep a workflow-only handoff packet when claiming
Tranche 4 is unblocked. Do not inherit prior green state as the only downstream
proof for an unblocked rollout tranche. Do not reopen settled compatibility or
typed-core decisions. Do not implement the rollout itself here.  
**Files**:
`.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`  
**Out of scope**: `STYLE-vocabulary.md` except for references to its settled
state, `src/*`, `README.md`, `docs/src/*`, `examples/*`, `test/*`, exports,
deprecations, rollout implementation  
**Verification**: Confirm that the final decision record closes Locks 1 through
3 directly. Confirm that a fresh implementing agent could use the file either
to execute Tranche 4 honestly or to stop honestly because Tranche 4 remains
blocked. The old bad handoff must fail this task because it scopes work to the
decision record alone while claiming rollout authorization.

Finalize the artifact as a real downstream control surface, not as narrative
cleanup. The task is complete only when the decision record cannot be used to
justify invented ratification, a fake Tranche 4 handoff, or unsynchronized
public vocabulary.
