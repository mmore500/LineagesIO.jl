---
date-created: 2026-04-25T22:51:00
version: 1.0
---

# PRD: LineagesIO.jl phase 1 — builder protocol and format support

## User statement

Formalize the existing design documents — `design/brief.md` (v2.0) and
`design/brief--community-support-objectives.md` (v1.0) — into an authoritative
implementation-ready PRD for phase 1 tranche work. The design is settled; this
document is the handoff artifact. All decisions are made. The brief documents
are authoritative; any deviation discovered during implementation must be
escalated rather than adapted in place.

## Problem statement

The Julia ecosystem has no standard FileIO-compatible backend for phylogenetic
graph formats. Packages such as PhyloNetworks.jl and Phylo.jl each implement
ad-hoc file I/O, forcing community developers to reinvent parsing logic rather
than focusing on domain work. There is no principled protocol for materializing
parsed graphs into arbitrary user-defined types, no lazy iteration layer for
multi-graph sources, and no unified metadata table interface.

LineagesIO.jl addresses this gap by providing:

- a FileIO-compatible backend for phylogenetic formats
- a principled builder protocol (`add_child`) for type-agnostic graph construction
- Tables.jl-compliant node and edge metadata tables
- lazy iteration over multi-graph and multi-source collections
- first-class extension support for PhyloNetworks.jl and Phylo.jl via Julia
  package extensions

## Target outcome

LineagesIO.jl phase 1 is complete when all of the following are true:

1. The `add_child` builder protocol is exported, documented, and dispatches
   correctly at both the network (general) and single-parent (restricted) levels.
2. Format submodules exist for `format"Newick"`, `format"LineageNetwork"`, and
   `format"LineageGraphML"`, each declaring their protocol tier before parsing
   begins.
3. The discovery pass runs before any `add_child` calls and produces stable `R`
   (node row) and `RE` (edge row) NamedTuple types for the entire source load.
4. `LineageGraphStore{NodeT}` and `LineageGraphAsset{NodeT}` are defined, correctly
   parameterized, and type-stable.
5. `load`, `loadfirst`, `loadone`, and multi-source `load([...], ...)` work for
   all phase 1 formats.
6. The FileIO adapter layer is in place with format detection and explicit
   override.
7. `finalize_graph!` is exported as a no-op default and correctly called after
   each graph's `add_child` sequence.
8. `PhyloNetworksExt` implements the full network-level `add_child` including
   per-edge gamma assignment from `edgedata` and post-build finalization via
   `finalize_graph!`.
9. `PhyloExt` implements the single-parent-level `add_child` for Newick trees.
10. Round-trip integration tests exist for file → `HybridNetwork` (via
    `PhyloNetworksExt`) and file → `RootedTree` (via `PhyloExt`).
11. All tests pass; Aqua.jl and JET.jl report no issues.

## User stories

The following numbered list covers all externally meaningful behaviors of phase 1,
including error states and edge cases.

### Builder protocol — method extension (dispatch style)

1. A user can define `LineagesIO.add_child(parent :: Nothing, ...) :: MyNode`
   and `LineagesIO.add_child(parent :: MyNode, ...) :: MyNode` for their node
   type, pass `MyNode` as a positional argument to `load`, and receive a
   `LineageGraphStore{MyNode}` with `graph_rootnode :: MyNode` on each `LineageGraphAsset`.

2. A user can define the network-level overload
   `LineagesIO.add_child(parents :: AbstractVector{MyNode}, ...) :: MyNode` and
   load a `format"LineageNetwork"` file to receive a `LineageGraphStore{MyNode}` with
   hybrid nodes correctly threaded through the builder.

3. The compiler specializes the entire parse pipeline on `NodeT` at compile time;
   no runtime dispatch or type inference failure occurs in the `add_child`
   invocation path.

### Builder protocol — callback style

4. A user can pass `builder = (parent, node_idx, label, edgelength, edgedata,
   nodedata) -> ...` as a keyword argument to `load` and receive a
   `LineageGraphStore{NodeT}` parameterized on the callback's return type.

5. When both extended methods and a `builder` callback are present, the `builder`
   callback takes precedence.

### Protocol determination and builder validation

6. Before any `add_child` call, the library determines the protocol tier (network
   or single-parent) from the format declaration — not from per-node runtime
   inspection.

7. If a `format"LineageNetwork"` file is loaded with a builder that defines only
   the single-parent overload, the library raises an informative error at load
   time, before parsing begins.

8. If a `format"Newick"` file is loaded with a builder that defines only the
   network-level overload, the library calls the network overload with
   `parents = []` for the root and `parents = [parent]` (a one-element vector)
   for all other nodes — no error is raised.

### Discovery pass and metadata tables

9. Before any `add_child` calls, the parser performs a discovery pass that
   collects every annotation key present in the source file for nodes and for
   edges.

10. Every discovered key is promoted to a typed column; no overflow dictionaries
    exist anywhere in the return types.

