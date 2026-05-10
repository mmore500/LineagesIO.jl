---
date-created: 2026-05-07T02:09:10-07:00
status: proposed
---

# PRD: post-audit contract repair for typed package-owned load rollout

## User statement

> A successful production workflow has been claimed by all agents.
>
> LineagesIO now features a full type-stable parse layer with full FileIO
> compatibility wrappers.
>
> Audit.
>
> Another agent provided the suggested audit fix to serve as the primer for a
> remedial PRD run:
> `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`
>
> Proceed.

## Problem statement

The typed package-owned load architecture effort landed its ratified first-class
public surfaces and its additive rollout, but the final audit still found three
surviving contract holes: one library-created MetaGraphsNext type-mismatch hole,
one supplied-instance MetaGraphsNext docs-versus-runtime hole, and one first-class
typed builder boundary hole.

The repository can currently claim green tests, green docs, and green examples
while those three bad shapes still survive. That means the remaining problem is
not general build breakage. It is contract honesty at the real public and owner
boundaries.

The proposed fix note in
`.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`
is directionally useful, but it is not safe as the only primer for downstream
execution. It does not carry the full governing authorities, parent workflow,
authorization boundary, or handoff packet, and one of its concrete MetaGraph type
descriptions is not the actual runtime type built by the current owner.

This remedial PRD exists to wrap the audit findings and the design note inside a
governed workflow artifact so downstream trancheing, tasking, implementation, and
review can proceed without silently reopening settled decisions or freezing a
partial diagnosis into execution.

## Target outcome

When this remedial work is complete:

- the ratified first-class public surfaces remain `LineagesIO.read_lineages` and
  `LineagesIO.BuilderDescriptor`
- `FileIO.load(...)` remains a compatibility wrapper and
  `load_alife_table(...)` remains the in-memory Tables.jl convenience wrapper
- the MetaGraphsNext library-created path is exact and honest about which target
  types it accepts and what concrete graph type it returns
- the MetaGraphsNext supplied-instance path has one explicit custom-data contract
  whose docs, tests, and runtime behavior agree
- the first-class typed builder path rejects erased or abstract handle types at
  the public boundary instead of allowing `Vector{Any}` back into the package-owned
  typed path
- downstream workflow documents no longer need to reconstruct the remedial
  controls from the audit report and the design note separately

## Primary-goal lock

### Lock 1: governed remedial workflow integrity

- The work is not complete if downstream execution still treats
  `00-02_audit-fix-decisions.md` as a ratified implementation order instead of a
  supporting design note.
- Direct red-state repro: a fresh downstream agent can act from the design note
  alone and miss the active authorities, parent workflow, authorization
  boundary, the direct bad-state repros, and the unresolved supplied-instance
  MetaGraphsNext contract decision.
- Owner, module, or tranche family expected to close it: this PRD and the
  downstream tranche file derived from it.
- Verification artifact that must fail the bad shape: downstream trancheing,
  tasking, or handoff artifacts must restate the active authorities, parent
  documents, settled decisions, the review gate for supplied-instance custom
  data, the direct red-state repros below, and the green-state gates. A
  link-only handoff is not sufficient.

### Lock 2: library-created MetaGraphsNext type-request honesty

- The work is not complete if any accepted library-created MetaGraphsNext
  request can still return a graph whose concrete type differs from the accepted
  requested type, or if unsupported concrete `MetaGraph` subtype requests are
  still silently accepted.
- Direct red-state repro: `read_lineages(tree_path, typeof(weighted_metagraph_target()))`
  currently succeeds even though `typeof(asset.graph) !== typeof(weighted_metagraph_target())`
  because the owner accepts a broad request but always constructs
  `default_metagraph()`.
- Owner, module, or tranche family expected to close it: the MetaGraphsNext
  library-created validation and construction boundary in `ext/MetaGraphsNextIO.jl`.
