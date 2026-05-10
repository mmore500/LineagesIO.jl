---
date-created: 2026-05-08T18:11:25-07:00
status: proposed
---

# Tasks for Tranche 5: public contract synchronization and audit closure

Tasking identifier: `20260508T181125--tranche-5-tasking`

Parent tranche: Tranche 5
Parent PRD: `01_prd.md`

## Settled user decisions and environment baseline

- This tasking is for Tranche 5 only in
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`.
- `read_lineages` remains the ratified first-class package-owned public
  surface.
- `BuilderDescriptor` remains the ratified first-class typed builder surface.
- `FileIO.load(...)` remains a `compatibility wrapper`.
- `load_alife_table(...)` remains the in-memory Tables.jl
  `convenience wrapper`.
- The Tranche 3 Branch-A supplied-instance contract in
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
  is fixed input. Supported custom data on the caller-supplied MetaGraphsNext
  path remains constructor-based on user-owned
  `VertexData(::NodeRowRef)` and
  `EdgeData(::EdgeWeightType, ::EdgeRowRef)`.
- The Tranche 4 library-created MetaGraphsNext target repair is fixed input.
  The supported library-created family remains only the ratified `MetaGraph`
  token and the owner-derived exact concrete
  `typeof(default_metagraph())`. No broader
  `Type{<:MetaGraph}` family and no hand-written partial `MetaGraph` type
  literal is a supported library-created customization path.
- Tranche 5 is a stabilization tranche. Runtime owner code is already green in
  the current repository state and is not authorized to be reopened here
  unless required revalidation proves a new live runtime contradiction that
  this tasking does not already capture.
- Use the installed upstream FileIO, MetaGraphsNext, and Tables sources named
  below. The older `codebases-and-documentation` checkout path referenced by
  the parent architecture PRD is not present in the current environment.
- Use the existing root, `test/Project.toml`, and `docs/Project.toml`
  environments. Do not add dependencies or edit dependency declarations
  directly.
- Live revalidation on 2026-05-08 confirms the remaining tranche-5 gaps are
  now public-contract and proof-closure gaps rather than runtime-owner gaps:
  - `git status --short` was empty
  - `julia --project=test test/runtests.jl` passed with `1362` tests in
    `1m28.9s`
  - `julia --project=docs docs/make.jl` passed
  - the hand-written partial request
    `MetaGraphsNext.MetaGraph{Int, MetaGraphsNext.Graphs.SimpleDiGraph{Int}, Symbol, Nothing}`
    already rejects manually with `ArgumentError` that directs callers to the
    caller-supplied `MetaGraph` path
  - `README.md` and `docs/src/index.md` still underspecify the ratified
    Branch-A constructor-based custom-data extension point and still do not
    explicitly close the broader library-created `Type{<:MetaGraph}` story
  - no automated regression yet proves rejection of that hand-written partial
    request shape at the canonical owner and retained public-surface levels
- The currently inspected examples are not in direct red state for this
  tranche. Keep examples out of scope unless required revalidation during
  execution finds a live stale MetaGraphsNext claim there.

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
- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
- this tasking file

The bundled style baseline under
`/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/`
was also checked during tasking. The bundled style files are byte-identical to
the repo-local style files above except for `STYLE-vocabulary.md`, where the
repo-local file is the higher-priority project authority. Bundled
`CONTRIBUTING.md` was not present there, so repo-local `CONTRIBUTING.md`
remains controlling.

`STYLE-makie.md` is not an active authority for this tranche because no Makie,
rendering, or figure work is in scope. `STYLE-python.md` was not present in
the repo-local or bundled governance set.

Workflow authorities used to produce this tasking were
`development-policies` and `devflow-architecture-03--tranche-to-tasks`.
Downstream execution must preserve their pass-forward mandates, especially
active-authority restatement, exact scope control, exact lock-item proof
obligations, required upstream-source naming, failure-oriented verification,
and honest stop conditions.

Mandatory upstream primary sources for this tranche are:

- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/types.jl`
- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/loadsave.jl`
- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/query.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`