11. For keys absent on some nodes (or some edges), the column type is
    `Union{T, Nothing}` and absent rows carry `nothing`.

12. The node row type `R` is a fixed `NamedTuple` type established after the
    discovery pass; it is stable for the entire load of a source.

13. The edge row type `RE` is a fixed `NamedTuple` type established after the
    discovery pass; it is stable for the entire load of a source.

14. `nodedata :: R` passed to each `add_child` call gives the user typed access to
    node annotations (e.g., `nodedata.bootstrap`).

15. `edgedata :: RE` (single-parent level) or `edgedata :: AbstractVector{RE}`
    (network level) passed to each `add_child` call gives the user typed access
    to edge annotations (e.g., `edgedata[i].gamma` for network-level hybrid
    edges).

16. The edge table in each `LineageGraphAsset` always contains one row per directed edge,
    with columns `src_node_idx`, `dst_node_idx`, `edgelength`, and any
    format-specific promoted columns.

### Node index and label

17. `node_idx` is a 1-based sequential integer assigned by the library; it is the
    primary key of the node table and the foreign key in the edge table
    (`src_node_idx`, `dst_node_idx`).

18. When a source node has no label, the parser passes `""` to `add_child`.
    The orchestration layer passes labels through unchanged. `node_idx` is
    the unique identifier within a graph.

### Return types

19. `load` always returns `LineageGraphStore{NodeT}`; callers cannot assume a source
    contains only one graph.

20. `LineageGraphStore` has fields: `source_table`, `collection_table`, `graph_table`,
    `graphs` (lazy iterator of `LineageGraphAsset{NodeT}`).

21. `LineageGraphAsset` has fields: `index`, `source_idx`, `collection_idx`,
    `collection_graph_idx`, `collection_label`, `graph_label`, `node_table`,
    `edge_table`, `graph_rootnode`, `source_path`.

22. `graph_rootnode :: NodeT` is the handle returned by the first `add_child`
    call (the entry-point node).

23. `LineageGraphStore{NodeT}` and `LineageGraphAsset{NodeT}` are fully type-stable; all type
    parameters are resolved at compile time.

### Convenience wrappers

24. `loadfirst(src, ...)` returns the first `LineageGraphAsset`; it does not error if
    the source contains multiple graphs.

25. `loadone(src, ...)` returns a single `LineageGraphAsset`; it raises an informative
    error if the source does not contain exactly one graph.

26. `load([f1, f2, ...], ...)` loads multiple sources; each `LineageGraphAsset` carries
    `source_idx` identifying its origin file.

### Lazy iteration

27. `LineageGraphStore.graphs` is a lazy iterator yielding `LineageGraphAsset{NodeT}` values;
    multi-graph sources are not fully materialized unless explicitly collected.

### Newick format

28. `format"Newick"` correctly parses standard parenthetical Newick notation,
    including edge lengths (`:length`), internal node labels, and multi-tree
    files.

29. The Newick parser declares single-parent protocol before parsing begins.

30. The Newick parser performs a discovery pass and produces node and edge table
    schemas before any `add_child` calls.

31. `add_child` is called in pre-order (top-down) traversal after the parser's
    internal state is complete.

### LineageNetwork format

32. `format"LineageNetwork"` correctly parses extended Newick with hybrid or
    reticulate node notation as used by PhyloNetworks.jl, including `#H1`-style
    hybrid markers and gamma on the third colon field (`:length:support:gamma`).

33. The LineageNetwork parser declares general (network) protocol before parsing
    begins.

34. Hybrid nodes (with multiple parent edges) are correctly threaded through
    `add_child(parents::AbstractVector{NodeT}, ...)` with `parents`,
    `edgelengths`, and `edgedata` as parallel vectors.

35. Gamma values are available in `edgedata[i].gamma` at the `add_child` call
    site; no two-phase workaround is required.

### LineageGraphML format

36. `format"LineageGraphML"` correctly parses the phylogeny-specific GraphML
    profile used by this project.

37. The LineageGraphML parser declares single-parent protocol before parsing
    begins.

38. Generic `.graphml` files are not treated as LineageGraphML; explicit format
    override is required for ambiguous extensions.

### FileIO adapter

39. `load` and `save` are implemented as private methods inside the `LineagesIO`
    module, not extending `FileIO.load` or `FileIO.save` directly.

40. Format auto-detection works for unambiguous extensions.

41. Explicit format override works: `load(File{format"Newick"}("file.txt"), ...)`.

42. Stream-based I/O works: `load(Stream{format"Newick"}(io), ...)`.

43. The package is designed to support `add_format` registration with stable
    format identifiers, documented extensions, and detection mechanisms;
    registration itself is out of scope for phase 1.

### finalize_graph! hook

44. `finalize_graph!` is exported from `LineagesIO` as a protocol function with a
    no-op default implementation.

