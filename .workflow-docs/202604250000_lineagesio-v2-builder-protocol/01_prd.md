---
date-created: 2026-04-25T00:00:00
status: approved
supersedes: .workflow-docs/logs/log.20260424--superceded-brief.md
design-authority:
  - design/brief.md
  - design/brief--community-support-objectives.md
---

# PRD: LineagesIO.jl v2.0 — Builder Protocol and Graph-General I/O Layer

## User statement

> "This Julia package provides FileIO-compatible loading and saving of
> phylogenetic graph (tree or network) data together with package-native lazy
> readers, behaving as a proper FileIO backend for a range of phylogenetic graph
> data formats."
>
> The builder protocol (the `add_child` generic and its dispatch conventions)
> is the primary design surface. It must support multi-parent directed/undirected
> networks as the general baseline, with single-parent restricted cases derived
> from the same mechanism. The package must return fully parameterized collection
> results, expose Tables.jl-compliant node and edge tables at all four metadata
> levels, support lazy iteration over multi-graph sources, and provide first-class
> package-extension integration for PhyloNetworks.jl and Phylo.jl.
>
> The `design-authority` documents are considered GOVERNING documents and provide key concepts, abstractions, constraints, conditions, and strategies. 
> These should be read line-by-line before proceeding any further, and downstream documents
> should also include and transmit this mandate.

---

## Problem statement

### User-facing problem

Julia has no single package that:

1. Reads phylogenetic network files (not just trees) via a FileIO-compatible API.
2. Returns structured, Tables.jl-compatible metadata alongside the graph object —
   enabling immediate joins without custom extraction code.
3. Supports arbitrary user-defined node types (not just the types each parser
   package happens to produce), using idiomatic Julia generics.
4. Handles multi-graph sources (NEXUS tree blocks, multi-Newick files, tskit
   `TreeSequence`) as a first-class collection, not as a surprise edge case.

---

## Target outcome

When this work is complete:

- `load("file.nwk", MyNode)` returns `GraphStore{MyNode}` — a collection,
  always, not a single graph — containing lazy graph iterators and Tables.jl
  tables for node, edge, graph, collection, and source metadata.
- The builder protocol dispatches through `LineagesIO.add_child`, which users
  extend for their concrete type. Protocol tier (general/network vs
  single-parent) is determined once before parsing begins, not per call.
- All annotation keys present in a source file are promoted to typed columns by
  a discovery pass — no overflow dicts, no format-specific bespoke data types.
- The same result is immediately consumable by PhyloNetworks.jl, Phylo.jl, and
  LineagesMakie.jl via package extensions and the accessor protocol, with no
  further transformation required.

---

## User stories

1. A researcher loads a single Newick file into their custom `MyNode` type with
   `loadone("tree.nwk", MyNode)` and receives a `GraphAsset{MyNode}`
   containing the root handle, a node table with bootstrap and edgelength
   columns, and an edge table.

2. A researcher loads a NEXUS file containing 1,000 MCMC samples and iterates
   lazily over the samples: `for g in load("samples.nex", MyNode).graphs`. The
   TRANSLATE table is visible in `result.collection_table`; each sample is a
   `GraphAsset` with index coordinates.

3. A researcher who does not define any builder calls `load("tree.nwk")` and
   receives a `GraphStore` containing fully populated node and edge tables; they
   can pass these directly to DataFrames, Plots, or CSV without writing any
   `add_child` method.

4. A researcher using PhyloNetworks calls
   `loadone("net.nwk", PhyloNetworksNodeHandle)` and receives a
   `GraphAsset{PhyloNetworksNodeHandle}`; they unwrap via
   `result.graph_rootnode.net` to get a fully finalized `HybridNetwork` (all
   post-build cleanup applied automatically via the finalization hook).

5. A researcher using Phylo.jl calls `load("samples.nex", PhyloNodeRef)` and
   iterates over graphs; each `g.graph_rootnode.tree` is a ready-to-use
   `RootedTree` with all NHX/metacomment keys in node data dictionaries.

6. A researcher extends `LineagesIO.add_child` for their custom graph type and
   immediately sees the correct method dispatched by passing their type as a
   positional argument to `load` — no `node_type` keyword argument, no
   registration step.

