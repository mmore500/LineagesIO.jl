# Vocabulary propagation: `rootnode` → `basenode` across all project files

**Run:** `20260430T23129--revocab`
**Date:** 2026-04-30
**Status:** Plan — awaiting execution

---

## 1. Governance pass-forward

This plan carries the full controlled-vocabulary mandate from `STYLE-vocabulary.md`.
Any agent executing this plan must read `STYLE-vocabulary.md` in full before touching
any file, and must re-pass these constraints into any downstream delegations.

### Canonical term

| Concept | Prose | Code identifier |
|---------|-------|-----------------|
| Distinguished node of a lineage graph | `basenode` | `basenode` |

### Proscribed in all project-owned contexts (code, docs, tests, design)

`root`, `root node`, `rootnode`, `root-node`, `base node`, `base-node`,
`base`, `root_node`, `base_node`, `basevertex`, `base_vertex`, `seed_node`,
`origin`, `source` (for this concept).

### Terms that are NOT proscribed and must NOT be changed

- `rooted` / `unrooted` as adjectives modifying graph or tree type
  (e.g., "rooted tree", "rooted network", "rooted-network-capable")
- `root cause` — idiomatic English, unrelated to tree concept
- PhyloNetworks external API fields: `graph.rooti`, `graph.isrooted`,
  `checkroot!`, `RootMismatch`, `directedges!`, `storeHybrids!`
- PhyloNetworks documentation paths (e.g., `dist_reroot.md`)
- `"Root"` as a string literal that is a Newick node label in fixture data
  and in test assertions checking those labels (it is domain data, not a
  project identifier)
- `root` in "The root `README.md`" (STYLE-julia.md:1306) — filesystem concept

---

## 2. Classification rules

### Change — project-owned identifiers and prose

Apply the renaming table in §3 to:
- All Julia source files (`src/`, `ext/`)
- All test files (`test/`) except fixture data (see below)
- All documentation files (`docs/`, `README.md`)
- All design and workflow documents (`design/`, `.workflow-docs/`)
- All STYLE documents where project-concept prose occurs

### Do not change — external API and domain data

- `.nwk` and `.txt` fixture file **contents** — Newick node label `Root` is
  biological data, not a project identifier. The string `"Root"` in test
  assertions that check Newick node labels is also data and must not change.
- `.nwk` and `.txt` fixture **filenames** that use `rooted` as a graph-type
  adjective (e.g., `annotated_simple_rooted.nwk`, `single_rooted_tree.nwk`,
  `rooted_network_with_annotations.nwk`) — keep.
- Any identifier or call site that references a PhyloNetworks or
  MetaGraphsNext external API member.

---

## 3. Renaming table

### 3a. Public API renames (breaking change — update all call sites)

| Old name | New name | Files affected |
|----------|----------|----------------|
| `bind_rootnode!` | `bind_basenode!` | `src/LineagesIO.jl`, `src/construction.jl`, `ext/MetaGraphsNextIO.jl`, `ext/PhyloNetworksIO.jl`, all test files, `design/brief.md`, `design/brief--user-stories.md`, `design/brief--community-support-objectives.md`, workflow-doc tasking files |
| `emit_rootnode` | `emit_basenode` | `src/construction.jl`, `ext/MetaGraphsNextIO.jl`, `ext/PhyloNetworksIO.jl`, `metagraphsnext-status.md` |

### 3b. Type renames

| Old name | New name | Files affected |
|----------|----------|----------------|
| `RootBindingLoadRequest{RootNodeT}` (struct + type param) | `BasenodeLoadRequest{BasenodeT}` | `src/construction.jl`, `src/fileio_integration.jl` |
| `RootBindingProtocolNode` | `BasenodeProtocolNode` | `test/core/root_binding.jl` |
| `MissingRootBindingProtocolNode` | `MissingBasenodeProtocolNode` | `test/core/error_paths.jl` |

### 3c. Function renames (internal / extension-private)

| Old name | New name | Files affected |
|----------|----------|----------------|
| `materialize_graph_rootnode` | `materialize_graph_basenode` | `src/construction.jl` |
| `validate_and_find_rootnodekey` | `validate_and_find_basenodekey` | `src/construction.jl` |
| `validate_multi_parent_root_binding_request` | `validate_multi_parent_basenode_binding_request` | `src/construction.jl` |
| `build_root_node` | `build_basenode` | `ext/PhyloNetworksIO.jl` |
| `normalize_singleton_root!` | `normalize_singleton_basenode!` | `ext/PhyloNetworksIO.jl` |

### 3d. Variable / field / constant renames (apply locally within each file)

| Old name | New name | Notes |
|----------|----------|-------|
| `rootnode` (parameter/variable name) | `basenode` | Everywhere it names the project's distinguished node |
| `rootnodekey` | `basenodekey` | `src/construction.jl`, `src/newick_format.jl` |
| `rootnodekeys` | `basenodekeys` | `src/construction.jl` |
| `rootnodedata` | `basenodedata` | `src/construction.jl` |
| `rootnode_handle` | `basenode_handle` | `src/construction.jl` |
| `root_node` (local var in PhyloNetworksIO.jl) | `basenode` | `ext/PhyloNetworksIO.jl` — context is `build_basenode` and `normalize_singleton_basenode!` |
| `root_is_leaf` | `is_leaf` | `ext/PhyloNetworksIO.jl:325` |
| `ROOT_BINDING_PROTOCOL_EVENTS` | `BASENODE_PROTOCOL_EVENTS` | `test/core/root_binding.jl` |
| `roots` (collection of parsed Newick occurrences) | `basenodes` | `src/newick_format.jl:48,288,291,295` |
| `root` (loop variable over parsed occurrences) | `basenode` | `src/newick_format.jl:49,84,88,89,105,302,306` |
| `root_edge_path` | `basenode_edge_path` | `test/core/network_newick_format.jl:157` |
| `root_edge_error` | `basenode_edge_error` | `test/core/network_newick_format.jl:158-163` |
| `root` (local var accessing PhyloNetworks node) | `basenode` | `test/extensions/phylonetworks_newick_networks.jl:47`, `test/extensions/phylonetworks_tree_compatible_newick.jl:16`, `test/integration/phylonetworks_soft_release.jl` (where applicable) |
| `builder_root` | `builder_basenode` | `test/core/network_newick_format.jl:133-134` |
| `materialized_root` | `materialized_basenode` | `test/core/network_target_validation.jl:221-222` |
| `bound_root` | `bound_basenode` | `test/core/network_target_validation.jl:183,187` |