- Verification artifact that must fail the bad shape: every accepted
  library-created request must prove `typeof(asset.graph) === requested_type`,
  and every unsupported concrete `MetaGraph` subtype request must fail with a
  precise `ArgumentError`. Silent type mismatch is forbidden.

### Lock 3: supplied-instance MetaGraphsNext contract honesty

- The work is not complete if docs still promise custom `VertexData` or
  `EdgeData` behavior that the supplied-instance runtime cannot honor, or if
  unsupported shapes still fail with a raw internal `MethodError` that does not
  reflect the ratified contract.
- Direct red-state repro: `read_lineages!(tree_path, MetaGraph(SimpleDiGraph{Int}(), Symbol, MyVertex, Float64, ...))`
  currently throws raw dispatch failure from the extension unless `VertexData`
  and `EdgeData` happen to match one of a narrow hard-coded set, while README
  and docs currently describe broader customization.
- Owner, module, or tranche family expected to close it: the MetaGraphsNext
  supplied-instance owner in `ext/MetaGraphsNextIO.jl`, plus the docs and tests
  that expose that contract.
- Verification artifact that must fail the bad shape: both the first-class
  `read_lineages(...)` surface and any retained wrapper or docs surface touched
  by the same semantic must either succeed for the ratified supported custom
  data shapes or reject unsupported ones with precise contract-level errors.
  Docs, examples, and tests must agree with runtime.

### Lock 4: first-class BuilderDescriptor concrete-handle guarantee

- The work is not complete if `BuilderDescriptor(builder, Any)` or equivalent
  abstract or erased handle shapes can still enter the first-class typed path
  and reintroduce `Vector{Any}` or equivalent erased storage into the canonical
  owner.
- Direct red-state repro: `read_lineages(network_path, BuilderDescriptor(builder, Any))`
  currently succeeds and produces `Vector{Any}` parent collections on
  multi-parent events.
- Owner, module, or tranche family expected to close it: the first-class
  `BuilderDescriptor` public boundary in `src/read_lineages.jl`.
- Verification artifact that must fail the bad shape: `BuilderDescriptor(builder, Any)`
  and equivalent abstract handle requests must throw `ArgumentError`, while the
  same surface continues to succeed for concrete handle types.

## User stories

1. As a maintainer, I can start a remedial workflow from one governed PRD
   instead of reconstructing the audit boundary from scattered notes.
2. As a caller using `read_lineages(src, MetaGraph)`, I either receive the
   supported library-created MetaGraph target contract or an honest rejection
   before construction.
3. As a caller who wants custom MetaGraphsNext data storage, I can tell from
   the docs and runtime whether my supplied-instance `VertexData` and `EdgeData`
   types are supported.
4. As a caller using a supplied MetaGraph instance, I do not get a broad docs
   promise followed by a raw internal `MethodError`.
5. As a caller using `BuilderDescriptor`, I get a real first-class typed
   surface that rejects erased handle types at the public boundary.
6. As a caller who still uses `FileIO.load(...)`, I keep the compatibility
   wrapper story and parity with the package-owned owner for any affected
   behavior.
7. As a reviewer, I can verify each surviving audit finding directly instead of
   relying on a green suite alone.
8. As a downstream agent, I can read exact governance, vocabulary, upstream,
   and stop-condition requirements from the remedial workflow documents.
9. As a maintainer, I keep the tranche-3 and tranche-4 ratified public-surface
   decisions without reopening them under the label of audit cleanup.
10. As a user, I do not pay for a broader redesign or migration churn when the
    real need is honest contract repair.

## Authorized disruption boundary

- internal redesign allowed: targeted repairs in `ext/MetaGraphsNextIO.jl`,
  `src/read_lineages.jl`, directly affected docs and README surfaces, and the
  tests or examples needed to prove the repaired contract
- internal redesign forbidden: reopening the ratified `read_lineages` and
  `BuilderDescriptor` names; reopening the `FileIO.load(...)` compatibility
  classification; reopening the `load_alife_table(...)` convenience-wrapper
  classification; weakening authoritative-table-first behavior, retained
  annotation semantics, rooted-network validation, or stable asset
  destructuring order