7. A researcher passes
   `builder = (parent, node_idx, label, edgelength, edgedata, nodedata) -> ...`
   to `load` and is not required to define any method extension. The callback
   always takes precedence over any extended methods.

8. A researcher with a file from an unknown program forces the format explicitly:
   `load(File{format"Newick"}("file.txt"), MyNode)`.

9. A researcher loads multiple source files at once:
   `load(["file1.nwk", "file2.nwk"], MyNode)`. The result is a single
   `GraphStore`; `source_idx` on each `GraphAsset` identifies the origin.

10. A researcher calls `loadone("file.nwk", MyNode)` and receives an error
    (with a clear message) if the file contains more than one graph; they call
    `loadfirst` instead if they want silently take the first.

11. A researcher extends their builder using the general (network) protocol. If
    their file is single-parent-only but they have defined only the
    `AbstractVector{NodeT}` overload, the library dispatches correctly.

12. A researcher whose builder only defines the single-parent overload loads a
    file that contains a hybrid node. The library raises an informative error at
    load time (not mid-parse) because the format declared general protocol but
    the builder does not provide the required overload.

13. A researcher's custom `MyNode` stores `node_idx`. They join the graph
    structure to `result.node_table` using `node_idx` as the primary key,
    extracting bootstrap values without traversing the tree.

14. A researcher loads a tskit `.trees` file and finds the individual, site,
    population, and migration tables from the `TreeSequence` model in
    `result.source_table`.

15. A researcher loads an extended Newick file with hybrid edges. The
    `GraphAsset.edge_table` has a `gamma` column; the gamma values are
    correct for each individual hybrid edge (one row per directed edge).

16. A researcher calls `save("out.nwk", graph, MyNode)` (Phase 2) and receives
    a Newick file from their `MyNode` structure.

17. A LineagesMakie developer accesses `g.graph_rootnode` as the `rootnode`
    argument to `lineageplot!` and calls the `children`, `edgelength`,
    `branchingtime`, and `coalescenceage` accessors on it directly — no
    adapters needed if the user's `MyNode` type implements these accessors.

---

## Authorized disruption boundary

- **Internal redesign allowed:** Complete redesign of the builder protocol
  (add_child signature, dispatch levels, protocol determination), the return
  type hierarchy (GraphStore, GraphAsset), and the metadata model (four
  levels, discovery pass, edge table). All internal parsing machinery is
  replaceable.
- **Internal redesign forbidden:** Governance document compliance obligations
  (STYLE-*.md, STYLE-vocabulary.md), FileIO backend contract semantics,
  Tables.jl interface contracts.
- **External breaking changes:** Not applicable — this is a v2 redesign of a
  package not yet in public use.
- **Non-negotiable protections:** The package must remain a valid FileIO
  backend. It must not define any concrete domain graph type. It must not
  claim ownership of generic GraphML. It must be type-stable throughout.

---

## Target architecture

### Major modules and responsibilities

| Module | Responsibility |
|---|---|
| `LineagesIO` (core) | Exports `add_child` generic function; exports `load`, `loadfirst`, `loadone`; defines `GraphStore`, `GraphAsset`; orchestrates format detection and builder dispatch |
| `LineagesIO.Newick` | Newick tokenizer, recursive-descent parser, discovery pass, `add_child` emission |
| `LineagesIO.LineageGraphML` | GraphML-with-phylogeny-profile parser, discovery pass, `add_child` emission |
| `LineagesIO.Nexus` (Phase 2) | NEXUS TAXA + TREES + TRANSLATE block parser |
| `LineagesIO.LineageNetwork` (Phase 2) | Extended Newick hybrid-node notation |
| `LineagesIO.TskitTrees` (Phase 2) | HDF5 tskit binary `TreeSequence` reader |
| `ext/PhyloNetworksExt` | Weak extension: `PhyloNetworksNodeHandle`, `add_child` methods, `finalize_graph!` hook |
| `ext/PhyloExt` | Weak extension: `PhyloNodeRef`, `add_child` methods |

### Ownership boundaries

- **Format parsers own**: tokenization, grammar, raw field extraction, protocol
  declaration, calling `add_child` in correct pre-order, assembling node/edge
  table rows.