### 3e. Prose term renames

Apply in all prose contexts (comments, docstrings, docs, design files, workflow docs):

| Old prose | New prose |
|-----------|-----------|
| "root node" (project concept) | `basenode` |
| "root-node" | `basenode` |
| "supplied-root binding" | "supplied-basenode binding" |
| "supplied-root" (adjective) | "supplied-basenode" |
| "library-created-root" | "library-created-basenode" |
| "root binding" (project concept) | "basenode binding" |
| "root-binding" | "basenode-binding" |
| "root creation" | "basenode creation" |
| "root-construction" | "basenode-construction" |
| "root node has no incoming edge" | "basenode has no incoming edge" |
| write "root node" in prose, but use `rootnode` | write `basenode` in prose and code |
| "Root binding, descendant construction" (section heading) | "Basenode binding, descendant construction" |

### 3f. `@testset` name renames

| Old testset name | New testset name | File |
|-----------------|-----------------|------|
| `"Supplied-root binding"` | `"Supplied-basenode binding"` | `test/core/root_binding.jl:47` |
| `"MetaGraphsNext supplied-root binding"` | `"MetaGraphsNext supplied-basenode binding"` | `test/extensions/metagraphsnext_supplied_root.jl:3` |

---

## 4. File renames (git mv required)

Execute all renames with `git mv` (not `mv`) to preserve history.
Update all `include(...)` statements and fixture path references after each rename.

| Old path | New path |
|----------|----------|
| `test/core/root_binding.jl` | `test/core/basenode_binding.jl` |
| `test/extensions/metagraphsnext_supplied_root.jl` | `test/extensions/metagraphsnext_supplied_basenode.jl` |
| `test/fixtures/multi_graph_root_binding_source.trees` | `test/fixtures/multi_graph_basenode_binding_source.trees` |
| `test/fixtures/invalid_network_root_edge_data.nwk` | `test/fixtures/invalid_network_basenode_edge_data.nwk` |

After file renames, update these references:

| File | Line | Old reference | New reference |
|------|------|---------------|---------------|
| `test/runtests.jl` | 31 | `include("core/root_binding.jl")` | `include("core/basenode_binding.jl")` |
| `test/runtests.jl` | 41 | `include("extensions/metagraphsnext_supplied_root.jl")` | `include("extensions/metagraphsnext_supplied_basenode.jl")` |
| `test/core/root_binding.jl` (→ renamed) | 74 | `"multi_graph_root_binding_source.trees"` | `"multi_graph_basenode_binding_source.trees"` |
| `test/core/network_newick_format.jl` | 157 | `"invalid_network_root_edge_data.nwk"` | `"invalid_network_basenode_edge_data.nwk"` |
| `metagraphsnext-status.md` | 54 | `metagraphsnext_supplied_root.jl` | `metagraphsnext_supplied_basenode.jl` |
| `metagraphsnext-status.md` | 55 | `metagraphsnext_supplied_root.jl` | `metagraphsnext_supplied_basenode.jl` |
| `metagraphsnext-status.md` | 56 | `metagraphsnext_supplied_root.jl` | `metagraphsnext_supplied_basenode.jl` |
| `metagraphsnext-status.md` | 57 | `metagraphsnext_supplied_root.jl` | `metagraphsnext_supplied_basenode.jl` |
| `.workflow-docs/runs/20260427--production01/02_tranches.md` | 409 | `metagraphsnext_supplied_root.jl` | `metagraphsnext_supplied_basenode.jl` |
| `.workflow-docs/runs/20260427--production01/03_tasking.md` | 107 | `metagraphsnext_supplied_root.jl` | `metagraphsnext_supplied_basenode.jl` |
| `.workflow-docs/runs/20260427--production01/03_tranche-03--tasking.md` | 393 | `metagraphsnext_supplied_root.jl` | `metagraphsnext_supplied_basenode.jl` |

---

## 5. Line-level change inventory

### 5a. `src/LineagesIO.jl`

| Line | Current | Change |
|------|---------|--------|
| 18 | `export bind_rootnode!` | `export bind_basenode!` |
| 28 | `MetaGraphsNext-backed rooted-tree materialization.` | `MetaGraphsNext-backed rooted-tree materialization.` — keep ("rooted-tree" is graph-type adjective) |

### 5b. `src/construction.jl`

Apply the following changes throughout the file. Exact line numbers may shift
as preceding edits are made; use the string patterns to locate each instance.

