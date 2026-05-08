---
date-created: 2026-05-07T16:50:04-07:00
date-revised: 2026-05-07T16:50:04-07:00
status: proposed
---

# Tasks for Tranche 1: `BuilderDescriptor` concrete-handle boundary repair

Tasking identifier: `20260507T1650--tranche-1-tasking`

Parent tranche: Tranche 1
Parent PRD: `01_prd.md`

## Settled user decisions and environment baseline

- This tasking is for Tranche 1 only in `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`.
- The tranche title and owner are already settled: this is the first-class `BuilderDescriptor` public-boundary repair, not a MetaGraphsNext tranche.
- `read_lineages` and `BuilderDescriptor` remain the ratified first-class package-owned public identifiers.
- `FileIO.load(...)` remains a `compatibility wrapper`.
- `load_alife_table(...)` remains the in-memory Tables.jl `convenience wrapper`.
- No rename, export change, deprecation, migration-policy change, or broader public-contract rewrite is authorized in this tranche.
- The owner that must remain is the public `BuilderDescriptor(...)` constructor in `src/read_lineages.jl`.
- The retained raw `load(...; builder = fn)` story remains untouched in this tranche and must not be relabeled as first-class typed behavior.
- The live red state was revalidated in the current repository: `LineagesIO.BuilderDescriptor(builder, Any)` still succeeds and constructs `BuilderDescriptor{..., Any, Vector{Any}}`, while `LineagesIO.BuilderDescriptor(builder, Int, AbstractVector{Int})` already fails with the current `ParentCollectionT` `ArgumentError`.
- There is not yet a direct public-surface regression in `test/core/read_lineages_public_surface.jl` that fails the `BuilderDescriptor(builder, Any)` shape.
- Use the existing root environment and the existing `test/Project.toml` and `docs/Project.toml` environments. Do not add dependencies or edit dependency declarations directly.

## Governance

Explicit line-by-line reading is mandatory before execution. All downstream work must read and conform to:

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
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
- this tasking file

The bundled style baseline under `/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/` was also checked during tasking. The bundled style files are byte-identical to the repo-local style files above except for `STYLE-vocabulary.md`, where the repo-local file is the higher-priority project authority. Bundled `CONTRIBUTING.md` was not present there, so repo-local `CONTRIBUTING.md` remains controlling.

Workflow authorities used to produce this tasking were `development-policies` and `devflow-architecture-03--tranche-to-tasks`. Downstream execution must preserve their pass-forward mandates, especially active-authority restatement, exact scope control, exact lock-item proof obligations, failure-oriented verification, and honest handoff packets.

No additional external upstream source materially constrains this narrow builder-boundary repair beyond the repo-owned workflow and governance authorities already listed above. If execution scope expands into `FileIO`, `Tables`, or `MetaGraphsNext` behavior, stop and re-read the installed upstream sources named in the parent PRD before continuing.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use `package-owned public surface`, `compatibility wrapper`, `convenience wrapper`, `ownership boundary`, `lock item`, `red-state repro`, `verification artifact`, `read_lineages`, and `BuilderDescriptor` consistently. Do not describe this tranche as reopening naming decisions or public migration policy.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, rebase, reset, and branch creation remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Primary-goal lock

### Lock 4a: first-class erased-handle rejection at the public boundary

- The work is not complete if `BuilderDescriptor(builder, Any)` or any equivalent abstract or erased `HandleT` shape still constructs a first-class typed descriptor.
- Direct red-state repro: in the current repository, `LineagesIO.BuilderDescriptor(builder, Any)` succeeds and produces `BuilderDescriptor{..., Any, Vector{Any}}`.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the old implementation or fake-fix shape: a direct public-surface regression that expects `ArgumentError` from `BuilderDescriptor(builder, Any)` and at least one additional abstract-handle request. The current implementation fails this artifact because the constructor currently succeeds.

### Lock 4b: concrete typed-builder public behavior must remain intact

- The work is not complete if the fix blocks or weakens valid concrete `BuilderDescriptor(builder, ConcreteHandleT[, ParentCollectionT])` requests, including the existing multi-parent typed-builder path.
- Direct bad shape to guard against: a fake fix that closes the negative case by over-restricting the public constructor or by changing valid concrete typed-builder behavior.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the bad implementation or fake-fix shape: existing concrete-handle success paths and existing typed-builder multi-parent coverage in `test/core/read_lineages_public_surface.jl` remain green after the boundary hardening.

### Lock 4c: the owning boundary must be repaired, not delayed downstream

- The work is not complete if erased or abstract `HandleT` shapes are rejected only after request normalization enters `typed_builder_request`, `TypedBuilderLoadRequest`, or later construction helpers.
- Direct red-state repro: the public `BuilderDescriptor(...)` constructor currently admits erased handle types and lets `Vector{Any}` back into the first-class typed path before any later layer can rediscover the problem.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the bad implementation or fake-fix shape: constructor-level regression proof and manual inspection that the rejection happens in `src/read_lineages.jl` before a `TypedBuilderLoadRequest` exists. A later-stage rejection is a fake fix and must fail review.

