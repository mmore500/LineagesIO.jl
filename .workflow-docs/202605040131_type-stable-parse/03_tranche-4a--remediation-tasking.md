---
date-created: 2026-05-06T18:09:14-0700
status: approved
---

# Tasks for Tranche 4 remediation: first-class rejection-path contract repair

Tasking identifier: `20260506T180914--tranche-4-remediation-tasking`

Parent tranche: Tranche 4
Parent PRD: `01_prd.md`
Parent tasking: `03_tranche-4--tasking.md`
Parent implementation under remediation: commit `f82c757`

## Settled user decisions and environment baseline

- `LineagesIO.read_lineages` remains the ratified first-class package-owned
  public file or stream verb.
- `LineagesIO.BuilderDescriptor` remains the ratified first-class typed builder
  descriptor spelling.
- `FileIO.load(...)` remains a retained compatibility wrapper. This remediation
  must not demote it further, remove it, or pretend that compatibility-only
  entry points are the first-class contract.
- `load_alife_table(...)` remains a convenience wrapper and is not part of this
  remediation scope.
- No deprecations, renames, removals, export changes, signature changes, or
  success-path behavior changes are authorized here.
- The current implementation commit `f82c757` already lands the tranche-4
  rollout and the repository is currently green: `julia --project=test
  test/runtests.jl` passes with 1194 tests, `julia --project=docs docs/make.jl`
  passes, and the three tranche-4 examples pass.
- This remediation is narrow. It repairs surviving first-class rejection-path
  contract drift and strengthens the direct public-surface proof so that the
  same drift cannot survive behind green wrapper tests again.
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
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-4--tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-4a--remediation-tasking.md`

The bundled style baseline under
`/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/`
was also read for this remediation run. It is byte-identical to the repo-local
style files except for `STYLE-vocabulary.md`. The repo-local vocabulary file is
higher priority because it carries the ratified public identifiers
`read_lineages` and `BuilderDescriptor`. Bundled `CONTRIBUTING.md` was not
present there, so repo-local `CONTRIBUTING.md` remains authoritative for
contribution guidance.

Workflow authorities used to produce this remediation tasking were
`development-policies` and `devflow-architecture-03--tranche-to-tasks`.
Downstream execution must preserve their pass-forward mandates, especially
active-authority restatement, exact upstream-source naming, exact
authorization boundaries, controlled vocabulary, primary-goal lock items,
direct red-state repros, and failure-oriented verification.

Upstream primary sources that must be read line by line for this remediation
are:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/metagraph.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/graphs.jl`

These sources constrain the remediation as follows:

- `FileIO` owns the host-framework `load(...)` surface. Any first-class
  `read_lineages(...)` rejection path that still teaches `load(...)` as the
  primary or only contract is a rollout drift, not a host-framework
  requirement.
- MetaGraphsNext upstream owns the concrete `MetaGraph` type and its supplied
  target story. Local validation messages may describe library-created versus
  caller-supplied `MetaGraph` paths, but they must no longer frame the wrapper
  verb as the primary public contract when the call entered through
  `read_lineages(...)`.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use
`package-owned public surface`, `compatibility wrapper`, `convenience wrapper`,
`authoritative tables`, `materialized graph or basenode result`,
`ownership boundary`, `lock item`, `red-state repro`, `handoff packet`, and
`verification artifact` consistently.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, rebase, reset, and branch creation remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Review-derived current-state diagnosis

This remediation exists because tranche 4 is functionally green but still fails
contract review on runtime rejection paths and proof coverage.

Verified current-state observations:

- `src/read_lineages.jl` exists, is exported, and routes first-class public
  calls into the canonical owner.