| Pattern / location | Change |
|--------------------|--------|
| `struct RootBindingLoadRequest{RootNodeT}` | `struct BasenodeLoadRequest{BasenodeT}` |
| field `rootnode::RootNodeT` (inside `RootBindingLoadRequest`) | `basenode::BasenodeT` |
| docstring `bind_rootnode!(rootnode, nodekey, label; nodedata)` | `bind_basenode!(basenode, nodekey, label; nodedata)` |
| docstring line: `Bind a parsed root node onto a caller-supplied \`rootnode\` handle.` | `Bind a parsed basenode onto a caller-supplied \`basenode\` handle.` |
| `function bind_rootnode!(` | `function bind_basenode!(` |
| parameter `rootnode` in `bind_rootnode!` default stub | `basenode` |
| error string: `No \`LineagesIO.bind_rootnode!\`...` | `No \`LineagesIO.bind_basenode!\`...` |
| error string: `Implement \`bind_rootnode!(rootnode, nodekey, label; nodedata)\`...` | `Implement \`bind_basenode!(basenode, nodekey, label; nodedata)\`...` |
| error string: `...for the supplied rootnode or materialization target...` | `...for the supplied basenode or materialization target...` |
| docstring line: `The root-construction event uses \`add_child(::Nothing, ...)\`.` | `The basenode-construction event uses \`add_child(::Nothing, ...)\`.` |
| error string in `add_child`: `No \`LineagesIO.add_child(::Nothing, ...)\` root-construction method` | `No \`LineagesIO.add_child(::Nothing, ...)\` basenode-construction method` |
| `request::RootBindingLoadRequest` (all occurrences) | `request::BasenodeLoadRequest` |
| error string: `The supplied-root load surface is valid only for...` | `The supplied-basenode load surface is valid only for...` |
| `function validate_multi_parent_root_binding_request(` | `function validate_multi_parent_basenode_binding_request(` |
| call `validate_multi_parent_root_binding_request(...)` | `validate_multi_parent_basenode_binding_request(...)` |
| `sample_parents = typeof(request.rootnode)[]` | `sample_parents = typeof(request.basenode)[]` |
| error string: `The supplied \`rootnode\` load surface cannot materialize...` (both occurrences) | `The supplied \`basenode\` load surface cannot materialize...` |
| `materialized = materialize_graph_rootnode(...)` | `materialize_graph_basenode(...)` |
| `function materialize_graph_rootnode(` | `function materialize_graph_basenode(` |
| `rootnodekey = validate_and_find_rootnodekey(...)` | `basenodekey = validate_and_find_basenodekey(...)` |
| `rootnodedata = NodeRowRef(node_table, rootnodekey)` | `basenodedata = NodeRowRef(node_table, basenodekey)` |
| `rootnode_handle = emit_rootnode(request, rootnodekey, labels[rootnodekey], rootnodedata)` | `basenode_handle = emit_basenode(request, basenodekey, labels[basenodekey], basenodedata)` |
| `rootnode_handle,` and `rootnodekey,` (immediately following) | `basenode_handle,` and `basenodekey,` |
| `return finalize_graph!(rootnode_handle)` (first occurrence, single-parent path) | `return finalize_graph!(basenode_handle)` |
| `materialized_handles[rootnodekey] = rootnode_handle` | `materialized_handles[basenodekey] = basenode_handle` |
| `materialized_ready[rootnodekey] = true` | `materialized_ready[basenodekey] = true` |
| `for child_nodekey in child_nodekeys_by_parent[rootnodekey]` | `for child_nodekey in child_nodekeys_by_parent[basenodekey]` |
| `return finalize_graph!(rootnode_handle)` (second occurrence, end of function) | `return finalize_graph!(basenode_handle)` |
| `function validate_and_find_rootnodekey(` | `function validate_and_find_basenodekey(` |
| `rootnodekeys = StructureKeyType[]` | `basenodekeys = StructureKeyType[]` |
| `push!(rootnodekeys, ...)` | `push!(basenodekeys, ...)` |
| `length(rootnodekeys) == 1 \|\| throw(ArgumentError("The authoritative graph tables must describe exactly one \`rootnode\`..."))` | `length(basenodekeys) == 1 \|\| throw(ArgumentError("The authoritative graph tables must describe exactly one \`basenode\`..."))` |
| `rootnodekey = only(rootnodekeys)` | `basenodekey = only(basenodekeys)` |
| `rootnodekey == StructureKeyType(1) \|\| throw(ArgumentError("...must preserve the tranche-4 \`rootnodekey == 1\` invariant...placed the root node at nodekey $(rootnodekey)."))` | `basenodekey == StructureKeyType(1) \|\| throw(ArgumentError("...must preserve the tranche-4 \`basenodekey == 1\` invariant...placed the basenode at nodekey $(basenodekey)."))` |
| `return rootnodekey` | `return basenodekey` |
| error string: `...impossible rooted-network parent schedule...` | keep ("rooted-network" is graph-type adjective) |
| `function emit_rootnode(` (all three overloads) | `function emit_basenode(` |
| `rootnode_handle = add_child(` (in first `emit_rootnode`) | `basenode_handle = add_child(` |
| `ensure_constructed_handle(rootnode_handle, "root-construction")` | `ensure_constructed_handle(basenode_handle, "basenode-construction")` |
| `rootnode_handle isa NodeT \|\| throw(ArgumentError("The root-construction \`LineagesIO.add_child(::Nothing, ...)\` call returned..."))` | `basenode_handle isa NodeT \|\| throw(ArgumentError("The basenode-construction \`LineagesIO.add_child(::Nothing, ...)\` call returned..."))` |
| `return rootnode_handle` (in first `emit_rootnode`) | `return basenode_handle` |
| `rootnode_handle = bind_rootnode!(request.rootnode, ...)` (in second `emit_rootnode`) | `basenode_handle = bind_basenode!(request.basenode, ...)` |
| `ensure_constructed_handle(rootnode_handle, "root-binding")` | `ensure_constructed_handle(basenode_handle, "basenode-binding")` |
| `return rootnode_handle` (in second `emit_rootnode`) | `return basenode_handle` |
| `rootnode_handle = request.builder(` (in third `emit_rootnode`) | `basenode_handle = request.builder(` |
| `ensure_constructed_handle(rootnode_handle, "builder root-construction")` | `ensure_constructed_handle(basenode_handle, "builder basenode-construction")` |
| `return rootnode_handle` (in third `emit_rootnode`) | `return basenode_handle` |
| `::RootBindingLoadRequest,` (in `validate_extension_load_target` dispatch) | `::BasenodeLoadRequest,` |
| `request::RootBindingLoadRequest,` (in multi-parent dispatch) | `request::BasenodeLoadRequest,` |
| `request::RootBindingLoadRequest,` (in other dispatch) | `request::BasenodeLoadRequest,` |

### 5c. `src/fileio_integration.jl`

| Line | Current | Change |
|------|---------|--------|
| 32 | error string containing `load(src, rootnode)` | `load(src, basenode)` |
| 48 | `function build_load_request(args::Tuple{RootNodeT}, builder)` | `function build_load_request(args::Tuple{BasenodeT}, builder)` (update type param name) |
| 49 | error string: `...cannot be combined with a supplied \`rootnode\`...` | `...cannot be combined with a supplied \`basenode\`...` |
| 50 | `return RootBindingLoadRequest(first(args))` | `return BasenodeLoadRequest(first(args))` |
| 54 | error string: `...Supported surfaces are \`load(src)\`, \`load(src, NodeT)\`, \`load(src, rootnode)\`...` (two occurrences) | replace `rootnode` with `basenode` |

