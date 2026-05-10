---
date-created: 2026-05-08T21:31:00-07:00
status: proposed
---

# Tasks for audit follow-up: MetaGraphsNext supplied-instance later-edge failure contract classification

Tasking identifier: `20260508T2131--rc1-audit2`

Parent audit: `.workflow-docs/20260508--rc1-audit.md`
Parent PRDs: `design/original-prd.md`; `.workflow-docs/202605040131_type-stable-parse/01_prd.md`; `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
Parent workflow tasking under review: `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3a--remediation-tasking.md`

## Settled user decisions and environment baseline

- The user-directed comprehensive authority set for this follow-up is the
  surviving design corpus under `design/`, the two workflow PRDs above, the
  tranche-3 public-surface decision record, and the saved audit report.
- Authority conflicts and code-versus-contract drift must be escalated for
  review and user classification. They must not be silently adapted away.
- `read_lineages` remains the ratified first-class package-owned public
  surface.
- `BuilderDescriptor` remains the ratified first-class typed builder
  descriptor.
- `FileIO.load(...)` remains a compatibility wrapper.
- `load_alife_table(...)` remains the in-memory Tables.jl convenience wrapper.
- The authoritative-table-first invariant, retained annotation behavior,
  stable materialized graph or basenode result order, and existing public
  naming boundary are fixed input for this follow-up.
- The direct audit issue here is narrow and specific: later throwing custom
  `EdgeData` construction on a caller-owned supplied `MetaGraph` currently
  leaves partial graph state and prevents same-target retry because
  `validate_empty_metagraph` still requires an empty graph at the next entry.
- The current landed Tranche 3a repair is real and must be preserved: missing
  edge-constructor failure on the first failing edge now leaves the supplied
  target empty and same-target retryable. This follow-up exists because the
  later-edge path is still unresolved, not because Tranche 3a was wholly
  ineffective.
- The recommended strong repair is not "just add more specific tests". If the
  stronger Tranche 3a contract is still intended, the owner fix is
  supplied-instance whole-load isolation for caller-owned `MetaGraph` targets,
  plus direct later-edge proof.
- If the project owner instead narrows the contract to the weaker live
  behavior, the honest fix is governance and truth-boundary repair plus direct
  tests that prove the accepted partial-state and retry-fails-at-empty-target
  behavior.
- The live repository was green at the audit boundary that produced this
  follow-up:
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
  - `julia --project=examples examples/src/alife_standard_mwe.jl`
  - `julia --project=examples examples/src/phylonetworks_mwe01.jl`
  - `julia --project=examples examples/src/phylonetworks_mwe02.jl`

## Governance

Explicit line-by-line reading is mandatory before execution. All downstream
work must read and conform to:

- `AGENTS.md`
- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `design/original-prd.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`
- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3a--remediation-tasking.md`
- `.workflow-docs/20260508--rc1-audit.md`
- this follow-up tasking file

The bundled style baseline under the `development-policies` skill reference
directory was also checked during tasking. Repo-local `STYLE-vocabulary.md` is
the higher-priority vocabulary authority where it differs from the bundled
baseline. Bundled `CONTRIBUTING.md` was not present there, so repo-local
`CONTRIBUTING.md` remains controlling.

`STYLE-makie.md` is not an active authority for this follow-up because no
Makie, plotting, or rendering work is in scope. `STYLE-python.md` was not
present in the repo-local or bundled governance set.

Legacy live-path gaps that matter here:

- `design/original-prd.md` and the companion design briefs still cite
  `design/brief.md` and `design/brief--user-stories.md`, but those files are
  not present at the cited live paths.
- Recovered sibling backup copies may be consulted as historical references if
  review work needs them, but they are not live controlling authorities by
  implication.
- If later execution needs those historical texts to settle a review gate, the
  follow-up must say so explicitly and record whether the result is
  ratification, supersession, deferral, or retirement.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use
`package-owned public surface`, `compatibility wrapper`,
`convenience wrapper`, `authoritative tables`,
`materialized graph or basenode result`, `ownership boundary`, `lock item`,
`red-state repro`, `verification artifact`, `read_lineages`, and
`BuilderDescriptor` consistently. Do not use `type stable` as shorthand for
universal exact public inference.

