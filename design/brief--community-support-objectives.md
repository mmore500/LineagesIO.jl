---
date-created: 2026-04-25T00:00:00
version: 1.0
---

# LineagesIO.jl — Community Support Objectives

## Purpose

This document defines LineagesIO.jl's community and ecosystem integration
objectives. It identifies focal packages for which LineagesIO will provide
first-class integrated support via Julia's package extension mechanism, documents
the parse stack and type structure of each target package (as determined by
line-by-line reading), and specifies the architecture and API for the extension
layer.

The table in §2 is the authoritative design reference for extension work and will
be expanded as additional packages are targeted.

---

## Focal packages (Phase 1)

| Package | Role | Integration priority |
|---|---|---|
| **PhyloNetworks.jl** | Phylogenetic networks; primary Julia package for reticulate evolution | Phase 1 |
| **Phylo.jl** | Parametric rooted/unrooted trees; Tables.jl and DataFrames.jl integration | Phase 1 |

---

## Parse stack reference table

One section per package. Each section answers: what files does it read, how does
it parse them, what concrete types does it produce, what metadata fields exist,
and what does the extension need to do.

---

### PhyloNetworks.jl

#### Supported formats

| Format | File extensions | Notes |
|---|---|---|
| Extended Newick | `.nwk`, `.tre`, `.newick` | Hybrid/reticulate notation `#H1`; gamma on 3rd colon field |
| NEXUS | `.nex`, `.nexus` | TREES block; TRANSLATE table; gamma in `[&gamma=x]` or `[&relSize=x]` comments |

#### Entry points

| Function | Signature | Returns |
|---|---|---|
| `readnewick` | `readnewick(input::AbstractString)` | `HybridNetwork` |
| `readnewick` | `readnewick(s::IO)` | `HybridNetwork` |
| `readmultinewick` | `readmultinewick(file::AbstractString, fast=true)` | `Vector{HybridNetwork}` |
| `readnexus_treeblock` | `readnexus_treeblock(file, treereader=readnewick; reticulate=true)` | `Vector{HybridNetwork}` |

#### Parse approach

Single-pass recursive descent, character-by-character (no formal tokenizer).
Builds `HybridNetwork` directly during traversal. Hybrid nodes are identified
by `#` prefix in node names; the parser deduplicates them (first occurrence
creates the node; second merges into it). Post-parse cleanup is mandatory:

| Step | Function | What it does |
|---|---|---|
| 1 | `storeHybrids!(net)` | Scans node array, populates `net.hybrid` |
| 2 | `checkNumHybEdges!(net)` | Validates each hybrid has ≥2 incoming hybrid edges |
| 3 | `directedges!(net)` | Sets `ischild1`, `containroot`, `net.isrooted = true` |

**NEXUS extras**: TRANSLATE table decoded post-parse (leaf names replaced from
numeric IDs). Gamma extracted from comment blocks **before** passing to
`readnewick`, then assigned via `readnexus_assigngammas!` after building.

#### Endpoint type: `HybridNetwork`

```julia
mutable struct HybridNetwork <: Network
    numtaxa   :: Int
    numnodes  :: Int
    numedges  :: Int
    node      :: Array{Node,1}       # all nodes (1-based index)
    edge      :: Array{Edge,1}       # all edges (1-based index)
    rooti     :: Int                 # index of root in node array
    names     :: Array{String,1}     # taxon + hybrid node names
    hybrid    :: Array{Node,1}       # pointers to hybrid nodes
    numhybrids:: Int
    leaf      :: Array{Node,1}       # pointers to leaf nodes
    isrooted  :: Bool
    # ... plus algorithm scratch fields (vec_int*, vec_bool, etc.)
end
```

#### Node type: `Node`

| Field | Type | Meaning | Missing sentinel |
|---|---|---|---|
| `number` | `Int` | unique identifier | negative during parse |
| `name` | `AbstractString` | taxon or hybrid name | `""` |
| `leaf` | `Bool` | is leaf/tip | — |
| `hybrid` | `Bool` | has ≥2 parent edges | — |
| `edge` | `Vector{Edge}` | incident edges | — |
| `booln1` | `Bool` | incident to any hybrid edge | — |