### 5d. `src/newick_format.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 48 | `roots = parse_newick_source(text, source_path)` | `basenodes = parse_newick_source(text, source_path)` |
| 49 | `[build_graph_asset(root, graph_index, source_path) for (graph_index, root) in enumerate(roots)]` | `[build_graph_asset(basenode, graph_index, source_path) for (graph_index, basenode) in enumerate(basenodes)]` |
| 84 | `root::ParsedNewickOccurrence,` | `basenode::ParsedNewickOccurrence,` |
| 88 | `root.edgeweight === nothing \|\|` and error string `"Incoming root edge weights..."` | `basenode.edgeweight === nothing \|\|` and `"Incoming basenode edge weights..."` |
| 89 | `isempty(root.edge_annotations)` and error string `"Incoming root edge annotations..."` | `isempty(basenode.edge_annotations)` and `"Incoming basenode edge annotations..."` |
| 105 | `rootnodekey = append_occurrence!(state, root, nothing)` | `basenodekey = append_occurrence!(state, basenode, nothing)` |
| 106 | `rootnodekey == StructureKeyType(1) \|\| throw(...)` — error string contains `` `rootnodekey == 1` `` and `root resolved to nodekey $(rootnodekey)` | Update to `` `basenodekey == 1` `` and `basenode resolved to nodekey $(basenodekey)` |
| 288 | `roots = ParsedNewickOccurrence[]` | `basenodes = ParsedNewickOccurrence[]` |
| 291 | `push!(roots, parse_graph!(parser))` | `push!(basenodes, parse_graph!(parser))` |
| 294 | `isempty(roots) &&` | `isempty(basenodes) &&` |
| 294 | error string: `"Newick sources must contain at least one rooted graph."` | keep — "rooted graph" is a Newick format term |
| 295 | `return roots` | `return basenodes` |
| 300 | error string: `"expected a rooted graph before end of input"` | keep |
| 301 | error string: `"expected a rooted graph before \`;\`"` | keep |
| 302 | `root = parse_subtree!(parser)` | `basenode = parse_subtree!(parser)` |
| 304 | error string: `"expected \`;\` after rooted graph"` | keep |
| 306 | `return root` | `return basenode` |

### 5e. `ext/MetaGraphsNextIO.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 27–29 | docstring: `Extension-private construction handle returned by \`bind_rootnode!\` and` | `...returned by \`bind_basenode!\` and` |
| 139 | comment: `Called before the supplied-instance load path binds a root node.` | `Called before the supplied-instance load path binds a basenode.` |
| 298 | comment: `# Protocol: emit_rootnode (library-created path only).` | `# Protocol: emit_basenode (library-created path only).` |
| 300 | comment: `# The generic emit_rootnode in construction.jl checks rootnode_handle isa NodeT` | `# The generic emit_basenode in construction.jl checks basenode_handle isa NodeT` |
| 307 | `function LineagesIO.emit_rootnode(` | `function LineagesIO.emit_basenode(` |
| 319 | comment: `# Protocol: bind_rootnode! (supplied-instance path).` | `# Protocol: bind_basenode! (supplied-instance path).` |
| 322 | `function LineagesIO.bind_rootnode!(` | `function LineagesIO.bind_basenode!(` |
| 356 | comment referencing `request.rootnode` | update to `request.basenode` |

### 5f. `ext/PhyloNetworksIO.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 320 | `function build_root_node(` | `function build_basenode(` |
| 325 | `root_is_leaf = node_count(node_table) == 1` | `is_leaf = node_count(node_table) == 1` |
| 326 | `root_node = PhyloNetworks.Node(Int(nodekey), root_is_leaf, false)` | `basenode = PhyloNetworks.Node(Int(nodekey), is_leaf, false)` |
| 327–330 | `root_node.name = normalize_phylonetworks_node_name(nodekey, label, root_is_leaf,)` | `basenode.name = normalize_phylonetworks_node_name(nodekey, label, is_leaf,)` |
| 332 | `return root_node` | `return basenode` |
| 343 | `root_node = build_root_node(nodekey, label, getfield(nodedata, :table))` | `basenode = build_basenode(nodekey, label, getfield(nodedata, :table))` |
| 348 | `root_node,` (passed to `register_node!`) | `basenode,` |
| 351 | `return PhyloNetworksBuildCursor(graph, target, root_node, nodekey, state)` | `return PhyloNetworksBuildCursor(graph, target, basenode, nodekey, state)` |
| 354 | `function LineagesIO.emit_rootnode(` | `function LineagesIO.emit_basenode(` |
| 364 | `function LineagesIO.bind_rootnode!(` | `function LineagesIO.bind_basenode!(` |
| 676 | `function normalize_singleton_root!(` | `function normalize_singleton_basenode!(` |
| 681 | `root_node = only(getfield(graph, :node))` | `basenode = only(getfield(graph, :node))` |
| 682 | `getfield(root_node, :leaf) && return nothing` | `getfield(basenode, :leaf) && return nothing` |
| 683 | `root_node.leaf = true` | `basenode.leaf = true` |
| 685 | `graph.leaf = PhyloNetworks.Node[root_node]` | `graph.leaf = PhyloNetworks.Node[basenode]` |
| 703 | `normalize_singleton_root!(graph)` | `normalize_singleton_basenode!(graph)` |
| 707 | `graph.isrooted = true` | keep — PhyloNetworks external API |

### 5g. `src/LineagesIO.jl`

| Line | Current | Change |
|------|---------|--------|
| 18 | `export bind_rootnode!` | `export bind_basenode!` |

### 5h. `test/core/root_binding.jl` (→ renamed `basenode_binding.jl`)

Global renames within this file:

| Old | New |
|-----|-----|
| `ROOT_BINDING_PROTOCOL_EVENTS` | `BASENODE_PROTOCOL_EVENTS` |
| `RootBindingProtocolNode` | `BasenodeProtocolNode` |
| `bind_rootnode!` (method definition and calls) | `bind_basenode!` |
| `rootnode` (variable and parameter) | `basenode` |
| `"Supplied-root binding"` testset name | `"Supplied-basenode binding"` |
| `(:bind_rootnode, ...)` event tuples | `(:bind_basenode, ...)` |
| `"multi_graph_root_binding_source.trees"` | `"multi_graph_basenode_binding_source.trees"` |

Retain `"Root"` string literals (they are Newick node labels being asserted on,
e.g., `@test rootnode.label == "Root"` → `@test basenode.label == "Root"`).

### 5i. `test/core/error_paths.jl`

| Line | Current | Change |
|------|---------|--------|
| 3 | `mutable struct MissingRootBindingProtocolNode` | `mutable struct MissingBasenodeProtocolNode` |
| 16 | `missing_root_binding_error = capture_expected_load_error() do` | `missing_basenode_error = capture_expected_load_error() do` |
| 17 | `load(fixture_path, MissingRootBindingProtocolNode(0))` | `load(fixture_path, MissingBasenodeProtocolNode(0))` |
| 19 | `@test missing_root_binding_error isa ArgumentError` | `@test missing_basenode_error isa ArgumentError` |
| 20 | `@test occursin("bind_rootnode!", sprint(showerror, missing_root_binding_error))` | `@test occursin("bind_basenode!", sprint(showerror, missing_basenode_error))` |
| 23 | `load(fixture_path, MissingRootBindingProtocolNode(0); builder = ...)` | `load(fixture_path, MissingBasenodeProtocolNode(0); builder = ...)` |