- external breaking changes allowed: only contract-tightening needed to turn
  currently wrong or undocumented MetaGraphsNext target shapes into honest
  supported behavior or honest `ArgumentError`s, with synchronized docs and
  wrapper verification in the same tranche
- external breaking changes forbidden: renames, removals, deprecations, export
  changes, or broader migration policy changes beyond the audit-fix boundary
- required migration or compatibility obligations: keep `FileIO.load(...)`
  support; verify the first-class `read_lineages(...)` path and any retained
  wrapper paths affected by the fix; update `README.md`, `docs/src/index.md`,
  and any touched extension docs or examples whenever the public contract story
  changes
- non-negotiable protections: separate lock closure for each audit finding; no
  silent type mismatch; no docs-versus-runtime drift; no first-class typed path
  that still permits package-owned erased handle storage

## Current-state architecture

- The original architecture effort landed its ratified first-class package-owned
  public surfaces. `LineagesIO.read_lineages` and
  `LineagesIO.BuilderDescriptor` are the approved first-class names.
  `FileIO.load(...)` remains compatibility-only. `load_alife_table(...)`
  remains the in-memory Tables.jl convenience wrapper.
- The authoritative-table-first invariant remains correct. The parse layer still
  builds authoritative `node_table` and `edge_table` assets before graph or
  basenode materialization.
- The repository is currently green on the claimed rollout gates. The audit pass
  revalidated `julia --project=test test/runtests.jl`,
  `julia --project=docs docs/make.jl`, and the three example scripts named in
  the final audit.
- The remaining defects sit at two real owners. `ext/MetaGraphsNextIO.jl`
  splits behavior between a library-created default MetaGraph path and a
  caller-supplied-instance path, while `src/read_lineages.jl` owns the
  first-class `BuilderDescriptor` public boundary.
- In `ext/MetaGraphsNextIO.jl`,
  `validate_extension_load_target(::Type{<:MetaGraph})` still accepts broad
  concrete target requests, but `emit_basenode(...)` always constructs
  `default_metagraph()`. That lets an apparently accepted concrete request
  return the wrong graph type.
- The same extension still hard-codes only a narrow set of `VertexData` and
  `EdgeData` shapes. The current docs describe a broader supplied-instance
  customization story than the runtime currently honors.
- In `src/read_lineages.jl`, `BuilderDescriptor(builder, HandleT)` still lacks
  a concrete-handle guard, so `HandleT = Any` can reintroduce `Vector{Any}` into
  the package-owned typed path.
- The original architecture PRD and tranche file referenced an upstream
  `codebases-and-documentation` checkout path that is not present in the current
  environment. This remedial planning run revalidated FileIO, MetaGraphsNext,
  and Tables contracts from installed package sources instead. Downstream work
  must name those actual sources unless a new upstream checkout is supplied and
  revalidated.

## Target architecture

- This remedial effort does not replace the typed package-owned load
  architecture. It closes the three surviving audit holes while preserving the
  already-ratified public-surface boundary.
- The library-created MetaGraphsNext path must become exact and honest. Any
  accepted library-created MetaGraph request must be produced by the owner
  exactly. Any unsupported concrete `MetaGraph` request must be rejected before
  construction.
- The accepted library-created default-target family must be derived from the
  real owner that builds the graph, such as `default_metagraph()` or
  `typeof(default_metagraph())`, not from a hand-written partial type literal.
- The supplied-instance MetaGraphsNext path must become the single honest owner
  for custom-data and multi-parent MetaGraph behavior. Its public contract may
  be expanded or narrowed, but it may not remain ambiguous between docs and
  runtime.
- The first-class `BuilderDescriptor` surface must own the concrete-handle
  invariant at the public boundary. Downstream layers should never have to
  rediscover that a supposed typed builder path is still erased.