45. `finalize_graph!` is called once per graph after the last `add_child` call
    for that graph and before `LineageGraphAsset` is assembled.

46. Extensions can override `finalize_graph!` for their node handle type to
    perform post-build cleanup.

### PhyloNetworksExt

47. When a user loads `using LineagesIO, PhyloNetworks`, the `PhyloNetworksExt`
    extension is automatically activated.

48. `PhyloNetworksNodeHandle` bundles a `HybridNetwork` and a `Node`; it is the
    `NodeT` for PhyloNetworks round-trips.

49. The entry-point `add_child` call creates the `HybridNetwork`, creates the
    root `Node`, and returns a `PhyloNetworksNodeHandle`.

50. Non-entry-point `add_child` calls add nodes and edges to `handle.net`; for
    hybrid nodes (`length(parents) > 1`), one `Edge` is created per parent, with
    `e.gamma` assigned from `edgedata[i].gamma` in a single pass.

51. `finalize_graph!` on `PhyloNetworksNodeHandle` calls `storeHybrids!`,
    `checkNumHybEdges!`, and `directedges!` on `handle.net`.

52. Integration test: load a Newick file and a LineageNetwork file and confirm
    the resulting `HybridNetwork` has the correct structure (node count, edge
    count, hybrid status, gamma values).

### PhyloExt

53. When a user loads `using LineagesIO, Phylo`, the `PhyloExt` extension is
    automatically activated.

54. `PhyloNodeRef` bundles a `RootedTree` and a node name string; it is the
    `NodeT` for Phylo round-trips.

55. The entry-point `add_child` call creates the `RootedTree`, creates the root
    node via `createnode!`, stores `node_idx` in node data, and returns a
    `PhyloNodeRef`.

56. Non-entry-point `add_child` calls use `createnode!` + `createbranch!`;
    `edgelength` is converted from `nothing` to `missing` for Phylo's
    `Union{Float64, Missing}` branch length field.

57. `node_idx` is stored in Phylo's node data dict (`"node_idx" => node_idx`)
    for round-trip joins to the LineagesIO node table.

58. Integration test: load a Newick file and confirm the resulting `RootedTree`
    has the correct node labels, branch lengths, and node data.

### LineagesMakie interoperability

59. Loaded graphs (regardless of `NodeT`) are immediately consumable by
    LineagesMakie via its accessor protocol (`children`, `edgelength`,
    `branchingtime`, `coalescenceage`, `nodevalue`, `nodecoordinates`, `nodepos`)
    once the user supplies the necessary accessors for their `NodeT`. LineagesIO
    itself does not need to supply these accessors.

### Error handling

60. Parse errors include source location (file name and line or character offset
    where possible).

61. Unsupported constructs raise an informative error naming the construct and
    its location.

62. Ambiguous formats that cannot be auto-detected raise an informative error
    requesting explicit format override.

63. A builder that is incompatible with the declared protocol tier raises an
    informative error at load time, before parsing begins.

64. `loadone` raises an informative error if the source contains zero or more
    than one graph.

## Authorized disruption boundary

- **Internal redesign allowed**: All implementation is within the library
  boundary. The source code is a clean stub; no existing implementation is
  disrupted.
- **Internal redesign forbidden**: Changes to the `add_child` protocol
  signature, `LineageGraphStore` or `LineageGraphAsset` struct fields, or the `finalize_graph!`
  hook contract must be escalated to the project owner. These interfaces are
  settled in the design briefs.
- **External breaking changes allowed**: None applicable. This is initial
  development; there are no external consumers.
- **Required migration or compatibility obligations**: None. The package is new.
- **Non-negotiable protections**:
  - `design/brief.md` and `design/brief--community-support-objectives.md` are
    authoritative. Deviations must be escalated.
  - `STYLE-vocabulary.md` controlled terms must be used throughout. Proscribed
    terms must not appear in any identifier, type name, function name, keyword
    argument, symbol, or field name.
  - `STYLE-julia.md` functional design principles apply without exception.
  - Tables.jl is the only table dependency; DataFrames.jl must not be added.

## Current-state architecture

The package currently consists of a stub module with no implementation:

```julia
module LineagesIO
# Write your package code here.
end
```

The test suite has a stub `runtests.jl` running `Aqua.test_all(LineagesIO)` and
`JET.test_package(LineagesIO; target_defined_modules = true)` only.

The `Project.toml` has no dependencies beyond the Julia version constraint
(`julia = "1.10.10"`).

There are no format parsers, no builder protocol, no return types, and no package
extensions.

The design is complete and authoritative in the companion documents named in the
further notes section.

## Target architecture

The package is organized into the following layers, each with a single
well-defined ownership boundary.

### add_child protocol layer

The central exported generic function. Everything in the parsing pipeline
converges on calls to `add_child`. The library calls it; users supply the
implementation.

Two dispatch levels:

- **Network level** (general case): handles rooted and unrooted graphs, directed
  and undirected, including reticulate and hybrid nodes with multiple incoming
  edges. Signature: `add_child(parents::AbstractVector{NodeT}, node_idx::Int,
  label::AbstractString, edgelengths::AbstractVector{Union{EdgeUnitT, Nothing}},
  edgedata::AbstractVector{RE}, nodedata::R) :: NodeT`.
- **Single-parent level** (restricted case): applies when every node has at most
  one parent. Entry-point overload: `add_child(parent::Nothing, ...) :: NodeT`.
  Non-entry-point overload: `add_child(parent::NodeT, ...) :: NodeT`.

Protocol tier is determined once, before any `add_child` call, by the format
declaration. Builder validation is enforced before the parse begins.

`finalize_graph!(handle::NodeT)` is called after the last `add_child` call for
each graph. The default is a no-op. Extensions override for post-build cleanup.

### Parsing layer

One submodule per format. Each submodule:

- declares protocol tier before parsing begins
- performs the discovery pass to build node and edge table schemas
- emits `add_child` calls in pre-order (top-down) traversal after completing
  internal format parsing
- performs source-location tracking for error messages

Phase 1 formats:

| Submodule | Format identifier | Protocol tier |
|---|---|---|
| Newick | `format"Newick"` | Single-parent |
| LineageNetwork | `format"LineageNetwork"` | General (network) |
| LineageGraphML | `format"LineageGraphML"` | Single-parent |

### Discovery pass

A pre-scanning phase owned by each parser submodule. Runs before any `add_child`
calls. Collects every annotation key name present across all nodes and all edges
in the full source. Builds fixed `R` (node NamedTuple row type) and `RE` (edge
NamedTuple row type) schemas. For optional fields, column type is
`Union{T, Nothing}`. Schema is stable for the entire load of a source.

### Builder protocol orchestration

The routing layer that:

- receives the format's protocol tier declaration
- validates builder compatibility before the first `add_child` call
- manages the `node_idx` counter (1-based, sequential, unique within a graph)
- calls `finalize_graph!` after each graph's `add_child` sequence
- assembles `LineageGraphAsset{NodeT}` after finalization

### Metadata architecture

All metadata is fully promoted. No overflow dictionaries exist anywhere.

Tables are Tables.jl-compliant. DataFrames.jl is not a dependency.

| Table | Granularity | Key columns |
|---|---|---|
| Node table | One row per node | `node_idx` (primary key) |
| Edge table | One row per directed edge | `src_node_idx`, `dst_node_idx`, `edgelength` |
| Graph table | One row per graph | Index coordinates + label summary |
| Collection table | One row per collection within a source | `source_idx`, `collection_idx`, `label`, `graph_count` |
| Source table | One row per source file | `source_idx`, `source_path` |

### Return types

- **`LineageGraphAsset{NodeT}`** — single-graph result struct with index coordinates,
  node and edge tables, and `graph_rootnode :: NodeT`. Parameterized and
  type-stable.
- **`LineageGraphStore{NodeT}`** — top-level load result with `source_table`,
  `collection_table`, `graph_table`, and `graphs` (lazy iterator of
  `LineageGraphAsset{NodeT}`).

### FileIO adapter layer

Private `load` and `save` implementations inside the `LineagesIO` module.
Format detection from extension and magic bytes. Explicit format override via
`File{format"..."}(...)`. Stream-based I/O via `Stream{fmt}(io)`.

### View layer

Lazy iterator over `LineageGraphStore.graphs`. Multi-source indexing via `source_idx`.
`loadfirst` and `loadone` convenience wrappers.

### Package extension architecture

Extensions activated automatically by Julia's package extension mechanism (Julia
1.9+) when both LineagesIO and the target package are loaded in the same Julia
session.

Phase 1 extensions:

| Extension module | Triggered by | Location |
|---|---|---|
| `PhyloNetworksExt` | `using PhyloNetworks` | `ext/PhyloNetworksExt.jl` |
| `PhyloExt` | `using Phylo` | `ext/PhyloExt.jl` |

Dependency structure:

```
LineagesIO (core)
  ├── FileIO     (dependency)
  ├── Tables     (dependency)
  ├── [weak] PhyloNetworks → ext/PhyloNetworksExt.jl
  └── [weak] Phylo         → ext/PhyloExt.jl
```

No version pinning on weak dependencies. Extensions are expected to work across
a supported range, validated in each extension's own test suite.

## Implementation decisions

All decisions below are made and authoritative. Any deviation discovered during
implementation requires escalation to the project owner before the tranche
proceeds.

1. **Protocol determination**: The library determines which dispatch level applies
   once, before any `add_child` call, from the format declaration. Per-call
   dispatch based on `length(parents)` is explicitly rejected.

2. **Builder validation gate**: Incompatible builders are caught at load time
   before parsing begins, not mid-parse and not on the first multi-parent node
   encountered.