## Required upstream primary sources

Mandatory upstream primary sources for this follow-up are:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/metagraph.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/graphs.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/dict_utils.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/src/Tables.jl`

Installed-package revalidation sources used in this tasking pass were:

- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`

Local owner reference to preserve design honesty:

- `ext/PhyloNetworksIO.jl`, whose supplied-target owner already stages work on
  a scratch graph and commits only in `finalize_graph!`

Contract facts carried forward from those sources:

- `MetaGraph` is an immutable struct whose stored graph, label, and property
  containers are mutable internal state. A fake fix that tries to replace the
  caller-owned `MetaGraph` object identity is not acceptable.
- `Base.zero(meta_graph)` produces an empty same-typed `MetaGraph`, making a
  scratch-build path derivable for the strong branch.
- `MetaGraphsNext.Graphs.add_vertex!` and `MetaGraphsNext.Graphs.add_edge!`
  mutate graph state in place and therefore do not themselves provide
  whole-load rollback for later user-owned constructor failure.
- `Tables.AbstractRow`, `Tables.getcolumn`, `Tables.columnnames`, and the
  optional typed `Tables.getcolumn(row, ::Type{T}, i, nm)` entrypoint define
  the row contracts already used by `NodeRowRef` and `EdgeRowRef`.

## Review-derived current-state diagnosis

The audit finding remains live and branch-sensitive:

- `ext/MetaGraphsNextIO.jl` now materializes edge payloads before mutation for
  a given single-parent or multi-parent `add_child` call, which honestly fixes
  the first-failing-edge dirty-target bug.
- The live later-edge multi-parent owner proof in
  `test/extensions/metagraphsnext_canonical_owner.jl` still codifies weaker
  behavior for a caller-owned supplied `MetaGraph`: a later throwing custom
  `EdgeData` constructor leaves the target partially built at `nv == 4`,
  `ne == 3`.
- That same test proves the surviving partial-state shape directly:
  `Symbol(1)`, `Symbol(2)`, `Symbol(3)`, and `Symbol(6)` remain present, while
  node `Symbol(4)` is absent after the throw.
- `validate_empty_metagraph` still rejects any non-empty supplied graph before
  load begins, so same-target retry after that later-edge failure would now
  fail at the empty-instance guard rather than at the original constructor
  error.
- The live public-surface tests prove only the first-failing-edge branch for
  missing custom edge constructors. They do not yet classify or prove the
  later-edge branch for either `read_lineages(source, supplied_metagraph)` or
  retained `load(source, supplied_metagraph)`.

This means the current mismatch is not "tests are vague". It is that the
workflow text still claims a stronger later-edge caller-owned retry guarantee
than the live code and tests provide.

## Primary-goal lock

### Lock A1: the later-edge contract must be classified explicitly

- The work is not complete if a fresh maintainer still has to guess whether the
  Tranche 3a later-edge supplied-instance contract is strong
  unchanged-and-retryable semantics or the weaker currently-tested
  partial-state semantics.
- Direct red-state repro: the prior remediation tasking claims caller-owned
  unchanged-and-retryable behavior, while the live owner-level test codifies
  partial retained state and no same-target retry proof.
- Closing tasks: 1, then either 2 or 3.
- Verification artifact that must fail the old ambiguous shape: a new explicit
  decision note under `.workflow-docs/20260508T2131--rc1-audit2/` and a tasking
  or authority update that makes the selected branch impossible to misread.

### Lock A2: if the strong branch is selected, later-edge constructor failure must leave the caller-owned target unchanged and same-target retryable

- The work is not complete if a later throwing custom `EdgeData` constructor
  can still leave a caller-owned supplied `MetaGraph` partially populated or
  flip the second attempt into `A supplied MetaGraph must be empty before
  loading into it.`
- Direct red-state repro: the live canonical-owner proof currently leaves
  `throwing_target` at `nv == 4`, `ne == 3` after the first throw and would
  fail same-target retry at `validate_empty_metagraph`.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the old implementation or fake-fix
  shape: direct canonical-owner and public-surface regressions for a later-edge
  throwing custom `EdgeData` path that assert `nv == 0`, `ne == 0` after the
  first failure and the same constructor failure class on same-target retry.

