---
date-created: 2026-05-06T08:48:28-0700
date-revised: 2026-05-06T20:08:14-0700
status: approved
---

# Tasks for Tranche 4: authoritative public rollout completion and cross-surface rejection-path repair

Tasking identifier: `20260506T200814--tranche-4-authoritative-tasking`

This file supersedes the earlier contents of
`.workflow-docs/202605040131_type-stable-parse/03_tranche-4--tasking.md`
and the follow-on remediation file
`.workflow-docs/202605040131_type-stable-parse/03_tranche-4a--remediation-tasking.md`.

If this file is executed honestly, no further tranche-4 remediation tasking
should be required. A single fresh implementation agent should be able to use
this file, together with the parent PRD, tranche file, and tranche-3 decision
record, as the sole authoritative tranche-4 execution handoff.

Parent tranche: Tranche 4
Parent PRD: `01_prd.md`
Parent tranche decision record: `00_tranche3-public-surface-decision.md`
Current implementation under repair: commit `c4bbaa5`

## Settled user decisions and environment baseline

- `LineagesIO.read_lineages` is the ratified first-class package-owned public
  file or stream verb.
- `LineagesIO.BuilderDescriptor` is the ratified first-class typed builder
  descriptor spelling.
- `FileIO.load(...)` remains a retained compatibility wrapper.
- `load_alife_table(...)` remains a repo-owned convenience wrapper.
- No deprecations, renames, removals, export breaks, or success-path contract
  changes are authorized in tranche 4. The rollout remains additive only.
- The tranche-3 ratified signature and format-policy supplement remains in
  force. This tranche must not reopen the `read_lineages` path or stream
  signatures, the `format` policy, `.csv` and `.txt` behavior, the
  `BuilderDescriptor(builder, HandleT[, ParentCollectionT])` shape, or the
  honest typed supplied-basenode rule.
- The settled rejection-path repair strategy for the remaining tranche-4 work
  is a surface-neutral shared-owner and shared-extension repair.
- For the shared rejection paths in scope here, do not thread entry-surface
  identity into the shared owner or shared extension validation layer merely so
  one message can say `read_lineages(...)` and another can say `load(...)`.
- If a rejection path is genuinely shared by both `read_lineages(...)` and
  `load(...)`, the shared layer must describe the capability boundary or
  corrective model in surface-neutral terms.
- If a message is truly unique to one entry surface, that message may remain
  boundary-owned by that entry surface. This tasking does not authorize new
  per-surface branching for the shared rejection paths listed below.
- Use the existing root environment and the existing `test/Project.toml`,
  `docs/Project.toml`, and `examples/Project.toml` environments. Do not add
  dependencies or edit dependency declarations directly without explicit user
  review.
- Use the approved upstream workspace at
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`
  for primary-source reading.

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
- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
- this tasking file

The bundled style baseline under
`/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/`
was also read during this rewrite. It is byte-identical to the repo-local
style files except for `STYLE-vocabulary.md`. The repo-local vocabulary file
is higher priority because it carries the ratified public identifiers
`read_lineages` and `BuilderDescriptor`. Bundled `CONTRIBUTING.md` was not
present there, so repo-local `CONTRIBUTING.md` remains authoritative for
contribution guidance.

Workflow authorities used to produce this tasking were `development-policies`
and `devflow-architecture-03--tranche-to-tasks`. Downstream implementation
must preserve their pass-forward mandates, especially active-authority
restatement, exact upstream-source naming, exact authorization boundaries,
controlled vocabulary, primary-goal lock items, direct red-state repros, and
failure-oriented verification.

Upstream primary sources that must be read line by line for this tranche are:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/src/Tables.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/metagraph.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/graphs.jl`

These sources constrain the tranche as follows:

- `FileIO` owns `load(...)`, format inference, ambiguity handling,
  `File{fmt}` wrappers, `Stream{fmt}` wrappers, and formatted dispatch. Local
  shared-owner repair must not make the compatibility wrapper dishonest while
  repairing the first-class package-owned surface.
- `Tables` owns the in-memory table contract used by `load_alife_table(...)`.
  The convenience-wrapper classification remains settled and must not drift
  while this tranche finishes.