3. **`finalize_graph!` as protocol function**: Exported from `LineagesIO` with a
   no-op default. Called after the last `add_child` for each graph. Extensions
   override for their node handle type.

4. **Per-edge metadata in `add_child` signatures**: All `add_child` overloads
   carry `edgedata`. Network level: `edgedata :: AbstractVector{RE}`. Single-
   parent non-entry-point: `edgedata :: RE`. Single-parent entry-point:
   `edgedata :: Nothing`. This eliminates any two-phase gamma workaround for
   `PhyloNetworksExt`.

5. **Node label passthrough**: The orchestration layer passes `label` from the
   parser to `add_child` unchanged. Parsers supply `""` for absent labels. The
   orchestration layer performs no disambiguation. Node identity and all
   programmatic joins use `node_idx`, the primary key of the node table.
   Extensions that require unique node names (e.g., Phylo, PhyloNetworks) handle
   name uniqueness internally.

6. **Tables.jl only, no DataFrames.jl**: LineagesIO takes Tables.jl as a
   dependency. DataFrames.jl is not a dependency; users who want a DataFrame
   call `DataFrame(result.graphs[1].node_table)`.

7. **GraphML policy**: Generic `.graphml` files are not claimed. Only the
   phylogeny-specific `format"LineageGraphML"` profile is owned by this package.

8. **`builder` callback precedence**: An explicit `builder` keyword argument
   always takes precedence over extended `LineagesIO.add_child` methods.

9. **NEXUS and TskitTrees deferred**: Phase 2 formats. NEXUS support for
   `PhyloNetworksExt` and `PhyloExt` is deferred to phase 2.

## Module design

### `add_child` protocol module

**Responsibility**: Define and export the central builder protocol generic
function and the `finalize_graph!` hook.

**Interface**:

```julia
# NodeT     = node handle type; dispatch target for user extensions
# EdgeUnitT = edge length element type (unconstrained; Nothing for absent lengths)
# R         = row type of node_table, fixed by discovery pass
# RE        = row type of edge_table, fixed by discovery pass

# Network level — general case (baseline)
function add_child(
    :: AbstractVector{NodeT},                      # parents
    :: Int,                                         # node_idx
    :: AbstractString,                              # label
    :: AbstractVector{Union{EdgeUnitT, Nothing}},  # edgelengths
    :: AbstractVector{RE},                          # edgedata
    :: R,                                           # nodedata
) :: NodeT where {NodeT, EdgeUnitT, R, RE} end

# Single-parent level — entry-point node
function add_child(
    :: Nothing,                      # parent
    :: Int,                           # node_idx
    :: AbstractString,                # label
    :: Union{EdgeUnitT, Nothing},     # edgelength
    :: Nothing,                       # edgedata
    :: R,                             # nodedata
) :: NodeT where {NodeT, EdgeUnitT, R} end

# Single-parent level — subsequent nodes
function add_child(
    :: NodeT,                         # parent
    :: Int,                           # node_idx
    :: AbstractString,                # label
    :: Union{EdgeUnitT, Nothing},     # edgelength
    :: RE,                            # edgedata
    :: R,                             # nodedata
) :: NodeT where {NodeT, EdgeUnitT, R, RE} end

# Post-build finalization hook
function finalize_graph!(:: NodeT) :: NodeT where {NodeT} end  # no-op default
```

**Tested**: Yes. Unit tests for: dispatch level detection logic; builder
validation gate (compatible and incompatible builders); `finalize_graph!` default
no-op; `builder` callback precedence over extended methods.

---

### Newick submodule

**Responsibility**: Parse standard parenthetical Newick format. Declare
single-parent protocol. Perform discovery pass. Emit `add_child` in pre-order.

**Interface**: Internal submodule; accessed through the FileIO adapter and builder
protocol orchestration layer.

**Tested**: Yes. Parse tests for: simple trees; trees with edge lengths; trees
with internal node labels; multi-tree files; empty labels (passed through as
`""`); bootstrap values in node metadata.

---

### LineageNetwork submodule

**Responsibility**: Parse extended Newick with `#H1`-style hybrid and reticulate
node notation (PhyloNetworks semantics). Declare general (network) protocol.
Perform discovery pass including gamma extraction from the third colon field.

**Interface**: Internal submodule.

**Tested**: Yes. Parse tests for: trees with no hybrid nodes (degrades gracefully);
networks with hybrid nodes; gamma available in `edgedata[i].gamma` at the
`add_child` call site.

---

### LineageGraphML submodule

**Responsibility**: Parse the phylogeny-specific GraphML profile. Declare
single-parent protocol.

**Interface**: Internal submodule.

**Tested**: Yes. Parse tests for: basic round-trip; attribute promotion; explicit
format override required for ambiguous extensions.

---

### Discovery pass