### Lock A3: if the narrow branch is selected, the workflow and tests must stop claiming the stronger guarantee

- The work is not complete if any workflow artifact still says later-edge
  supplied-instance failure leaves the caller-owned target unchanged and
  retryable after the project owner has classified the weaker behavior as the
  honest contract.
- Direct bad shape to guard against: keeping the old stronger workflow text,
  adding only one more later-edge test, and leaving future agents to think the
  strong branch is still a promised contract.
- Closing tasks: 1 and 3.
- Verification artifact that must fail the old ambiguous shape: the updated
  workflow note or revised prior tasking no longer claims same-target retry for
  later-edge throws, while direct owner-level and public-surface tests prove
  the accepted partial-state and empty-target-retry rejection behavior.

### Lock A4: the first-failing-edge Tranche 3a repair and supported Branch-A success contract must remain green regardless of branch

- The work is not complete if this follow-up regresses the already-landed
  first-failing-edge missing-constructor atomicity proof, the supported Branch-A
  success paths, or the current public-surface classification.
- Direct bad shape to guard against: "fixing" the later-edge ambiguity by
  weakening first-failing-edge behavior, reintroducing raw internal helper
  blame, or reopening the `read_lineages` / `FileIO.load(...)` classification.
- Closing tasks: 2 or 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: the existing first-failing-edge canonical-owner and public-surface
  regressions remain green, the supported custom metadata success paths remain
  green, and the standing test and docs gates remain green.

### Lock A5: the repair must stay at the owner or authority layer, not in wrapper cleanup or object replacement

- The work is not complete if the selected branch "passes" only by clearing the
  graph in wrapper layers, replacing the caller-owned `MetaGraph` object,
  catching and rewriting user-owned constructor failures, or using a broad
  undocumented rollback story.
- Direct bad shape to guard against: a compatibility-wrapper catch-and-clear
  fix, a fresh graph substituted for the caller's target, or a `setfield!`
  strategy that assumes `MetaGraph` itself is mutable.
- Closing tasks: 2 or 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: owner-level tests and exact-file scope prove the branch closure at the
  real owner or authority boundary.

## Handoff packet

- Active authorities:
  - `AGENTS.md`
  - `CONTRIBUTING.md`
  - `STYLE-agent-handoffs.md`
  - `STYLE-architecture.md`
  - `STYLE-docs.md`
  - `STYLE-git.md`
  - `STYLE-julia.md`
  - `STYLE-upstream-contracts.md`
  - `STYLE-verification.md`
  - `STYLE-vocabulary.md`
  - `STYLE-workflow-docs.md`
  - `STYLE-writing.md`
  - `design/original-prd.md`
  - `design/brief--community-support-objectives.md`
  - `design/brief--community-support-user-stories.md`
  - `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
  - `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
  - `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3a--remediation-tasking.md`
  - `.workflow-docs/20260508--rc1-audit.md`
  - this follow-up tasking file