- `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, and the three
  tranche-4 examples already tell the first-class public happy-path story.
- The current repository is green on the tranche-4 gates named above.
- Despite that, several first-class rejection paths still expose wrapper-era
  guidance:
  - `LineagesIO.read_lineages("test/fixtures/single_rooted_tree.nwk", Int)`
    currently throws a basenode-construction error that tells the caller to use
    `load(src; builder = fn)`.
  - `LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", Int)`
    currently throws a multi-parent node-type error that says
    "The `load(src, Int64)` surface cannot materialize this source ..."
  - `julia --project=test -e 'using LineagesIO, MetaGraphsNext; try; LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", MetaGraph); catch err; showerror(stdout, err); println(); end'`
    currently throws a MetaGraphsNext rejection that instructs the caller to
    use `load(src, MetaGraph)` or `load(src, my_graph)`.
- Current direct public-surface failure coverage is too narrow to catch this
  drift:
  - `test/core/read_lineages_public_surface.jl` currently covers ambiguous
    format, missing stream format, raw builder rejection, and untyped supplied
    `basenode` rejection, but not the owner-level `NodeT` rejection paths above.
  - `test/extensions/metagraphsnext_network_rejection.jl` currently exercises
    only `load(...)`, so the first-class MetaGraphsNext rejection wording can
    drift while the test suite stays green.
- A stale wrapper-era string also remains in `ext/PhyloNetworksIO.jl`, but no
  direct first-class red-state repro is currently established for that string.
  This remediation therefore does not authorize broad PhyloNetworks extension
  churn unless revalidation during implementation proves a live
  `read_lineages(...)` rejection-path drift there too.

This is not a success-path or docs-synchronization problem anymore. It is an
owner-level public rejection-path wording problem plus a missing direct
verification problem.

## Primary-goal lock

### Lock 1: first-class rejection paths must not teach wrapper-first ownership

- The work is not complete if any user-facing failure reached through
  `read_lineages(...)` still presents `load(...)` as the primary public surface
  or the only corrective next step.
- Direct red-state repros:
  - `LineagesIO.read_lineages("test/fixtures/single_rooted_tree.nwk", Int)`
    currently says "use `load(src; builder = fn)` instead."
  - `LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", Int)`
    currently says "The `load(src, Int64)` surface ..."
  - `LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", MetaGraph)`
    under `julia --project=test` currently instructs the caller to use
    `load(src, MetaGraph)` and `load(src, my_graph)`.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix
  shape: direct public-surface rejection tests and manual repros showing that
  first-class failures now speak in package-owned or surface-neutral terms, and
  mention `load(...)` only as an explicit retained compatibility note when
  relevant. The current implementation fails because it still emits
  wrapper-first guidance.

### Lock 2: rejection-path wording must be repaired at the real owner

- The work is not complete if the fix only changes comments, wrapper tests, or
  one boundary message while the shared owner or shared extension validation
  layers still hard-code wrapper-era contract text for first-class callers.
- Direct red-state repros:
  - `src/construction.jl` currently hard-codes `load(...)` language in shared
    rejection paths that are reached through `read_lineages(...)`.
  - `ext/MetaGraphsNextIO.jl` currently hard-codes `load(src, MetaGraph)` and
    `load(src, my_graph)` in a validation path reached through
    `read_lineages(...)`.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the old implementation or fake-fix
  shape: review of the touched owner layers plus direct public-surface
  rejection tests. A fake fix that leaves the shared owner unchanged while only
  weakening assertions or editing comments must still fail those repros.

### Lock 3: public-surface rejection verification must exist independently of wrapper tests

- The work is not complete if wrapper-only rejection tests can still stay green
  while `read_lineages(...)` rejection wording drifts.
- Direct red-state repros:
  - `test/core/read_lineages_public_surface.jl` currently omits the live
    `NodeT` rejection paths above.
  - `test/extensions/metagraphsnext_network_rejection.jl` currently tests
    `load(...)` only.
- Closing tasks: 3.
- Verification artifact that must fail the old implementation or fake-fix
  shape: direct `read_lineages(...)` rejection tests for the shared owner and
  MetaGraphsNext extension paths, with retained wrapper tests still green. The
  current implementation fails because the first-class failure wording drifts
  while the wrapper-only tests keep passing.

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
  `.workflow-docs/202605040131_type-stable-parse/03_tranche-4--tasking.md`,
  and this remediation tasking file