#### Edge type: `Edge`

| Field | Type | Meaning | Missing sentinel |
|---|---|---|---|
| `length` | `Float64` | branch length | `-1.0` |
| `y` | `Float64` | bootstrap / support value | `-1.0` |
| `z` | `Float64` | `1 - y` (SNaQ internal) | `-1.0` |
| `gamma` | `Float64` | inheritance proportion | `-1.0` (hybrid) / `1.0` (tree) |
| `hybrid` | `Bool` | is hybrid edge | — |
| `ismajor` | `Bool` | `gamma > 0.5` | — |
| `ischild1` | `Bool` | `node[1]` is child | — |
| `containroot` | `Bool` | can root here | `true` until hybrid |

#### Metadata flow: file → `HybridNetwork`

| Source (file) | Field in Newick | Parsed by | Stored on | Field |
|---|---|---|---|---|
| Branch length | `:length` | `parsenewick_edgedata!` (1st colon) | `Edge` | `.length` |
| Bootstrap/support | `:length:support` | `parsenewick_edgedata!` (2nd colon) | `Edge` | `.y` |
| Gamma (hybrid) | `:length:support:gamma` | `parsenewick_edgedata!` (3rd colon) + `synchronizepartnersdata!` | `Edge` | `.gamma` |
| Node label | `name` or `(...)name` | `readnewick_nodename` | `Node` | `.name` |
| Hybrid marker | `#H1` prefix | `parsenewick_hybridnode!` | `Node` | `.hybrid = true` |
| NEXUS gamma | `[&gamma=x]` or `[&relSize=x]` | `readnexus_extractgamma` + `readnexus_assigngammas!` | `Edge` | `.gamma` |

#### Integration requirements for LineagesIO extension

**Protocol level**: General (network) — hybrid nodes require
`add_child(parents::AbstractVector{NodeT}, ...)`.

**Wrapper type needed**: `HybridNetwork` is the graph container; `Node` is the
node handle. The `add_child` protocol returns `NodeT` per call, but
`HybridNetwork` holds all nodes and must persist across calls. The extension
must bundle both:

```julia
# ext/PhyloNetworksExt.jl
struct PhyloNetworksNodeHandle
    net  :: PhyloNetworks.HybridNetwork
    node :: PhyloNetworks.Node
end
```

Root creation (`parents = []`) creates the `HybridNetwork`, creates the root
`Node`, and returns a `PhyloNetworksNodeHandle`. Subsequent calls add nodes and
edges to `handle.net` via PhyloNetworks' `pushNode!`, `pushEdge!`, `setNode!`,
`setEdge!` API.

**Post-build finalization** (called after all `add_child` for one graph):

```julia
PhyloNetworks.storeHybrids!(handle.net)
PhyloNetworks.checkNumHybEdges!(handle.net)
PhyloNetworks.directedges!(handle.net)
```

LineagesIO must expose a finalization hook (see **Open design questions**).

**Gamma edge assignment problem**: In LineagesIO's current protocol, gamma is
per-node metadata in `nodedata`. But in PhyloNetworks, gamma lives on each
hybrid *edge* individually. For a hybrid node with two parent edges, each edge
has its own gamma, requiring parallel edge-level metadata vectors at `add_child`
call time.

The LineagesIO edge table carries gamma at the correct level
(`edge_table.gamma`). The extension can therefore:
1. Build graph structure during `add_child` (edges created with `length` only)
2. Post-build: iterate `GraphParseResult.edge_table`, locate hybrid edges by
   `(src_node_idx, dst_node_idx)`, assign `.gamma` from the table row

This is a two-phase approach. See **Open design questions** for the alternative
of extending the network-level `add_child` signature with per-edge metadata.

**`load` calling convention**:

```julia
using LineagesIO, PhyloNetworks

# Single graph:
result = loadone("file.nwk", PhyloNetworksNodeHandle)
net = result.graph_rootnode.net   # :: HybridNetwork

# Multiple graphs:
for g in load("file.nex", PhyloNetworksNodeHandle).graphs
    net = g.graph_rootnode.net
end
```

---

### Phylo.jl

#### Supported formats

| Format | File extensions | Notes |
|---|---|---|
| Newick | `.nwk`, `.nwl`, `.newick` | NHX/beast metacomments `[&key=value]`; bootstrap as number before first branch |
| NEXUS | `.nex`, `.nexus` | TAXA + TREES blocks with TRANSLATE |

#### Entry points

| Function | Signature | Returns |
|---|---|---|
| `parsenewick` | `parsenewick(inp::String, ::Type{TREE})` | `TREE <: AbstractTree` |
| `parsenewick` | `parsenewick(io, ::Type{TREE})` | `TREE <: AbstractTree` |
| `parsenewick` | `parsenewick(inp)` | `RootedTree` (default) |
| `parsenexus` | `parsenexus(inp::String, ::Type{TREE})` | `TreeSet` or `TREE` |
| `parsenexus` | `parsenexus(inp)` | `TreeSet` (default) |

Note: `parsenewick` and `parsenexus` are Phylo.jl's native entry points; they
are NOT FileIO `load` wrappers.

#### Parse approach

Token-based recursive descent using `Tokenize.jl`. Input is tokenized into a
stream (LPAREN, RPAREN, COLON, COMMA, IDENTIFIER, FLOAT, LSQUARE, etc.) before
parsing begins. Grammar is a standard Newick grammar extended with `[&key=value]`
metacomments parsed by `parsedict`.

NEXUS: processes TAXA block first (builds taxon set), then TREES block. TRANSLATE
table maps short codes to full names during tree parsing. No post-build
finalization required.

#### Endpoint types

| Alias | Full parameterized type | Use |
|---|---|---|
| `RootedTree` | `RecursiveTree{OneRoot, String, Dict{String,Any}, Dict{String,Any}, PolytomousBranching, Float64, Dict{String,Any}}` | Default single tree |
| `BinaryRootedTree` | same with `BinaryBranching` | Strictly binary |
| `UnrootedTree` | same with `Unrooted` | Unrooted |
| `TreeSet{...}` | `TreeSet{String, OneRoot, String, RecursiveNode, RecursiveBranch, RootedTree}` | Multiple trees (NEXUS) |

#### `RecursiveTree` fields

| Field | Type | Meaning |
|---|---|---|
| `name` | `String` | tree name |
| `nodedict` | `Dict{NL, Int}` | node name → index |
| `roots` | `Vector{RecursiveNode}` | root nodes |
| `nodes` | `Vector{RecursiveNode}` | all nodes by index |
| `branches` | `Vector{RecursiveBranch}` | all branches by index |
| `data` | `Dict{String, Any}` | tree-level metadata |
| `tipdata` | `TD` | leaf info (Dict or DataFrame) |
| `rootheight` | `Union{Float64, Missing}` | root height |
| `cache` | `Dict{TraversalOrder, Vector{...}}` | traversal memoization |

#### `RecursiveBranch` fields

| Field | Type | Meaning | Missing sentinel |
|---|---|---|---|
| `length` | `Union{Float64, Missing}` | branch length | `missing` |
| `data` | `Dict{String, Any}` | branch-level metadata | empty dict |

#### Node data: `RecursiveNode`

| Field | Type | Meaning |
|---|---|---|
| `name` | `Union{NL, Nothing}` | node label |
| `in` | `Union{RecursiveBranch, Nothing}` | inbound branch |
| `conns` | `Vector{RecursiveBranch}` | outbound branches |
| `data` | `Dict{String, Any}` | per-node metadata (bootstrap, NHX keys, etc.) |

Node metadata is accessed via `getnodedata(tree, nodename) → Dict{String,Any}`.

#### Metadata flow: file → `RootedTree`