- Public and compatibility surfaces that expose an affected semantic must stay
  aligned. If the same semantic is available through `read_lineages(...)` and a
  retained wrapper, verification must cover both surfaces.

## Implementation decisions

- Preserve the settled tranche-3 and tranche-4 public decisions.
  `read_lineages` and `BuilderDescriptor` remain the ratified first-class
  package-owned public identifiers. `FileIO.load(...)` remains a
  compatibility-only wrapper. `load_alife_table(...)` remains the in-memory
  Tables.jl convenience wrapper.
- Repair owner boundaries, not symptoms. Finding 1 belongs at the MetaGraphsNext
  library-created validation and construction boundary. Finding 2 belongs at
  the MetaGraphsNext supplied-instance contract boundary plus its docs. Finding 3
  belongs at the `BuilderDescriptor` constructor boundary.
- Do not implement a post-hoc cast, silent subtype widening, or other anti-fix
  for the library-created MetaGraphsNext target mismatch. If a concrete
  library-created request is accepted, the produced graph must actually be of
  that type.
- Do not freeze the wrong concrete MetaGraphsNext type into workflow text. Any
  restriction on the library-created default target must be expressed in terms
  of the real owner that constructs it, not a hand-written partial
  parameterization.
- The supplied-instance MetaGraphsNext repair is a real public contract choice,
  not mere implementation latitude. Downstream workflow must record which custom
  `VertexData` and `EdgeData` story is ratified before claiming this finding is
  closed.
- Preferred supplied-instance direction for planning: ordinary Julia constructor
  dispatch on the user-owned data types is the leading candidate because it
  preserves the current custom-data story and makes the library-created path's
  redirect to the supplied-instance path honest. This candidate is not treated
  as ratified solely because it appears in
  `00-02_audit-fix-decisions.md`.
- If downstream review rejects constructor-based extension, the alternative must
  be a narrower supplied-instance contract with explicit early validation,
  precise `ArgumentError`s, and synchronized docs. Raw internal `MethodError`s
  plus broad docs claims are not an acceptable end state.
- The first-class typed builder fix must happen at the public boundary. Reject
  abstract or erased handle types during `BuilderDescriptor` construction rather
  than allowing them into the canonical owner and testing for bad shapes later.
- This remedial run must also repair workflow-source honesty. Downstream
  documents must name the upstream files actually read in this environment, not
  a missing checkout path.

## Module design

### MetaGraphsNext library-created target owner

- responsibility: validate and construct the library-created MetaGraph target
  path honestly
- interface: accepted library-created requests either produce the exact
  supported graph type or fail before construction with a precise error
- tested: direct contract tests for accepted and rejected library-created
  MetaGraphsNext target requests

### MetaGraphsNext supplied-instance owner

- responsibility: bind into caller-supplied empty MetaGraph instances, own the
  custom-data story, and preserve multi-parent support where documented
- interface: the ratified custom-data contract is explicit and the runtime error
  surface matches it
- tested: direct `read_lineages(...)` tests, retained wrapper parity where
  applicable, docs examples, and negative tests for unsupported shapes

### First-class typed builder boundary

- responsibility: enforce the concrete-handle invariant for `BuilderDescriptor`
  before request normalization enters the canonical owner
- interface: `BuilderDescriptor(builder, ConcreteHandleT[, ParentCollectionT])`
  succeeds; abstract or erased handle types fail with precise `ArgumentError`s
- tested: direct public-surface tests that fail erased handle shapes and
  preserve concrete-handle success

### Public docs and wrapper synchronization

- responsibility: keep README, extension docs, index docs, and retained wrapper
  stories aligned with the repaired contract
- interface: `read_lineages(...)` remains the first-class public surface;
  wrapper classifications do not drift; MetaGraphsNext custom-data claims match
  runtime
- tested: docs build, touched examples, and direct parity tests for any retained
  wrapper path affected by the repair

## Governance and required reading

All downstream trancheing, tasking, implementation, review, and audit work
derived from this PRD must require line-by-line reading of:

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
- this PRD

