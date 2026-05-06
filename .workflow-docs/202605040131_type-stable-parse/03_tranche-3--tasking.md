---
date-created: 2026-05-05T22:30:35-07:00
date-revised: 2026-05-05T22:30:35-07:00
status: proposed
---

# Tasks for Tranche 3: public surface ratification and migration decision

Tasking identifier: `20260505T2230--tranche-3-tasking`

Parent tranche: Tranche 3
Parent PRD: `01_prd.md`

## Settled user decisions and environment baseline

- Treat `FileIO.load(...)` as a compatibility wrapper, not as the canonical package-owned owner of LineagesIO load semantics.
- Preserve authoritative table construction as the canonical parse output and preserve the typed core and compatibility boundary decisions already ratified in the parent PRD and earlier tranche work.
- No repo-owned public API removal, rename, export change, deprecation, or signature break is authorized until the user ratifies it explicitly in this tranche.
- No final exported package-owned public load verb has been ratified yet.
- No final exported public builder-surface spelling has been ratified yet.
- The long-term public role of `load_alife_table(...)` is not yet ratified. It must be classified explicitly in this tranche rather than inferred from current exports or docs inertia.
- Tranche 4 remains blocked unless this tranche records an explicit ratified decision that unblocks it. A recorded deferral is an allowed green outcome, but it must leave Tranche 4 blocked plainly and explicitly.
- Use the existing root environment and the existing `test/Project.toml`, `docs/Project.toml`, and `examples/Project.toml` environments. Do not add dependencies or edit dependency declarations directly without user review.
- Current code reality has already moved beyond the original red-state diagnosis in the PRD. `src/load_owner.jl` already contains a non-exported typed canonical owner, direct source descriptors, and typed request surfaces. `test/core/canonical_load_owner.jl` already proves direct-owner entry for those internal surfaces.
- Current docs reality remains unresolved. `README.md`, `docs/src/index.md`, and `docs/src/phylonetworks.md` still present wrapper-first `load(...)` flows as the primary user story, while `src/LineagesIO.jl` exports `load_alife_table` but not a package-owned public `load` verb.
- The decision record file named by the tranche, `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`, does not exist yet. That missing artifact is the direct red state for this tranche.

## Governance

Explicit line-by-line reading is mandatory before execution. All downstream work must read and conform to:

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
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-1--tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-1a--remediation-tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-2--tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`

The bundled style baseline under `/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/` was also read during this tasking run and is byte-identical to the repo-local `STYLE*.md` files above. Bundled `CONTRIBUTING.md` was not present there, so repo-local `CONTRIBUTING.md` remains authoritative for contribution guidance.

Workflow authorities used to produce this tasking were `development-policies` and `devflow-architecture-03--tranche-to-tasks`. Downstream execution must preserve their pass-forward mandates, especially active-authority restatement, exact upstream-source naming, controlled vocabulary, exact authorization boundaries, primary-goal lock items, direct red-state repros, and failure-oriented verification.

Upstream primary sources that must be read line by line for this tranche are:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/src/Tables.jl`

These sources constrain the work as follows:

- `FileIO` owns the host-framework `load(...)` surface, format detection, ambiguity handling, `File{fmt}` wrappers, `Stream{fmt}` wrappers, and formatted dispatch.
- `Tables` owns the in-memory table contract used by `load_alife_table(...)`, including `Tables.istable`, `Tables.columns`, `Tables.columnnames`, `Tables.getcolumn`, and the optional typed `getcolumn` entrypoint.
- Local inference from those verified sources: a package-owned first-class public surface must be classified separately from `FileIO` host dispatch, and `load_alife_table(...)` must be judged as a repo-owned surface over Tables-compatible input rather than as a `FileIO` surface.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use `basenode`, `compatibility wrapper`, `package-owned public surface`, `authoritative tables`, `materialized graph or basenode result`, `source descriptor`, `materialization descriptor`, `parent collection`, `ownership boundary`, `green state`, `lock item`, `red-state repro`, `handoff packet`, and `verification artifact` consistently. Do not use `type stable` as shorthand for universal exact inference when the real contract is absence of package-owned erasure and runtime recovery in owned paths.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, rebase, reset, and branch creation remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Primary-goal lock

### Lock 1: the tranche must produce an explicit decision record outcome