- **Builder protocol layer owns**: `add_child` generic definition, protocol
  determination, builder validation gate, `node_idx` assignment, discovery pass
  coordination.
- **GraphStore / GraphAsset own**: index coordinate tracking, table
  materialization, lazy iteration surface.
- **Extensions own**: target-package wrapper types, `add_child` methods for
  those types, finalization hooks.
- **FileIO adapter owns**: format detection, `File{format"..."}` dispatch,
  `Stream{fmt}` support, registration readiness.

### Shared contracts and invariants

- `add_child` is always called in pre-order (top-down). Every ancestor handle is
  in scope when a node's `add_child` call is made.
- `node_idx` is 1-based, sequential across all nodes in a single graph, and is
  the primary key of `node_table` and the foreign key in `edge_table`.
- `load` always returns `GraphStore`. No calling convention may return a bare
  `NodeT` or bare `GraphAsset` from `load`.
- The row type `R` of `nodedata :: R` and the row type `RE` of `edgedata :: RE`
  are both fixed for the entire parse of a source. Both are determined after the
  discovery pass and before the first `add_child` call.
- Node labels are disambiguated at parse time: empty or colliding labels are
  replaced with `"node_$node_idx"` before any `add_child` call.
- Protocol tier is declared by the format parser and validated once before
  parsing begins. It never changes mid-parse.

---

## Implementation decisions

1. **Positional node-type argument** (`load("file.nwk", MyNode)`) follows the
   CSV.jl / Tables.jl sink-type pattern. This eliminates need for a `node_type`
   keyword argument and allows the compiler to specialize the entire parse on
   `NodeT` without runtime lookup.

2. **Discovery pass over full source** before any `add_child` calls. All
   annotation keys promoted to typed columns. `Union{T, Nothing}` for keys
   absent on some nodes. No overflow dicts anywhere.

3. **`nodedata :: R` and `edgedata :: RE` are NamedTuple rows from the
   discovery pass**. Both `R` (node table row type) and `RE` (edge table row
   type) are fixed after the discovery pass, before the first `add_child` call.
   Field names come from the source file, not from format-specific type
   definitions.

4. **`edgedata` is part of all `add_child` signatures — the complex case is the
   baseline**. Network protocol: `edgedata :: AbstractVector{RE}` parallel to
   `parents`. Single-parent protocol: `edgedata :: RE` (non-entry-point) or
   `edgedata :: Nothing` (entry-point). There is no two-phase workaround; gamma
   and other per-edge values are available at `add_child` call time.

5. **Edge table always present**. For single-parent graphs it is a degenerate
   case (one row per non-entry-point node) but it is never absent or optional.

6. **Protocol determination**: format declares tier (A), builder validated before
   first call (B). Per-call `length(parents)` dispatch is rejected.

7. **`finalize_graph!` hook**: Called once per graph after the last `add_child`
   call. Extensions overload `LineagesIO.finalize_graph!` for their handle types.
   Default is a no-op. `PhyloNetworksExt` overloads it to call `storeHybrids!`,
   `checkNumHybEdges!`, `directedges!`.

8. **Node label disambiguation**: Empty or colliding node labels are replaced
   with `"node_$node_idx"` at parse time, before any `add_child` call. This
   guarantees uniqueness within a graph and a stable join key to the node table.
   `node_idx` is also stored in extension-managed node metadata (e.g. Phylo node
   data dict) for round-trip disambiguation.

9. **Tables.jl dependency only**: LineagesIO takes Tables.jl as a lightweight
   pure-interface dependency. No DataFrames.jl dependency. Users convert with
   `DataFrame(result.node_table)`.

---

## Module design

### `LineagesIO` core

**Responsibility:** Public API surface: `add_child` generic, `load`, `loadfirst`,
`loadone`, `GraphStore`, `GraphAsset`, `finalize_graph!`. Format detection
and builder dispatch orchestration.

**Interface (public):**