### 5j. `test/core/builder_callback.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 12 | `function LineagesIO.finalize_graph!(rootnode::BuilderCallbackNode)` | `function LineagesIO.finalize_graph!(basenode::BuilderCallbackNode)` |
| 13 | `push!(BUILDER_CALLBACK_EVENTS, (:finalize, rootnode.nodekey, rootnode.label))` | `push!(BUILDER_CALLBACK_EVENTS, (:finalize, basenode.nodekey, basenode.label))` |
| 14 | `rootnode.finalized = true` | `basenode.finalized = true` |
| 15 | `return rootnode` | `return basenode` |
| 24 | `(parent === nothing ? :root : :child, ...)` | `(parent === nothing ? :basenode : :child, ...)` |
| 31–38 | `rootnode = asset.materialized` through `rootnode.child_collection[...]` | rename `rootnode` → `basenode` throughout |
| 44 | `(:root, 1, nothing, "Root", ...)` event tuple | `(:basenode, 1, nothing, "Root", ...)` — keep `"Root"` as label data |
| 49 | `(:finalize, 1, "Root")` | keep `"Root"` as label data |

### 5k. `test/core/construction_protocol_single_parent.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 24 | `push!(SINGLE_PARENT_PROTOCOL_EVENTS, (:root, nodekey, ...)` | `push!(SINGLE_PARENT_PROTOCOL_EVENTS, (:basenode, nodekey, ...)` |
| 54–57 | `function LineagesIO.finalize_graph!(rootnode::SingleParentProtocolNode)` and body | rename `rootnode` → `basenode` |
| 65–75 | `rootnode = asset.materialized` through `rootnode.child_collection[...]` | rename `rootnode` → `basenode` |
| 104 | `(:root, 1, nothing, "Root", ...)` | `(:basenode, 1, nothing, "Root", ...)` — keep `"Root"` |
| 109 | `(:finalize, 1, nothing, "Root", ...)` | keep `"Root"` |

### 5l. `test/core/network_newick_format.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 20 | `push!(NETWORK_FIXTURE_EVENTS, (:root, nodekey, String(label)))` | `(:basenode, nodekey, String(label))` |
| 56–59 | `function LineagesIO.finalize_graph!(rootnode::FixtureNetworkNode)` and body | rename `rootnode` → `basenode` |
| 91–94 | `rootnode = materialized_asset.materialized` through `rootnode.label`, `rootnode.child_collection` | rename `rootnode` → `basenode` |
| 96 | `(:root, 1, "Root")` | `(:basenode, 1, "Root")` — keep `"Root"` |
| 105–106 | `left = rootnode.child_collection[1]`, `right = rootnode.child_collection[2]` | `left = basenode.child_collection[1]`, `right = basenode.child_collection[2]` |
| 116 | `push!(NETWORK_BUILDER_EVENTS, (:root, nodekey, String(label)))` | `(:basenode, nodekey, String(label))` |
| 133–134 | `builder_root = first(builder_store.graphs).materialized` and `@test builder_root.label == "Root"` | rename `builder_root` → `builder_basenode`, keep `"Root"` |
| 157 | `root_edge_path = abspath(...)` referencing `"invalid_network_root_edge_data.nwk"` | `basenode_edge_path = abspath(...)` referencing `"invalid_network_basenode_edge_data.nwk"` |
| 158–163 | `root_edge_error = capture_expected_load_error()` and uses | `basenode_edge_error = capture_expected_load_error()` and uses |
| 162 | `@test occursin("Incoming root edge", ...)` | `@test occursin("Incoming basenode edge", ...)` |

### 5m. `test/core/network_protocol_multi_parent.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 109 | `push!(MULTI_PARENT_PROTOCOL_EVENTS, (:root, nodekey, ...))` | `(:basenode, nodekey, ...)` |
| 169–172 | `function LineagesIO.finalize_graph!(rootnode::SchedulerProtocolNode)` and body | rename `rootnode` → `basenode` |
| 184 | `(:root, 1, "Root", "0.99"),` | `(:basenode, 1, "Root", "0.99"),` — keep `"Root"` |
| 200 | `(:root, 1, "Root", "0.99"),` | `(:basenode, 1, "Root", "0.99"),` — keep `"Root"` |
| 213 | `@test occursin("impossible rooted-network parent schedule", ...)` | keep — "rooted-network" is graph-type adjective |

### 5n. `test/core/network_target_validation.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 50–59 | `function LineagesIO.bind_rootnode!(rootnode::ValidationBoundNode, ...)` and body | `function LineagesIO.bind_basenode!(basenode::ValidationBoundNode, ...)` |
| 58 | `push!(VALIDATION_BOUND_EVENTS, (:bind_rootnode, nodekey, String(label)))` | `(:bind_basenode, ...)` |
| 104 | `push!(VALIDATION_MULTI_PARENT_EVENTS, (:root, nodekey, String(label)))` | `(:basenode, ...)` |
| 151–154 | `function LineagesIO.finalize_graph!(rootnode::ValidationMultiParentNode)` and body | rename `rootnode` → `basenode` |
| 183 | `bound_root = ValidationBoundNode(nothing, "", ValidationBoundNode[])` | `bound_basenode = ValidationBoundNode(...)` |
| 187 | `LineagesIO.RootBindingLoadRequest(bound_root),` | `LineagesIO.BasenodeLoadRequest(bound_basenode),` |
| 191 | `@test occursin("supplied \`rootnode\` load surface", ...)` | `@test occursin("supplied \`basenode\` load surface", ...)` |
| 197 | `push!(VALIDATION_BUILDER_EVENTS, (:root, nodekey, String(label)))` | `(:basenode, ...)` |
| 221–222 | `materialized_root = only(graph_assets).materialized` and `materialized_root.finalized` | `materialized_basenode = only(graph_assets).materialized` |

### 5o. `test/extensions/metagraphsnext_simple_newick.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 34 | `# Root→Inner` | `# basenode→Inner` |
| 37 | `# Root→C, no weight → default` | `# basenode→C, no weight → default` |

### 5p. `test/extensions/metagraphsnext_supplied_root.jl` (→ renamed `metagraphsnext_supplied_basenode.jl`)

| Lines | Current | Change |
|-------|---------|--------|
| 3 | `@testset "MetaGraphsNext supplied-root binding" begin` | `@testset "MetaGraphsNext supplied-basenode binding" begin` |
| 21 | `"multi_graph_root_binding_source.trees"` | `"multi_graph_basenode_binding_source.trees"` |
| 67 | `# Root→Inner` | `# basenode→Inner` |
| 89 | `@test LineagesIO.node_property(..., :label) == "Root"` | keep — checking Newick label data |