- The work is not complete if `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md` is still missing, or if it exists but does not record either a ratified decision or an explicit deferral.
- Direct red-state repro: the tranche-designated decision record file does not exist in current code reality.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix shape: the final decision record file itself, containing an explicit outcome and an explicit Tranche 4 blocked or unblocked status. The current repository fails this artifact because the file is absent.

### Lock 2: the first-class package-owned public verb must be classified explicitly

- The work is not complete if the repository still relies on wrapper-first docs, internal-owner existence, or local intuition instead of an explicit ratified-or-deferred statement about whether the first-class package-owned public verb should be `LineagesIO.load`, a distinct exported name, or remain deferred.
- Direct red-state repro: `src/load_owner.jl` already contains `canonical_load(...)` and typed source and request descriptors, but `src/LineagesIO.jl` exports no package-owned public `load` verb while `README.md` and `docs/src/index.md` still teach `load(...)` wrapper flows as the primary story.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the old implementation or fake-fix shape: a guarantee matrix in the decision record that names the first-class package-owned public surface, or explicitly records that the public-verb decision is deferred and therefore Tranche 4 stays blocked.

### Lock 3: the builder public spelling and guarantee boundary must be made explicit

- The work is not complete if the decision record leaves it ambiguous whether the first-class typed builder surface is the documented `builder = fn` wrapper story, a future exported typed descriptor name, or an explicitly deferred public decision.
- Direct red-state repro: the code and tests already prove `TypedBuilderLoadRequest(...)` on the internal canonical owner path, while the current docs expose only `load(src; builder = fn)` as the builder-facing public story.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the old implementation or fake-fix shape: a reviewed decision-record section that classifies `builder = fn` and the typed builder descriptor separately, names the public builder spelling if ratified, or records explicit deferral if not ratified.

### Lock 4: the public role of `load_alife_table(...)` must be classified explicitly

- The work is not complete if `load_alife_table(...)` remains an exported but policy-ambiguous surface with no explicit classification as first-class typed surface, convenience wrapper, transitional wrapper, or compatibility-only wrapper.
- Direct red-state repro: `src/LineagesIO.jl` exports `load_alife_table`, `src/alife_format.jl` documents it as the in-memory alife entry surface, and `docs/src/index.md` teaches it directly, but the PRD explicitly leaves its long-term public role open for user review.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the old implementation or fake-fix shape: a reviewed guarantee matrix and migration note that classify `load_alife_table(...)` explicitly instead of treating current export status as an implicit decision.

### Lock 5: Tranche 4 must receive an honest unblock-or-block handoff

- The work is not complete if a fresh implementing agent could begin Tranche 4 without knowing which surfaces are first-class, which are convenience wrappers, which are compatibility-only wrappers, what migration or deprecation policy is approved, and whether public rollout is actually authorized.
- Direct red-state repro: current workflow docs contain no Tranche 3 decision record, so there is no explicit public-contract handoff packet for Tranche 4.
- Closing tasks: 2 and 3.
- Verification artifact that must fail the old implementation or fake-fix shape: the final decision record handoff packet, including settled decisions, authorization boundary, exact scope in and out, green-state gates, and stop conditions. The current repository fails because no such handoff exists.

## Handoff packet

- Active authorities:
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
  - `.workflow-docs/202605040131_type-stable-parse/03_tranche-1--tasking.md`
  - `.workflow-docs/202605040131_type-stable-parse/03_tranche-1a--remediation-tasking.md`
  - `.workflow-docs/202605040131_type-stable-parse/03_tranche-2--tasking.md`
  - `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`
- Parent documents:
  - `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
  - `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
  - this tasking file
- Settled decisions and non-negotiables:
  - `FileIO.load(...)` is a compatibility wrapper, not the package-owned semantic owner.
  - No repo-owned public API breakage is authorized without explicit user ratification.
  - No final exported public load verb or builder spelling has been ratified yet.
  - `load_alife_table(...)` is current code reality and must be classified explicitly rather than ignored.
  - The typed core, authoritative tables, retained annotation behavior, stable asset destructuring order, and typed-ownership framing from the PRD are not being reopened here.
- Authorization boundary:
  - In-scope execution for this tranche is creation and revision of `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`.
  - Default execution scope is workflow artifacts only.
  - Repo-owned docs or code may be touched only if needed to keep a supporting artifact honest and green while preparing the decision record; such touches do not authorize public rollout, export changes, or deprecations.