Relevant workflow authorities for this run also include the
`development-policies` and `devflow-architecture-01--write-a-prd` skill
instructions.

`STYLE-makie.md` is not an active authority for this remedial PRD because no
Makie or rendering work is in scope. `STYLE-python.md` was not present in the
repo-local governance set. The bundled development-policies reference depot also
did not include a bundled `CONTRIBUTING.md`, so repo-local `CONTRIBUTING.md`
remains controlling.

Controlled vocabulary constraints to preserve downstream:

- use `package-owned public surface`, `compatibility wrapper`, and
  `convenience wrapper` exactly as ratified in the parent workflow
- use `authoritative tables`, `materialized graph or basenode result`,
  `ownership boundary`, `lock item`, `red-state repro`, `verification artifact`,
  and `pass forward` as defined in `STYLE-vocabulary.md`
- use `read_lineages` and `BuilderDescriptor` as the exact first-class public
  identifiers
- do not describe this remedial effort as reopening the public naming decision;
  it is a contract-repair remediation inside the already-ratified boundary

## Primary upstream references

This remedial planning run revalidated the contract-sensitive upstream sources
actually available in the current environment.

Mandatory upstream sources for downstream work in this remedial workflow:

- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/README.md`
- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/loadsave.jl`
- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/types.jl`
- `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/query.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`

Contract facts carried from those sources into this PRD:

- FileIO owns formatted `load` dispatch, `File{fmt}` and `Stream{fmt}` wrappers,
  and path or stream format querying.
- MetaGraphsNext empty-graph construction requires explicit constructor inputs.
  There is no generic zero-argument path that can materialize arbitrary concrete
  `MetaGraph` subtypes implicitly.
- MetaGraphsNext `add_vertex!` and `add_edge!` accept caller-supplied data
  values and therefore rely on the graph's `VertexData` and `EdgeData` types to
  be coherent with those values.
- Tables defines the row and column access contracts that LineagesIO's
  authoritative tables and row refs depend on.

If the project owner later supplies a fresh `codebases-and-documentation`
checkout, downstream work may swap to that source set, but it must say so
explicitly and revalidate any contract conclusions that were previously taken
from installed package sources.

## Tranche gates

- every tranche must begin from a green state and end at a green state
- required standing gates for this remedial workflow are
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- if touched, run the relevant example scripts under `examples/Project.toml`,
  including
- `julia --project=examples examples/src/alife_standard_mwe.jl`
- `julia --project=examples examples/src/phylonetworks_mwe01.jl`
- `julia --project=examples examples/src/phylonetworks_mwe02.jl`
- if a tranche changes only workflow artifacts, it may inherit the current green
  code state, but it must still preserve honest handoff and lock-item closure
- no tranche may declare success from the green suite alone while any direct
  audit repro still survives

## Testing and verification decisions

- preserve the standing test, docs, and example gates recorded above
- add one direct regression or equivalent contract-proof artifact for each lock
  item in this PRD
- for library-created MetaGraphsNext target requests, verify both the accepted
  path and the rejected path so a fake fix cannot simply remove the positive
  path or keep the silent mismatch
- for the supplied-instance MetaGraphsNext contract, verification must cover at
  least one supported shape and at least one unsupported shape, and it must
  include every retained public surface through which that same semantic is
  available
- if the supplied-instance custom-data story remains public, keep at least one
  docs or example artifact aligned with that supported story
- for the first-class typed builder boundary, leave behind a direct regression
  that fails `BuilderDescriptor(builder, Any)` and preserves success for a
  concrete handle type
- weak proxies are not sufficient. The work is not complete because the suite is
  green if the direct audit repros still survive

## Out of scope

- redesigning the typed package-owned load architecture from scratch
- reopening the tranche-3 and tranche-4 public naming decisions
- adding new file-format owners or new public load surfaces
- changing authoritative table schemas or the stable asset destructuring order
- unrooted-network redesign or new MetaGraphsNext capabilities unrelated to the
  three audit findings
- broad MetaGraph factory design beyond what is required to make the current
  contract honest
- removing FileIO integration or changing its host-framework role

## Open questions

- Owner: explicit review inside the remedial workflow. Question: should the
  supplied-instance MetaGraphsNext fix ratify constructor-based extension on
  user-owned `VertexData` and `EdgeData` types, or should it instead narrow the
  supported contract and reject unsupported shapes early. Preferred planning
  direction: constructor-based extension, because it preserves the current
  custom-data story and makes the library-created redirect honest. Required
  discipline: downstream work must not silently choose one branch without
  recording the ratified contract and updating the verification plan
  accordingly.

## Handoff packet

- active authorities: `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  `STYLE-writing.md`, the original type-stable parse PRD and tranche file, the
  tranche-3 decision record, the audit report, the audit-fix design note, and
  this PRD
