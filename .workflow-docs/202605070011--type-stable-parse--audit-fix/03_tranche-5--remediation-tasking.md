---
date-created: 2026-05-08T19:19:01-07:00
date-revised: 2026-05-08T19:19:01-07:00
status: proposed
---

# Tasks for Tranche 5 remediation: additive MetaGraphsNext rejection proof restoration

Tasking identifier: `20260508T191901--tranche-5-remediation-tasking`

Parent tranche: Tranche 5
Parent PRD: `01_prd.md`
Parent tasking: `03_tranche-5--tasking.md`

## Settled user decisions and environment baseline

- This remediation is for Tranche 5 only in
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`.
- This remediation exists because post-implementation review found a
  proof-closure delivery failure in the landed Tranche 5 work, not because the
  MetaGraphsNext runtime owner or the tranche's public docs synchronization are
  being reopened.
- `read_lineages` remains the ratified first-class package-owned public
  surface.
- `BuilderDescriptor` remains the ratified first-class typed builder surface.
- `FileIO.load(...)` remains a `compatibility wrapper`.
- `load_alife_table(...)` remains the in-memory Tables.jl
  `convenience wrapper`.
- The Tranche 3 Branch-A supplied-instance contract remains fixed input:
  supported caller-supplied custom data on the MetaGraphsNext path is still
  constructor-based on user-owned
  `VertexData(::NodeRowRef)` and
  `EdgeData(::EdgeWeightType, ::EdgeRowRef)`.
- The Tranche 4 library-created MetaGraphsNext target repair remains fixed
  input: the supported library-created family is still only the ratified
  `MetaGraph` token and the owner-derived exact concrete
  `typeof(default_metagraph())`.
- The Tranche 5 docs synchronization landed and is fixed input here. This
  remediation must not reopen `README.md` or `docs/src/index.md` unless
  required revalidation proves a new live docs contradiction not present in the
  current repository state.
- The Tranche 5 runtime owner behavior is green and fixed input here. This
  remediation must not reopen `ext/MetaGraphsNextIO.jl`, `src/read_lineages.jl`,
  `src/load_owner.jl`, or `src/load_compat.jl` unless required revalidation
  proves a new live runtime contradiction not present in the current
  repository state.
- Use the installed upstream FileIO and MetaGraphsNext sources named below.
  The older `codebases-and-documentation` checkout path referenced by the
  parent architecture PRD is not present in the current environment.
- Use the existing root, `test/Project.toml`, and `docs/Project.toml`
  environments. Do not add dependencies or edit dependency declarations
  directly.
- Live revalidation on 2026-05-08 confirms the remaining gap is proof-set
  incompleteness rather than runtime or docs drift:
  - `git status --short` was empty
  - `julia --project=test test/runtests.jl` passed with `1362` tests in
    `1m30.8s`
  - `julia --project=docs docs/make.jl` passed
  - direct runtime exercise of both rejected library-created request shapes on
    `test/fixtures/single_rooted_tree.nwk` currently throws `ArgumentError`:
    `typeof(weighted_metagraph_target())` and
    `MetaGraphsNext.MetaGraph{Int, MetaGraphsNext.Graphs.SimpleDiGraph{Int}, Symbol, Nothing}`
  - `test/extensions/metagraphsnext_canonical_owner.jl` now contains the
    hand-written partial rejection test as the only direct owner-level negative
    library-created rejection slot in that section
  - `test/extensions/metagraphsnext_public_surface.jl` now contains the
    hand-written partial rejection test as the only direct public-surface
    negative library-created rejection slot in that section
  - the previously required weighted-concrete direct rejection proofs are no
    longer present in those two proof slots even though the runtime still
    rejects that shape

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
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-5--tasking.md`
- this remediation tasking file

The bundled style baseline under
`/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/`
was also checked during tasking. The bundled style files are byte-identical to
the repo-local style files above except for `STYLE-vocabulary.md`, where the
repo-local file is the higher-priority project authority. Bundled
`CONTRIBUTING.md` was not present there, so repo-local `CONTRIBUTING.md`
remains controlling.

`STYLE-makie.md` is not an active authority for this remediation because no
Makie, rendering, or figure work is in scope. `STYLE-python.md` was not
present in the repo-local or bundled governance set.

Workflow authorities used to produce this remediation tasking were
`development-policies` and `devflow-architecture-03--tranche-to-tasks`.
Downstream execution must preserve their pass-forward mandates, especially
active-authority restatement, exact scope control, exact lock-item proof
obligations, required upstream-source naming, failure-oriented verification,
and honest stop conditions.

Mandatory upstream primary sources for this remediation are:

- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/types.jl`
- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/loadsave.jl`
- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/query.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`

These sources constrain the remediation as follows:

- FileIO remains the host-framework owner for the retained `load(...)`
  wrapper surface, so public-surface parity proof still has to cover both
  `read_lineages(...)` and retained `load(...)`.
- MetaGraphsNext type construction remains explicit and positional, which is
  why the weighted-concrete and hand-written partial library-created request
  shapes are distinct rejected contract cases, not interchangeable aliases of
  one generic bad input.

Local inference from those verified facts:

- The current problem is not that the runtime rejects the wrong thing. The
  current problem is that the proof artifact set no longer leaves behind one
  direct regression per rejected request shape at every required surface.
- An honest remediation must therefore restore the additive proof matrix in the
  test owner layer, not reopen runtime code or docs text.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use
`package-owned public surface`, `compatibility wrapper`,
`convenience wrapper`, `ownership boundary`, `lock item`, `red-state repro`,
`verification artifact`, `read_lineages`, and `BuilderDescriptor`
consistently. Do not describe this remediation as a new runtime fix, because
the current runtime contract is already green.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, rebase, reset, and branch creation remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Review-derived current-state diagnosis

This remediation exists because the landed Tranche 5 implementation satisfied
the new hand-written partial request proof objective by overwriting an earlier
proof artifact rather than by extending the proof set additively.

- The original Tranche 5 tasking was not silent on proof preservation. It
  explicitly required preservation of the existing weighted-concrete proof in
  Lock 5d, in the green-state gates, in the failure-oriented verification
  block, and in the positive contracts for Tasks 2 and 3.
- The implementing agent nevertheless changed the earlier weighted-concrete
  rejection test slots in place so they now cover only the hand-written
  partial request shape.
- The primary delivery failure is therefore implementation drift against an
  explicit preservation requirement.
- There was also a smaller tasking durability gap: the original tasking
  preserved the obligation in prose, but it did not freeze the proof set as an
  exact additive matrix of distinct artifacts. A fresh implementer could still
  satisfy the new requirement by reusing the old rejection slot, leave the
  suite green, and miss that the weighted-concrete proof had been displaced.
- This remediation keeps the design conclusion fixed:
  - docs synchronization is already green
  - runtime rejection behavior is already green
  - the remaining owner under repair is the proof artifact set in the two
    MetaGraphsNext test files

These are not style-only issues. A tranche whose tasking explicitly required
the weighted-concrete rejection proofs to remain intact cannot honestly be
reported complete while the direct proof slots for that shape have been
replaced, even if the runtime still behaves correctly and the repository stays
green.

## Primary-goal lock

### Lock 5e: owner-level proof must cover both rejected library-created request shapes additively

- The work is not complete if
  `test/extensions/metagraphsnext_canonical_owner.jl` still leaves only one
  direct negative library-created request-shape regression in that proof slot,
  or if the weighted-concrete request shape is still absent there.
- Equivalent observed current bad behavior: the file currently contains the
  hand-written partial rejection test in that slot, while the prior direct
  weighted-concrete rejection proof is gone even though the runtime still
  rejects the weighted-concrete shape.
- Closing tasks: 1.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: two distinct direct owner-level negative regressions in
  `test/extensions/metagraphsnext_canonical_owner.jl`, one for
  `requested_type = typeof(weighted_metagraph_target())` and one for
  `requested_type = handwritten_partial_metagraph_request()`, plus
  `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl`. The current landed file fails this
  artifact because only the hand-written partial request shape still has that
  direct owner-level negative proof.

### Lock 5f: public-surface proof must cover both rejected library-created request shapes additively across both retained surfaces

- The work is not complete if
  `test/extensions/metagraphsnext_public_surface.jl` still leaves only one
  direct negative library-created request-shape regression in that proof slot,
  or if either `read_lineages(...)` or retained `load(...)` still lacks direct
  weighted-concrete rejection proof.
- Equivalent observed current bad behavior: the file currently contains the
  hand-written partial rejection test in that slot, while the prior direct
  weighted-concrete public-surface parity proof is gone even though both
  retained public surfaces still reject the weighted-concrete shape at runtime.
- Closing tasks: 2.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: two distinct direct public-surface negative regressions in
  `test/extensions/metagraphsnext_public_surface.jl`, each covering both
  `read_lineages(...)` and retained `load(...)`: one for
  `requested_type = typeof(weighted_metagraph_target())` and one for
  `requested_type = handwritten_partial_metagraph_request()`, plus
  `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl`. The current landed file fails this
  artifact because only the hand-written partial request shape still has that
  direct public-surface parity proof.

### Lock 5g: the remediation must stay proof-only and must not reopen already-green docs or runtime owners

- The work is not complete if the remediation drags `README.md`,
  `docs/src/index.md`, `ext/MetaGraphsNextIO.jl`, `src/read_lineages.jl`, or
  any other runtime owner file back into scope without a newly revalidated live
  contradiction.
- Direct bad shape to guard against: solving a missing proof artifact by
  wandering back into docs or runtime code that are already green and fixed
  input for this remediation.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: touched-file scope remains limited to the two MetaGraphsNext test
  files below, while the full `test` and `docs` gates remain green.

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
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-5--tasking.md`
  - this remediation tasking file