These sources constrain the tranche as follows:

- FileIO owns the host-framework `load(...)` wrapper behavior and surface
  classification; this tranche may preserve or clarify that public story but
  must not recast the wrapper as a first-class owner.
- MetaGraphsNext empty-graph construction is explicit and positional, which is
  why Tranche 4 narrowed the supported library-created family rather than
  broadening factory behavior in public docs.
- Tables row access is still the underlying source of `NodeRowRef` and
  `EdgeRowRef`, which is why the supplied-instance custom-data story remains a
  constructor contract on user-owned data types rather than a free-form
  metadata promise.

Local inference from those verified facts:

- The honest Tranche 5 repair is to synchronize public docs and direct proof
  artifacts to the already-reviewed runtime contract.
- Re-broadening the library-created family or teaching a second public custom
  data story would be an anti-fix because the owners and boundaries were
  already ratified upstream.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use
`package-owned public surface`, `compatibility wrapper`,
`convenience wrapper`, `authoritative tables`,
`materialized graph or basenode result`, `ownership boundary`, `lock item`,
`red-state repro`, `verification artifact`, `read_lineages`, and
`BuilderDescriptor` consistently. Do not describe `FileIO.load(...)` as a
first-class public surface, and do not describe the caller-supplied
MetaGraphsNext custom-data path as a broad library-created type-family
extension point.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, rebase, reset, and branch creation remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Primary-goal lock

### Lock 5a: the public custom-data story must explicitly match the ratified supplied-instance contract

- The work is not complete if `README.md` or `docs/src/index.md` still leave
  the supported caller-supplied MetaGraphsNext custom-data path ambiguous, or
  if they continue to imply that "pass an empty MetaGraph instance" alone is a
  complete description of how custom `VertexData` or `EdgeData` support works.
- Direct red-state repro: the current README and package index mention the
  caller-supplied empty-graph path but do not explicitly name the ratified
  constructor-based extension points
  `VertexData(::NodeRowRef)` and
  `EdgeData(::EdgeWeightType, ::EdgeRowRef)`.
- Closing tasks: 1.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: direct manual inspection of the touched README and package index
  sections against the ratified Branch-A contract, plus `julia --project=docs
  docs/make.jl` and `julia --project=test test/runtests.jl` to prove the docs
  stay synchronized to the reviewed runtime.

### Lock 5b: public docs must not preserve a second broad library-created `MetaGraph` contract

- The work is not complete if touched public docs still imply that arbitrary
  concrete `Type{<:MetaGraph}` requests or hand-written partial `MetaGraph`
  type literals are supported on the library-created path, or if they newly
  teach `typeof(default_metagraph())` as a reader-facing customization path.
- Direct red-state repro: current README and package index do not explicitly
  close the broader library-created family after Tranche 4, which leaves the
  old broad request story available as a stale public interpretation.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: public-doc inspection that names the tree-only `MetaGraph` token and
  caller-supplied redirect honestly, plus new direct negative regressions for
  the hand-written partial request shape on the canonical owner and retained
  public surfaces.

### Lock 5c: rejection of the hand-written partial `MetaGraph` request shape must stop being manual-only proof

- The work is not complete if rejection of
  `MetaGraphsNext.MetaGraph{Int, MetaGraphsNext.Graphs.SimpleDiGraph{Int}, Symbol, Nothing}`
  remains proven only by manual shell repro, or if only one affected surface
  gains automated coverage while the sibling surfaces can still drift.
- Direct red-state repro: manual runtime exercise now rejects the hand-written
  partial request honestly, but there is still no direct automated regression
  for that exact shape in `LineagesIO.canonical_load(...)`,
  `read_lineages(...)`, and retained `load(...)`.
- Closing tasks: 2 and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: direct negative regressions in
  `test/extensions/metagraphsnext_canonical_owner.jl` and
  `test/extensions/metagraphsnext_public_surface.jl` that name the exact
  partial request shape and assert precise `ArgumentError`.

