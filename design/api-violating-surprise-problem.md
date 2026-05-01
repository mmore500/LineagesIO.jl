# API Surprise Problem: `asset.materialized` and the `LineageGraphAsset` access pattern

## Purpose

This document provides full context for a design discussion about a known ergonomics
problem in the LineagesIO.jl public API. It is written to be self-contained: a fresh
agent with no prior conversation history should be able to read this document, understand
the problem precisely, understand the constraints, and reason about solutions.

---

## 1. Package overview

LineagesIO.jl is a Julia package for loading phylogenetic data (Newick format, `.trees`
files, etc.) into a structured in-memory representation. Its distinguishing design
commitment is that every load operation produces **authoritative package-owned tables**
(node and edge data in Tables.jl-compatible form) regardless of whether the user also
requests a graph object from a consumer package such as `PhyloNetworks.jl` or
`MetaGraphsNext.jl`. The tables are not a side effect — they are the primary parsed
representation.

---

## 2. The data model

### 2.1 Type hierarchy

A `load(src, ...)` call always returns a `LineageGraphStore`, which carries three levels
of data:

```
LineageGraphStore                    ← file-level result
    .source_table     :: SourceTable           ← one row per source file
    .collection_table :: CollectionTable       ← one row per tree-collection block
    .graph_table      :: GraphTable            ← one row per graph in the file
    .graphs           :: GraphAssetIterator    ← lazy iterator over per-graph assets
        └── LineageGraphAsset                  ← one per graph
                .index              :: Int
                .source_idx         :: Int
                .collection_idx     :: Int
                .collection_graph_idx :: Int
                .collection_label   :: Union{Nothing,String}
                .graph_label        :: Union{Nothing,String}
                .node_table         :: NodeTable   ← authoritative node data
                .edge_table         :: EdgeTable   ← authoritative edge data
                .materialized       :: MaterializedT
                .source_path        :: Union{Nothing,String}
```

`MaterializedT` is the type parameter that flows from the load surface through the store
to the asset. See §2.2 for what it is in each case.

All table types (`SourceTable`, `CollectionTable`, `GraphTable`, `NodeTable`,
`EdgeTable`) are concrete, package-owned structs implementing the full `Tables.jl`
column-access interface. They are not wrappers over user-supplied containers.

### 2.2 What `materialized` actually holds

The field `asset.materialized` is typed `MaterializedT`. Its value depends entirely on
which load surface was used:

| Load surface | Example | `MaterializedT` | `asset.materialized` |
|---|---|---|---|
| Tables-only | `load(src)` | `Nothing` | `nothing` |
| Type-directed (native protocol) | `load(src, MyNode)` | `MyNode` | the root node of the tree |
| Supplied-instance (native protocol) | `load(src, my_root)` | `typeof(my_root)` | the same root node |
| Builder callback | `load(src; builder = fn)` | return type of `fn` | the root node returned by `fn` |
| PhyloNetworks extension | `load(src, HybridNetwork)` | `HybridNetwork` | a fully finalized `HybridNetwork` container |
| MetaGraphsNext extension | `load(src, MetaGraph(...))` | `MetaGraph{...}` | a fully built `MetaGraph` container |