- MetaGraphsNext upstream owns the concrete `MetaGraph` type and supplied
  target story. Local validation messages may describe the library-created
  target path versus the caller-supplied target path, but shared validation
  must not falsely claim that one entry surface is the active one when the path
  is reachable from both `read_lineages(...)` and `load(...)`.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use
`package-owned public surface`, `compatibility wrapper`, `convenience wrapper`,
`authoritative tables`, `materialized graph or basenode result`,
`ownership boundary`, `lock item`, `red-state repro`, `handoff packet`, and
`verification artifact` consistently.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, rebase, reset, and branch creation remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Revalidated current state

This tranche is no longer a from-scratch public rollout. Most of tranche 4 is
already landed and green.

Revalidated green state:

- `src/LineagesIO.jl` exports `read_lineages`, `BuilderDescriptor`, and
  `load_alife_table(...)`.
- `src/read_lineages.jl` implements the ratified package-owned path and stream
  surfaces, format policy, typed builder boundary, and typed supplied-basenode
  boundary.
- `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, and the three
  tranche-4 example scripts now tell the first-class package-owned happy-path
  story rather than a wrapper-first story.
- `test/core/read_lineages_public_surface.jl` exists and covers direct
  first-class public-surface loads and several failure boundaries.
- The current repository is green on the full tranche gates re-run during this
  rewrite:
  - `julia --project=test test/runtests.jl` passes with `1204/1204`
  - `julia --project=docs docs/make.jl` passes
  - `julia --project=examples examples/src/alife_standard_mwe.jl` passes
  - `julia --project=examples examples/src/phylonetworks_mwe01.jl` passes
  - `julia --project=examples examples/src/phylonetworks_mwe02.jl` passes

Revalidated remaining red state:

- The surviving tranche-4 problem is no longer missing exports, stale docs, or
  missing first-class tests. It is a cross-surface rejection-path dishonesty
  problem caused by a shared-owner anti-fix.
- Shared rejection paths in `src/construction.jl` and
  `ext/MetaGraphsNextIO.jl` were rewritten to repair the first-class
  `read_lineages(...)` failures, but that shared rewrite made the retained
  `load(...)` compatibility wrapper dishonest on the same paths.
- The live six-command rejection matrix is:

```text
LineagesIO.read_lineages("test/fixtures/single_rooted_tree.nwk", Int)
load("test/fixtures/single_rooted_tree.nwk", Int)
LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", Int)
load("test/fixtures/rooted_network_with_annotations.nwk", Int)
LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", MetaGraph)
load("test/fixtures/rooted_network_with_annotations.nwk", MetaGraph)
```

- Current observed surfaced wording from that matrix is:
  - `read_lineages(tree, Int)` now says to implement the basenode-construction
    method or use the first-class typed builder surface `read_lineages(source,
    BuilderDescriptor(...))`, with a secondary compatibility note for raw
    `builder = fn`
  - `load(tree, Int)` surfaces the same message, which is dishonest for the
    compatibility wrapper call
  - `read_lineages(network, Int)` now says
    `The package-owned node-type load surface for Int64 ...`
  - `load(network, Int)` surfaces that same package-owned wording, which is
    dishonest for the compatibility wrapper call
  - `read_lineages(network, MetaGraph)` now says the unsupported path is the
    first-class package-owned `read_lineages(source, MetaGraph)` library-created
    target surface
  - `load(network, MetaGraph)` surfaces that same first-class wording, which is
    dishonest for the compatibility wrapper call
- The root cause is structural:
  - `src/construction.jl` now hard-codes first-class or package-owned wording
    in shared owner paths that are reached by both entry surfaces
  - `ext/MetaGraphsNextIO.jl` now hard-codes first-class `read_lineages(...)`
    wording in a shared extension validation path reached by both entry
    surfaces
- Current test coverage is also asymmetric:
  - `test/core/read_lineages_public_surface.jl` now contains direct first-class
    rejection checks, but some of those assertions encode the obsolete
    first-class-specific wording that the new surface-neutral strategy must
    remove from shared paths
  - `test/core/fileio_load_surfaces.jl` does not directly assert wrapper-path
    rejection honesty for `load(..., Int)`
  - `test/extensions/metagraphsnext_network_rejection.jl` checks the
    first-class message directly, but its `load(..., MetaGraph)` assertion is
    still too weak to catch the current cross-surface dishonesty

This is therefore not a docs tranche, not an export tranche, and not a
success-path tranche. It is the final owner-level rejection-path contract
repair plus the missing two-surface proof.

## Primary-goal lock

### Lock 1: ratified public-surface classification must remain in force

- The work is not complete if `read_lineages`, `BuilderDescriptor`,
  `load_alife_table(...)`, README/index/PhyloNetworks docs, or the runnable
  examples regress back toward wrapper-first classification while this repair is
  being made.
- Historical red state: missing `read_lineages` export, missing
  `BuilderDescriptor`, wrapper-first docs, and wrapper-first examples.
- Current status: revalidated green. This lock is now a preservation lock.
- Owner and invariant under protection: the repo-owned public contract must
  keep one first-class package-owned public surface, one convenience wrapper,
  and retained compatibility wrappers without reopening the tranche-3
  classification decision.
- Closing tasks: 1, 2, and 3.
- Verification artifact: revalidated exports, revalidated docs and examples,
  and the standing green-state gates.

### Lock 2: the typed builder boundary must stay honest

- The work is not complete if `read_lineages(...; builder = fn)` becomes
  accepted, if the first-class typed builder story regresses, or if the shared
  rejection-path repair breaks the current honest builder boundary.
- Historical red state: no public `BuilderDescriptor`, no `read_lineages`, and
  wrapper-only raw builder guidance.
- Current status: revalidated green.
- Owner and invariant under protection: `read_lineages` owns the typed builder
  path; raw `builder = fn` remains compatibility-only.
- Closing tasks: 1, 2, and 3.
- Verification artifact: retained first-class builder rejection tests plus the
  six-command matrix for the shared `tree, Int` failure path.

### Lock 3: the typed supplied-basenode boundary must stay honest

- The work is not complete if `read_lineages(source, basenode)` regresses to
  the legacy single-parent compatibility fallback, or if the final tranche-4
  repair blurs the distinction between the first-class typed boundary and the
  compatibility wrapper boundary.
- Historical red state: no first-class `read_lineages` basenode boundary.
- Current status: revalidated green.
- Owner and invariant under protection: the first-class supplied-basenode path
  remains typed and honest; the compatibility wrapper retains the legacy
  fallback story.
- Closing tasks: 1, 2, and 3.
- Verification artifact: retained supplied-basenode tests in
  `test/core/read_lineages_public_surface.jl` and the standing full test gate.

### Lock 4: docs, examples, and public-contract prose must stay synchronized

- The work is not complete if the current synced docs/examples are reopened
  into wrapper-first contract drift while this repair is underway.
- Historical red state: README/index/PhyloNetworks docs and examples taught
  wrapper-first public flows.
- Current status: revalidated green.
- Owner and invariant under protection: the user-facing ownership story must
  stay aligned with the tranche-3 decision and the shipped tranche-4 happy
  path.
- Closing tasks: 1 and 3.
- Verification artifact: README/docs/example revalidation plus docs/examples
  gate runs.

### Lock 5: cross-surface rejection honesty must hold in both directions

- The work is not complete if any rejection path shared by `read_lineages(...)`
  and `load(...)` identifies the sibling entry surface as the active contract.
- Direct red-state repro matrix: the six commands listed in the current-state
  section above.
- Current bad behavior:
  - `load(tree, Int)` currently surfaces a first-class `read_lineages(...,
    BuilderDescriptor(...))` correction path as if it were the active surface
  - `load(network, Int)` currently says `package-owned node-type load surface`
  - `load(network, MetaGraph)` currently says the unsupported path is
    `read_lineages(source, MetaGraph)` and recommends `read_lineages(source,
    my_graph)`
- Owner and invariant under repair: shared rejection paths must be truthful for
  both the first-class package-owned surface and the retained compatibility
  wrapper.
- Closing tasks: 1, 2, and 3.
- Verification artifact: the six-command matrix plus direct two-surface tests
  that fail both the old wrapper-first drift and the current “fix one surface /
  break the sibling surface” anti-fix.

### Lock 6: shared-owner and shared-extension repair must be surface-neutral

- The work is not complete if the fix rewrites one shared message to name
  `read_lineages(...)`, `load(...)`, `package-owned`, or `first-class` as the
  active surface for a path that is actually shared by both entrypoints.
- Direct red-state sites:
  - `src/construction.jl` shared add-child rejection and node-type rejection
    helpers
  - `ext/MetaGraphsNextIO.jl` shared `MetaGraph` multi-parent validation
- Anti-fix shapes that must fail:
  - repairing `read_lineages(...)` by making `load(...)` dishonest
  - repairing `load(...)` by making `read_lineages(...)` wrapper-first again
  - threading entry-surface identity into the shared owner merely so the shared
    path can print different strings
- Owner and invariant under repair: the shared layer owns capability and
  corrective-model wording; it must not impersonate one entrypoint.
- Closing tasks: 1 and 3.
- Verification artifact: direct code review of the touched shared layers plus
  the six-command matrix.

### Lock 7: direct first-class rejection proof must match the settled strategy

- The work is not complete if the first-class tests are left in a state where
  they still encode the obsolete first-class-specific wording for shared paths,
  or if they are weakened to generic checks that no longer protect the contract.
- Direct red-state repros:
  - `test/core/read_lineages_public_surface.jl` currently expects the shared
    network `Int` rejection to say `package-owned node-type load surface`
  - `test/extensions/metagraphsnext_network_rejection.jl` currently expects the
    shared `MetaGraph` rejection to say `read_lineages(source, MetaGraph)` and
    `read_lineages(source, my_graph)`
- Owner and invariant under repair: first-class tests must assert rejection
  honesty for the first-class surface without forcing shared-layer messages to
  impersonate that surface.
- Closing tasks: 2 and 3.
- Verification artifact: updated first-class rejection tests that assert
  surface-neutral honesty on shared paths while preserving boundary-specific
  first-class checks where the path is truly first-class-owned.

### Lock 8: direct compatibility-wrapper rejection proof must exist independently

- The work is not complete if wrapper-path rejection dishonesty can still
  survive behind a green suite because wrapper tests assert only generic failure
  markers.
- Direct red-state repros:
  - `test/core/fileio_load_surfaces.jl` currently lacks direct `load(..., Int)`
    rejection assertions for the tree and rooted-network cases
  - `test/extensions/metagraphsnext_network_rejection.jl` currently checks only
    `multi-parent` on the `load(..., MetaGraph)` path
- Owner and invariant under repair: retained compatibility wrappers are still
  part of the supported contract and must be tested honestly on their own
  boundary.
- Closing tasks: 2 and 3.
- Verification artifact: direct wrapper-path rejection tests for
  `load(tree, Int)`, `load(network, Int)`, and `load(network, MetaGraph)` that
  fail the current shared-message anti-fix.

## Handoff packet

- Active authorities:
  `AGENTS.md`, `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`,
  `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`,
  `STYLE-workflow-docs.md`, `STYLE-writing.md`,
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  and this tasking file
- Parent documents:
  `01_prd.md`, `02_tranches.md`,
  `00_tranche3-public-surface-decision.md`, and this tasking file
- Settled decisions and non-negotiables:
  `read_lineages` is first-class; `BuilderDescriptor` is first-class;
  `FileIO.load(...)` remains compatibility-only; `load_alife_table(...)`
  remains a convenience wrapper; additive-only rollout remains in force; the
  settled tranche-4 rejection-path strategy is a surface-neutral shared-owner
  and shared-extension repair
- Authorization boundary:
  preserve the landed public rollout and green docs/examples/tests; repair only
  the remaining shared rejection-path dishonesty and strengthen direct
  rejection-path proof on both entry surfaces; no deprecations, renames,
  removals, export changes, or success-path behavior changes
- Current-state diagnosis:
  exports, docs, examples, first-class rollout, and green gates are landed;
  the remaining red state is cross-surface rejection dishonesty in shared owner
  and shared extension paths plus insufficient wrapper-path rejection proof
- Primary-goal lock:
  locks 1 through 8 above
- Direct red-state repros:
  the six-command rejection matrix and the weak wrapper-test gaps listed above
- Owner and invariant under repair:
  shared rejection paths reachable from both `read_lineages(...)` and
  `load(...)` must stay truthful for both entry surfaces at once; they must
  describe capability boundaries in surface-neutral terms rather than
  impersonating one entrypoint
- Exact files or surfaces in scope:
  `src/construction.jl`, `ext/MetaGraphsNextIO.jl`,
  `test/core/read_lineages_public_surface.jl`,
  `test/core/fileio_load_surfaces.jl`,
  `test/extensions/metagraphsnext_network_rejection.jl`, and `test/runtests.jl`
  only if new file inclusion becomes necessary
- Exact files or surfaces requiring revalidation even if they are not primary
  edit targets:
  `src/read_lineages.jl`, `src/load_compat.jl`, `src/fileio_integration.jl`,
  `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`,
  `examples/src/alife_standard_mwe.jl`,
  `examples/src/phylonetworks_mwe01.jl`,
  `examples/src/phylonetworks_mwe02.jl`
- Exact files or surfaces out of scope unless revalidation contradicts the
  current diagnosis:
  exports, `src/load_owner.jl`, `src/alife_format.jl`, README/docs/example
  churn, PhyloNetworks extension behavior, public signature changes,
  deprecations, removals, authoritative table semantics, retained annotation
  semantics, stable asset order, and success-path behavior
- Required upstream primary sources:
  the exact `FileIO`, `Tables`, and `MetaGraphsNext` sources named in the
  Governance section
- Green-state gates:
  the six-command rejection matrix with honest surfaced wording on both entry
  surfaces; `julia --project=test test/runtests.jl`;
  `julia --project=docs docs/make.jl`;
  `julia --project=examples examples/src/alife_standard_mwe.jl`;
  `julia --project=examples examples/src/phylonetworks_mwe01.jl`;
  `julia --project=examples examples/src/phylonetworks_mwe02.jl`
- Stop conditions:
  stop if the only apparent repair is to introduce per-surface branching in the
  shared owner or shared extension layer; stop if a new current-state
  revalidation shows docs/examples or public-surface classification are no
  longer green; stop if PhyloNetworks reveals a live shared rejection-path
  drift that would broaden this tranche beyond the scope documented here

## Required revalidation before implementation

- Read the parent PRD, parent tranche file, tranche-3 decision record, and
  this tasking file in full.
- Read `src/LineagesIO.jl`, `src/read_lineages.jl`, `src/construction.jl`,
  `src/load_compat.jl`, `src/fileio_integration.jl`, and
  `ext/MetaGraphsNextIO.jl` in full.
- Read `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`,
  `examples/src/alife_standard_mwe.jl`,
  `examples/src/phylonetworks_mwe01.jl`, and
  `examples/src/phylonetworks_mwe02.jl` in full.
- Read `test/core/read_lineages_public_surface.jl`,
  `test/core/fileio_load_surfaces.jl`,
  `test/extensions/metagraphsnext_network_rejection.jl`, and
  `test/runtests.jl` in full.
- Re-read the exact upstream primary sources named in the Governance section
  before changing rejection-path wording or tests.
- Re-run the exact six-command rejection matrix named in the current-state
  section before editing.
- Re-check that the docs, examples, and full green-state gates remain green
  before changing code, so this tranche starts from an honest shipped state.
- Re-check that the current first-class rejection tests still encode the
  obsolete shared-path wording expectations named in Lock 7.
- Re-check that the current wrapper-path tests are still too weak in the ways
  named in Lock 8.
- If any of those revalidation points no longer hold, stop and revise this
  tasking before changing code.

## Tranche execution rule

This tranche begins from an already-shipped tranche-4 happy path. Execution
must preserve that green public rollout and repair only the remaining
cross-surface rejection dishonesty plus the missing wrapper-path proof.

When this tranche is complete:

- the landed first-class public rollout remains intact
- the landed docs/examples/public classification remain intact
- shared owner and shared extension rejection paths in scope are surface-neutral
- both `read_lineages(...)` and `load(...)` are honest on the six-command
  rejection matrix
- first-class rejection tests protect the right contract
- compatibility-wrapper rejection tests protect the sibling contract directly
- no further tranche-4 remediation tasking should be needed

## Non-negotiable execution rules

- Do not reopen tranche-4 naming, format policy, builder shape, or
  supplied-basenode design.
- Do not repair the shared rejection paths by threading entry-surface identity
  through the shared owner or shared extension layer.
- Do not hard-code `read_lineages(...)`, `load(...)`, `package-owned`, or
  `first-class` as the active surface in any shared rejection path listed in
  this tasking.
- Do not rewrite `src/load_compat.jl` or `src/fileio_integration.jl` as the
  primary repair path unless revalidation proves a rejection path unique to the
  compatibility wrapper still remains stale after the shared surface-neutral
  repair.
- Do not change success-path behavior, authoritative table semantics, retained
  annotation semantics, stable asset destructuring order, extension activation,
  or green docs/examples while repairing messages.
- Do not fix this only by editing tests while leaving runtime wording
  dishonest.
- Do not “fix” the first-class tests by weakening them to generic
  `multi-parent` or `ArgumentError` checks that would miss the current anti-fix
  shape.
- Do not broaden this tranche into README/docs/example churn unless current
  revalidation contradicts the green state recorded above.
- Do not introduce deprecations, removals, export changes, or wrapper-surface
  policy changes.

## Concrete anti-patterns or removal targets

- any shared-owner or shared-extension message that repairs one entry surface
  by lying about the sibling surface
- `src/construction.jl` helper wording that labels shared node-type failures as
  `package-owned` or `first-class`
- `ext/MetaGraphsNextIO.jl` validation wording that says the active shared path
  is `read_lineages(source, MetaGraph)` or `load(source, MetaGraph)`
- first-class rejection tests that force shared messages to impersonate the
  first-class surface
- compatibility-wrapper rejection tests that assert only generic substrings and
  therefore allow shared dishonesty to survive
- any implementation that treats the continued green docs/examples state as
  permission to skip the six-command rejection matrix

## Failure-oriented verification

Run and inspect the following exact matrix:

```julia
LineagesIO.read_lineages("test/fixtures/single_rooted_tree.nwk", Int)
load("test/fixtures/single_rooted_tree.nwk", Int)
LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", Int)
load("test/fixtures/rooted_network_with_annotations.nwk", Int)
LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", MetaGraph)
load("test/fixtures/rooted_network_with_annotations.nwk", MetaGraph)
```

The repaired matrix must satisfy all of the following:

- the shared `tree, Int` rejection must not present either `read_lineages(...)`
  or `load(...; builder = fn)` as the active surface for that call path
- the shared `tree, Int` rejection may mention `BuilderDescriptor(...)` and the
  retained raw builder callback availability, but only in a surface-neutral way
- the shared network `Int` rejection must not say `package-owned node-type load
  surface`, `first-class`, or ``load(src, Int64)``
- the shared `MetaGraph` rejection must not say
  `read_lineages(source, MetaGraph)` or `load(source, MetaGraph)` as the
  active surface
- the shared `MetaGraph` rejection may describe the library-created versus
  caller-supplied `MetaGraph` construction model, and may mention retained
  wrapper availability secondarily, but not as the active path identity
- the three `read_lineages(...)` calls may share the same surface-neutral
  message text with the three `load(...)` calls where the rejection path is
  truly shared
- the implementation completion report must include the post-fix surfaced
  wording for all six commands above, not just “tests passed”

Full green-state gates remain mandatory:

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- `julia --project=examples examples/src/alife_standard_mwe.jl`
- `julia --project=examples examples/src/phylonetworks_mwe01.jl`
- `julia --project=examples examples/src/phylonetworks_mwe02.jl`

## Tasks

### 1. Repair the shared owner and shared MetaGraphsNext rejection paths with surface-neutral wording

**Type**: WRITE  
**Output**: the shared rejection paths in `src/construction.jl` and
`ext/MetaGraphsNextIO.jl` describe the capability gap or corrective
construction model in surface-neutral terms that are honest for both
`read_lineages(...)` and `load(...)`.  
**Depends on**: none  
**Positive contract**:

- Repair the shared `tree, Int`, shared network `Int`, and shared
  `MetaGraph` rejection paths so they no longer impersonate either entry
  surface.
- For shared node-type failures, prefer a neutral phrase such as
  `node-type construction path` or an equivalent capability description over
  `package-owned node-type load surface` or ``load(src, NodeT)` surface``.