### Lock 5d: wrapper classifications and existing audit proofs must stay preserved while synchronization lands

- The work is not complete if the tranche re-centers `FileIO.load(...)` or
  `load_alife_table(...)`, weakens the existing weighted-concrete and
  `BuilderDescriptor` proofs, or turns this stabilization pass into a new
  runtime-redesign tranche.
- Direct bad shape to guard against: a doc refresh or regression update that
  drifts the already-ratified naming and wrapper roles, or that drops existing
  direct proof because the suite is already green.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: touched docs preserve wrapper classifications, touched tests preserve
  existing weighted-concrete, supplied-instance, multi-parent, and
  `BuilderDescriptor` regressions, and the full `test` and `docs` gates remain
  green.

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
  - `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
  - `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
  - `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
  - this tasking file
- Parent documents:
  - the parent type-stable parse PRD and tranche file
  - the tranche-3 public-surface decision record
  - the production final audit
  - the audit-fix design note
  - the supplied-instance contract decision artifact
  - the remedial PRD
  - this tasking file
- Settled decisions and non-negotiables:
  - `read_lineages` remains the first-class package-owned public surface
  - `BuilderDescriptor` remains the first-class typed builder surface
  - `FileIO.load(...)` remains a `compatibility wrapper`
  - `load_alife_table(...)` remains a `convenience wrapper`
  - the Tranche 3 Branch-A supplied-instance contract remains fixed input
  - the Tranche 4 owner-derived library-created target repair remains fixed
    input
  - runtime owner logic is already green and is not to be reopened here unless
    required revalidation proves a new contradiction
  - no new factory protocol, wrapper reclassification, or public naming change
    is authorized here
- Authorization boundary:
  - public docs, directly affected public-facing proof artifacts, and any
    narrow wording or test updates needed to keep those artifacts honest are in
    scope
- Current-state diagnosis:
  - the repaired runtime owners are green today
  - the remaining stale artifacts are README/index prose that underspecifies
    the Branch-A constructor contract and the lack of automated proof for the
    hand-written partial `MetaGraph` rejection
- Primary-goal lock:
  - finish public synchronization and proof closure so the repaired contract
    cannot drift back behind stale docs or weak tests
- Direct red-state repros:
  - README and `docs/src/index.md` currently omit the ratified constructor
    entry points for supported caller-supplied custom data
  - no automated regression yet covers the exact hand-written partial request
    `MetaGraphsNext.MetaGraph{Int, MetaGraphsNext.Graphs.SimpleDiGraph{Int}, Symbol, Nothing}`
    at the canonical owner or retained public-surface levels
- Owner and invariant under repair:
  - the public contract story must agree with the already-reviewed
    package-owned owners and retained wrapper classifications without
    reopening them
- Supported public surfaces affected by that owner or semantic:
  - `read_lineages(source, MetaGraph)`
  - retained `load(source, MetaGraph)`
  - `read_lineages!(source, supplied_metagraph)`
  - retained `load(source, supplied_metagraph)`
  - direct owner verification through `LineagesIO.canonical_load(...)`
  - rejected library-created requests shaped like the hand-written partial
    `MetaGraph` literal above
- Exact files or surfaces in scope:
  - `README.md`
  - `docs/src/index.md`
  - `test/extensions/metagraphsnext_canonical_owner.jl`
  - `test/extensions/metagraphsnext_public_surface.jl`
- Exact files or surfaces out of scope:
  - `ext/MetaGraphsNextIO.jl`
  - `src/read_lineages.jl`
  - `src/load_compat.jl`
  - `src/load_owner.jl`
  - `docs/src/phylonetworks.md`
  - `examples/src/alife_standard_mwe.jl`
  - `examples/src/phylonetworks_mwe01.jl`
  - `examples/src/phylonetworks_mwe02.jl`
  - broader docs refresh or marketing copy
  - public naming or wrapper-classification redesign
  - dependency declarations
- Required upstream primary sources:
  - `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/types.jl`
  - `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/loadsave.jl`
  - `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/query.jl`
  - `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
  - `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
  - `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`
  - `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`
  - `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`
- Green-state gates:
  - touched README and package index prose match the ratified Branch-A and
    Tranche 4 contracts exactly
  - direct negative owner-level and public-surface regressions exist for the
    hand-written partial `MetaGraph` request shape
  - existing weighted-concrete, supplied-instance, multi-parent, and
    `BuilderDescriptor` proof remains green
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
  - touched examples only if required revalidation expands scope honestly
- Stop conditions:
  - stop and escalate if required revalidation shows the repaired runtime no
    longer matches the Tranche 3 or Tranche 4 settled contract
  - stop and escalate if synchronizing docs honestly would require reopening
    the ratified public naming boundary or wrapper classifications
  - stop and escalate if another stale public artifact beyond the scoped
    README, index docs, and proof tests appears and materially broadens scope
  - stop and escalate if closing the proof gap requires runtime code changes
    rather than the documented preservation and regression work scoped here

## Required revalidation before implementation

- Read the tranche and parent PRD in full.
- Read the relevant code, tests, docs, and examples in full:
  - `README.md`
  - `docs/src/index.md`
  - `ext/MetaGraphsNextIO.jl`
  - `src/read_lineages.jl`
  - `src/load_compat.jl`
  - `src/load_owner.jl`
  - `test/core/fileio_load_surfaces.jl`
  - `test/core/read_lineages_public_surface.jl`
  - `test/extensions/metagraphsnext_canonical_owner.jl`
  - `test/extensions/metagraphsnext_public_surface.jl`
  - `test/extensions/metagraphsnext_network_rejection.jl`
  - `test/extensions/metagraphsnext_supplied_basenode.jl`
  - `examples/src/alife_standard_mwe.jl`
  - `examples/src/phylonetworks_mwe01.jl`
  - `examples/src/phylonetworks_mwe02.jl`
- Read the cited upstream primary sources in full where they constrain the
  work.
- Re-check the user-authorized disruption boundary before making changes.
- Re-run `julia --project=test test/runtests.jl`,
  `julia --project=docs docs/make.jl`, and the direct manual repro for the
  hand-written partial `MetaGraph` request shape before touching files.
- Reconfirm that runtime owner logic is still green, that no later tranche has
  already synchronized `README.md` or `docs/src/index.md`, and that examples
  still remain outside the live red state.
- If the diagnosis no longer matches reality, stop and raise that before
  changing files.

## Tranche execution rule

This tranche begins from green runtime and green package-doc build. It
synchronizes public contract text and direct proof artifacts to the already
reviewed Tranche 3 and Tranche 4 repairs. Runtime API redesign remains out of
scope unless a stop condition is triggered.

For this stabilization tranche:

- the owners that must remain are the already-repaired runtime boundaries plus
  the public docs and direct proof artifacts that describe them
- the artifacts that must no longer survive are stale README/index contract
  prose and manual-only proof for the hand-written partial `MetaGraph`
  rejection
- the forbidden workaround is to broaden runtime support or public teaching to
  make the docs easier to write
- if the current public docs cannot be made truthful without contradicting the
  reviewed runtime, stop and escalate instead of silently teaching a different
  contract

## Non-negotiable execution rules

- Do not reopen `read_lineages`, `BuilderDescriptor`, `FileIO.load(...)`, or
  `load_alife_table(...)` naming and role decisions.
- Do not touch `ext/MetaGraphsNextIO.jl`, `src/read_lineages.jl`,
  `src/load_compat.jl`, or `src/load_owner.jl` unless required revalidation
  finds a new live runtime mismatch that this tasking does not already cover.
- Do not teach `typeof(default_metagraph())` as a new reader-facing happy path.
- Do not imply that arbitrary concrete `Type{<:MetaGraph}` requests or
  hand-written partial `MetaGraph` literals are supported on the
  library-created path.
- Do not solve docs drift by broadening the API surface or by recasting
  wrapper roles.
- Do not replace runtime regressions with grep-only, source-text-only, or
  docs-only proof.
- Do not broaden this tranche into unrelated examples refresh, migration
  guidance, or extension redesign.

## Concrete anti-patterns or removal targets

- README or package-doc prose that says to pass an empty `MetaGraph` for custom
  metadata needs but never names the required
  `VertexData(::NodeRowRef)` and
  `EdgeData(::EdgeWeightType, ::EdgeRowRef)` constructor contract
- README or package-doc prose that implies broad library-created
  `Type{<:MetaGraph}` support or treats a hand-written partial `MetaGraph`
  type literal as supported customization
- proof that covers only the previously added weighted-concrete rejection while
  leaving the hand-written partial request shape manual-only
- updating only one of `README.md` or `docs/src/index.md` while the sibling
  public surface remains stale
- regression coverage that asserts only generic `ArgumentError` or covers only
  `read_lineages(...)` without retained `load(...)` and canonical-owner proof

## Failure-oriented verification

- Direct manual inspection must confirm that `README.md` and `docs/src/index.md`
  now describe the supported library-created token, the caller-supplied
  redirect, and the constructor-based custom-data extension point without
  teaching unsupported concrete request families.
- Owner-level verification must include a direct
  `LineagesIO.canonical_load(...)` negative regression for the hand-written
  partial `MetaGraph` request shape. The old broad-acceptance implementation
  from before Tranche 4 and any future broadening regression must fail here.
- Public-surface verification must include both `read_lineages(...)` and
  retained `load(...)` for that same hand-written partial request shape. This
  tranche is not complete if only one surface gets the direct proof artifact.
- Existing weighted-concrete rejection, supplied-instance custom-data support,
  multi-parent library-created rejection, and
  `BuilderDescriptor(builder, Any)` boundary proof must remain green so this
  tranche cannot pass by dropping earlier audit closure.
- `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` remain mandatory tranche-end gates.
- Examples are verification artifacts only if required revalidation honestly
  expands scope to a touched example surface.

## Tasks

### 1. Synchronize README and package index MetaGraphsNext contract prose

**Type**: WRITE  
**Output**: `README.md` and `docs/src/index.md` describe the repaired
MetaGraphsNext public contract exactly, including the ratified
constructor-based caller-supplied custom-data path and the narrowed
library-created boundary.  
**Depends on**: none  
**Positive contract**: Update the MetaGraphsNext sections in `README.md` and
`docs/src/index.md` so they explicitly state that
`read_lineages(source, MetaGraph)` is the supported tree-only
library-created request token, that alternate metadata parameterization and
multi-parent sources belong on the caller-supplied empty-graph path, and that
supported caller-supplied custom data remains the constructor-based contract on
user-owned `VertexData(::NodeRowRef)` and
`EdgeData(::EdgeWeightType, ::EdgeRowRef)`. Preserve the already-ratified
wrapper classifications wherever those surfaces are mentioned. Keep the docs
truthful to the reviewed runtime and aligned across both public docs surfaces.  
**Negative contract**: Do not teach `typeof(default_metagraph())` as a
reader-facing customization path. Do not imply that arbitrary concrete
`Type{<:MetaGraph}` requests or hand-written partial `MetaGraph` type literals
are supported. Do not recenter `FileIO.load(...)` as a first-class owner, do
not redefine `load_alife_table(...)`, and do not solve docs drift by changing
runtime behavior.  
**Files**: `README.md`, `docs/src/index.md`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, `src/read_lineages.jl`,
`src/load_compat.jl`, `src/load_owner.jl`, `docs/src/phylonetworks.md`,
`examples/src/alife_standard_mwe.jl`, `examples/src/phylonetworks_mwe01.jl`,
`examples/src/phylonetworks_mwe02.jl`, and dependency declarations  
**Verification**: Manually inspect the touched README and package index
sections against the Tranche 3 Branch-A decision and the Tranche 4 accepted
family boundary. Run `julia --project=docs docs/make.jl` and
`julia --project=test test/runtests.jl`. The current docs fail this
verification because they underspecify the constructor-based custom-data
contract and do not explicitly close the old broad library-created request
story.

### 2. Add canonical-owner regression coverage for the hand-written partial `MetaGraph` request

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_canonical_owner.jl` directly proves
that `LineagesIO.canonical_load(...)` rejects the hand-written partial
`MetaGraph` request shape with precise `ArgumentError`.  
**Depends on**: 1  
**Positive contract**: Extend
`test/extensions/metagraphsnext_canonical_owner.jl` with a direct negative
regression for
`MetaGraphsNext.MetaGraph{Int, MetaGraphsNext.Graphs.SimpleDiGraph{Int}, Symbol, Nothing}`.
Assert that the canonical owner rejects that exact request shape with
`ArgumentError` that names the supplied type and directs the caller to the
caller-supplied `MetaGraph` path. Keep the existing authoritative-table
snapshot, basenode, graph-contract, built-in-shape, `MetaGraph` token, exact
owner-derived concrete-request, and weighted-concrete rejection proofs intact
so the new regression closes the manual-only gap instead of replacing earlier
coverage.  
**Negative contract**: Do not weaken proof to a generic exception check. Do not
restyle this hand-written partial request as a supported exact-concrete request.
Do not move retained public-surface parity proof into this task. Do not edit
runtime code, README, package docs, or supplied-instance tests here.  
**Files**: `test/extensions/metagraphsnext_canonical_owner.jl`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`,
`test/extensions/metagraphsnext_public_surface.jl`,
`test/extensions/metagraphsnext_supplied_basenode.jl`,
`test/extensions/metagraphsnext_activation.jl`, `README.md`,
`docs/src/index.md`, and `test/runtests.jl`  
**Verification**: Run `julia --project=test test/runtests.jl` and
`julia --project=docs docs/make.jl`. Confirm the new owner-level regression
would have failed the pre-Tranche-4 broad-acceptance behavior and would also
fail any future regression that silently broadens the accepted
library-created family again.

### 3. Add `read_lineages` and retained `load` parity regressions for the hand-written partial `MetaGraph` request

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_public_surface.jl` proves that both
retained public surfaces reject the same hand-written partial `MetaGraph`
request shape with the same precise contract story.  
**Depends on**: 1, 2  
**Positive contract**: Extend
`test/extensions/metagraphsnext_public_surface.jl` with paired negative
regressions for
`MetaGraphsNext.MetaGraph{Int, MetaGraphsNext.Graphs.SimpleDiGraph{Int}, Symbol, Nothing}`
through both `read_lineages(...)` and retained `load(...)`. Assert precise
`ArgumentError` that names the supplied type and directs callers to the
caller-supplied `MetaGraph` path. Keep the existing exact-concrete
owner-derived request proof, weighted-concrete rejection proof, authoritative
table parity, basenode parity, graph-contract parity, and network-rejection
coverage intact so the new regression closes only the remaining manual-only
hole.  
**Negative contract**: Do not cover only `read_lineages(...)` or only retained
`load(...)`. Do not settle for generic `ArgumentError`, `isa MetaGraph`, or
parity-without-contract assertions. Do not broaden this task into
supplied-instance contract work, docs rewriting, or runtime repair.  
**Files**: `test/extensions/metagraphsnext_public_surface.jl`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`,
`test/extensions/metagraphsnext_canonical_owner.jl`,
`test/extensions/metagraphsnext_activation.jl`,
`test/extensions/metagraphsnext_network_rejection.jl`, `README.md`, and
`docs/src/index.md`  
**Verification**: Run `julia --project=test test/runtests.jl` and
`julia --project=docs docs/make.jl`. Confirm the new parity regressions would
have failed the pre-Tranche-4 broad-acceptance behavior and would fail any
future drift where `read_lineages(...)` and retained `load(...)` stop agreeing
about rejection of the hand-written partial request shape.