- Parent documents:
  `01_prd.md`, `02_tranches.md`, `00_tranche3-public-surface-decision.md`,
  and `03_tranche-4--tasking.md`
- Settled decisions and non-negotiables:
  `read_lineages` is first-class; `BuilderDescriptor` is first-class;
  `FileIO.load(...)` remains compatibility-only; `load_alife_table(...)`
  remains a convenience wrapper; no docs or success-path contract is being
  reopened; no deprecations, renames, removals, or export changes are
  authorized
- Authorization boundary:
  narrow remediation only for first-class rejection-path wording and direct
  public-surface rejection verification; no rollout redesign, no docs churn,
  no example churn, no public API expansion, and no compatibility-surface
  policy change
- Current-state diagnosis:
  the repository is green and the tranche-4 happy path is shipped, but
  first-class rejection paths still emit wrapper-era guidance and current tests
  do not fail that drift directly
- Primary-goal lock:
  locks 1 through 3 above
- Direct red-state repros:
  the three repros named in lock 1 above
- Owner and invariant under repair:
  the first-class public contract must stay honest on failure paths, not only
  on success paths; shared owner and shared extension validation layers must
  not regrow wrapper-first runtime guidance for first-class callers
- Exact files or surfaces in scope:
  `src/construction.jl`, `src/read_lineages.jl` only if a boundary-specific
  rewrite or helper is required, `ext/MetaGraphsNextIO.jl`,
  `test/core/read_lineages_public_surface.jl`,
  `test/extensions/metagraphsnext_network_rejection.jl`, and `test/runtests.jl`
  only if new test file inclusion becomes necessary
- Exact files or surfaces out of scope:
  `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`,
  `examples/src/*`, exports, `src/load_compat.jl`, `src/fileio_integration.jl`,
  `load_alife_table(...)`, success-path semantics, authoritative table
  semantics, stable asset order, and broad PhyloNetworks extension cleanup
  unless current implementation revalidation proves a live
  `read_lineages(...)` rejection-path drift there too
- Required upstream primary sources:
  the exact `FileIO` and `MetaGraphsNext` sources named in the Governance
  section
- Green-state gates:
  `julia --project=test test/runtests.jl`; `julia --project=docs docs/make.jl`;
  `julia --project=examples examples/src/alife_standard_mwe.jl`;
  `julia --project=examples examples/src/phylonetworks_mwe01.jl`;
  `julia --project=examples examples/src/phylonetworks_mwe02.jl`
- Stop conditions:
  stop if the only apparent fix is to change tests while leaving runtime
  wording unchanged; stop if implementation would need to rewrite compatibility
  surfaces in `src/load_compat.jl` or `src/fileio_integration.jl`; stop if
  revalidation shows that one of the red-state repros no longer exists and the
  diagnosis must be rewritten before code changes proceed

## Required revalidation before implementation

- Read the parent PRD, parent tranche file, tranche-3 decision record, and
  tranche-4 tasking file in full.
- Read `src/read_lineages.jl`, `src/construction.jl`,
  `ext/MetaGraphsNextIO.jl`, `src/load_compat.jl`, and
  `src/fileio_integration.jl` in full.
- Read `test/core/read_lineages_public_surface.jl`,
  `test/extensions/metagraphsnext_network_rejection.jl`, and
  `test/runtests.jl` in full.
- Re-run or otherwise confirm the three red-state repros named in lock 1
  before editing.
- Re-check that `julia --project=test test/runtests.jl`,
  `julia --project=docs docs/make.jl`, and the three tranche-4 examples are
  green before changing code, so this remediation starts from an honest green
  state.
- Re-check that the current public docs and examples are already synchronized,
  so this remediation does not drift into unnecessary docs churn.
- If any of those revalidation points no longer hold, stop and revise this
  remediation tasking before changing code.