### 5q. `test/extensions/phylonetworks_newick_networks.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 47 | `root = graph.node[graph.rooti]` | `basenode = graph.node[graph.rooti]` |
| 53 | `@test root.number == 1` | `@test basenode.number == 1` |
| 54 | `@test root.name == "Root"` | `@test basenode.name == "Root"` — keep `"Root"` |
| 62 | `@test phylonetworks_child_numbers(root) == [2, 6]` | `@test phylonetworks_child_numbers(basenode) == [2, 6]` |

### 5r. `test/extensions/phylonetworks_tree_compatible_newick.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 16 | `root = graph.node[graph.rooti]` | `basenode = graph.node[graph.rooti]` |
| 19 | `@test root.number == 1` | `@test basenode.number == 1` |
| 20 | `@test root.name == "Root"` | `@test basenode.name == "Root"` — keep `"Root"` |
| 21 | `@test phylonetworks_child_numbers(root) == [2, 5]` | `@test phylonetworks_child_numbers(basenode) == [2, 5]` |
| 45 | `@test phylonetworks_child_numbers(graph.node[graph.rooti]) == [2, 6]` | keep — inline access, no variable to rename |

### 5s. `test/extensions/metagraphsnext_abstracttrees.jl`, `metagraphsnext_activation.jl`, `metagraphsnext_tables_after_load.jl`, `phylonetworks_activation.jl`, `phylonetworks_annotation_paths.jl`, `phylonetworks_rejection_paths.jl`, `phylonetworks_tables_after_load.jl`

Scan each for `rootnode` / `bind_rootnode!` / `emit_rootnode` occurrences. Apply
the §3 renaming table. Keep `"Root"` string literals (Newick label data) and
`graph.rooti` / `graph.isrooted` (PhyloNetworks API). Note: `phylonetworks_rejection_paths.jl:19`
contains an inline Newick string with `Root` as a node label — keep as-is.

### 5t. `test/integration/phylonetworks_soft_release.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 49 | `soft_release_child_numbers(graph.node[graph.rooti])` | keep — PhyloNetworks API access |
| 96 | `@test Tables.getcolumn(asset.node_table, :label) == ["Root", ...]` | keep — Newick label data |

### 5u. `test/core/companion_tables.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 26 | `label = ["root", "left", "right"],` | `label = ["basenode", "left", "right"],` |
| 64 | `@test node_property(node_table, 1, "label") == "root"` | `@test node_property(node_table, 1, "label") == "basenode"` |

### 5v. `test/core/row_references.jl`

| Lines | Current | Change |
|-------|---------|--------|
| 4 | `label = ["root", "left", "right"],` | `label = ["basenode", "left", "right"],` |

### 5w. `README.md`

| Lines | Current | Change |
|-------|---------|--------|
| 8 | `...loading of rooted lineage graphs...` | keep — "rooted" is graph-type adjective |
| 12 | `Phase 1 currently supports rooted-tree and rooted-network-capable Newick` | keep — "rooted-tree", "rooted-network-capable" are graph-type adjectives |
| 18 | `- library-created-root construction through \`load("tree.nwk", NodeT)\`` | `library-created-basenode construction` |
| 19 | `- supplied-root binding through \`load("tree.nwk", rootnode)\`` | `supplied-basenode binding through \`load("tree.nwk", basenode)\`` |
| 22 | `- tree-compatible rooted \`HybridNetwork\` loads...` | keep — "rooted" is graph-type adjective |
| 100 | `rootnode = first(store.graphs).materialized` | `basenode = first(store.graphs).materialized` |
| 106–107 | `...from rooted-network-capable and tree-compatible / rooted \`format"Newick"\` sources...` | keep — graph-type adjective |
| 124 | `- rooted-network native loads through ...` | keep |
| 126 | `- tree-compatible rooted loads through ...` | keep |
| 131 | `The current soft-release contract does not include unrooted-network support,` | keep |
| 136 | `For tree-compatible rooted inputs...` | keep |
| 165 | `gains rooted traversal methods without changing...` | keep |

### 5x. `docs/src/index.md`

| Lines | Current | Change |
|-------|---------|--------|
| 7 | `loading of rooted lineage graph` | keep |
| 30 | `supports rooted-tree and rooted-network-capable Newick loads` | keep |
| 35 | `\`load("tree.nwk", NodeT)\` for library-created-root construction` | `library-created-basenode construction` |
| 36 | `\`load("tree.nwk", rootnode)\` for supplied-root binding on one-graph sources` | `\`load("tree.nwk", basenode)\` for supplied-basenode binding on one-graph sources` |
| 37–38 | `...PhyloNetworks.jl extension path for rooted-network and / tree-compatible rooted...` | keep — graph-type adjectives |
| 91 | `rootnode = first(store.graphs).materialized` | `basenode = first(store.graphs).materialized` |
| 99 | `- rooted-network native loads through ...` | keep |
| 101 | `- tree-compatible rooted loads through ...` | keep |
| 157 | `supports rooted traversal:` | keep |

### 5y. `docs/src/phylonetworks.md`

| Lines | Current | Change |
|-------|---------|--------|
| 4 | `HybridNetwork workflow over rooted-network-capable ...` | keep |
| 13 | `rooted-network native loads...` | keep |
| 15 | `tree-compatible rooted loads...` | keep |
| 21 | `unrooted-network support` | keep |
| 26–97 | All `rooted-network`, `rooted`, `unrooted` uses | keep (graph-type adjectives) |

### 5z. `metagraphsnext-status.md`

| Lines | Current | Change |
|-------|---------|--------|
| 27 | `` `emit_rootnode` override for `NodeTypeLoadRequest{<:MetaGraph}` `` | `` `emit_basenode` override `` |
| 28 | `` `bind_rootnode!(graph::GraphT <: MetaGraph, ...)` `` | `` `bind_basenode!(graph::GraphT <: MetaGraph, ...)` `` |
| 38 | `ConcreteMetaGraphsNextTreeView rooted at nodekey=1` | `ConcreteMetaGraphsNextTreeView at basenode (nodekey=1)` |
| 39 | same pattern | same change |
| 48 | `(Root→Inner≈2.0, ...)` | `(basenode→Inner≈2.0, ...)` |
| 70 | `` Return type annotation on `emit_rootnode` `` | `` `emit_basenode` `` |
| 71 | `` Return type annotation on `bind_rootnode!` `` | `` `bind_basenode!` `` |
| 78 | `"...unsupported supplied-root combinations..."` | `"...unsupported supplied-basenode combinations..."` |
| 81 | `distinguished rootnode` | `distinguished basenode` |