### Lock 4d: compatibility and migration boundaries must remain unchanged

- The work is not complete if this tranche changes `FileIO.load(...)`, `load_alife_table(...)`, public naming, export policy, or docs classification to make the builder-boundary fix easier.
- Direct bad shape to guard against: preserving the old first-class red state by broadening or relabeling compatibility-wrapper behavior.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the bad implementation or fake-fix shape: touched-file scope remains limited to `src/read_lineages.jl` and direct public-surface tests, and no compatibility-wrapper code or docs surfaces are modified.

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
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
  - this tasking file
- Parent documents:
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
  - this tasking file
- Settled decisions and non-negotiables:
  - `read_lineages` and `BuilderDescriptor` remain the ratified first-class package-owned public names.
  - `FileIO.load(...)` remains compatibility-only.
  - `load_alife_table(...)` remains the in-memory Tables.jl convenience wrapper.
  - No broader public migration policy or naming decision is being reopened.
  - The owner that must remain is the public `BuilderDescriptor(...)` constructor.
- Authorization boundary:
  - Only the first-class builder boundary, directly affected public-surface tests, and any directly required error wording are in scope.
- Current-state diagnosis:
  - `src/read_lineages.jl` guards only `ParentCollectionT`, leaving `HandleT = Any` free to reintroduce erased handle storage through the first-class typed path.
- Primary-goal lock:
  - Locks 4a through 4d above are mandatory and separate.
- Direct red-state repros:
  - `LineagesIO.BuilderDescriptor(builder, Any)` currently succeeds and constructs `BuilderDescriptor{..., Any, Vector{Any}}`.
  - There is no direct public-surface regression yet that fails this bad shape.
- Owner and invariant being repaired or relied on:
  - owner: the public `BuilderDescriptor(...)` constructor
  - invariant: first-class typed builder requests must own a concrete handle contract at the public boundary before request normalization reaches the canonical owner
- Exact files or surfaces in scope:
  - `src/read_lineages.jl`
  - `test/core/read_lineages_public_surface.jl`
  - `test/core/canonical_load_owner.jl` only if a directly affected concrete typed-builder success assertion must be mirrored or adjusted without changing owner scope
- Exact files or surfaces out of scope:
  - `src/load_owner.jl`
  - `src/construction.jl`
  - `src/load_compat.jl`
  - `ext/*`
  - `README.md`
  - `docs/src/*`
  - compatibility-wrapper policy
  - public naming, export, migration, or deprecation decisions
- Required upstream primary sources:
  - none beyond the repo-owned authorities already named for this narrow repair
  - if scope expands into wrapper, table, or extension behavior, the installed `FileIO`, `Tables`, and `MetaGraphsNext` sources named in the parent PRD become mandatory
- Green-state gates:
  - direct regression for `BuilderDescriptor(builder, Any)`
  - continued success for concrete `HandleT` requests
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
- Stop conditions:
  - stop and escalate if the repair appears to require reopening the ratified builder spelling
  - stop and escalate if the repair appears to require changing compatibility-wrapper policy
  - stop and escalate if honest repair appears to require moving the rejection into `src/load_owner.jl`, `src/construction.jl`, or any later layer instead of the public constructor
  - stop and escalate if scope pressure reaches MetaGraphsNext, `FileIO`, `Tables`, or docs synchronization, because those belong to later tranches

## Required revalidation before implementation

- Read the parent remedial PRD and tranche file in full.
- Read `src/read_lineages.jl` in full.
- Read `test/core/read_lineages_public_surface.jl` in full.
- Read the directly relevant typed-builder coverage in `test/core/canonical_load_owner.jl` in full.
- Re-check the live runtime red state that `LineagesIO.BuilderDescriptor(builder, Any)` still succeeds and produces `BuilderDescriptor{..., Any, Vector{Any}}`.
- Re-check the current positive boundary that `LineagesIO.BuilderDescriptor(builder, Int)` still succeeds.
- Re-check the existing negative boundary that `LineagesIO.BuilderDescriptor(builder, Int, AbstractVector{Int})` still fails with the `ParentCollectionT` `ArgumentError`.
- Re-check that no direct public-surface regression yet fails `BuilderDescriptor(builder, Any)`.
- Re-check the user-authorized disruption boundary before making code changes.
- If any of those revalidation points no longer hold, stop and revise this tasking before changing code.

## Tranche execution rule

This tranche is a foundational boundary-hardening tranche. It may redesign or tighten the first-class `BuilderDescriptor(...)` constructor internally where needed, but it must begin and end in the tranche's required green, policy-compliant state.

This tranche does not authorize broader refactoring of the canonical owner, builder compatibility wrappers, docs truth boundary, or extension behavior. The real fix here is public-boundary ownership of the concrete-handle invariant, not a later-layer rejection or a public-story workaround.

Task 1 may land the owner-level code repair and prove it manually plus with standing green gates before the permanent public-surface regression is added. Task 2 closes the tranche by leaving behind the direct automated proof artifact that fails the old behavior.

## Non-negotiable execution rules

