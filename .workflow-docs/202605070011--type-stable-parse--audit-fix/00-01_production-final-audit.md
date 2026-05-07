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


## Alternate agent review

Finding 1 — "build a real factory"

The bug is in MetaGraphsNextIO.jl:321-330. The emit_basenode dispatch on NodeTypeLoadRequest{<:MetaGraph, <:Any}unconditionally calls default_metagraph(), which always produces the one hard-wired type defined at MetaGraphsNextIO.jl:116-126: MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, Union{Nothing,Float64}, ...). The NodeT type parameter from the request is never used. Meanwhile validate_extension_load_target(::Type{<:MetaGraph}) at line 271 is a no-op — it accepts every concrete MetaGraph subtype silently.

"Build a real factory" means: instead of always calling default_metagraph(), look at the requested NodeT and construct an instance of it. The problem is that MetaGraph has no zero-argument constructor — you must supply graph type, label type, vertex data type, edge data type, default weight, weight function, and default weight value. So a general factory would need either a user-supplied constructor callback, or a protocol like build_default_metagraph(::Type{MyMetaGraph}) -> MyMetaGraph. This is extension-side work only and lives entirely in MetaGraphsNextIO.jl.

The simpler fix the audit also mentions: narrow the accepted type to exactly what default_metagraph() produces, reject everything else at validate_extension_load_target. That is ~3 lines. "Build a real factory" is harder — probably 1 new protocol function, a default implementation, and tests. It's not a trivial one-liner, but it's not a deep refactor either. All contained in the extension.

As for origin: this was not a previous restriction that was deliberately carried forward. The emit_basenode dispatch was written to produce the default type, and the validator was written broadly without thinking through what "accept any MetaGraph subtype" commits you to. The two were never reconciled. It crept in as an implicit assumption rather than arriving as an explicit design decision.

Finding 2 — custom VertexData/EdgeData

The supplied-instance path dispatches on the concrete MetaGraph type's type parameters. add_node_to_metagraph! has exactly two methods, at MetaGraphsNextIO.jl:171-195: one for VertexData = Nothing, one for VertexData <: NodeRowRef. add_edge_to_metagraph! has four methods, at MetaGraphsNextIO.jl:204-264: EdgeData = Nothing, EdgeData = Union{Nothing,Float64}, EdgeData <: Real, EdgeData <: EdgeRowRef. Nothing else. Any VertexData type outside those two, or any EdgeData type outside those four, has no matching method and Julia throws a raw MethodError from inside the dispatch.

The docs at the referenced lines promise that you can supply a MetaGraph with any VertexData/EdgeData parametrization to control what gets stored. The implementation never delivered that generality — it only covers the shapes needed for the internal default and the NodeRowRef/EdgeRowRef pass-through cases.

Where did the drift occur: the docs were written from the user-facing perspective of "you hand in a MetaGraph with the types you want, you get it back populated." The implementation was written from the protocol perspective of "handle the shapes I know about." Those two framings were never reconciled in a test that proves the docs' claim for an arbitrary user struct.

Is implementing it complex? Genuine custom VertexData support requires a protocol — something like extract_vertex_data(::Type{MyVertex}, nodedata::NodeRowRef) -> MyVertex — so the extension knows how to populate a node from the row reference when VertexData = MyVertex. That's a real interface design decision. The narrow fix (honest docs + early rejection with a clear ArgumentError) is small. The full implementation is architectural.

Finding 3 — HandleT = Any, "first-class typed owner path", "canonical"

Starting with the vocabulary:

Canonical = the single internal load function canonical_load(source_descriptor, request) that both read_lineages(...) and load(...) ultimately call. It's "canonical" in the sense that it's the one authoritative path regardless of which surface the user entered from.
First-class = read_lineages(...) specifically. "First-class" is being used to mean "the new primary surface" as opposed to "compatibility wrapper" (load(...)).
Typed owner path = the route through the canonical owner where the handle type and parent-collection type are fully concrete at construction time. The whole point of this effort was to ensure that the canonical owner's hot path — specifically the multi-parent parent-collection that gets built on every multi-parent construction event — is a concrete typed Vector{MyHandleType}, not Vector{Any}.
The actual bug: BuilderDescriptor has a guard at read_lineages.jl:46-50 that checks isconcretetype(ParentCollectionT) and rejects abstract parent collection types. But there is no equivalent guard for HandleT. So BuilderDescriptor(builder, Any) constructs BuilderDescriptor{BuilderT, Any, Vector{Any}} without complaint. That flows through typed_builder_request into TypedBuilderLoadRequest(builder, Any, Vector{Any}) and then into ParentCollectionFactory{Any, Vector{Any}}, which calls Vector{Any}(parent_handles) on every multi-parent event. The builder callback receives a Vector{Any} instead of a concrete typed vector — the same erased shape the compatibility load(...; builder = fn) path uses, now reachable through the first-class surface.

The fix is one guard: isconcretetype(HandleT) || throw(ArgumentError(...)) in the BuilderDescriptor constructor at read_lineages.jl:27-35, mirroring the existing ParentCollectionT guard. One line of code plus a test. This one is the most straightforward of the three.