- For the shared `MetaGraph` failure, describe the library-created target path
  versus the caller-supplied empty target path in neutral terms without naming
  either `read_lineages(...)` or `load(...)` as the active entry surface.
- If the shared `tree, Int` message needs to mention builder alternatives,
  present them as available corrective models without pretending one is the
  active surface for the current call path.
- Keep the landed first-class unique boundary messages in `src/read_lineages.jl`
  intact where the path is actually first-class-owned and not shared.

**Negative contract**:

- Do not fix this by making the compatibility wrapper dishonest in a different
  direction.
- Do not introduce new per-surface branching in the shared owner or shared
  extension layer.
- Do not change success-path behavior, request normalization, docs/examples, or
  wrapper policy.
- Do not edit `src/load_compat.jl` or `src/fileio_integration.jl` unless
  revalidation proves a wrapper-only stale rejection path remains after the
  shared repair.

**Files**: `src/construction.jl`, `ext/MetaGraphsNextIO.jl`  
**Out of scope**: README/docs/examples, exports, `src/load_owner.jl`,
`src/alife_format.jl`, PhyloNetworks surfaces, and all success-path semantics  
**Verification**: Task 2 and Task 3 must be able to fail the current head
`c4bbaa5` because cases 2, 4, and 6 in the six-command matrix are currently
dishonest.