```julia
# Generic function — users extend this
function add_child end
function finalize_graph! end   # default no-op; extensions overload

# Load entry points
load(src, NodeT; kwargs...)         :: GraphStore{NodeT}
load(src; builder, kwargs...)       :: GraphStore{NodeT}
load(src; kwargs...)                :: GraphStore
loadfirst(src, ...; kwargs...)      :: GraphAsset
loadone(src, ...; kwargs...)        :: GraphAsset
load(srcs::AbstractVector, ...; kwargs...)  :: GraphStore   # multi-source

# Return types
struct GraphAsset{NodeT}
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

struct GraphStore{NodeT}
    source_table     :: <Tables.jl compliant>
    collection_table :: <Tables.jl compliant>
    graph_table      :: <Tables.jl compliant>
    graphs           :: <lazy iterator of GraphAsset{NodeT}>
end
```

**Builder protocol dispatch levels:**

```julia
# General case (baseline) — required for network/reticulate graphs
# R = node_table row type; RE = edge_table row type (both from discovery pass)
add_child(
    parents     :: AbstractVector{NodeT},
    node_idx    :: Int,
    label       :: AbstractString,
    edgelengths :: AbstractVector{Union{EdgeLenT, Nothing}},
    edgedata    :: AbstractVector{RE},   # one row per parent edge, parallel to parents
    nodedata    :: R,
) :: NodeT where {R, RE}

# Single-parent restricted case — entry-point (no parent edge)
add_child(parent::Nothing, node_idx::Int, label,
          edgelength, edgedata::Nothing, nodedata::R) :: NodeT where {R}
# Single-parent restricted case — subsequent nodes
add_child(parent::NodeT,   node_idx::Int, label,
          edgelength, edgedata::RE, nodedata::R) :: NodeT where {R, RE}
```

**Tested:** Yes — integration tests against Newick and LineageGraphML. Unit
tests for protocol determination gate, builder validation, discovery pass,
`node_idx` primary-key correctness.

---

### `LineagesIO.Newick`

**Responsibility:** Tokenize and parse Newick format (including NHX metacomments
`[&key=value]`). Perform discovery pass. Emit `add_child` calls in pre-order.
Build node table and edge table rows.

**Interface (internal):** Called by FileIO adapter layer. Declares
`SINGLE_PARENT` protocol. Returns iterator of `GraphAsset` values.

**Tested:** Yes — roundtrip tests, edge-length precision, bootstrap parsing,
NHX key extraction, empty label handling, multi-Newick files.

---

### `LineagesIO.LineageGraphML`

**Responsibility:** Parse GraphML with the LineageGraphML phylogeny-specific
attribute profile. Discovery pass over all `<data>` elements. Emit `add_child`
calls. Build node/edge tables.

**Interface (internal):** Declares `SINGLE_PARENT` protocol (Phase 1). Returns
iterator of `GraphAsset` values.

**Tested:** Yes — roundtrip tests, data element extraction, multi-graph
GraphML files.

---

### FileIO adapter layer

**Responsibility:** `__init__` format registration, format detection via
extensions and magic bytes, `load`/`save` dispatch to format submodules,
`File{format"..."}` and `Stream{fmt}` support.

**Interface:** Private FileIO backend methods. Not user-facing directly.

**Tested:** Yes — format auto-detection, explicit override, stream-based load.

---

### `ext/PhyloNetworksExt`

**Responsibility:** Define `PhyloNetworksNodeHandle`, implement
`LineagesIO.add_child` methods for it (general/network protocol), implement
`LineagesIO.finalize_graph!` to call `storeHybrids!`, `checkNumHybEdges!`,
`directedges!`.

**Interface (public):**

```julia
struct PhyloNetworksNodeHandle
    net  :: PhyloNetworks.HybridNetwork
    node :: PhyloNetworks.Node
end
get_hybridnetwork(g::GraphAsset) :: HybridNetwork
```

**Tested:** Yes — roundtrip Newick → `HybridNetwork` for single-parent and
hybrid-node cases; per-edge gamma values verified from `edgedata` at call time.

---

### `ext/PhyloExt`

**Responsibility:** Define `PhyloNodeRef`, implement `LineagesIO.add_child`
methods for it (single-parent protocol), map `nodedata` fields to Phylo node
data dict, store `node_idx` in Phylo node data for round-trip disambiguation.
Name-collision strategy: `"node_$node_idx"` for empty/non-unique labels.

**Interface (public):**

```julia
struct PhyloNodeRef
    tree     :: Phylo.RootedTree
    nodename :: String
end
get_rootedtree(g::GraphAsset) :: RootedTree
```