- Parent documents:
  - `design/original-prd.md`
  - `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
  - `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3a--remediation-tasking.md`
  - `.workflow-docs/20260508--rc1-audit.md`
  - this follow-up tasking file
- Settled decisions and non-negotiables:
  - `read_lineages` remains the ratified first-class package-owned public
    surface.
  - `BuilderDescriptor` remains the ratified first-class typed builder
    descriptor.
  - `FileIO.load(...)` remains a compatibility wrapper.
  - `load_alife_table(...)` remains the in-memory Tables.jl convenience
    wrapper.
  - The authoritative-table-first invariant and stable materialized graph or
    basenode result order remain in force.
  - The already-landed first-failing-edge Tranche 3a repair must not regress.
- Authorization boundary:
  - Only the later-edge supplied-instance `MetaGraph` contract classification,
    the owner repair if the strong branch is selected, and the exact workflow
    and tests needed to prove the chosen branch are in scope.
  - This follow-up does not reopen the overall public naming decision, the
    FileIO compatibility classification, or the broader architecture.
- Current-state diagnosis:
  - later-edge throwing custom `EdgeData` still leaves partial caller-owned
    state in the live owner-level test
  - same-target retry for that path is not currently proven and would fail at
    the empty-target guard
  - the earlier first-failing-edge missing-constructor bug is genuinely fixed
  - the current workflow text overclaims relative to the later-edge live proof
- Primary-goal lock:
  - Locks A1 through A5 above are mandatory and separate
- Direct red-state repros:
  - owner-level later-edge throw currently leaves `throwing_target` at
    `nv == 4`, `ne == 3`
  - same-target retry would now fail at `A supplied MetaGraph must be empty
    before loading into it.`
  - the prior remediation tasking still claims unchanged-and-retryable
    behavior for this branch
- Owner and invariant under repair or review:
  - owner if strong branch: supplied-instance `MetaGraph` construction state in
    `ext/MetaGraphsNextIO.jl`
  - authority if narrow branch: the workflow and verification truth boundary
  - invariant under review: whether later-edge custom `EdgeData` constructor
    failure on a caller-owned empty supplied `MetaGraph` must leave the target
    unchanged and same-target retryable
- Supported public surfaces affected by that owner or semantic:
  - `LineagesIO.canonical_load(...)` through `BasenodeLoadRequest`
  - `read_lineages(source, supplied_metagraph)`
  - retained `load(source, supplied_metagraph)`
- Exact files or surfaces in scope:
  - `.workflow-docs/20260508T2131--rc1-audit2/`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3a--remediation-tasking.md`
  - `ext/MetaGraphsNextIO.jl`
  - `test/extensions/metagraphsnext_canonical_owner.jl`
  - `test/extensions/metagraphsnext_public_surface.jl`
- Exact files or surfaces out of scope:
  - `README.md`
  - `docs/src/index.md`
  - `docs/src/phylonetworks.md`
  - `src/read_lineages.jl`
  - `ext/PhyloNetworksIO.jl`
  - `ext/MetaGraphsNextAbstractTreesIO.jl`
  - the library-created `MetaGraph` owner
  - `BuilderDescriptor`
  - new public API naming or export policy
- Required upstream primary sources:
  - the MetaGraphsNext and Tables sources named above
- Green-state gates:
  - exact direct proof for the selected branch
  - existing first-failing-edge missing-edge-constructor atomicity remains
    green
  - existing Branch-A supported custom metadata success paths remain green
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
- Stop conditions:
  - stop and escalate if revalidation shows the later-edge test no longer
    leaves partial state, because this tasking would then be stale
  - stop and escalate if strong-branch implementation appears to require
    replacing the caller-owned `MetaGraph` object identity
  - stop and escalate if narrow-branch classification would contradict live
    README or package docs text rather than only workflow text
  - stop and escalate if the missing live `design/brief.md` or
    `design/brief--user-stories.md` become necessary to settle the review gate
    and no owner classification has been recorded yet

## Required revalidation before implementation

- Read all active authorities named above in full.
- Re-read `ext/MetaGraphsNextIO.jl` in full.
- Re-read `test/extensions/metagraphsnext_canonical_owner.jl` and
  `test/extensions/metagraphsnext_public_surface.jl` in full.
- Re-read the audit report and prior Tranche 3a remediation tasking in full.
- Re-read the MetaGraphsNext and Tables upstream sources named above in full.
- Confirm the live owner-level later-edge repro still yields partial retained
  state.
- Confirm the live first-failing-edge missing-edge-constructor regressions are
  still green and still leave supplied targets empty and retryable.
- Confirm README and package docs still do not explicitly promise the stronger
  later-edge supplied-instance rollback guarantee.
- Confirm the branch-sensitive decision still genuinely requires owner review.
- If any of those revalidation points no longer hold, stop and revise this
  tasking before proceeding.

## Follow-up execution rule

This follow-up begins with a human classification gate because the correct
later-edge contract is no longer derivable from current authorities alone. Once
Task 1 is complete, downstream execution must take exactly one of the two
branches below:

- `Branch Strong`: preserve the stronger Tranche 3a promise and repair the real
  owner with whole-load isolation for caller-owned supplied `MetaGraph`
  targets.