### 2. Rewrite the rejection-path tests so they protect both surfaces and the settled strategy

**Type**: TEST  
**Output**: direct first-class and direct compatibility-wrapper rejection tests
protect the surface-neutral repair rather than the obsolete first-class-only
wording.  
**Depends on**: 1  
**Positive contract**:

- Update `test/core/read_lineages_public_surface.jl` so the shared rejection
  paths assert surface-neutral honesty rather than forcing
  `package-owned` or `read_lineages(...)` wording on shared paths.
- Extend `test/core/fileio_load_surfaces.jl` with direct wrapper-path rejection
  assertions for:
  - `load("test/fixtures/single_rooted_tree.nwk", Int)`
  - `load("test/fixtures/rooted_network_with_annotations.nwk", Int)`
- Strengthen `test/extensions/metagraphsnext_network_rejection.jl` so both
  `read_lineages(..., MetaGraph)` and `load(..., MetaGraph)` assert the neutral
  shared-path contract directly.
- Keep the existing green first-class and wrapper success-path proof in place.
- Keep the builder and supplied-basenode negative tests that are already green.

**Negative contract**:

- Do not weaken the first-class tests to generic `ArgumentError` or
  `multi-parent` checks that would miss the cross-surface anti-fix.
- Do not delete wrapper tests simply because first-class tests exist.
- Do not reintroduce first-class-specific wording expectations for shared paths.
- Do not broaden the proof into unrelated docs or example churn.