- Current-state diagnosis:
  - a non-exported typed canonical owner already exists in `src/load_owner.jl`
  - direct-owner tests already exist in `test/core/canonical_load_owner.jl`
  - `load_alife_table(...)` is exported in `src/LineagesIO.jl`
  - user-facing docs still present wrapper-first `load(...)` flows as the primary narrative
  - the tranche-designated decision record file is missing
- Primary-goal lock:
  - Locks 1 through 5 above are mandatory and separate
- Direct red-state repros:
  - missing `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  - `README.md` and `docs/src/index.md` still teach wrapper-first `load(...)` flows
  - `docs/src/phylonetworks.md` still calls `load(path, HybridNetwork)` the primary public happy path
  - no workflow artifact currently reconciles `canonical_load(...)`, exported `load_alife_table(...)`, and wrapper-first docs
- Owner and invariant under repair:
  - owner under repair: the review-gated public contract and compatibility-policy boundary for LineagesIO load surfaces
  - invariant: no repo-owned public rollout, rename, export, or deprecation may proceed until first-class typed surfaces, convenience wrappers, and compatibility-only wrappers are classified explicitly by a user-ratified or explicitly deferred decision record
- Exact files or surfaces in scope:
  - `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  - read-only diagnosis inputs from `src/LineagesIO.jl`, `src/load_owner.jl`, `src/load_compat.jl`, `src/fileio_integration.jl`, `src/alife_format.jl`, `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, `test/core/canonical_load_owner.jl`, `test/core/fileio_load_surfaces.jl`, and `test/core/alife_format.jl`
- Exact files or surfaces out of scope:
  - public rollout implementation in `src/*`
  - export changes in `src/LineagesIO.jl`
  - docs repositioning in `README.md` or `docs/src/*`
  - example updates in `examples/*`
  - rollout or parity tests for a ratified public surface
  - dependency changes
- Required upstream primary sources:
  - the six `FileIO` and `Tables` sources listed in the Governance section above
- Green-state gates:
  - if only workflow artifacts change, inherit prior repository green state and leave repo-owned code, docs, tests, and examples unchanged
  - if any repo-owned docs or code change, run `julia --project=test test/runtests.jl`
  - if any repo-owned docs or code change, run `julia --project=docs docs/make.jl`
  - if examples change, run the relevant example scripts and record them explicitly
- Stop conditions:
  - stop and revise this tasking if the decision record already exists, or if `src/LineagesIO.jl` already exports a package-owned public load verb that materially changes the tranche diagnosis
  - stop and escalate if execution would require shipping a new exported verb, public rename, deprecation, or docs rollout, because that belongs to Tranche 4
  - if the user declines to ratify a decision, record explicit deferral and leave Tranche 4 blocked; do not convert non-decision into silent approval

## Required revalidation before implementation

- Read `.workflow-docs/202605040131_type-stable-parse/02_tranches.md` and `.workflow-docs/202605040131_type-stable-parse/01_prd.md` in full.
- Read `src/LineagesIO.jl`, `src/load_owner.jl`, `src/load_compat.jl`, `src/fileio_integration.jl`, and `src/alife_format.jl` in full.
- Read `README.md`, `docs/src/index.md`, and `docs/src/phylonetworks.md` in full.
- Read `test/core/canonical_load_owner.jl`, `test/core/fileio_load_surfaces.jl`, and `test/core/alife_format.jl` in full.
- Re-read the upstream `FileIO` and `Tables` primary sources listed above in full before writing the decision record.
- Re-check that `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md` is still absent before creating it.
- Re-check that `README.md` and `docs/src/index.md` still present wrapper-first `load(...)` flows and that `docs/src/phylonetworks.md` still describes `load(path, HybridNetwork)` as the primary public happy path.
- Re-check that `src/LineagesIO.jl` still exports `load_alife_table` and does not export a package-owned public `load` verb.
- Re-check that `test/core/canonical_load_owner.jl` still proves direct-owner typed entry through `canonical_load(...)`, source descriptors, and typed request surfaces.
- If any of those revalidation points no longer hold, stop and revise this tasking before proceeding.

## Tranche execution rule

This tranche is a user-review gate, not a rollout tranche. It may create a ratified public-surface decision record or an explicit deferral record, but it must not silently ship the decision into repo-owned API, docs, examples, exports, deprecations, or migration behavior.

When this tranche is complete:

- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md` must exist.
- That file must record either a ratified public-surface decision or an explicit deferral.
- The file must classify first-class typed surfaces, convenience wrappers, and compatibility-only wrappers explicitly.
- The file must state plainly whether Tranche 4 is unblocked or remains blocked.
- If the tranche changes only workflow artifacts, the repository must otherwise remain unchanged.

## Non-negotiable execution rules

- Do not export `LineagesIO.load`, add a new exported public verb, rename a public surface, or introduce a deprecation in this tranche.
- Do not treat the existence of internal `canonical_load(...)` or typed request types as self-ratifying public API.
- Do not treat current wrapper-first docs as a settled public policy merely because they already exist.
- Do not treat the export of `load_alife_table(...)` as a settled classification. This tranche must classify it explicitly.
- Do not blur first-class typed surfaces and compatibility wrappers to avoid making the decision.
- Do not reopen the typed core, authoritative tables, retention semantics, stable asset destructuring order, or extension implementation boundaries under the label of public-surface review.
- Do not let Tranche 4 appear authorized unless this tranche records a ratified decision that explicitly unblocks it.
- Do not replace the guarantee matrix and migration note with a prose-only summary that omits surface-by-surface classification.

## Concrete anti-patterns or removal targets

- the missing Tranche 3 decision record file
- unresolved ambiguity about the first-class package-owned public load verb
- unresolved ambiguity about the public builder spelling and guarantee boundary
- unresolved ambiguity about the long-term public role of `load_alife_table(...)`
- wrapper-first docs and extension-specific happy-path docs surviving without an explicit approved compatibility story
- any attempt to preserve the status quo indefinitely through silence rather than through an explicit ratified deferral
- any Tranche 4 handoff that says only "see parent documents" instead of restating the settled public contract and stop conditions

## Failure-oriented verification

- The decision record file `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md` must exist at tranche end. Current code reality fails this check because the file is absent.
- The decision record must include a guarantee matrix naming, at minimum:
  - `FileIO.load(...)` path and stream surfaces
  - `load(src, NodeT)`
  - `load(src, basenode)`
  - `load(src; builder = fn)`
  - `load_alife_table(...)`
  - the direct typed owner surfaces already present in `src/load_owner.jl`
  - the extension-backed `HybridNetwork` and `MetaGraph` stories as they relate to the package-owned public contract
- The matrix must classify each surface as first-class typed surface, convenience wrapper, compatibility-only wrapper, internal owner surface, or explicitly deferred public decision. A document that leaves any one of those surfaces implicit fails verification.
- The decision record must include a migration and compatibility note that names any approved deprecations or breaks, or explicitly states that no such breakage is ratified yet.
- If the outcome is deferral, the decision record must say explicitly that Tranche 4 remains blocked and why. A vague "defer for later" note without a block condition fails verification.
- If the outcome is ratification, the decision record must state the exact approved scope and must not broaden that approval into a general default rule.
- If any repo-owned docs or code are touched while supporting this tranche, run `julia --project=test test/runtests.jl`.
- If any repo-owned docs or code are touched while supporting this tranche, run `julia --project=docs docs/make.jl`.

## Tasks

### 1. Draft the public-surface inventory and decision matrix

**Type**: WRITE  
**Output**: `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md` exists as a draft decision artifact containing a current-state inventory, a guarantee matrix, explicit decision options, and a migration-note skeleton for user review.  
**Depends on**: none  
**Positive contract**: The draft must inventory every current load surface that a user or maintainer could reasonably interpret as part of the public story. It must name `canonical_load(...)`, current source and request descriptor types, `FileIO.load(...)` path and stream surfaces, `load(src, NodeT)`, `load(src, basenode)`, `load(src; builder = fn)`, `load_alife_table(...)`, and the current extension-facing `HybridNetwork` and `MetaGraph` stories. It must also record the current export reality, current docs reality, current direct-owner test reality, and the exact decision questions reserved for user ratification.  
**Negative contract**: Do not write rollout instructions as if the decision were already approved. Do not omit the current mismatch between internal owner, exports, and docs. Do not classify internal names as public API merely because they exist in code. Do not treat current wrapper docs as the answer.  
**Files**: `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`  
**Out of scope**: `src/*`, `README.md`, `docs/src/*`, `examples/*`, `test/*`, export lists, deprecations, and rollout implementation  
**Verification**: Cross-check the draft against `src/LineagesIO.jl`, `src/load_owner.jl`, `src/load_compat.jl`, `src/fileio_integration.jl`, `src/alife_format.jl`, `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, `test/core/canonical_load_owner.jl`, `test/core/fileio_load_surfaces.jl`, and `test/core/alife_format.jl`. The old implementation must fail this task because the decision file does not exist and therefore no explicit inventory or matrix is present.

Draft the decision record in workflow-doc form only. Use the current codebase and docs as factual inputs, not as implied policy. The draft must distinguish verified facts from local inference wherever upstream host-framework semantics matter. It must be strong enough that the next REVIEW step is choosing among explicit options, not first discovering what surfaces exist.

### 2. Run the user-review ratification gate

**Type**: REVIEW  
**Output**: The draft decision record contains explicit user-reviewed answers, or explicit user-reviewed deferral language, for the public-verb decision, the builder public spelling decision, the `load_alife_table(...)` role decision, and any migration or deprecation decision.  
**Depends on**: 1  
**Positive contract**: The review resolves or explicitly defers each reserved public-contract decision separately. The decision record must distinguish first-class typed surfaces, convenience wrappers, compatibility-only wrappers, and internal owner surfaces without relying on implication.  
**Negative contract**: Do not turn silence into approval. Do not collapse several separate review gates into one broad acceptance note. Do not broaden a narrow approval into general breakage authorization. Do not let current wrapper-first docs wording answer the review by inertia.  
**Files**: `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`  
**Out of scope**: `src/*`, `README.md`, `docs/src/*`, `examples/*`, `test/*`, exports, deprecations, or rollout implementation  
**Verification**: The reviewed decision record must contain an explicit answer, or explicit deferral language, for each of the four decision clusters named below. A fake fix fails if any one cluster remains implicit, is answered only by current code reality, or is answered only by current docs phrasing.

Use the draft guarantee matrix and migration note to run the review gate that the PRD reserved for this tranche. The review must resolve or defer, explicitly and separately:

- whether the first-class package-owned public verb is `LineagesIO.load`, a distinct exported name, or deferred
- what public spelling, if any, should represent the builder-driven typed surface
- whether `load_alife_table(...)` is first-class, convenience, transitional, or compatibility-only
- whether any deprecations, renames, or explicit migration notes are approved

The review outcome must not be inferred from silence, convenience, or existing docs wording. Each unresolved choice must become an explicit deferral with scope and block conditions.

### 3. Finalize the decision record and the Tranche 4 handoff boundary

**Type**: WRITE  
**Output**: `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md` is complete, internally consistent, and usable as the sole decision artifact needed to unblock or keep blocking Tranche 4 honestly.  
**Depends on**: 2  
**Positive contract**: The final decision record must include active authorities, parent documents, settled decisions and non-negotiables, authorization boundary, current-state diagnosis, primary-goal lock coverage, direct red-state repros, exact scope in and out, required upstream primary sources, the guarantee matrix, migration and compatibility note, Tranche 4 blocked or unblocked status, green-state gates, and stop conditions. If the user ratifies a path, the file must state the exact approved scope. If the user defers, the file must state the exact deferral and the exact reason Tranche 4 remains blocked.  
**Negative contract**: Do not implement the ratified public rollout in this tranche. Do not leave Tranche 4 status implicit. Do not collapse several decisions into one vague approval note. Do not leave a fresh implementing agent guessing which surfaces are first-class, which are wrappers, or what breakage is authorized.  
**Files**: `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`  
**Out of scope**: `src/*`, `README.md`, `docs/src/*`, `examples/*`, `test/*`, `Project.toml`, and any dependency declaration unless a supporting artifact truly requires a narrow truth fix and the standard gates are then run  
**Verification**: Confirm that the final file satisfies Locks 1 through 5 directly. Confirm that a fresh implementing agent could execute Tranche 4, or honestly stop because it remains blocked, using only the decision record, the PRD, the tranche file, and the codebase. If any repo-owned docs or code were touched while finalizing the decision record, run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. Otherwise, inherit the prior green state because the tranche changed only workflow artifacts.

Finalize the decision record as the durable handoff artifact, not as a narrative memo. The task is complete only when the file makes it impossible for a fresh implementing agent to claim Tranche 4 is ready while any of the public-surface decision locks remain unresolved.