- `Branch Narrow`: ratify the weaker live later-edge behavior and repair the
  authority and verification boundary so no artifact overclaims the contract.

No implementation run may "split the difference" by partly changing owner code
and partly narrowing the workflow text without an explicit recorded review
decision.

## Non-negotiable execution rules

- Do not treat this as a test-only cleanup unless Task 1 explicitly selects the
  narrow branch.
- Do not catch and rewrite user-owned constructor failures in wrapper layers.
- Do not replace the caller-owned supplied `MetaGraph` object with a fresh
  graph and call that success.
- Do not use `setfield!` on the `MetaGraph` object itself.
- Do not reopen `read_lineages`, `BuilderDescriptor`, `FileIO.load(...)`, or
  `load_alife_table(...)` classification.
- Do not rewrite README or package docs text unless Task 1 and revalidation
  prove they overclaim the selected branch.
- Do not conflate the first-failing-edge repair with the later-edge contract
  branch under review here.
- Do not claim closure from a green suite alone while the direct later-edge
  proof for the selected branch is still missing.

## Concrete anti-patterns or removal targets

- workflow text that still claims unchanged-and-retryable later-edge behavior
  after the narrow branch has been selected
- helper-only proof that never exercises `canonical_load(...)`,
  `read_lineages(...)`, and retained `load(...)` for the chosen branch
- strong-branch fixes that operate by wrapper-layer catch-and-clear or by
  swapping in a new graph object
- weak later-edge tests that only assert the thrown error and never inspect the
  caller-owned target state or retry the same target when that is part of the
  selected contract
- authority-resolution notes that say only "see audit" or "see parent tasking"
  without recording the actual branch decision

## Failure-oriented verification

- The existing owner-level later-edge repro must fail the strong branch and
  must remain the direct proof anchor for the narrow branch.
- If the strong branch is selected, add direct owner-level and public-surface
  proofs that fail the old implementation by observing partial retained state
  or same-target retry rejection.
- If the narrow branch is selected, add direct owner-level and public-surface
  proofs that fail the old ambiguous workflow story by codifying the accepted
  later-edge partial-state and empty-target-retry rejection behavior.
- In either branch, keep the existing first-failing-edge missing-edge
  constructor regressions green so this follow-up cannot silently reopen the
  already-repaired bug.
- `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` remain mandatory end gates.

## Tasks

1. **Title**: Classify the later-edge supplied-instance contract
   **Type**: REVIEW
   **Output**: `.workflow-docs/20260508T2131--rc1-audit2/00-01_contract-classification.md`
   records one explicit decision: `Branch Strong` or `Branch Narrow`. The note
   must cite the active authorities, the direct owner-level red-state repro,
   the supported public surfaces affected, and the reason the selected branch is
   the honest contract boundary.
   **Depends on**: none
   **Positive contract**: a fresh implementing agent can read the decision note
   and know unambiguously whether later-edge throwing custom `EdgeData` on a
   caller-owned supplied `MetaGraph` must leave the target unchanged and
   same-target retryable, or whether the weaker live partial-state behavior is
   the ratified contract.
   **Negative contract**: the output must not say "more investigation needed",
   "decide during implementation", "as needed", or any equivalent reopening of
   the branch decision.
   **Files**:
   `.workflow-docs/20260508T2131--rc1-audit2/00-01_contract-classification.md`
   **Out of scope**: code changes; README or package docs edits; unrelated
   workflow cleanup.
   **Verification**: the note explicitly names either `Branch Strong` or
   `Branch Narrow`, cites the current later-edge owner-level red-state repro,
   cites the affected public surfaces, and states whether same-target retry is
   required or intentionally unsupported for this later-edge branch.