## Tranche execution rule

This remediation begins from an already-shipped tranche-4 happy path. It must
preserve that green, additive rollout and repair only the surviving
first-class rejection-path contract drift and its missing direct proof.

When this remediation is complete:

- no first-class `read_lineages(...)` rejection path teaches wrapper-first
  ownership
- shared owner and shared extension validation layers no longer regrow that
  stale guidance for first-class callers
- direct public-surface rejection tests fail the old behavior and keep passing
  alongside retained wrapper tests

## Non-negotiable execution rules

- Do not reopen tranche-4 naming, format policy, or success-path design.
- Do not rewrite compatibility-only errors in `src/load_compat.jl` or
  `src/fileio_integration.jl` to pretend those surfaces are first-class.
- Do not change accepted success-path behavior, validation semantics,
  authoritative table semantics, extension activation behavior, or stable asset
  order while repairing messages.
- Do not fix this only by editing comments, docstrings, or tests while leaving
  the runtime first-class repros unchanged.
- Do not replace direct rejection-path verification with grep checks,
  docs-string policing, or source-text audits alone.
- Do not broaden this remediation into README, docs, examples, export, or
  deprecation work. Those tranche-4 happy-path surfaces are already green.

## Concrete anti-patterns or removal targets

- shared `src/construction.jl` rejection messages that still hard-code
  `load(...)` when reached through `read_lineages(...)`
- extension validation messages in `ext/MetaGraphsNextIO.jl` that still present
  `load(...)` as the primary corrective surface for first-class callers
- wrapper-only rejection tests as the sole proof for first-class runtime
  contract wording
- comment-only or test-only fixes that leave the direct public repros unchanged
- broad consistency churn in unrelated docs or examples

## Failure-oriented verification

- Add direct public-surface rejection tests proving that
  `LineagesIO.read_lineages("test/fixtures/single_rooted_tree.nwk", Int)` no
  longer tells the caller to switch to `load(src; builder = fn)` as if that
  were the first-class contract.
- Add direct public-surface rejection tests proving that
  `LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", Int)`
  no longer exposes "`load(src, Int64)` surface" wording to the caller.
- Add direct extension rejection tests proving that
  `LineagesIO.read_lineages("test/fixtures/rooted_network_with_annotations.nwk", MetaGraph)`
  under `julia --project=test` no longer instructs the caller to use
  `load(src, MetaGraph)` or `load(src, my_graph)` as the primary story.
- Keep retained `load(...)` rejection tests green so compatibility-wrapper
  coverage does not regress while the first-class proof is strengthened.
- Run `julia --project=test test/runtests.jl`.
- Run `julia --project=docs docs/make.jl`.
- Run `julia --project=examples examples/src/alife_standard_mwe.jl`.
- Run `julia --project=examples examples/src/phylonetworks_mwe01.jl`.
- Run `julia --project=examples examples/src/phylonetworks_mwe02.jl`.

## Tasks

### 1. Repair shared owner rejection-path wording for first-class callers

**Type**: WRITE  
**Output**: owner-level rejection paths reached through `read_lineages(...)`
no longer hard-code wrapper-era `load(...)` contract language.
**Depends on**: none  
**Positive contract**: Repair the shared owner wording in `src/construction.jl`
so the current tree `Int` and network `Int` public-surface repros no longer
teach wrapper-first ownership. If the correct ownership boundary for
surface-specific wording is the `read_lineages` entry boundary rather than the
shared owner, add the minimal package-owned boundary rewrite needed so
first-class callers see package-owned or surface-neutral guidance while
retained compatibility wrappers keep their own compatibility story honest.
**Negative contract**: Do not change request normalization, success-path
behavior, or compatibility-only `load(...)` semantics. Do not leave one shared
owner rejection path stale while repairing only another. Do not fix this only
by editing tests or comments.
**Files**: `src/construction.jl`, `src/read_lineages.jl` only if a
boundary-specific rewrite or helper is required
**Out of scope**: `src/load_compat.jl`, `src/fileio_integration.jl`,
`README.md`, `docs/src/*`, `examples/src/*`, exports, and extension files
**Verification**: Task 3 must be able to fail the old implementation through
direct `read_lineages(...)` rejection tests for the tree `Int` and network
`Int` repros above. The old implementation fails because those paths still
mention `load(...)` as the surfaced contract.