**Files**: `test/core/read_lineages_public_surface.jl`,
`test/core/fileio_load_surfaces.jl`,
`test/extensions/metagraphsnext_network_rejection.jl`, `test/runtests.jl` only
if new file inclusion becomes necessary  
**Out of scope**: README/docs/examples, unrelated extension tests, and
success-path parity tests that are already green  
**Verification**: the new test set must fail the current head `c4bbaa5`
because the wrapper paths are currently dishonest and the first-class shared
path assertions are currently keyed to the wrong wording strategy.

### 3. Close the full tranche gates and report completion against the six-command matrix

**Type**: TEST  
**Output**: the repository ends green, the six-command rejection matrix is
honest on both surfaces, and the completion report includes the surfaced
wording for all six commands.  
**Depends on**: 1, 2  
**Positive contract**:

- Run the six-command rejection matrix and confirm that the shared-path wording
  is honest for both entry surfaces.
- Run:
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
  - `julia --project=examples examples/src/alife_standard_mwe.jl`
  - `julia --project=examples examples/src/phylonetworks_mwe01.jl`
  - `julia --project=examples examples/src/phylonetworks_mwe02.jl`
- In the implementation completion report, report lock-by-lock closure and
  include the surfaced wording for all six matrix commands so a review can
  audit the shared-path honesty directly.

**Negative contract**:

- Do not declare success on the basis of `1204/1204` alone.
- Do not omit the six surfaced messages from the completion report.
- Do not substitute grep checks or source-text inspection for the live
  rejection matrix.

**Files**: verification-only unless test-file inclusion changes are required  
**Out of scope**: any additional tranche-4 workflow-doc creation  
**Verification**: this task itself is the final verification gate. If any one
of the six surfaced messages is still dishonest, tranche 4 remains incomplete.