- Do not recreate the old red state through a silent coercion from abstract `HandleT` to a different concrete wrapper.
- Do not move the real rejection into `typed_builder_request`, `TypedBuilderLoadRequest`, or later construction helpers and call that a fix.
- Do not modify `load(...; builder = fn)` or any compatibility-wrapper code in this tranche.
- Do not solve this tranche by broadening public docs, compatibility stories, or naming policy.
- Do not weaken the existing concrete typed-builder path merely to make the new negative cases pass.
- Do not reopen `ParentCollectionT` policy beyond preserving the existing concrete check that is already in force.
- Do not claim success from the green suite alone if the direct `BuilderDescriptor(builder, Any)` red-state repro still survives.

## Concrete anti-patterns or removal targets

- `BuilderDescriptor(builder, Any)` surviving as an accepted first-class typed input
- equivalent abstract or erased `HandleT` requests surviving as accepted first-class typed inputs
- the current asymmetry where `ParentCollectionT` is guarded but `HandleT` is not
- any expectation that later `TypedBuilderLoadRequest` checks can substitute for public-boundary rejection
- any fake fix that rejects erased handle types only after canonical-owner normalization or multi-parent construction has already begun
- any fake fix that keeps the public constructor permissive and relies on helper-level assertions instead

## Failure-oriented verification

- The direct constructor-level red-state repro must fail after the fix: `LineagesIO.BuilderDescriptor(builder, Any)` must throw `ArgumentError`. The current implementation fails this verification because it currently succeeds.
- At least one additional abstract-handle request beyond `Any` must be covered by a direct public-surface negative regression so the fix cannot overfit to a single literal shape.
- Existing concrete typed-builder success must remain verified through the public surface, including the current multi-parent typed-builder event coverage.
- Manual inspection must confirm the rejection occurs in `src/read_lineages.jl` before a `TypedBuilderLoadRequest` is created.
- Run `julia --project=test test/runtests.jl`.
- Run `julia --project=docs docs/make.jl`.
- No touched-file drift beyond the scoped files listed above is allowed.

## Tasks

### 1. Harden the public `BuilderDescriptor` constructor against abstract `HandleT`

**Type**: WRITE  
**Output**: `src/read_lineages.jl` rejects abstract or erased handle types at the two-argument `BuilderDescriptor(builder, HandleT)` boundary with a precise `ArgumentError`, while preserving the existing `ParentCollectionT` guard and the concrete typed-builder path.  
**Depends on**: none  
**Positive contract**: Add the owner-level guard in the public constructor path in `src/read_lineages.jl`, mirroring the current `ParentCollectionT` discipline. When this task is done, `BuilderDescriptor(builder, ConcreteHandleT)` still constructs the same typed descriptor shape, and the rejection of abstract or erased handles happens before `typed_builder_request` or any canonical-owner normalization.  
**Negative contract**: Do not place the real rejection in `typed_builder_request`, `TypedBuilderLoadRequest`, `src/load_owner.jl`, or `src/construction.jl`. Do not silently convert an erased handle request into a different concrete wrapper. Do not touch compatibility-wrapper behavior or public-surface naming.  
**Files**: `src/read_lineages.jl`  
**Out of scope**: `src/load_owner.jl`, `src/construction.jl`, `src/load_compat.jl`, `ext/*`, docs, README, compatibility-wrapper semantics, naming policy, and migration policy  
**Verification**: Manually prove that `LineagesIO.BuilderDescriptor(builder, Any)` now throws `ArgumentError`, `LineagesIO.BuilderDescriptor(builder, Int)` still succeeds, and `LineagesIO.BuilderDescriptor(builder, Int, AbstractVector{Int})` still throws the existing `ParentCollectionT` error. Then run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. This verification must fail the old implementation because the old constructor currently accepts `Any`.

### 2. Add direct public-surface regressions for erased-handle rejection and concrete-handle preservation

**Type**: TEST  
**Output**: `test/core/read_lineages_public_surface.jl` directly proves the bad first-class public shape is gone and the valid typed-builder path still works.  
**Depends on**: 1  
**Positive contract**: Add direct public-surface negative regressions that fail `BuilderDescriptor(builder, Any)` and at least one additional abstract-handle request, and preserve the current concrete typed-builder success story, including existing multi-parent typed-builder coverage. If a directly affected concrete success assertion must be mirrored or adjusted for clarity, keep that work tightly scoped and preserve the same owner boundary.  
**Negative contract**: Do not replace the direct constructor-level regression with a later `read_lineages(...)` failure. Do not use source-text assertions, helper-only tests, or a proxy that would still pass if the constructor remained permissive. Do not weaken or remove existing concrete typed-builder coverage to make the new negative cases pass.  
**Files**: `test/core/read_lineages_public_surface.jl`; `test/core/canonical_load_owner.jl` only if a directly affected concrete typed-builder success assertion needs a minimal scoped adjustment  
**Out of scope**: extension tests, docs, README, compatibility-wrapper tests, workflow docs, and any owner change outside the first-class `BuilderDescriptor` boundary  
**Verification**: Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. Confirm the new regression would have failed the old implementation because `BuilderDescriptor(builder, Any)` previously constructed `BuilderDescriptor{..., Any, Vector{Any}}` instead of throwing.