| Source (file) | Format | Parsed by | Stored on | Field/access |
|---|---|---|---|---|
| Branch length | `:length` | `parsenode` (after `:` token) | `RecursiveBranch` | `.length` |
| Metacomments | `[&key=value]` | `parsedict` | `RecursiveNode` | `.data["key"]` |
| Bootstrap (number at internal node) | `(...)0.95` | `parsenewick!` — number after `)` treated as support | `RecursiveNode` | `.data` or node name |
| NEXUS tree metadata | `TREE name [&key=val] = ...` | `parsetrees` | `TreeSet.treeinfo["name"]` | `treeinfo[name]["key"]` |
| NEXUS taxon labels | TAXA block / TRANSLATE | `parsetaxa` + `parsetrees` | Node names in tree | — |

Note: Phylo stores all NHX/metacomment keys in `Dict{String,Any}` — these are
the raw keys from the file, not promoted to typed fields. This matches
LineagesIO's `nodedata::R` row where the row type `R` is built from the
discovery pass.

#### Integration requirements for LineagesIO extension

**Protocol level**: Single-parent (restricted) for standard Newick/NEXUS — Phylo
does not handle hybrid/reticulate nodes.

**Wrapper type needed**: Same pattern as PhyloNetworks — `RootedTree` is the
container; node names (strings) are the handles. The extension bundles both:

```julia
# ext/PhyloExt.jl
struct PhyloNodeRef
    tree     :: Phylo.RootedTree
    nodename :: String
end
```

Root creation (`parent = nothing`) creates the `RootedTree` via Phylo's
constructor, creates the root node via `createnode!(tree, name)`, returns a
`PhyloNodeRef`. Subsequent calls use `createnode!` + `createbranch!` +
`setnodedata!`.

**No post-build finalization required** — Phylo builds incrementally and
validates lazily.

**Metadata flow from LineagesIO to Phylo**:

| LineagesIO arg | Phylo API call | Result |
|---|---|---|
| `label` | `createnode!(tree, label)` | node created by name |
| `edgelength` | `createbranch!(tree, parent_name, child_name, length=edgelength)` | branch with length |
| `nodedata.*` | `setnodedata!(tree, child_name, Dict(pairs(nodedata)))` | all promoted fields as node data dict |
| `node_idx` | Stored in node data: `"node_idx" => node_idx` | enables joins to LineagesIO node table |

Note: Phylo stores node metadata as `Dict{String,Any}`. LineagesIO's `nodedata::R`
(a `NamedTuple`) converts cleanly via `Dict(pairs(nodedata))`. Field names from
the discovery-pass-promoted columns become the keys in Phylo's node data dict.

**`load` calling convention**:

```julia
using LineagesIO, Phylo

# Single tree:
result = loadone("file.nwk", PhyloNodeRef)
tree = result.graph_rootnode.tree   # :: RootedTree

# Multiple trees (NEXUS):
for g in load("file.nex", PhyloNodeRef).graphs
    tree = g.graph_rootnode.tree
end
```

---

## Extension architecture

### Triggering mechanism

Julia 1.9+ package extensions: the extension module is loaded automatically when
both LineagesIO and the target package are loaded in the same Julia session.

In `LineagesIO/Project.toml`:

```toml
[weakdeps]
PhyloNetworks = "<uuid>"
Phylo = "<uuid>"

[extensions]
PhyloNetworksExt = "PhyloNetworks"
PhyloExt = "Phylo"
```

The extension modules live at:

```
LineagesIO.jl/
  ext/
    PhyloNetworksExt.jl
    PhyloExt.jl
```

No hard dependency on either package. If the user loads only LineagesIO, neither
extension is activated. If they load `using LineagesIO, PhyloNetworks`, Julia
automatically loads `PhyloNetworksExt.jl`.

### Dependency structure

```
LineagesIO (core)
  ├── FileIO (dep)
  ├── Tables (dep)
  ├── [weak] PhyloNetworks → ext/PhyloNetworksExt.jl
  └── [weak] Phylo         → ext/PhyloExt.jl
```