**Important distinction:** for native-protocol loads, the "materialized" value is the
**root node** of the tree (the user's custom type); the whole tree is accessible through
it because the root holds its children. For extension loads (PhyloNetworks,
MetaGraphsNext), the "materialized" value is the **entire graph container** — not a
node.

### 2.3 The tables-only path

When `load(src)` is called without a construction target, the store is returned with
`MaterializedT = Nothing` and `asset.materialized === nothing`. The authoritative tables
are fully populated and accessible in both cases. This is the tables-only path, and it
is a first-class supported use case, not a fallback.

---

## 3. Load surfaces

```julia
# Tables-only — no graph construction
store = load(src)
asset = first(store.graphs)
asset.materialized === nothing  # true

# Type-directed — native protocol
store = load(src, MyNode)
asset = first(store.graphs)
root = asset.materialized  # root node of type MyNode

# PhyloNetworks extension
store = load(src, HybridNetwork)
asset = first(store.graphs)
net = asset.materialized  # a HybridNetwork

# MetaGraphsNext extension
store = load(src, MetaGraph(SimpleDiGraph(), Symbol, Nothing, Nothing))
asset = first(store.graphs)
graph = asset.materialized  # a MetaGraph

# Supplied-instance (native or extension)
store = load(src, my_existing_instance)
asset = first(store.graphs)
asset.materialized === my_existing_instance  # true for extension paths
```

---

## 4. The problem: principle of surprise

### 4.1 Navigation depth

To obtain the primary value from a typed load, a user must write:

```julia
store = load(example_path, HybridNetwork)
asset = first(store.graphs)
net = asset.materialized
```

Three operations after `load`. The user supplied `HybridNetwork` at call time; the
return type carries `MaterializedT = HybridNetwork` all the way through. Yet recovering
the `HybridNetwork` requires knowing the name of an opaque field on an intermediate
wrapper object.

A user encountering this API for the first time would not guess `.materialized`. There
is no ergonomic or naming cue to indicate that the field exists or what it is. The type
system has the answer; the API makes the user dig for it.

(The `first(store.graphs)` step is not the problem: it is idiomatic and expected for
iterating over a multi-graph result. The problem is specifically `.materialized`.)

### 4.2 Field name semantics

`materialized` is a **past participle** used as a stand-in for a noun. It names the
**process that produced the thing**, not **what the thing is**. This is unusual for
struct field names, which conventionally name content:

```julia
asset.graph          # "the graph"  — names content
asset.result         # "the result" — names content
asset.materialized   # "the thing that was materialized" — names process
```

A reader inspecting a `LineageGraphAsset` definition for the first time sees:

```julia
node_table    :: NodeTableT      # clear: the node data table
edge_table    :: EdgeTableT      # clear: the edge data table
materialized  :: MaterializedT   # opaque: what is this?
```

The type parameter `MaterializedT` at least carries the target type at the type level,
but the field name adds no semantic content.

### 4.3 `MaterializedT` means different things per load surface

For native-protocol loads, `asset.materialized` is the **root node** of the constructed
tree. The entire tree is accessible through it. For extension loads, `asset.materialized`
is the **entire graph container** (a `MetaGraph` or a `HybridNetwork`). The field name
gives no indication of this distinction.

### 4.4 The `basenode` accessor

There is a public function `basenode(asset)` defined in `src/views.jl`. Its intended
purpose is to return the root node (basenode) of the graph from a construction load.

**Historical bug (recently fixed):** the function was implemented as a thin wrapper over
`asset.materialized` for all load paths. For native-protocol loads this was accidentally
correct (the materialized value IS the root node). For extension loads it was wrong: it
returned the entire graph container, not the root node. The docstring described the wrong
behavior ("Return the materialized graph result").

**Current state (after fixes applied in this session):**

| Load surface | `basenode(asset)` now returns |
|---|---|
| Native protocol | `asset.materialized` — the user's root node object ✓ |
| PhyloNetworks | `net.node[net.root]` — the root `PhyloNetworks.Node` ✓ |
| MetaGraphsNext | `Symbol(1)` = `:1` — the vertex label of the basenode ✓ |
| Tables-only | throws `ArgumentError` ✓ |

The docstring has been updated to reflect this. Extension-specific methods are defined
in `ext/PhyloNetworksIO.jl` and `ext/MetaGraphsNextIO.jl`. The base method in
`src/views.jl` handles the native-protocol and tables-only cases.

---

## 5. Constraints (non-negotiable)

1. **Tables are a first-class promise.** Every load operation must provide access to
   authoritative `node_table` and `edge_table` data on each `LineageGraphAsset`, and
   `source_table`, `collection_table`, `graph_table` on the store. These must not be
   hidden, removed, or made secondary. Users who only want tables (tables-only path)
   must have a clean way to use the package.

2. **Not all users want tables.** A user who calls `load(src, HybridNetwork)` typically
   wants the `HybridNetwork` and may not care about the tables. The API must serve this
   case ergonomically without requiring the tables-wanting user to give anything up.

3. **The multi-graph case must be handled.** A single source file may contain many
   graphs (e.g., a `.trees` posterior sample file). The `store.graphs` iterator is the
   correct abstraction for this. This is not in question.

4. **Extension-backed and native-protocol load surfaces must coexist.** The design must
   work for `HybridNetwork`, `MetaGraph`, and user-defined native-protocol node types.

---

## 6. The open design question

The core question is: **what should `asset.materialized` be renamed to, and/or should
the access pattern change?**

This question has not been resolved. The discussion so far established the problem
(§4 above) and the constraints (§5 above) but reached no conclusion on the solution.

### 6.1 Sub-question: rename the field

If the field is renamed, the name should describe **what the thing is**, not how it was
created. Candidates discussed or implied:

- `graph` — clear in context, but semantically wrong for native-protocol loads where the
  value is a root node, not a graph container; also potentially confusing when
  `MaterializedT = Nothing`
- `result` — generic but honest; does not lie about what it is
- `value` — very generic; does not convey domain meaning
- `target` — names the intended recipient, not the result; could be confused with the
  load surface
- Keep `materialized` — accept the process-naming convention given the strong prior art
  (see §7)

### 6.2 Sub-question: change the access pattern

Even with a better field name, the user must still write three steps to get the primary
value. Possible approaches:

- **Named accessor function** — the existing `basenode(asset)` is one such accessor, but
  its name is only apt for native-protocol loads where the result is a root node. A more
  general accessor with a different name would serve extension paths better.
- **Convenience on the store** — `store.graphs` currently yields `LineageGraphAsset`
  values. An alternative accessor (e.g., `graphs(store)` or `objects(store)`) could
  yield `MaterializedT` values directly when `MaterializedT != Nothing`, bypassing the
  asset wrapper. The asset wrapper would still be accessible via the existing
  `store.graphs` for users who need tables.
- **Both** — rename the field AND add a convenience accessor.

### 6.3 The `materialized` field on `LineageGraphStore`

`LineageGraphStore` has no field named `materialized`; the name only appears on
`LineageGraphAsset`. The type parameter `MaterializedT` flows through both structs.
Any rename must be consistent at both the field level and the type-parameter level
(though type parameter names are less user-visible).

---

## 7. Terminology context: "materialize"

This section records the terminology analysis that preceded the design discussion, for
completeness.

### 7.1 Prior art

The word "materialize" in this codebase was borrowed from two well-established
traditions:

- **Database materialized views** (SQL, highly formal): a materialized view is a
  query whose result is pre-computed and stored, as opposed to a virtual view computed
  on demand. The core idea: something abstract or deferred becomes concrete and stored.
- **Lazy evaluation / streaming** (FP, Julia, Spark, Arrow): "materializing" a lazy
  sequence forces evaluation into a concrete in-memory structure. `collect()` in Julia
  is the canonical materialization operation.
- **`Tables.jl` in the Julia ecosystem**: `Tables.materializer(T)` is a sink-side
  dispatch hook that returns the function to convert any Tables.jl-compatible source
  into a concrete `T`. LineagesIO implements this for its own table types. This is
  adjacent but does not directly name the graph-construction concept.

### 7.2 The honest tension

In ORM and database contexts, "materialize" specifically implies loading from persistent
storage into memory. In lazy-evaluation contexts it means forcing deferred computation.
In this codebase it means **constructing a consumer-type graph object from parsed
in-memory tables**. This is a related but distinct sense. `Tables.materializer` is the
closest prior art in the same ecosystem, but it names the *converter function*, not the
*result*.

The word is defensible and has strong prior art, but it names the process (the thing was
materialized) rather than the product (the thing itself).

---

## 8. Files most relevant to the design question

| File | Relevance |
|---|---|
| `src/views.jl` | Defines `LineageGraphAsset`, `LineageGraphStore`, `basenode()` |
| `src/construction.jl` | Defines `materialize_graph`, `materialize_graphs`, `materialize_graph_basenode` |
| `src/newick_format.jl` | Calls `materialize_graphs`; entry point for Newick parsing |
| `src/fileio_integration.jl` | Defines `load` surfaces and `build_load_request` |
| `ext/PhyloNetworksIO.jl` | Extension `basenode` override; `finalize_graph!` returns `HybridNetwork` |
| `ext/MetaGraphsNextIO.jl` | Extension `basenode` override; `finalize_graph!` returns `MetaGraph` |
| `examples/src/phylonetworks_mwe01.jl` | Canonical user-facing usage example |
| `examples/src/phylonetworks_mwe02.jl` | Canonical user-facing usage example |
| `docs/src/index.md` | Public-facing documentation; uses `asset.materialized` |
| `README.md` | Public-facing; uses `asset.materialized` |

---

## 9. What has already been decided and applied in this session

The following changes have been made to the repository. They are not in question.

1. **Renamed `builder_root` → `builder_basenode`** in
   `test/core/network_newick_format.jl:133-134`. (Incomplete rename from prior revocab
   run.)

2. **`materialized_root` → `materialized_basenode`** in
   `test/core/network_target_validation.jl:221-222`. (Same revocab run.)

3. **`basenode(asset)` fixed for PhyloNetworks** (`ext/PhyloNetworksIO.jl`): now
   returns `net.node[net.root]` — the root `PhyloNetworks.Node`.

4. **`basenode(asset)` implemented for MetaGraphsNext** (`ext/MetaGraphsNextIO.jl`):
   returns `Symbol(StructureKeyType(1))` = `:1`, the vertex label of the basenode.

5. **Docstring for `basenode` rewritten** (`src/views.jl:182-199`): now correctly
   describes the per-load-surface return type and the tables-only `ArgumentError`.

---

## 10. What is NOT yet decided

- Whether to rename `asset.materialized` (and to what).
- Whether to change the access pattern (add a convenience accessor, change iterator
  semantics, or both).
- Whether `basenode(asset)` should be expanded into the primary user-facing accessor
  for extension paths (its name is apt for native protocol but not for MetaGraph or
  HybridNetwork returns).
- Whether tests for the new extension `basenode` methods should be added (they should,
  but this was deferred pending the naming discussion).