**Responsibility**: Pre-scan source before any `add_child` calls. Collect all
node and edge annotation key names. Build fixed NamedTuple row types `R` and
`RE`. Promote optional fields to `Union{T, Nothing}`.

**Interface**: Internal to each parser submodule.

**Tested**: Yes. Tests for: schema inference correctness; `Union{T,Nothing}`
promotion; schema stability across rows; empty source handling.

---

### Builder protocol orchestration

**Responsibility**: Route between format parsers and user builders. Validate
builder compatibility. Manage `node_idx`. Call `finalize_graph!`. Assemble
`LineageGraphAsset`.

**Interface**: Internal layer; coordinates parser submodules and user-supplied
builders.

**Tested**: Yes. Tests for: error on incompatible builder at load time; `builder`
kwarg precedence; `node_idx` sequencing; `finalize_graph!` invocation timing.

---

### `LineageGraphAsset{NodeT}`

**Responsibility**: Single-graph result struct.

**Interface**: Public exported type.

```julia
struct LineageGraphAsset{NodeT}
    index                :: Int
    source_idx           :: Int
    collection_idx       :: Int
    collection_graph_idx :: Int
    collection_label     :: Union{String, Nothing}
    graph_label          :: Union{String, Nothing}
    node_table           :: <Tables.jl compliant>
    edge_table           :: <Tables.jl compliant>
    graph_rootnode       :: NodeT
    source_path          :: Union{String, Nothing}
end
```

**Tested**: Yes. Type stability tests; parameterization tests; Tables.jl
compliance tests for node and edge tables.

---

### `LineageGraphStore{NodeT}`

**Responsibility**: Top-level load result.

**Interface**: Public exported type.

```julia
struct LineageGraphStore{NodeT}
    source_table     :: <Tables.jl compliant>
    collection_table :: <Tables.jl compliant>
    graph_table      :: <Tables.jl compliant>
    graphs           :: <lazy iterator of LineageGraphAsset{NodeT}>
end
```

**Tested**: Yes. Single-source and multi-source tests; lazy iteration;
`loadfirst` and `loadone` behavioral tests.

---

### FileIO adapter

**Responsibility**: Private `load` and `save`; format detection; explicit
override; stream I/O.

**Interface**: Follows FileIO backend contract. Does not extend `FileIO.load` or
`FileIO.save`.

**Tested**: Yes. Tests for: format detection by extension; explicit override via
`File{format"..."}(...)`; stream I/O via `Stream{fmt}(io)`; multi-source loading;
error on ambiguous format without explicit override.

---

### `finalize_graph!` protocol hook

**Responsibility**: Export no-op default; define the protocol contract for
post-build finalization.

**Interface**: `finalize_graph!(handle :: NodeT) :: NodeT`

**Tested**: Yes. Test that the no-op default does not error. Integration tests
(via `PhyloNetworksExt`) that the hook is called after each graph's `add_child`
sequence and before `LineageGraphAsset` is assembled.

---

### `PhyloNetworksExt`

**Responsibility**: Implement `add_child` and `finalize_graph!` for
`PhyloNetworksNodeHandle`. Build `HybridNetwork` with correct hybrid edges,
gamma values from `edgedata`, and post-build finalization.

**Interface**: Extension module at `ext/PhyloNetworksExt.jl`. Defines
`PhyloNetworksNodeHandle`; implements network-level `add_child`; overrides
`finalize_graph!`.

Concrete implementation stubs are specified in
`design/brief--community-support-objectives.md`.

**Tested**: Yes. Integration tests: load a Newick file → correct `HybridNetwork`
(node count, edge count, labels); load a LineageNetwork file with hybrid nodes
→ correct `HybridNetwork` with gamma values; `graph_rootnode.net` is a valid
`HybridNetwork`.

---

### `PhyloExt`

**Responsibility**: Implement `add_child` for `PhyloNodeRef`. Build `RootedTree`
incrementally. Store `node_idx` in node data dict.

**Interface**: Extension module at `ext/PhyloExt.jl`. Defines `PhyloNodeRef`;
implements single-parent-level `add_child`.

Concrete implementation stubs are specified in
`design/brief--community-support-objectives.md`.

**Tested**: Yes. Integration tests: load a Newick file → correct `RootedTree`;
node labels correct; branch lengths correct (`nothing` → `missing` conversion);
`node_idx` present in node data dict enabling join to node table.

---

## Governance and controlled vocabulary

### Governance documents — mandatory line-by-line reading

All implementers, reviewers, tranche authors, and downstream agents must read the
following governance documents **line by line** before planning, implementing,
reviewing, or delegating any work derived from this PRD. This obligation must be
**passed forward** into every downstream tranche document, tasking document, and
delegated work description without exception.