### 5aa. `design/brief.md`

Apply the §3e prose renaming table throughout. Specific high-priority locations:

| Lines | Current | Change |
|-------|---------|--------|
| 308 | `### One rootnode per graph` | `### One basenode per graph` |
| 311 | `API names as \`rootnode\`.` | `API names as \`basenode\`.` |
| 380 | `## Root binding, descendant construction, and finalization` | `## Basenode binding, descendant construction, and finalization` |
| 389 | `### `bind_rootnode!`` | `### \`bind_basenode!\`` |
| 403 | `the root-node or root handle itself` | `the basenode or basenode handle itself` |
| 422 | `## Root binding and child-construction protocol` | `## Basenode binding and child-construction protocol` |
| 426 | `- \`bind_rootnode!\`` | `- \`bind_basenode!\`` |
| 430 | `` `bind_rootnode!` binds a parsed root node onto...`` | `` `bind_basenode!` binds a parsed basenode onto...`` |
| 436 | `### \`bind_rootnode!\`` | `### \`bind_basenode!\`` |
| 438–464 | All `bind_rootnode!`, `rootnode`, "root node" references | apply §3 renaming |
| 476 | `### Library-created root node` | `### Library-created basenode` |
| 479 | `creating the root node, the root-construction call is:` | `creating the basenode, the basenode-construction call is:` |
| 494–495 | `This root-construction call is used for rooted trees and rooted networks / alike. The root node still has no incoming edge.` | `This basenode-construction call is used for rooted trees and rooted networks alike. The basenode still has no incoming edge.` |
| 498 | `typically the root node or root handle itself.` | `typically the basenode or basenode handle itself.` |
| 1239–1240 | `- \`rootnode\`` and `- \`bind_rootnode!\`` in glossary | `- \`basenode\`` and `- \`bind_basenode!\`` |

All other occurrences of `rootnode`, `bind_rootnode!`, "root node" (project concept),
"supplied-root", "library-created-root", "root-binding", "root binding" in
`design/brief.md` should be updated per §3e.

### 5ab. `design/brief--user-stories.md`

| Lines | Current | Change |
|-------|---------|--------|
| 96 | `## User story 4: Library-created-root construction into custom node handles` | `## User story 4: Library-created-basenode construction into custom node handles` |
| 141 | `rootnode = asset.materialized` | `basenode = asset.materialized` |
| 144 | `## User story 5: Root binding onto a caller-supplied rootnode` | `## User story 5: Basenode binding onto a caller-supplied basenode` |
| 146–147 | "root graph object", "parsed root node", `rootnode` | apply §3 renaming |
| 161–170 | `function LineagesIO.bind_rootnode!(...` and body | rename to `bind_basenode!` |
| 187–190 | `rootnode = BoundNode(...)` through `asset.materialized === rootnode` | rename `rootnode` → `basenode` |
| 253 | `## User story 8: Multi-parent rooted-network construction` | keep — "rooted-network" is graph-type adjective |
| 255–256 | "rooted networks", "one \`rootnode\`" | keep "rooted networks"; rename `\`rootnode\`` → `\`basenode\`` |
| 303 | "root-binding surface" | "basenode-binding surface" |
| 310 | `load("posterior.trees", my_rootnode)` | `load("posterior.trees", my_basenode)` |
| 311 | error string: `The supplied \`rootnode\` load surface...` | `The supplied \`basenode\` load surface...` |

### 5ac. `design/brief--community-support-objectives.md`

| Lines | Current | Change |
|-------|---------|--------|
| 230 | `- one \`rootnode\` per graph` | `- one \`basenode\` per graph` |
| 323 | `- \`bind_rootnode!\` methods for supplied-root construction...` | `- \`bind_basenode!\` methods for supplied-basenode construction...` |
| 324 | `- \`add_child\` methods for library-created-root and descendant construction...` | `library-created-basenode and descendant construction...` |
| 353 | `- weaken the one-rootnode-per-graph contract` | `one-basenode-per-graph contract` |
| 363 | `- one \`rootnode\` per graph` | `- one \`basenode\` per graph` |
| 380 | `## Root binding, descendant construction, and finalization` | `## Basenode binding, descendant construction, and finalization` |
| 385–432 | All `bind_rootnode!`, `rootnode`, "root node" occurrences | apply §3 renaming |
| 529–530 | `exactly one \`rootnode\`...unrooted trees are treated as rooted at a distinguished node` | `exactly one \`basenode\`...` |
| 533 | `No multiple-root semantics are permitted.` | `No multiple-basenode semantics are permitted.` |
| 639–641 | `A rooted network still has one \`rootnode\`. Hybrid or reticulate interior nodes...not roots.` | `A rooted network still has one \`basenode\`. Hybrid or reticulate interior nodes...not basenodes.` |
| 745 | `- one \`rootnode\` per graph` | `- one \`basenode\` per graph` |
| 799 | `unrooted trees with a distinguished \`rootnode\`` | `unrooted trees with a distinguished \`basenode\`` |
| 808 | `rooted-network construction uses one \`rootnode\`...` | `...one \`basenode\`...` |
| 831 | `any assumption that rooted networks require multiple roots` | `...multiple basenodes` |
| 862–863 | `- \`rootnode\`` and `- \`bind_rootnode!\`` | `- \`basenode\`` and `- \`bind_basenode!\`` |

### 5ad. `.workflow-docs/runs/20260427--production01/02_tranches.md`

Apply §3 renaming throughout. Key changes:

| Lines | Current | Change |
|-------|---------|--------|
| 52–53 | `` `rootnode`, `bind_rootnode!` `` in vocabulary blocks | `` `basenode`, `bind_basenode!` `` |
| 320 | `` `bind_rootnode!`, single-parent `add_child` `` | `` `bind_basenode!`, single-parent `add_child` `` |
| 323 | `` `load(src, rootnode::NodeT)` `` | `` `load(src, basenode::NodeT)` `` |
| 325 | `root-binding validation` | `basenode-binding validation` |
| 339 | `` `test/core/root_binding.jl` `` | `` `test/core/basenode_binding.jl` `` |
| 348–349 | `supplied \`rootnode\`` and `load(src, rootnode)` | `supplied \`basenode\`` and `load(src, basenode)` |
| 355 | `Core user story 5: Root binding onto a caller-supplied rootnode` | `Basenode binding onto a caller-supplied basenode` |
| 391 | `supplied-root` | `supplied-basenode` |
| 409 | `metagraphsnext_supplied_root.jl` | `metagraphsnext_supplied_basenode.jl` |
| 468–469 | `one-\`rootnode\` semantics` | `one-\`basenode\` semantics` |
| 480 | `one-\`rootnode\` invariant` | `one-\`basenode\` invariant` |
| 492–493 | `one \`rootnode\`...rather than any multiple-root assumption` | `one \`basenode\`...rather than any multiple-basenode assumption` |
| 694 | `distinguished \`rootnode\`` | `distinguished \`basenode\`` |
| 721 | `distinguished \`rootnode\`` | `distinguished \`basenode\`` |