Repair the wording at the real owner. Shared-owner messages that serve both
first-class and compatibility surfaces must stop hard-coding wrapper-first
guidance. If a corrective next-step note truly needs entry-surface-specific
language, the `read_lineages` boundary must own that rewrite explicitly.

### 2. Repair MetaGraphsNext first-class rejection guidance without broadening the extension scope

**Type**: WRITE  
**Output**: the MetaGraphsNext network rejection reached through
`read_lineages(..., MetaGraph)` no longer presents `load(...)` as the primary
public correction path.
**Depends on**: 1  
**Positive contract**: Repair the shared MetaGraphsNext validation wording so
the first-class library-created `MetaGraph` rejection speaks in package-owned
or surface-neutral terms and presents a caller-supplied empty `MetaGraph`
target as the corrective construction model without reverting to wrapper-first
ownership language. A retained compatibility note is allowed, but it must be
secondary and explicit.
**Negative contract**: Do not broaden this into general MetaGraphsNext docs or
success-path changes. Do not change graph materialization semantics, supplied
target semantics, or the existing multi-parent support boundary. Do not pull
in PhyloNetworks extension churn unless current revalidation proves a live
first-class drift there too.
**Files**: `ext/MetaGraphsNextIO.jl`
**Out of scope**: `ext/PhyloNetworksIO.jl`, `README.md`, `docs/src/*`,
`examples/src/*`, and extension-core behavior beyond message or local
commentary repair
**Verification**: Task 3 must be able to fail the old implementation through a
direct `read_lineages(..., MetaGraph)` rejection test in the test environment.
The old implementation fails because the current message tells the caller to
use `load(src, MetaGraph)` or `load(src, my_graph)`.

If the touched file also contains nearby stale wrapper-era comments or
docstrings about the same first-class library-created `MetaGraph` path, update
them in the same pass so the file does not immediately contradict its repaired
runtime contract.

### 3. Strengthen direct first-class rejection verification and close the green gates

**Type**: TEST  
**Output**: the test suite directly proves that the first-class public surface
no longer leaks wrapper-era rejection guidance, while retained wrapper
rejection tests stay green.
**Depends on**: 1, 2  
**Positive contract**: Extend the public-surface failure coverage so it
includes the tree `Int` basenode-construction rejection, the network `Int`
multi-parent node-type rejection, and the MetaGraphsNext multi-parent network
rejection through `read_lineages(...)`. Keep existing `load(...)` rejection
tests green, because retained compatibility wrappers are still supported.
**Negative contract**: Do not replace direct runtime rejection checks with
grep-based wording checks. Do not delete wrapper rejection tests simply because
new public-surface tests exist. Do not broaden the proof into unrelated docs or
example churn.
**Files**: `test/core/read_lineages_public_surface.jl`,
`test/extensions/metagraphsnext_network_rejection.jl`, `test/runtests.jl` only
if new file inclusion becomes necessary
**Out of scope**: README, docs, examples, unrelated extension tests, and
success-path parity tests that are already green
**Verification**: Run `julia --project=test test/runtests.jl`, `julia
--project=docs docs/make.jl`, `julia --project=examples
examples/src/alife_standard_mwe.jl`, `julia --project=examples
examples/src/phylonetworks_mwe01.jl`, and `julia --project=examples
examples/src/phylonetworks_mwe02.jl`. The old implementation must fail the new
rejection tests because it still emits wrapper-era wording on the first-class
surface.

Finish by proving that the first-class public surface and the retained
compatibility wrappers can still coexist honestly in one green repository
state, including on rejection paths.