**Tested:** Yes — roundtrip Newick → `RootedTree`, NHX metacomment
round-trip, NEXUS TRANSLATE table, `node_idx` join verification.

---

## Governance and controlled vocabulary

### Governance documents — mandatory line-by-line reading

All agents, contributors, and tranches must read these documents line by line
before any design, implementation, review, or test work:

| Document | Location | Notes |
|---|---|---|
| Controlled vocabulary | `STYLE-vocabulary.md` | Authoritative term definitions; proscribed terms must not appear in any identifier |
| Julia style | `STYLE-julia.md` | Naming, docstrings, dispatch conventions, type stability |
| Architecture style | `STYLE-architecture.md` | Ownership boundaries, module design, interface discipline |
| Documentation style | `STYLE-docs.md` | Docstring format, prose conventions |
| Git style | `STYLE-git.md` | Commit message format, branch naming |
| Verification style | `STYLE-verification.md` | What counts as a verified tranche |
| Upstream contracts | `STYLE-upstream-contracts.md` | How to handle FileIO and third-party contracts |
| Workflow docs style | `STYLE-workflow-docs.md` | How to structure tranche and task documents |
| Writing style | `STYLE-writing.md` | Prose standards for all project documents |

### Vocabulary decisions for this PRD

The following controlled-vocabulary decisions are in effect. All downstream
tranches and tasks must preserve and enforce them.

| Canonical term | Proscribed alternatives | Notes |
|---|---|---|
| `add_child` | `add_node`, `build_node`, `create_child` | The one exported generic function |
| `graph_rootnode` | `root`, `graph`, `rootvertex` | Entry-point handle in `GraphAsset` |
| `GraphStore` | any bare-node or bare-graph return type | `load` always returns a collection |
| `GraphAsset` | `Graph`, `TreeResult` | Single-graph result struct |
| `node_idx` | `nodeid`, `nodeindex`, `node_id` | Library-assigned 1-based join key |
| `nodedata` | `data`, `metadata`, `node_data` | The `nodedata :: R` argument to `add_child` |
| `edgelengths` | `branch_lengths`, `weights`, `lengths` | Parallel vector in network protocol |
| `edgedata` | `edge_metadata`, `edge_data`, `edgeMeta` | Per-edge row(s) passed to `add_child`; `:: AbstractVector{RE}` (network), `:: RE` / `:: Nothing` (single-parent) |
| `finalize_graph!` | `postprocess!`, `cleanup!` | Post-build hook |
| `GraphStore.graphs` | `trees`, `results`, `items` | Lazy iterator field |
| general (network) protocol | "multi-parent protocol", "network mode" | The baseline dispatch level |
| single-parent protocol | "tree protocol", "restricted mode" | The restricted case |
| discovery pass | "pre-scan", "schema inference" | Full-source scan before `add_child` |
| `src_node_idx` / `dst_node_idx` | `from`, `to`, `parent_idx`, `child_idx` | Edge table columns; follows `src`/`dst` convention |

**Proscribed framing:** Any design, documentation, or code that defaults to
trees and back-designs for networks is explicitly rejected. The general case
(multi-parent, directed, undirected, hybrid/reticulate nodes, multi-collection,
multi-source) is the design baseline. Trees are a restricted special case.

---

## Primary upstream references