- Parent documents:
  - the parent type-stable parse PRD and tranche file
  - the tranche-3 public-surface decision record
  - the production final audit
  - the audit-fix design note
  - the supplied-instance contract decision artifact
  - the remedial PRD
  - the original Tranche 5 tasking file
  - this remediation tasking file
- Settled decisions and non-negotiables:
  - `read_lineages` remains the first-class package-owned public surface
  - `BuilderDescriptor` remains the first-class typed builder surface
  - `FileIO.load(...)` remains a `compatibility wrapper`
  - `load_alife_table(...)` remains a `convenience wrapper`
  - the Tranche 3 Branch-A supplied-instance contract remains fixed input
  - the Tranche 4 owner-derived library-created target repair remains fixed
    input
  - the Tranche 5 docs synchronization is already green and fixed input
  - current runtime rejection behavior for both rejected library-created
    request shapes is already green and fixed input
  - no runtime redesign, no docs resynchronization, and no wrapper
    reclassification is authorized here
- Authorization boundary:
  - only the two MetaGraphsNext proof-oriented test files that lost additive
    coverage are in scope
- Current-state diagnosis:
  - the current repository state is green
  - the weighted-concrete and hand-written partial request shapes both reject
    correctly at runtime today
  - the owner-level and public-surface proof slots now cover only the
    hand-written partial request shape because the weighted-concrete proof was
    displaced during the Tranche 5 implementation
  - the primary failure was implementation drift, with a smaller tasking
    durability gap around additive proof-matrix naming
- Primary-goal lock:
  - restore additive proof closure so the Tranche 5 implementation cannot stay
    "complete" while one required rejected request shape has lost its own
    direct regression
- Direct red-state repros:
  - `test/extensions/metagraphsnext_canonical_owner.jl` currently contains the
    hand-written partial owner-level rejection test but no direct
    weighted-concrete owner-level rejection test in that slot
  - `test/extensions/metagraphsnext_public_surface.jl` currently contains the
    hand-written partial public-surface rejection test but no direct
    weighted-concrete public-surface rejection test in that slot
  - direct runtime exercise still rejects both shapes, proving the surviving
    problem is missing proof, not live runtime behavior
- Owner and invariant under repair:
  - the proof artifact set in the two MetaGraphsNext test files must enforce
    one direct negative regression per rejected request shape at each required
    surface
  - new proof must add to the matrix, not replace a pre-existing proof slot
- Supported public surfaces affected by that owner or semantic:
  - direct owner verification through `LineagesIO.canonical_load(...)`
  - `read_lineages(source, requested_type)`
  - retained `load(source, requested_type)`
  - rejected library-created requests shaped like
    `typeof(weighted_metagraph_target())`
  - rejected library-created requests shaped like the hand-written partial
    `MetaGraphsNext.MetaGraph{Int, MetaGraphsNext.Graphs.SimpleDiGraph{Int}, Symbol, Nothing}`
- Exact files or surfaces in scope:
  - `test/extensions/metagraphsnext_canonical_owner.jl`
  - `test/extensions/metagraphsnext_public_surface.jl`
- Exact files or surfaces out of scope:
  - `README.md`
  - `docs/src/index.md`
  - `ext/MetaGraphsNextIO.jl`
  - `src/read_lineages.jl`
  - `src/load_owner.jl`
  - `src/load_compat.jl`
  - `test/extensions/metagraphsnext_network_rejection.jl`
  - `test/extensions/metagraphsnext_supplied_basenode.jl`
  - `test/core/read_lineages_public_surface.jl`
  - `test/core/fileio_load_surfaces.jl`
  - `docs/src/phylonetworks.md`
  - examples
  - dependency declarations
- Required upstream primary sources:
  - `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/types.jl`
  - `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/loadsave.jl`
  - `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/query.jl`
  - `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
  - `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
  - `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`