| Document | Relevance |
|---|---|
| `STYLE-architecture.md` | Ownership boundaries; anti-fix prohibition; green-state discipline |
| `STYLE-docs.md` | Documentation formatting |
| `STYLE-git.md` | Commit style and branching model |
| `STYLE-julia.md` | Functional design; naming; type annotations; testing; mutation contract |
| `STYLE-makie.md` | Makie integration contracts (relevant to LineagesMakie interoperability) |
| `STYLE-upstream-contracts.md` | Host-framework contract reading and preservation |
| `STYLE-verification.md` | Verification artifact standards; what counts as sufficient proof |
| `STYLE-vocabulary.md` | Controlled terminology; proscribed terms |
| `STYLE-workflow-docs.md` | Workflow document structure; pass-forward obligations |
| `STYLE-writing.md` | Prose style for documentation |
| `CONTRIBUTING.md` | Contribution process and expectations |

### Companion design documents — mandatory reading

Both documents must be read alongside this PRD before any implementation begins.

- `design/brief.md` (v2.0, 2026-04-25) — primary design document; authoritative
- `design/brief--community-support-objectives.md` (v1.0, 2026-04-25) —
  extension architecture; parse stack reference; resolved design decisions

Neither document is complete without the other, and neither is complete without
this PRD.

### Controlled vocabulary

`STYLE-vocabulary.md` is the authoritative reference. The following constraints
apply to all code, tests, documentation, and workflow documents derived from this
PRD.

**Terms that must be used in identifiers and type names**:

| Concept | Correct form | Proscribed forms |
|---|---|---|
| Graph elements (generic) | `node`, `NodeT` | `vertex`, `vertices`, `n`, `v`, `V` |
| Connections | `edge` (in code) | `branch`, `arc`, `link` |
| Terminal nodes | `leaf`, `leaves` | `tip`, `terminal` |
| Entry-point node (identifier) | `rootnode` | `root`, `root_node`, `rootvertex` |
| Edge weight (identifier) | `edgelength` | `branch_length`, `edge_length`, `weight`, `len` |
| Edge source argument | `src` | `fromnode`, `fromvertex`, `from_node` |
| Edge destination argument | `dst` | `tonode`, `tovertex`, `to_node` |
| Branching structure | `clade graph` | `topology` (unqualified) |
| Central protocol function | `add_child` | — |
| Post-build hook | `finalize_graph!` | — |
| Top-level result types | `LineageGraphStore`, `LineageGraphAsset` | — |
| Workflow work unit | `tranche` | `issue` (as workflow term), `ticket` |
| Bounded steps within a tranche | `task` | `step` (when carrying formal verification) |
| Masking change | `anti-fix` | `fix` or `workaround` without explicit owner/scope statement |

Any agent or contributor needing to coin a new term must raise the question with
the project owner before implementing. If a decision is made, `STYLE-vocabulary.md`
must be updated with explicit approval. No amendment may be made unilaterally.

---

## Primary upstream references

The following upstream primary sources materially constrain the design of phase 1.
All implementers and downstream tranche authors must read the relevant sources
**line by line** before implementing the affected functionality.

Available at `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`:

| Source | Relevance |
|---|---|
| `fileio.jl/` | FileIO backend contract; private `load`/`save` protocol; `add_format` registration; stream and file dispatch |
| `NewickTree.jl/` | Julia Newick parser reference (stack-based); tokenization and traversal approach |
| `DendroPy/` | Python reference for Newick/NEXUS parsing architecture; builder pattern; tokenizer design |
| `Phylo.jl/` | Julia Newick parser (combinator-based); NHX metadata parsing; `createnode!`, `createbranch!`, `setnodedata!` API |
| `PhyloNetworks.jl/` | Extended Newick with hybrid nodes; `HybridNetwork`, `Node`, `Edge` types; `pushNode!`, `pushEdge!`, `storeHybrids!`, `checkNumHybEdges!`, `directedges!` API |
| `AbstractTrees.jl/` | Traversal traits and iteration interface; LineagesMakie interoperability |
| `Phylogenies.jl/` | Minimal Julia core type reference; ecosystem context |

Companion package (local workspace):

| Source | Relevance |
|---|---|
| `../../LineagesMakie.jl/` | Accessor protocol (`children`, `edgelength`, `branchingtime`, etc.); loaded graphs must be immediately consumable |

---

## Tranche gates

Every tranche of implementation work derived from this PRD must satisfy the
following gates.

### Green state at tranche start

- All existing tests pass (`julia --project=. test/runtests.jl`).
- `Aqua.test_all(LineagesIO)` reports no issues.
- `JET.test_package(LineagesIO; target_defined_modules = true)` reports no issues.
- No uncommitted changes from the previous tranche.

### Green state at tranche end

All of the above, plus:

- All tests added by the tranche pass.
- No regressions in functionality delivered by earlier tranches.
- New public functions, types, and exported names have docstrings.
- If a format submodule was added, at least one round-trip parse test exists for
  that format.
- If a package extension was added or modified, at least one integration test
  demonstrates the round-trip (file → target package type) and verifies
  field-level values, not merely that the function returns something.