2. **Title**: Repair the owner for strong later-edge caller-owned graph integrity
   **Type**: WRITE
   **Output**: if Task 1 selects `Branch Strong`, the supplied-instance
   `MetaGraph` owner stages construction on a scratch same-typed graph derived
   from `Base.zero(target)` and commits into the caller-owned original target
   only after successful full-graph construction, leaving later-edge custom
   `EdgeData` failure unchanged and same-target retryable for all affected
   public surfaces.
   **Depends on**: 1
   **Positive contract**: the strong branch must be implemented at the real
   owner in `ext/MetaGraphsNextIO.jl`. The repair must preserve caller-owned
   target identity, preserve current first-failing-edge atomicity, and provide
   direct proof for `canonical_load(...)`, `read_lineages(...)`, and retained
   `load(...)`.
   **Negative contract**: no wrapper-layer catch-and-clear, no object
   replacement, no `setfield!` attempt on the immutable `MetaGraph` object, no
   public-surface renaming, no library-created `MetaGraph` redesign, and no
   README or package-docs sync work.
   **Files**:
   `ext/MetaGraphsNextIO.jl`
   `test/extensions/metagraphsnext_canonical_owner.jl`
   `test/extensions/metagraphsnext_public_surface.jl`
   `.workflow-docs/20260508T2131--rc1-audit2/00-01_contract-classification.md`
   **Out of scope**:
   `README.md`
   `docs/src/index.md`
   `docs/src/phylonetworks.md`
   `src/read_lineages.jl`
   `ext/MetaGraphsNextAbstractTreesIO.jl`
   library-created `MetaGraph` validation or construction
   **Verification**:
   - direct owner-level later-edge throwing custom `EdgeData` proof now leaves
     the caller-owned supplied target at `nv == 0`, `ne == 0`
   - same-target retry reproduces the same constructor failure class rather than
     the empty-target validation error
   - direct public-surface later-edge proofs exist for both
     `read_lineages(source, supplied_metagraph)` and retained
     `load(source, supplied_metagraph)`
   - existing first-failing-edge missing-edge-constructor regressions stay green
   - `julia --project=test test/runtests.jl`
   - `julia --project=docs docs/make.jl`

3. **Title**: Narrow the contract honestly if the weaker later-edge behavior is ratified
   **Type**: WRITE
   **Output**: if Task 1 selects `Branch Narrow`, the workflow and verification
   boundary explicitly state that the later-edge supplied-instance branch does
   not promise unchanged-and-retryable caller-owned behavior, and direct tests
   prove the accepted partial-state and empty-target-retry rejection behavior
   for the affected public surfaces.
   **Depends on**: 1
   **Positive contract**: the selected weaker contract is recorded clearly in
   the decision note and the prior remediation tasking no longer overclaims the
   stronger guarantee. Owner-level and public-surface tests prove the accepted
   later-edge behavior directly rather than leaving it implicit.
   **Negative contract**: do not leave any workflow artifact claiming
   unchanged-and-retryable later-edge behavior; do not pretend this branch is a
   code fix when it is actually a contract-narrowing decision; do not touch the
   first-failing-edge repaired path except to keep it green.
   **Files**:
   `.workflow-docs/20260508T2131--rc1-audit2/00-01_contract-classification.md`
   `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3a--remediation-tasking.md`
   `test/extensions/metagraphsnext_canonical_owner.jl`
   `test/extensions/metagraphsnext_public_surface.jl`
   **Out of scope**:
   `README.md`
   `docs/src/index.md`
   `docs/src/phylonetworks.md`
   `ext/MetaGraphsNextIO.jl` unless revalidation proves code comments directly
   overclaim the stronger contract
   **Verification**:
   - the follow-up decision note explicitly names `Branch Narrow`
   - the revised prior remediation tasking no longer claims unchanged-and-
     retryable later-edge behavior
   - direct owner-level later-edge proof asserts the accepted retained graph
     state and same-target retry failure at the empty-target guard
   - direct public-surface later-edge parity proofs exist for both
     `read_lineages(source, supplied_metagraph)` and retained
     `load(source, supplied_metagraph)`
   - existing first-failing-edge missing-edge-constructor regressions stay green
   - `julia --project=test test/runtests.jl`
   - `julia --project=docs docs/make.jl`

Fresh-agent durability check for this tasking:

- A fresh agent can execute Task 1 without guessing about authorities.
- After Task 1, the remaining branch work is concrete and derivation-free.
- The file says what must not be done, not just what to build.
- The file converts the audit finding into separate lock items instead of one
  generic "fix the MetaGraph issue" note.
- The direct proof requirements would fail the current ambiguous state.