All agents and implementers must read these upstream primary sources from the
local checkouts at
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`
before implementing work that depends on them.

| Package / framework | What to read | Why |
|---|---|---|
| **FileIO.jl** | `implementing.md`, `registering.md`, `reference.md`; `src/query.jl`, `src/loadsave.jl` | Defines the FileIO backend contract: private `load`/`save`, format registration, `File{fmt}`, `Stream{fmt}` dispatch |
| **Tables.jl** | `src/Tables.jl`, `src/interface.jl`, `src/fallbacks.jl` | Defines the Tables.jl interface that all node/edge tables must satisfy |
| **PhyloNetworks.jl** | `src/types.jl`, `src/readwrite.jl`, `src/parsenewick.jl`, `src/nexus.jl` | `HybridNetwork`, `Node`, `Edge` types; parse architecture; post-build cleanup sequence; gamma assignment |
| **Phylo.jl** | `src/parse.jl`, `src/newick.jl`, `src/nexus.jl`, `src/RecursiveTree.jl` | `RecursiveTree`, `RecursiveBranch`, `RecursiveNode`; `parsenewick`, `parsenexus`; metadata in `Dict{String,Any}` |
| **DendroPy** | `dendropy/dataio/newickreader.py`, `dendropy/dataio/nexusreader.py` | Reference for builder/callback Newick parsing architecture and tokenizer design |
| **NewickTree.jl** | `src/` | Stack-based Julia Newick parser reference |
| **tskit** | `python/tskit/tables.py`, format spec | `TreeSequence` tabular model; required for `format"TskitTrees"` Level 4 metadata design |
| **AbstractTrees.jl** | `src/AbstractTrees.jl` | Traversal traits and iteration interface |
| **LineagesMakie.jl** | accessor protocol (`children`, `edgelength`, `branchingtime`, `coalescenceage`, `nodevalue`, `nodecoordinates`, `nodepos`) | Loaded graphs must satisfy this protocol for direct visualization |

---

## Tranche gates

### Start-of-tranche requirements

- All applicable governance documents have been read line by line.
- All primary upstream sources relevant to the tranche have been read.
- The working state compiles and all existing tests pass.
- No outstanding broken invariants from a prior tranche.

### End-of-tranche requirements

- All new public functions have docstrings.
- All new public functions have test coverage in `test/`.
- `test/runtests.jl` passes with no failures or unexpected errors.
- `docs/` builds without errors or broken references.
- Example scripts in `examples/` (if present) run to completion.
- No regressions in existing tests.
- All changed identifiers conform to `STYLE-vocabulary.md`.
- Any new `STYLE-*.md` violations are resolved before close.

### Allowed internal disruption

A tranche may replace internal module implementations, redesign data structures,
and add new protocol functions without requiring user approval, provided:

1. The external FileIO contract remains intact.
2. The `add_child` public generic signature is not changed without explicit
   approval.
3. The `GraphStore` and `GraphAsset` field names are not changed without
   explicit approval.

---

## Testing and verification decisions

- **Must remain green throughout:** `test/runtests.jl` at every tranche boundary.
- **Format round-trip tests required:** For each format parser: file → `GraphStore`
  → node table values verified against known-good expected output.
- **Node index join test required:** `node_idx` in graph structure must match
  primary key of `node_table`; join must return correct metadata.
- **Protocol determination gate test:** Loading a network-format file with a
  single-parent-only builder must raise an informative error at load time.
- **Edge table correctness and `edgedata` pass-through:** For a hybrid-node
  file, `edge_table.gamma` values must match the source file's per-edge gamma
  annotations; the same values must be present in `edgedata[i].gamma` at the
  `add_child` call site (verified by extension integration tests).
- **Extension round-trip tests:** PhyloNetworksExt and PhyloExt must each have
  integration tests: file → extension type → verify target-package API works on
  result. PhyloNetworksExt must confirm `Edge.gamma` is set correctly from
  `edgedata` without a post-build lookup pass.
- **Multi-source test:** `load([f1, f2], NodeT)` must return correct
  `source_idx` values distinguishing the two origins.
- **Collection table test:** NEXUS file with TRANSLATE block must have the
  TRANSLATE mapping visible in `result.collection_table`.

---

## Out of scope

- Phylogenetic inference, reconciliation, comparative methods, plotting, and
  analysis algorithms.
- Solving every dialect or program-specific annotation convention in Phase 1.
- FileIO registry inclusion (engineering readiness is in scope; actual
  registration is not).
- Any concrete domain graph type in LineagesIO itself.
- Generic GraphML ownership (LineagesIO uses only the `LineageGraphML` profile).
- `save` implementation (Phase 2).
- NEXUS, LineageNetwork, and TskitTrees format parsers (Phase 2).
- Phylo `RecursiveBranch` per-edge metadata forwarding (no generic metadata
  field on `RecursiveBranch`; Phase 2 if Phylo adds support).

---

## Open questions

| # | Question | Owner | Suggested resolution |
|---|---|---|---|
| 1 | Should `finalize_graph!` be called by the lazy iterator (before yielding each `GraphAsset`) or by the format parser (after last `add_child` for a graph)? | Project owner | Recommend: lazy iterator, for streaming consistency. |
| 2 | `load(src)` with no builder — what is the concrete type of `graph_rootnode`? | Project owner | Recommend: `graph_rootnode :: Nothing`; `GraphStore{Nothing}`; field documented as only meaningful when a builder is provided. |
| 3 | Does `format"LineageNetwork"` use a separate parser submodule or augment `LineagesIO.Newick`? | Project owner | Recommend: separate submodule `LineagesIO.LineageNetwork` to keep single-parent Newick parser clean and testable independently. |

---

## Further notes

### Graph-first design mandate

This PRD is governed by an explicit graph-first design mandate. Every design
decision, identifier choice, section heading, and return type must be framed
from the most complex case (multi-parent directed/undirected networks, rooted
and unrooted, multi-source, multi-collection, multi-graph) down to the
restricted cases (single rooted tree). Defaulting to trees and back-designing
for networks is not acceptable at any stage of implementation.

Concretely:
- "Tree level" is proscribed — use "single-parent level (restricted case)".
- "Network level" is proscribed — use "general case (baseline)".
- The vector-parents overload of `add_child` is listed first in all documentation.
- `GraphStore` and `GraphAsset` field names use graph-general language.

### Community integration objectives

Community integration is a **core design requirement**, not a post-release addon.
The `add_child` protocol, `edgedata` signatures, `finalize_graph!` hook, and
`node_idx` join key are all shaped by the requirement that loading into
PhyloNetworks.jl and Phylo.jl types works in a single load call with no
post-processing.

The authoritative specification for this is
`design/brief--community-support-objectives.md`, which must be read alongside
`design/brief.md`. It documents:

- Parse stack and type structure of PhyloNetworks.jl and Phylo.jl (from
  line-by-line reading of upstream source)
- `PhyloNetworksNodeHandle` and `PhyloNodeRef` wrapper types and their
  `add_child` implementations
- `finalize_graph!` hook contract and the three PhyloNetworks cleanup functions
- Resolved design decisions: `edgedata` in all signatures (direct gamma
  assignment, no two-phase pass); `"node_$node_idx"` label disambiguation
- Phase 2 extension targets and the `[weakdeps]` / `[extensions]` wiring

Downstream tranche authors implementing `ext/PhyloNetworksExt` or `ext/PhyloExt`
must read `brief--community-support-objectives.md` before writing any code.

### Design document chain

This PRD synthesizes:

- `design/brief.md` — the complete v2.0 design brief, with builder protocol,
  metadata architecture, return types, and format support plan.
- `design/brief--community-support-objectives.md` — parse stack reference for
  PhyloNetworks.jl and Phylo.jl; extension architecture; resolved design
  decisions (edgedata, finalize_graph!, label disambiguation).
- `STYLE-vocabulary.md` — controlled terminology (ratified 2026-04-24).

All downstream tranche documents must cite `design/brief.md` and
`design/brief--community-support-objectives.md` as primary design references
and must re-state the governance document reading mandate from this PRD.

### Next step

Activate the `PRD → Tranches` phase to decompose this PRD into implementation
tranches. Recommended tranche ordering:

1. **Foundational tranche** — core module skeleton: `add_child` generic,
   `GraphStore`, `GraphAsset`, `finalize_graph!` no-op, `node_idx`
   assignment, protocol determination gate, builder validation. No format
   parsers yet; scaffold with stubs.

2. **Newick tranche** — `LineagesIO.Newick` parser: tokenizer, recursive
   descent, discovery pass, `add_child` emission, single-parent protocol. Full
   roundtrip tests.

3. **LineageGraphML tranche** — GraphML parser with LineageGraphML profile.

4. **PhyloNetworksExt tranche** — extension module, `PhyloNetworksNodeHandle`,
   `add_child` methods (network protocol), `finalize_graph!` hook.

5. **PhyloExt tranche** — extension module, `PhyloNodeRef`, `add_child` methods
   (single-parent protocol), node-data mapping.

6. **FileIO adapter tranche** — format detection, `File{fmt}` dispatch,
   `Stream{fmt}`, `__init__` registration wiring.