- If the `add_child` protocol signature, `LineageGraphStore` or `LineageGraphAsset` struct
  fields, or the `finalize_graph!` hook contract changed, the design briefs were
  updated with explicit project owner approval before implementation proceeded.

### Authorization rule

Any proposed deviation from the `add_child` protocol signature, `LineageGraphStore` or
`LineageGraphAsset` struct fields, `finalize_graph!` hook contract, format identifiers,
or controlled vocabulary must be escalated to the project owner before the
tranche proceeds. The tranche must not silently adapt.

---

## Testing and verification decisions

### What must stay green throughout

- `Aqua.test_all(LineagesIO)` — code quality
- `JET.test_package(LineagesIO; target_defined_modules = true)` — static type
  inference
- All functional tests

### Required verification artifacts by component

| Component | Required artifact |
|---|---|
| `add_child` dispatch | Unit tests for both levels; builder validation gate for compatible and incompatible builders |
| Protocol determination | Unit test: format declaration → tier; unit test: per-call dispatch is not used |
| Discovery pass | Tests: schema inference; `Union{T,Nothing}` promotion; schema stability |
| Newick parser | Parse tests: simple trees; edge lengths; internal labels; multi-tree files |
| LineageNetwork parser | Parse tests: networks with hybrid nodes; gamma in `edgedata[i].gamma` at call site |
| LineageGraphML parser | Parse tests: basic round-trip; attribute promotion |
| `LineageGraphStore` / `LineageGraphAsset` | Type stability tests; Tables.jl compliance; multi-source indexing |
| FileIO adapter | Detection tests; override tests; stream I/O tests |
| `finalize_graph!` | No-op default test; called-at-right-time integration test |
| `PhyloNetworksExt` | Round-trip: file → `HybridNetwork`; hybrid node structure; gamma values on edges |
| `PhyloExt` | Round-trip: file → `RootedTree`; labels; branch lengths; node data dict |
| `loadone` / `loadfirst` | Error on wrong count (`loadone`); no error on multiple (`loadfirst`) |
| Multi-source `load` | `source_idx` correctly distinguishes origins |

### What is not sufficient on its own

- "Tests pass" is not sufficient if the test only checks that a function returns
  something, not that it returns the correct value.
- Type-stable compilation alone is not sufficient; behavioral correctness tests
  must accompany it.
- Geometry-only checks (node count, edge count) are not sufficient for integration
  tests; field-level values (labels, edge lengths, gamma) must be verified.

---

## Out of scope (phase 1)

- `format"Nexus"` — deferred to phase 2
- `format"TskitTrees"` — deferred to phase 2
- NEXUS support for `PhyloNetworksExt` and `PhyloExt` — deferred to phase 2
- `TreeSet` support for Phylo multi-tree NEXUS files — deferred to phase 2
- FileIO registry registration — out of scope; package must be designed to
  support it
- Concrete domain types inside LineagesIO — responsibility of `LineageGraphs.jl`
- `save` implementation beyond stubs — deferred
- Compliance suite and conversion matrix — deferred to phase 2
- Additional focal package extensions beyond PhyloNetworks.jl and Phylo.jl —
  deferred

---

## Open questions

None. All design decisions are made and documented in the companion design
documents. If an implementer encounters an apparent ambiguity, they must escalate
rather than resolve it unilaterally.

---

## Further notes

### Companion design documents

This PRD formalizes:

- `design/brief.md` (v2.0, 2026-04-25) — primary design authority
- `design/brief--community-support-objectives.md` (v1.0, 2026-04-25) — extension
  architecture authority; concrete `add_child` stubs for `PhyloNetworksExt` and
  `PhyloExt`

Both documents must be read alongside this PRD. In the event of apparent
conflict, escalate to the project owner.

### Project structure conventions

Per `STYLE-julia.md`:

- Format parsers are submodules, included via `include` from the main module file.
- Extension modules live in `ext/`.
- Tests live in `test/` with their own `Project.toml` using a `[sources]` section
  to reference the main package path.
- Ideal source file size is 400–600 LOC (excluding comments); large files should
  be split.

### Julia version and compatibility

Current `Project.toml` specifies Julia ≥ 1.10.10. Package extensions require
Julia ≥ 1.9; this constraint is satisfied.

### Dependency policy

Per `STYLE-julia.md` and `CONTRIBUTING.md`: new dependencies require explicit
project owner approval. Use `Pkg.add` to add dependencies; do not edit
`Project.toml` directly unless there is no alternative (e.g., adding `[weakdeps]`
and `[extensions]` sections, in which case bring to project owner's attention
before proceeding).

Phase 1 expected hard dependencies:
- `FileIO` — core I/O framework
- `Tables` — lightweight table interface

Phase 1 expected weak dependencies (for extensions):
- `PhyloNetworks` — weak dependency for `PhyloNetworksExt`
- `Phylo` — weak dependency for `PhyloExt`