No version pinning on the weak deps — extensions are expected to work across
a supported range, validated in the extension's own test suite.

### Extension module layout

Each extension module:

1. Defines the node-handle wrapper type
2. Implements `LineagesIO.add_child` methods for the wrapper type
3. Implements any finalization hooks (see **Open design questions**)
4. Optionally exports convenience functions (e.g., `phylonetworks_result(g)`)

```julia
# ext/PhyloNetworksExt.jl
module PhyloNetworksExt

using LineagesIO
using PhyloNetworks: HybridNetwork, Node, Edge, pushNode!, pushEdge!, setNode!, setEdge!,
                     storeHybrids!, checkNumHybEdges!, directedges!

struct PhyloNetworksNodeHandle
    net  :: HybridNetwork
    node :: Node
end

# Entry-point node creation (parents is empty)
# edgelengths and nodedata are anonymous (::) — structurally inapplicable to the
# entry-point node: no parent edges exist, and HybridNetwork/Node has no generic
# metadata dict. nodedata fields (e.g. bootstrap) are stored on incoming Edge.y
# in the non-entry-point overload below.
function LineagesIO.add_child(
    parents     :: AbstractVector{PhyloNetworksNodeHandle},
    node_idx    :: Int,
    label       :: AbstractString,
    :: AbstractVector,    # edgelengths — empty for entry-point; no parent edges
    :: R,                 # nodedata — no metadata store on root Node; see below
) where {R}
    @assert isempty(parents)
    net = HybridNetwork()
    root = Node(node_idx, false)
    root.name = isempty(label) ? "node_$node_idx" : label
    pushNode!(net, root)
    net.rooti = 1
    return PhyloNetworksNodeHandle(net, root)
end

# Non-entry-point node. For hybrid nodes (length(parents) > 1): one Edge per parent.
# Gamma values are assigned post-build from GraphParseResult.edge_table (two-phase).
function LineagesIO.add_child(
    parents     :: AbstractVector{PhyloNetworksNodeHandle},
    node_idx    :: Int,
    label       :: AbstractString,
    edgelengths :: AbstractVector,
    nodedata    :: R,
) where {R}
    @assert !isempty(parents)
    net = parents[1].net
    is_hybrid = length(parents) > 1
    child = Node(node_idx, is_hybrid)
    child.name = isempty(label) ? "node_$node_idx" : label
    pushNode!(net, child)
    bootstrap = hasproperty(nodedata, :bootstrap) ? something(nodedata.bootstrap, -1.0) : -1.0
    for (par, elen) in zip(parents, edgelengths)
        e = Edge(length(net.edge) + 1, isnothing(elen) ? -1.0 : elen)
        e.y = bootstrap    # bootstrap support stored on incoming Edge.y
        e.hybrid = is_hybrid
        pushEdge!(net, e)
        setNode!(e, [par.node, child])
        setEdge!(par.node, e)
        setEdge!(child, e)
    end
    return PhyloNetworksNodeHandle(net, child)
end

function LineagesIO.finalize_graph!(handle :: PhyloNetworksNodeHandle)
    storeHybrids!(handle.net)
    checkNumHybEdges!(handle.net)
    directedges!(handle.net)
    return handle
end

end # module
```