- Green-state gates:
  - the two test files contain distinct direct rejection proofs for both
    rejected request shapes
  - existing exact-concrete, supplied-instance, multi-parent, and
    `BuilderDescriptor` proofs remain green
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
- Stop conditions:
  - stop and escalate if required revalidation shows docs or runtime behavior
    is no longer green, because that would reopen broader Tranche 5 work
  - stop and escalate if the current weighted-concrete proof gap has already
    been repaired by another change, because this remediation would then be
    stale
  - stop and escalate if restoring additive proof coverage appears to require
    runtime or docs edits rather than the narrow test-owner repair scoped here

## Required revalidation before implementation

- Read the parent tranche, parent PRD, original Tranche 5 tasking, and this
  remediation tasking in full.
- Read the relevant code, tests, and docs in full:
  - `README.md`
  - `docs/src/index.md`
  - `ext/MetaGraphsNextIO.jl`
  - `src/read_lineages.jl`
  - `src/load_owner.jl`
  - `src/load_compat.jl`
  - `test/extensions/metagraphsnext_canonical_owner.jl`
  - `test/extensions/metagraphsnext_public_surface.jl`
  - `test/extensions/metagraphsnext_network_rejection.jl`
  - `test/extensions/metagraphsnext_supplied_basenode.jl`
  - `test/core/read_lineages_public_surface.jl`
- Read the cited upstream primary sources in full where they constrain the
  work.
- Re-check the user-authorized disruption boundary before making changes.
- Re-run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl`.
- Re-run the direct manual runtime repro for both rejected request shapes on
  `test/fixtures/single_rooted_tree.nwk` and confirm both still throw
  `ArgumentError`.
- Inspect the two scoped test files and confirm that the hand-written partial
  rejection proof is present while the direct weighted-concrete rejection proof
  is absent from those direct proof slots.
- If the diagnosis no longer matches reality, stop and raise that before
  changing files.

## Tranche execution rule

This remediation begins from green runtime and green package-doc build. It
restores additive proof coverage only. Runtime API redesign, docs rewrite, and
public-surface renaming remain out of scope unless a stop condition is
triggered.

For this proof-remediation tranche:

- the owners that must remain are the already-reviewed runtime boundaries and
  the already-synchronized docs surfaces
- the artifact that must be repaired is the additive proof matrix in the two
  MetaGraphsNext test files
- the forbidden workaround is to satisfy one rejected request-shape obligation
  by repurposing the other request-shape proof slot
- if required revalidation shows the problem is no longer a proof-only gap,
  stop and escalate instead of silently broadening the remediation

## Non-negotiable execution rules

- Do not edit `README.md` or `docs/src/index.md`.
- Do not edit `ext/MetaGraphsNextIO.jl`, `src/read_lineages.jl`,
  `src/load_owner.jl`, or `src/load_compat.jl`.
- Do not rename or repurpose the existing hand-written partial rejection
  regression to stand in for the weighted-concrete rejection shape.
- Do not hide both rejected request shapes behind one loop, one generic helper,
  or one generic rejection testset. Leave behind distinct direct proof
  artifacts for each shape.
- Do not weaken proof to generic `ArgumentError`, helper-level coverage only,
  or one-surface-only coverage.
- Do not drop existing exact-concrete, supplied-instance, multi-parent, or
  `BuilderDescriptor` proof while restoring the missing weighted-concrete
  artifact.
- Do not broaden this remediation into test-architecture cleanup, helper
  ownership cleanup, include-order cleanup, docs cleanup, or runtime repair.

## Concrete anti-patterns or removal targets

- in-place replacement of
  `requested_type = typeof(weighted_metagraph_target())` with
  `requested_type = handwritten_partial_metagraph_request()` in an existing
  rejection proof slot
- one rejection testset that is claimed to prove both rejected
  library-created request shapes
- owner-level proof for one rejected request shape while public-surface proof
  exists only for the other
- claiming completion from green `test` and `docs` gates alone while the
  weighted-concrete direct proof artifact is still absent
- reopening docs or runtime code to compensate for a missing test artifact

## Failure-oriented verification

- Direct runtime manual verification must confirm that both
  `typeof(weighted_metagraph_target())` and the hand-written partial
  `MetaGraph` request still throw `ArgumentError`. This is necessary context,
  but it is not sufficient proof for this remediation because the current
  runtime is already green.
- Owner-level verification must include two distinct direct negative
  regressions in `test/extensions/metagraphsnext_canonical_owner.jl`:
  one for `typeof(weighted_metagraph_target())` and one for
  `handwritten_partial_metagraph_request()`.
- Public-surface verification must include two distinct direct negative
  regressions in `test/extensions/metagraphsnext_public_surface.jl`, each
  proving both `read_lineages(...)` and retained `load(...)` rejection for its
  request shape.
- Supplemental source inspection is required because the current failure is a
  missing artifact, not a live runtime break. Confirm after edits that both
  test files contain distinct direct proof for both request shapes. This
  inspection is supplemental only; it does not replace runtime regressions.
- Existing exact-concrete request proof, supplied-instance custom-data proof,
  multi-parent library-created rejection proof, and
  `BuilderDescriptor(builder, Any)` boundary proof must remain green.
- `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` remain mandatory tranche-end gates.

## Tasks

### 1. Restore additive canonical-owner rejection coverage for both rejected library-created request shapes

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_canonical_owner.jl` contains two
distinct direct owner-level negative regressions: one for the weighted-concrete
request shape and one for the hand-written partial request shape.  
**Depends on**: none  
**Positive contract**: Keep the existing hand-written partial rejection
regression in `test/extensions/metagraphsnext_canonical_owner.jl`, and add
back a second direct owner-level negative regression for
`requested_type = typeof(weighted_metagraph_target())`. Use the same
single-parent tree fixture and the same precise `ArgumentError` message
assertions that name the supplied type, the caller-supplied `MetaGraph` path,
and the owner-derived concrete type boundary. Leave behind two plainly distinct
direct proof artifacts, not one generic combined slot. Keep the `MetaGraph`
token proof, the exact owner-derived concrete-request proof, the
authoritative-table snapshot, the basenode assertions, the graph-contract
assertions, and the supplied-instance coverage intact.  
**Negative contract**: Do not replace the existing hand-written partial test.
Do not convert both request shapes into a single loop, a single helper-only
assertion, or one generic rejection testset. Do not touch public-surface
tests, runtime code, README, or package docs in this task.  
**Files**: `test/extensions/metagraphsnext_canonical_owner.jl`  
**Out of scope**: `test/extensions/metagraphsnext_public_surface.jl`,
`ext/MetaGraphsNextIO.jl`, `README.md`, `docs/src/index.md`,
`test/extensions/metagraphsnext_supplied_basenode.jl`,
`test/extensions/metagraphsnext_network_rejection.jl`, and `test/runtests.jl`  
**Verification**: Run `julia --project=test test/runtests.jl` and
`julia --project=docs docs/make.jl`. Supplement with direct inspection that
`test/extensions/metagraphsnext_canonical_owner.jl` now contains one direct
negative regression for `typeof(weighted_metagraph_target())` and one direct
negative regression for `handwritten_partial_metagraph_request()`. The current
landed file fails this verification because only the hand-written partial
regression remains in that owner-level proof slot.