All vocabulary blocks in tasking-file headers (lines 42–54 of each tranche tasking file) that instruct to "write 'root node' in prose, but use `rootnode` for project-owned identifiers" must change to "write `basenode` in prose and code".

### 5ae. `.workflow-docs/runs/20260427--production01/03_tasking.md` and `03_tranche-0*--tasking.md`

Each tranche tasking file contains a vocabulary header block. Update:
- `rootnode`, `bind_rootnode!` → `basenode`, `bind_basenode!`
- "write 'root node' in prose, but use `rootnode`..." → "write `basenode` in both prose and code"
- "do not introduce proscribed alternates such as `root`, `root_node`..." → add `base_node`, `rootnode` to the proscribed list
- All `supplied-root`, `library-created-root`, `root-binding` → `supplied-basenode`, `library-created-basenode`, `basenode-binding`
- All `load(src, rootnode)` → `load(src, basenode)`
- File references to renamed test files

### 5af. `examples/src/phylonetworks_mwe01.jl`

| Line | Current | Change |
|------|---------|--------|
| 26 | `println("root node number: ", net.node[net.rooti].number)` | `println("basenode number: ", net.node[net.rooti].number)` |

### 5ag. `examples/src/phylonetworks_mwe02.jl`

| Line | Current | Change |
|------|---------|--------|
| 22 | `println("tree root node number: ", tree.node[tree.rooti].number)` | `println("tree basenode number: ", tree.node[tree.rooti].number)` |
| 39 | `println("supplied-target rooted-network path: ", network_path)` | keep — "rooted-network" is graph-type adjective |

### 5ah. `STYLE-vocabulary.md`

Already updated as of 2026-04-30. No further changes required in this run.

---

## 6. Execution order

Execute in this order to minimize forward-reference breakage:

1. **File renames** (`git mv`) — do all four renames in §4 first. This ensures subsequent edits target the correct filenames.
2. **`src/LineagesIO.jl`** — export rename.
3. **`src/construction.jl`** — struct, function, and variable renames. This is the most complex file; take care with the three `emit_rootnode` overloads.
4. **`src/fileio_integration.jl`** — type reference and error-string updates.
5. **`src/newick_format.jl`** — variable and error-string updates.
6. **`ext/MetaGraphsNextIO.jl`** — function renames and comment updates.
7. **`ext/PhyloNetworksIO.jl`** — function renames and local variable updates.
8. **Test files** — all files under `test/`, including the renamed ones.
9. **Documentation** — `README.md`, `docs/src/`.
10. **Design and workflow docs** — `design/`, `.workflow-docs/`.
11. **Status and other markdown** — `metagraphsnext-status.md`.
12. **Update `test/runtests.jl`** includes.

---

## 7. Verification

After all edits:

### 7a. Grep check — no residual project-owned `root` uses

```bash
git ls-files | xargs grep -In '\broot\b\|\brootnode\b\|bind_rootnode\|emit_rootnode\|RootBinding\|rootnodekey\|rootnode_handle\|rootnodedata\|build_root_node\|normalize_singleton_root\|root_is_leaf\|materialize_graph_root\|validate_and_find_root\|validate_multi_parent_root\|ROOT_BINDING\|RootBinding\|MissingRootBinding\|supplied-root\|library-created-root\|root-binding\|root binding' \
  --include='*.jl' --include='*.md' --include='*.toml' 2>/dev/null
```

Allowable survivors:
- `graph.rooti`, `graph.isrooted`, `checkroot!`, `RootMismatch` — PhyloNetworks API
- `"Root"` as string literal in Newick data assertions or in Newick file content
- `root cause` — idiomatic English
- `rooted`/`unrooted` as graph-type adjectives
- `dist_reroot.md` — PhyloNetworks path
- `STYLE-julia.md:1306` — "root `README.md`" (filesystem)
- STYLE-vocabulary.md — governance text (deliberately uses "root" in justification/proscription blocks)
- Workflow-doc history references that explicitly cite "root" as the old proscribed term

### 7b. Run the test suite

```julia
# From the project root
using Pkg
Pkg.test()
```

All tests must pass. No test should reference a renamed symbol by its old name.

### 7c. Check that `bind_basenode!` dispatches work

Confirm that `ext/MetaGraphsNextIO.jl` and `ext/PhyloNetworksIO.jl` each define
`LineagesIO.bind_basenode!` (not `bind_rootnode!`), and that `src/construction.jl`
calls `bind_basenode!` from within `emit_basenode`.

### 7d. Confirm public API export

```julia
using LineagesIO
@assert :bind_basenode! in names(LineagesIO)
@assert :bind_rootnode! ∉ names(LineagesIO)
```

### 7e. Spot-check docs build

```bash
julia --project=docs docs/make.jl
```

Confirm no broken references.

---

## 8. Notes and gotchas

- **`"Root"` string literals are data, not identifiers.** Do not change them in
  Newick fixture files or in test assertions that check node labels from Newick
  data. The distinction: if a string appears as a node label from a `.nwk` file,
  it is domain data. If a string names a project function, type, or variable, it
  must change.
- **The `:root` event symbol in test event tuples** (e.g., `(:root, 1, "Root", ...)`)
  IS a project-owned symbol — rename to `:basenode`. The `"Root"` label in the
  same tuple is Newick data — keep it.
- **`RootBindingLoadRequest` → `BasenodeLoadRequest`**: also rename the type
  parameter from `{RootNodeT}` to `{BasenodeT}` and the field from `.rootnode`
  to `.basenode`.
- **The `normalize_singleton_root!` call site** at `ext/PhyloNetworksIO.jl:703`
  must be updated to `normalize_singleton_basenode!` alongside the definition.
- **`graph.isrooted = true`** (PhyloNetworksIO.jl:707) — do NOT change; this is
  setting a PhyloNetworks.HybridNetwork field.
- **`build_root_node` is called from two places** in PhyloNetworksIO.jl (line 343
  in `build_graph_cursor` and implicitly via the returned cursor); rename both
  the definition and the call site.