```julia
# ext/PhyloExt.jl
module PhyloExt

using LineagesIO
using Phylo: RootedTree, createnode!, createbranch!

struct PhyloNodeRef
    tree     :: RootedTree
    nodename :: String
end

# Entry-point node creation (parent is nothing)
# parent and edgelength are anonymous (::) — dispatch-only and structurally
# inapplicable: the entry-point node has no parent and no incoming edge.
function LineagesIO.add_child(
    :: Nothing,                   # parent — dispatch-only; entry-point has no parent
    node_idx   :: Int,
    label      :: AbstractString,
    :: Union{Float64, Nothing},   # edgelength — no incoming edge for entry-point node
    nodedata   :: R,
) where {R}
    tree = RootedTree(; name = "tree_$node_idx")
    nodename = isempty(label) ? "node_$node_idx" : label
    createnode!(tree, nodename; data = Dict{String,Any}(pairs(nodedata)))
    return PhyloNodeRef(tree, nodename)
end

# Non-entry-point node creation
function LineagesIO.add_child(
    parent     :: PhyloNodeRef,
    node_idx   :: Int,
    label      :: AbstractString,
    edgelength :: Union{Float64, Nothing},
    nodedata   :: R,
) where {R}
    tree = parent.tree
    nodename = isempty(label) ? "node_$node_idx" : label
    # Store node_idx in node data so callers can join to LineagesIO node_table
    data = Dict{String,Any}(pairs(nodedata))
    data["node_idx"] = node_idx
    createnode!(tree, nodename; data = data)
    # Phylo branch length is Union{Float64,Missing}; convert Nothing → missing
    phylo_len = isnothing(edgelength) ? missing : edgelength
    createbranch!(tree, parent.nodename, nodename, phylo_len)
    return PhyloNodeRef(tree, nodename)
end

# No finalize_graph! override needed — Phylo validates lazily

end # module
```

### Extension API surface

Each extension exports a single accessor for the target-package type from a
`GraphParseResult`:

| Extension | Function | Returns |
|---|---|---|
| `PhyloNetworksExt` | `get_hybridnetwork(g::GraphParseResult)` | `HybridNetwork` |
| `PhyloExt` | `get_rootedtree(g::GraphParseResult)` | `RootedTree` |

---

## Open design questions

### 1. Post-build finalization hook

PhyloNetworks requires `storeHybrids!`, `checkNumHybEdges!`, `directedges!`
after all `add_child` calls for a graph complete. LineagesIO currently has no
mechanism for the extension to register a callback at this point.

Options:
- **A**: LineagesIO calls `finalize_graph!(handle)` if it is defined for the
  handle type. Extension overloads `LineagesIO.finalize_graph!` for
  `PhyloNetworksNodeHandle`.
- **B**: The accessor `get_hybridnetwork(g)` performs finalization lazily on
  first call.

Recommendation: Option A — `finalize_graph!` as a protocol function in
LineagesIO's public API, called once per graph after the last `add_child` call
for that graph and before `GraphParseResult` is assembled.

### 2. Per-edge metadata at `add_child` call time

In the current protocol, `add_child` for network nodes receives `edgelengths`
(parallel to `parents`) but no parallel edge metadata vector. PhyloNetworks'
gamma values are per-edge, not per-node. The current workaround is a two-phase
approach: build topology during `add_child`, then assign gamma from
`GraphParseResult.edge_table` after loading.

The alternative is extending the network-level signature:

```julia
add_child(
    parents     :: AbstractVector{NodeT},
    node_idx    :: Int,
    label       :: AbstractString,
    edgelengths :: AbstractVector{Union{EdgeLenT, Nothing}},
    edgedata    :: AbstractVector{RE},   # parallel to parents — one row per parent edge
    nodedata    :: RE,
) where {RE}
```

This enables single-pass gamma assignment but adds complexity to the protocol.
Decision deferred; post-build lookup from edge table is acceptable for Phase 1.

### 3. `PhyloNodeRef` node name collision

Phylo uses node names (strings) as primary keys. If the source file has empty
or non-unique node labels, the extension must generate unique names
(e.g., `"node_$node_idx"`). The strategy for name generation should be
documented and consistent.

---

## Phase plan

### Phase 1

- `PhyloNetworksExt`: Newick (single-parent + network protocol), via
  `format"Newick"` and `format"LineageNetwork"`
- `PhyloExt`: Newick (single-parent protocol only), via `format"Newick"`
- `finalize_graph!` hook implementation
- Integration tests for round-trip: file → `HybridNetwork` / `RootedTree`

### Phase 2

- NEXUS support for both extensions
- Gamma two-phase assignment (or per-edge metadata protocol decision)
- `TreeSet` support for Phylo multi-tree NEXUS files
- Additional focal packages (to be added to §2 table as identified)
