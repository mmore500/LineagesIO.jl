# Audit report: typed package-owned load architecture

Parent PRD: `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
Date: 2026-05-06
Files in scope: 35

## Summary

The effort is close to structurally sound: the package-owned `read_lineages(...)`
surface, compatibility-wrapper classification, authoritative-table-first
invariant, docs rollout, and repository green-state gates are all landed and
currently passing. However, the implementation still leaves 2 high-severity
public-contract holes and 1 medium-severity typed-core hole behind that green
state, so the claimed production workflow should not yet be treated as fully
complete.

## Handoff integrity

The surviving PRD, tranche, tasking, and tranche-3 decision chain preserve the
real authorities, the additive-only public rollout boundary, the compatibility
classification of `FileIO.load(...)`, and the ratified `read_lineages` /
`BuilderDescriptor` naming decisions honestly.

The remaining drift is in verification closure, not in the workflow prose. The
tranche-4 green-state record proves that the happy-path rollout, docs build, and
examples are green, but it does not yet fail 3 still-live bad shapes:

- a library-created MetaGraphsNext type request whose requested concrete
  `MetaGraph` type is silently ignored
- a supplied-instance MetaGraphsNext path whose docs claim custom
  `VertexData`/`EdgeData` support but whose implementation rejects many such
  targets with a raw `MethodError`
- a first-class typed builder descriptor that still permits `HandleT = Any`,
  reintroducing `Vector{Any}` into the canonical owner path

Those gaps mean the active lock items around honest typed ownership and honest
public contract enforcement are not all closed yet, even though the standard
green-state gates pass.

## Critical findings

No critical findings.

## High findings

### 1. MetaGraphsNext library-created type requests are accepted without honoring the requested graph type

**Location**: `ext/MetaGraphsNextIO.jl:271-329`
**Category**: Logic / Architecture
**Problem**: The library-created MetaGraphsNext path accepts any
`Type{<:MetaGraph}` through `validate_extension_load_target(::Type{<:MetaGraph})`,
but `emit_basenode(...)` always constructs `default_metagraph()` instead of a
value of the requested concrete type. A direct repro with
`read_lineages(tree_path, typeof(weighted_metagraph_target()))` succeeds and
returns a different `MetaGraph` type than the caller asked for. This violates
the node-type public contract: the surface either needs to materialize the
requested type or reject unsupported type requests up front.
**Suggestion**: Narrow the accepted library-created MetaGraphsNext node-type
surface to the exact supported type family and fail early for any unsupported
concrete `MetaGraph` type, or implement a real factory path that constructs the
requested concrete type. Add a direct regression that asserts
`typeof(asset.graph) === requested_type` for every accepted library-created
MetaGraphsNext node-type request.

### 2. The MetaGraphsNext supplied-instance contract over-promises custom data-type support and fails with a raw MethodError

**Location**: `docs/src/index.md:214-232`, `README.md:174-179`,
`ext/MetaGraphsNextIO.jl:142-258`
**Category**: Logic / Consistency
**Problem**: The public docs say callers can pass an empty MetaGraph instance
to customize `VertexData` / `EdgeData`, but the implementation only provides
node/edge insertion methods for a narrow subset of type shapes:
`Nothing`, `NodeRowRef`, `EdgeRowRef`, and numeric edge-data variants. A direct
repro with a supplied target such as
`MetaGraph(SimpleDiGraph{Int}(), Symbol, MyVertex, Float64, ...)` fails with a
raw `MethodError` from `add_node_to_metagraph!`, not an honest contract-level
error. This is a user-facing contract mismatch on a documented public surface.
**Suggestion**: Either implement the advertised generic custom-data behavior, or
narrow the docs and add early validation that rejects unsupported `VertexData`
and `EdgeData` combinations with a precise `ArgumentError`. Add public-surface
regressions for both supported custom shapes and explicitly unsupported ones so
the docs and runtime behavior cannot drift apart again.

## Medium findings

### 3. The first-class BuilderDescriptor surface still permits `Any` and reintroduces `Vector{Any}` into the canonical owner

**Location**: `src/read_lineages.jl:12-52`, `src/load_owner.jl:153-190`,
`src/construction.jl:103-129`, `src/construction.jl:747-800`
**Category**: Architecture
**Problem**: `BuilderDescriptor(builder, HandleT[, ParentCollectionT])` accepts
`HandleT = Any`, and the canonical typed builder path then creates
`Vector{Any}` parent collections on multi-parent sources. A direct repro with
`read_lineages(network_path, BuilderDescriptor(builder, Any))` succeeds and
surfaces `Vector{Any}` in the parent-collection event stream. That defeats the
core architectural guarantee this effort was meant to establish: first-class
typed owner paths should not permit package-owned erased hot-path handle
storage.
**Suggestion**: Reject `HandleT = Any` and other abstract/erased handle types on
the first-class `BuilderDescriptor` surface, and consider similarly tightening
`ParentCollectionT` so the typed path cannot degrade into the old erased-core
shape. Add a direct public-surface regression that fails when a first-class
builder descriptor would cause `Vector{Any}` or equivalent erased handle
storage to enter the canonical owner.

## Low findings

No low-severity findings.

## No findings

- `FileIO.load(...)` remains correctly classified as a compatibility wrapper,
  and the public docs/examples now consistently center `read_lineages(...)`.
- The authoritative-table-first parse invariant is preserved across Newick and
  alife ingestion.
- `load_alife_table(...)` is consistently positioned as the in-memory
  Tables.jl convenience wrapper over the same canonical owner.
- The PhyloNetworks public rollout, docs, examples, and parity checks remained
  structurally consistent in this audit pass.
- The repository’s claimed green-state commands all passed during this audit:
  `julia --project=test test/runtests.jl`,
  `julia --project=docs docs/make.jl`,
  `julia --project=examples examples/src/alife_standard_mwe.jl`,
  `julia --project=examples examples/src/phylonetworks_mwe01.jl`, and
  `julia --project=examples examples/src/phylonetworks_mwe02.jl`.