- parent documents:
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  and this PRD
- settled decisions and non-negotiables: `read_lineages` and `BuilderDescriptor`
  remain the ratified first-class package-owned public names; `FileIO.load(...)`
  remains compatibility-only; `load_alife_table(...)` remains the in-memory
  Tables.jl convenience wrapper; authoritative-table-first behavior, retained
  annotation semantics, rooted-network validation, and stable asset order are
  not being reopened
- authorization boundary: targeted contract repair only in the MetaGraphsNext
  extension, the first-class typed builder boundary, directly affected docs, and
  the verification artifacts needed to prove those repairs
- current-state diagnosis: the original rollout is green and structurally
  landed, but the MetaGraphsNext extension still contains a library-created type
  mismatch and a supplied-instance docs-versus-runtime drift, and the
  `BuilderDescriptor` boundary still permits erased handle typing
- primary-goal lock: downstream work must close all four lock items above
  separately and must not collapse them into one generic "audit fixed" claim
- direct red-state repros:
  `read_lineages(tree_path, typeof(weighted_metagraph_target()))` returns a
  different MetaGraph type than the accepted concrete target request;
  `read_lineages!(tree_path, supplied_custom_metagraph)` fails with raw internal
  dispatch for many custom `VertexData` or `EdgeData` shapes while docs still
  suggest broader support; `read_lineages(network_path, BuilderDescriptor(builder, Any))`
  still permits erased parent collections in the first-class typed path
- owner and invariant being repaired or relied on: the package-owned public
  contract must remain `read_lineages`-first and authoritative-table-first,
  while the MetaGraphsNext extension and the `BuilderDescriptor` boundary become
  honest about the types and contracts they actually own
- exact files or surfaces in scope: `ext/MetaGraphsNextIO.jl`,
  `src/read_lineages.jl`, directly affected docs and README files, and the
  tests or examples needed to prove the repaired contract
- exact files or surfaces out of scope: new public naming decisions, broad
  migration policy changes, authoritative table schema redesign, asset-order
  changes, and unrelated extension redesign
- required upstream primary sources: the installed FileIO, MetaGraphsNext, and
  Tables sources named in this PRD
- green-state gates: the standing test and docs gates, the touched example
  gates if applicable, plus direct lock-item regressions that fail the known bad
  shapes
- stop conditions: stop and escalate if downstream work needs to reopen the
  ratified public-surface names or classifications, if the supplied-instance
  MetaGraphsNext contract cannot be made honest without a broader external
  compatibility decision, if the real upstream contract differs materially from
  the sources named here, or if the missing upstream checkout path is treated as
  if it had been read in the current environment

## Further notes

- This PRD intentionally wraps
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`
  as supporting input only. That note is not the governing remedial artifact by
  itself.
- The final audit report in
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`
  remains the authoritative source for the three surviving findings this PRD
  operationalizes.
- The current environment did not provide the original
  `codebases-and-documentation` checkout path referenced by the first PRD. This
  PRD deliberately replaces that missing reference with the installed-package
  sources actually read during this planning run.
