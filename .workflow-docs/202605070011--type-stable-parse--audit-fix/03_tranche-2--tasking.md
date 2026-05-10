---
date-created: 2026-05-07T19:00:00-07:00
status: proposed
---

# Tasks for Tranche 2: Supplied-instance MetaGraphsNext contract decision record

Tasking identifier: `20260507T1900--tranche-2-tasking`

Parent tranche: Tranche 2
Parent PRD: `01_prd.md`

## Settled user decisions and environment baseline

- This tasking is for Tranche 2 only in `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`.
- This tranche is decision-only. It must not implement runtime, docs, example, or test changes that claim the supplied-instance MetaGraphsNext finding is closed.
- `read_lineages` and `BuilderDescriptor` remain the ratified first-class package-owned public identifiers.
- `FileIO.load(...)` remains a `compatibility wrapper`.
- `load_alife_table(...)` remains the in-memory Tables.jl `convenience wrapper`.
- No rename, export change, deprecation, migration-policy change, or broader public-contract rewrite is authorized in this tranche.
- The HITL reviewer for this tranche is the human project owner. No downstream agent may ratify branch A or branch B on its own. If the draft artifact is ready and the human project owner has not yet answered, execution must stop and wait.
- The only open contract branch for this tranche is the supplied-instance MetaGraphsNext custom-data story. Already-settled supplied-instance prerequisites must remain fixed input: the caller-supplied `MetaGraph` must be directed, empty, and use `Symbol` labels.
- The supplied-instance path already supports both single-parent and multi-parent sources when the caller supplies an empty `MetaGraph` instance with supported type parameters. This tranche does not reopen that settled runtime shape.
- Later Tranche 4 work depends on this tranche because any library-created MetaGraphsNext rejection that redirects callers to the supplied-instance path is honest only after the supplied-instance custom-data contract branch is explicitly reviewed here.
- The current live red state for this tranche remains active in the repository:
  - `ext/MetaGraphsNextIO.jl` currently supports only `VertexData = Nothing` or `VertexData <: NodeRowRef`.
  - `ext/MetaGraphsNextIO.jl` currently supports only `EdgeData = Nothing`, `Union{Nothing, Float64}`, `EdgeData <: Real`, or `EdgeData <: EdgeRowRef`.
  - a supplied `MetaGraph` with user-defined `VertexData` currently fails with a raw `MethodError` in `add_node_to_metagraph!`
  - a supplied `MetaGraph` with user-defined `EdgeData` currently fails with a raw `MethodError` in `add_edge_to_metagraph!`
  - `README.md` and `docs/src/index.md` still describe a broader empty-instance customization story than the runtime currently honors
- The reviewed decision artifact required by the tranche does not exist yet at `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`.
- Current repo state has already moved beyond the neighboring Tranche 1 red-state claims. This tasking must not inherit stale adjacent diagnosis. It must use the live repository state for Tranche 2 only.
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

Workflow authorities used to produce this tasking were `development-policies` and `devflow-architecture-03--tranche-to-tasks`. Downstream execution must preserve their pass-forward mandates, especially active-authority restatement, exact scope control, exact lock-item proof obligations, upstream-source naming, failure-oriented verification, and honest handoff packets.

Mandatory upstream primary sources for this tranche are:

- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`

These sources constrain the tranche as follows:

- `MetaGraphsNext` empty-graph construction requires explicit constructor inputs. There is no general zero-argument factory for arbitrary concrete `MetaGraph` subtype requests.
- `MetaGraphsNext.Graphs.add_vertex!` and `MetaGraphsNext.Graphs.add_edge!` accept caller-supplied metadata values. That means LineagesIO can only claim a broader custom `VertexData` or `EdgeData` story if it owns an honest conversion or validation boundary for those values.
- `MetaGraphsNext.Graphs.weights` and `MetaGraphsNext.default_weight` confirm the current weight-bearing `EdgeData` shapes used by the live LineagesIO extension.
- `Tables.AbstractRow`, `Tables.getcolumn`, `Tables.columnnames`, and the optional typed `getcolumn(row, ::Type{T}, i, nm)` entrypoint constrain what `NodeRowRef` and `EdgeRowRef` can honestly serve as constructor inputs for any user-owned custom-data extension path.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use `package-owned public surface`, `compatibility wrapper`, `convenience wrapper`, `authoritative tables`, `materialized graph or basenode result`, `ownership boundary`, `lock item`, `red-state repro`, `verification artifact`, `read_lineages`, and `BuilderDescriptor` consistently. Do not describe `00-02_audit-fix-decisions.md` as a ratified contract decision. Do not use `type stable` as a euphemism for a broader guarantee than the sources actually support.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, rebase, reset, and branch creation remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Primary-goal lock

### Lock 3a: the tranche must produce a human-reviewed branch decision or an explicit human-reviewed deferral

- The work is not complete if `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md` is still missing, or if it exists but does not record either a branch ratified by the human project owner or an explicit human-project-owner deferral that keeps later tranches blocked.
- Direct red-state repro: the required decision artifact does not exist in the current repository, and the parent PRD still leaves the supplied-instance branch explicitly open.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix shape: the final decision artifact itself, containing an explicit human-project-owner-reviewed branch or explicit human-project-owner-reviewed deferral plus plain blocked or unblocked status for Tranche 3 tasking. The current repository fails because the file is absent.

### Lock 3b: the current supplied-instance runtime contract must be recorded honestly

- The work is not complete if the decision artifact still over-promises custom `VertexData` or `EdgeData` support, or if it omits the exact current supported-shape matrix and the direct raw-dispatch failure modes.
- Direct red-state repro:
  - a supplied `MetaGraph(SimpleDiGraph{Int}(), Symbol, MyVertex, Float64, ...)` currently throws a raw `MethodError` from `add_node_to_metagraph!`
  - a supplied `MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, MyEdge, ...)` currently throws a raw `MethodError` from `add_edge_to_metagraph!`
  - the docs still tell users to pass an empty `MetaGraph` instance when custom `VertexData` or `EdgeData` types are needed
- Closing tasks: 1 and 3.
- Verification artifact that must fail the old implementation or fake-fix shape: the decision artifact must include the exact current supported-shape matrix, the exact unsupported-shape repros above, and the already-settled `directed + empty + Symbol labels` prerequisites. A generic "custom data is supported" summary fails this lock.

### Lock 3c: every affected public surface must be named and assigned to a downstream owner

- The work is not complete if one supported surface could still drift while another is fixed because the artifact names only the extension file or only one user-facing surface.
- Direct red-state repro: the same supplied-instance custom-data semantic currently appears through the first-class `read_lineages!(source, supplied_metagraph)` surface, the retained `load(source, supplied_metagraph)` compatibility wrapper, `README.md`, and `docs/src/index.md`.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix shape: the final artifact must enumerate each affected surface and say whether it is handled in this tranche, deferred to Tranche 3, or deferred to Tranche 5. A link-only or owner-only handoff fails this lock.

### Lock 1b: the supporting design note must not be treated as a ratified implementation order

- The work is not complete if a fresh downstream agent could still treat `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md` as a settled implementation order for the supplied-instance branch instead of a supporting note with one candidate direction.
- Direct red-state repro: `00-02_audit-fix-decisions.md` proposes constructor-based extension, but the parent PRD explicitly says that branch is not ratified solely because it appears there.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix shape: the final artifact must label `00-02_audit-fix-decisions.md` as supporting input only and record the actual reviewed branch or explicit deferral. A document that simply copies its preferred branch forward fails this lock.

### Lock 3d: the review gate and the implementation plan must remain separate

- The work is not complete if this tranche authorizes runtime implementation, docs synchronization, or test updates before the reviewed branch artifact exists.
- Direct bad shape to guard against: collapsing the review gate and the implementation plan into one unbroken tranche so downstream code work starts without an explicit contract decision.
- Closing tasks: 2 and 3.
- Verification artifact that must fail the bad implementation or fake-fix shape: the final artifact must state plainly that Tranche 3 owns runtime owner repair and that Tranche 5 owns public-surface synchronization and audit closure. If this tranche itself contains code tasking or rollout instructions, it fails.

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
  - The supplied-instance path must remain directed-only, empty-instance-only, and `Symbol`-label-only.
  - The HITL reviewer is the human project owner. A downstream agent may draft the decision artifact, but it must stop and wait for explicit human ratification or explicit human deferral before claiming Task 2 is complete.
  - This tranche decides only the custom `VertexData` / `EdgeData` branch. It does not reopen public naming, wrapper classification, or broader migration policy.
- Authorization boundary:
  - Only the reviewed decision artifact and the workflow reasoning needed to produce it are in scope.
  - Task 2 is not complete until the human project owner has supplied an explicit ratification or explicit deferral that is recorded in the artifact.
  - Runtime implementation, test updates, docs synchronization, and later-tranche tasking are out of scope.
- Current-state diagnosis:
  - the current extension supports only a narrow hard-coded set of `VertexData` and `EdgeData` shapes
  - user-defined custom-data shapes still fail with raw internal `MethodError`
  - docs still imply a broader empty-instance customization story
  - the required decision artifact is missing
- Primary-goal lock:
  - Locks 3a through 3d above are mandatory and separate
- Direct red-state repros:
  - a supplied user-owned `MyVertex` type currently fails in `add_node_to_metagraph!`
  - a supplied user-owned `MyEdge` type currently fails in `add_edge_to_metagraph!`
  - `README.md` and `docs/src/index.md` still suggest broader custom-data behavior than the runtime currently honors
  - `00-02_audit-fix-decisions.md` still presents one candidate direction without user review closure
- Owner and invariant under repair:
  - owner under repair in this tranche: the workflow review gate for the supplied-instance MetaGraphsNext custom-data contract
  - runtime owner under later repair: `ext/MetaGraphsNextIO.jl`
  - invariant: the supplied-instance path must have one explicit custom-data contract whose runtime, wrapper, docs, and tests can later be synchronized honestly
- Supported public surfaces affected by that owner or semantic:
  - first-class `read_lineages!(source, supplied_metagraph)`
  - retained `load(source, supplied_metagraph)` compatibility wrapper
  - `README.md` MetaGraphsNext extension guidance
  - `docs/src/index.md` MetaGraphsNext extension guidance
- Exact files or surfaces in scope:
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
  - read-only diagnosis inputs from `ext/MetaGraphsNextIO.jl`, `README.md`, `docs/src/index.md`, `test/extensions/metagraphsnext_public_surface.jl`, `test/extensions/metagraphsnext_supplied_basenode.jl`, and `test/extensions/metagraphsnext_canonical_owner.jl`
- Exact files or surfaces out of scope:
  - `ext/MetaGraphsNextIO.jl`
  - `README.md`
  - `docs/src/index.md`
  - `test/*`
  - `03_tranche-3--tasking.md`
  - runtime behavior changes
  - docs changes
  - migration or deprecation policy changes
- Required upstream primary sources:
  - the installed `MetaGraphsNext` and `Tables` sources named in the Governance section above
- Green-state gates:
  - the decision artifact exists
  - it records either a human-project-owner-reviewed branch or an explicit human-project-owner deferral
  - it records the exact current supported-shape matrix:
    - `VertexData = Nothing`
    - `VertexData <: NodeRowRef`
    - `EdgeData = Nothing`
    - `EdgeData = Union{Nothing, Float64}`
    - `EdgeData <: Real`
    - `EdgeData <: EdgeRowRef`
  - it records the direct unsupported-shape repros for a user-defined `MyVertex` and a user-defined `MyEdge` and says that the current failure mode is a raw internal `MethodError`
  - it enumerates every affected public surface and the later tranche that must move it
  - it labels `00-02_audit-fix-decisions.md` as supporting input only
  - if this tranche remains workflow-only, it may inherit the current code green state without rerunning the suite
- Stop conditions:
  - stop and wait for the human project owner's explicit branch ratification or explicit deferral once the draft artifact is ready
  - stop and escalate if review cannot honestly choose between the two parent-PRD branches
  - stop and escalate if the branch choice appears to require reopening the ratified public naming boundary or wrapper classification
  - stop and escalate if the current code or docs no longer match the live red-state repros named above
  - stop and escalate if execution pressure reaches runtime implementation, docs synchronization, or later-tranche tasking, because those belong to Tranches 3 and 5

## Required revalidation before implementation

- Read `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md` and `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md` in full.
- Read `ext/MetaGraphsNextIO.jl` in full.
- Read `README.md` and `docs/src/index.md` in full.
- Read `test/extensions/metagraphsnext_public_surface.jl`, `test/extensions/metagraphsnext_supplied_basenode.jl`, and `test/extensions/metagraphsnext_canonical_owner.jl` in full.
- Read the installed upstream `MetaGraphsNext` and `Tables` sources named above in full.
- Re-check that `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md` is still absent before creating it.
- Re-check that the supplied-instance path still accepts only the narrow hard-coded `VertexData` and `EdgeData` shapes listed in this tasking.
- Re-check that a supplied `MyVertex` still fails with a raw `MethodError` in `add_node_to_metagraph!`.
- Re-check that a supplied `MyEdge` still fails with a raw `MethodError` in `add_edge_to_metagraph!`.
- Re-check that `README.md` and `docs/src/index.md` still describe a broader empty-instance customization story than the runtime currently honors.
- Re-check the user-authorized disruption boundary before making workflow changes.
- If any of those revalidation points no longer hold, stop and revise this tasking before proceeding.

## Tranche execution rule

This tranche is a pure HITL decision tranche. It may create and finalize the reviewed decision artifact only. It must not perform runtime implementation, docs synchronization, example updates, test updates, or later-tranche tasking.

The HITL decision gate belongs to the human project owner. After Task 1 drafts the artifact, execution must pause and wait for the human project owner's explicit ratification or explicit deferral. No downstream agent may choose branch A or branch B on its own and count the gate as satisfied.

When this tranche is complete:

- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md` must exist.
- That file must record either a reviewed branch or an explicit reviewed deferral.
- That file must name the exact current supported-shape matrix and the exact unsupported-shape repros.
- That file must enumerate every affected public surface and say which later tranche owns its migration.
- That file must state plainly whether Tranche 3 is unblocked for a separate tranche-to-tasking pass or whether later tranches remain blocked.

Because this tranche is workflow-only, it may inherit the current repository green state if it changes only workflow artifacts. If execution drifts into code, docs, tests, or examples, stop for scope drift instead of claiming success.

## Non-negotiable execution rules

- Do not implement constructor-based fallbacks or narrowed early validation in this tranche.
- Do not edit `ext/MetaGraphsNextIO.jl`, `README.md`, `docs/src/index.md`, or `test/*` in this tranche.
- Do not reopen `read_lineages`, `BuilderDescriptor`, `FileIO.load(...)`, or `load_alife_table(...)` naming or classification.
- Do not treat the candidate direction in `00-02_audit-fix-decisions.md` as ratified merely because it exists.
- Do not let any downstream agent self-ratify branch A or branch B. Only the human project owner may close the HITL review gate.
- Do not leave the supported-shape matrix implicit.
- Do not leave one affected public surface implicit while naming only another.
- Do not let a green suite stand in for the required reviewed contract decision.
- Do not collapse the review gate and the implementation plan into one artifact.

## Concrete anti-patterns or removal targets

- the missing `00-03_supplied-instance-contract-decision.md` artifact
- the broad but unratified claim that "an empty MetaGraph instance customizes VertexData and EdgeData" without an exact supported contract
- any downstream assumption that `00-02_audit-fix-decisions.md` already settled the supplied-instance branch
- any link-only handoff that points to the parent PRD or design note without restating the branch, red-state repros, and stop conditions
- any decision artifact that records only a preference rather than a ratified branch or explicit deferral
- any artifact that merges review-gate work and runtime tasking into one unbroken tranche

## Failure-oriented verification

- The final decision artifact must exist at `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`. Current repository state fails because the file is absent.
- The final artifact must record either a branch ratified by the human project owner or an explicit human-project-owner deferral. A candidate, leaning, or agent-selected branch alone fails.
- The final artifact must contain the exact current supported-shape matrix:
  - `VertexData = Nothing`
  - `VertexData <: NodeRowRef`
  - `EdgeData = Nothing`
  - `EdgeData = Union{Nothing, Float64}`
  - `EdgeData <: Real`
  - `EdgeData <: EdgeRowRef`
- The final artifact must contain the direct unsupported-shape repros for a user-defined `MyVertex` and a user-defined `MyEdge` custom-data type, and it must say that the current failure is a raw internal `MethodError`.
- The final artifact must enumerate each affected surface:
  - `read_lineages!(source, supplied_metagraph)`
  - `load(source, supplied_metagraph)`
  - `README.md`
  - `docs/src/index.md`
- For each affected surface, the artifact must say whether it is handled in this tranche, deferred to Tranche 3, or deferred to Tranche 5. A document that names only the runtime owner or only the docs fails.
- The final artifact must name `00-02_audit-fix-decisions.md` as supporting input only and must not let it stand in for the reviewed branch decision.
- If this tranche changes only workflow artifacts, inherit the current green code and docs state. If code, docs, examples, or tests are touched, that is scope drift and must fail instead of being counted as success.

## Tasks

### 1. Draft the supplied-instance contract decision artifact

**Type**: WRITE  
**Output**: `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md` exists as a draft decision artifact containing active authorities, current-state diagnosis, upstream contract facts, affected-surface inventory, explicit branch matrix, and direct red-state repros.  
**Depends on**: none  
**Positive contract**: The draft must record the live runtime contract exactly, not a generalized story. It must inventory the settled supplied-instance prerequisites, the exact currently supported `VertexData` and `EdgeData` shapes, and every affected public surface. It must also record the two parent-PRD decision branches explicitly:

- branch A: constructor-based extension on user-owned data types, where later implementation would support user-owned `VertexData(::NodeRowRef)` and `EdgeData(::EdgeWeightType, ::EdgeRowRef)` constructors while preserving the existing built-in special cases
- branch B: narrowed supported-shape contract, where later implementation would keep support only for the currently built-in `VertexData` and `EdgeData` shapes and would reject unsupported shapes early with precise `ArgumentError`

The draft must also record the later-tranche ownership boundary:

- Tranche 3 owns runtime owner repair in `ext/MetaGraphsNextIO.jl` plus direct supported and unsupported contract proofs across `read_lineages(...)` and retained `load(...)`
- Tranche 5 owns `README.md` and `docs/src/index.md` synchronization plus final public-contract lock closure

**Negative contract**: Do not pre-ratify either branch. Do not write runtime implementation steps as if the decision were already approved. Do not omit the exact current supported-shape matrix. Do not treat `00-02_audit-fix-decisions.md` as a settled branch choice.  
**Files**: `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, `README.md`, `docs/src/index.md`, `test/*`, later-tranche tasking, runtime fixes, docs synchronization, and public-surface behavior changes  
**Verification**: Cross-check the draft against `ext/MetaGraphsNextIO.jl`, `README.md`, `docs/src/index.md`, `test/extensions/metagraphsnext_public_surface.jl`, `test/extensions/metagraphsnext_supplied_basenode.jl`, `test/extensions/metagraphsnext_canonical_owner.jl`, and the installed `MetaGraphsNext` and `Tables` sources. The old state fails this task because the decision file does not exist and no exact supported-shape matrix or branch matrix is present.

### 2. Run the supplied-instance contract review gate

**Type**: REVIEW  
**Output**: The decision artifact records an explicit human-project-owner-reviewed answer selecting one branch, or an explicit human-project-owner-reviewed deferral that keeps Tranches 3 through 5 blocked.  
**Depends on**: 1  
**Positive contract**: The review must pause and wait for an explicit answer from the human project owner. No agent-side inference or preference is allowed to close this gate. The human project owner must resolve or explicitly defer the single open contract branch reserved by the parent PRD. If branch A is ratified, the artifact must say that later implementation may rely on user-owned `VertexData(::NodeRowRef)` and `EdgeData(::EdgeWeightType, ::EdgeRowRef)` constructors as the extension point. If branch B is ratified, the artifact must say that later implementation must keep only the currently supported built-in shapes and reject everything else early with precise `ArgumentError`. In either case, the reviewed outcome must say how the branch applies across both supported runtime entry surfaces and across the two later docs surfaces.  
**Negative contract**: Do not turn a preferred direction into ratification. Do not allow an unstated middle ground. Do not authorize runtime implementation, docs updates, or tests from this task alone. Do not let current docs wording or the design note answer the review by inertia. Do not let any downstream agent self-select branch A or branch B and mark the task complete.  
**Files**: `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, docs files, tests, exports, migration work, and Tranche 3 implementation planning  
**Verification**: The reviewed artifact must plainly say branch A, branch B, or explicit deferral, and it must attribute that answer to the human project owner. A fake fix fails if the file records only a leaning, only a candidate, only a restatement of current runtime facts, or only an agent-authored choice with no human-project-owner response.

### 3. Finalize the decision artifact and the Tranche 3 handoff boundary

**Type**: WRITE  
**Output**: `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md` is complete, internally consistent, and strong enough for a fresh downstream agent to prepare or consume a separate Tranche 3 tasking pass honestly, or to stop honestly because the branch remains deferred.  
**Depends on**: 2  
**Positive contract**: The final artifact must include active authorities, parent documents, settled decisions and non-negotiables, authorization boundary, current-state diagnosis, separate lock coverage, direct red-state repros, the owner and invariant under repair, every affected public surface, required upstream primary sources, green-state gates, and stop conditions. It must state exactly whether Tranche 3 is unblocked for a separate tranche-to-tasking pass, and if so, what that later tasking must cover in the runtime owner and what Tranche 5 must later synchronize in the public docs and final verification. If the review defers the branch, the final artifact must keep Tranches 3 through 5 blocked and must name the exact remaining stop condition.  
**Negative contract**: Do not write Tranche 3 runtime tasking here. Do not leave any affected public surface implicit. Do not present the decision artifact as sufficient for direct runtime implementation without the dedicated Tranche 3 tasking pass. Do not unblock Tranche 3 tasking without a branch-specific handoff packet. Do not let a fresh agent infer scope from parent links alone.  
**Files**: `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, `README.md`, `docs/src/index.md`, `test/*`, `03_tranche-3--tasking.md`, and any runtime or docs changes  
**Verification**: Confirm that a fresh downstream agent could use only the final decision artifact, the remedial PRD, the tranche file, and the codebase to prepare or consume a separate Tranche 3 tasking artifact without reopening derivable decisions. Confirm that the decision artifact still does not authorize direct runtime implementation without that Tranche 3 tasking pass. The old state fails because no decision artifact exists and `00-02_audit-fix-decisions.md` is not a sufficient handoff.