### 2. Restore additive public-surface rejection coverage for both rejected library-created request shapes

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_public_surface.jl` contains two
distinct direct public-surface negative regressions, and each regression proves
both `read_lineages(...)` and retained `load(...)` rejection for its request
shape.  
**Depends on**: 1  
**Positive contract**: Keep the existing hand-written partial public-surface
rejection regression in `test/extensions/metagraphsnext_public_surface.jl`,
and add back a second direct public-surface rejection regression for
`requested_type = typeof(weighted_metagraph_target())`. Each direct regression
must assert precise `ArgumentError` on both `read_lineages(...)` and retained
`load(...)`, and must assert the same message obligations as the owner-level
proof. Leave the exact owner-derived concrete-request proof, authoritative
table parity, basenode parity, graph-contract parity, custom-metadata proof,
and network-rejection coverage intact.  
**Negative contract**: Do not prove only one surface. Do not use one generic
loop or one generic rejection testset to stand in for both request shapes. Do
not touch the canonical-owner file, runtime code, README, or package docs in
this task.  
**Files**: `test/extensions/metagraphsnext_public_surface.jl`  
**Out of scope**: `test/extensions/metagraphsnext_canonical_owner.jl`,
`ext/MetaGraphsNextIO.jl`, `README.md`, `docs/src/index.md`,
`test/extensions/metagraphsnext_supplied_basenode.jl`,
`test/extensions/metagraphsnext_network_rejection.jl`, and `test/runtests.jl`  
**Verification**: Run `julia --project=test test/runtests.jl` and
`julia --project=docs docs/make.jl`. Supplement with direct inspection that
`test/extensions/metagraphsnext_public_surface.jl` now contains one direct
negative regression for `typeof(weighted_metagraph_target())` and one direct
negative regression for `handwritten_partial_metagraph_request()`, each
covering both `read_lineages(...)` and retained `load(...)`. The current
landed file fails this verification because only the hand-written partial
public-surface regression remains in that proof slot.
