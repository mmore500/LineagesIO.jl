# MetaGraphsNextIO — Current Code Status

Audit date: 2026-04-29
Source files read: `ext/MetaGraphsNextIO.jl` (464 lines), `ext/MetaGraphsNextAbstractTreesIO.jl` (44 lines), all six `test/extensions/metagraphsnext_*.jl` files.

---

## Fulfilled

| # | What the code does | Location |
|---|-------------------|----------|
| 1 | Extension module `MetaGraphsNextIO` exists as a Julia package extension | `ext/MetaGraphsNextIO.jl:1` |
| 2 | Extension module `MetaGraphsNextAbstractTreesIO` exists as a Julia package extension | `ext/MetaGraphsNextAbstractTreesIO.jl:1` |
| 3 | `load(src, MetaGraph)` accepted — `validate_extension_load_target(::Type{<:MetaGraph})` returns nothing unconditionally | `ext/MetaGraphsNextIO.jl:270-272` |
| 4 | `load(src, MetaGraph{...})` accepted — `::Type{<:MetaGraph}` covers all parameterizations | `ext/MetaGraphsNextIO.jl:270` |
| 5 | Library-created path rejects multi-parent sources with an `ArgumentError` containing "multi-parent" | `ext/MetaGraphsNextIO.jl:274-287` |
| 6 | `default_metagraph()` returns a `MetaGraph` with `SimpleDiGraph{Int}`, `Symbol` labels, `Nothing` VertexData, `Union{Nothing,Float64}` EdgeData, weight function `ed -> ed === nothing ? 1.0 : ed`, default weight `1.0` | `ext/MetaGraphsNextIO.jl:115-125` |
| 7 | `validate_empty_metagraph` checks: directed (error "must be directed"), empty (error "must be empty"), Symbol label (error "must use `Symbol`") | `ext/MetaGraphsNextIO.jl:141-161` |
| 8 | `node_label(nodekey::StructureKeyType)::Symbol = Symbol(nodekey)` | `ext/MetaGraphsNextIO.jl:84` |
| 9 | `label_nodekey(label::Symbol)::StructureKeyType` via `parse(Int, String(label))` | `ext/MetaGraphsNextIO.jl:91` |
| 10 | `add_node_to_metagraph!` dispatches on `VertexData=Nothing`: calls `add_vertex!(graph, label)` without data | `ext/MetaGraphsNextIO.jl:170-181` |
| 11 | `add_node_to_metagraph!` dispatches on `VertexData<:NodeRowRef`: calls `add_vertex!(graph, label, nodedata)` | `ext/MetaGraphsNextIO.jl:183-194` |
| 12 | `add_edge_to_metagraph!` dispatches on `EdgeData=Nothing`: calls `add_edge!` without data | `ext/MetaGraphsNextIO.jl:203-216` |
| 13 | `add_edge_to_metagraph!` dispatches on `EdgeData=Union{Nothing,Float64}`: calls `add_edge!` with edgeweight | `ext/MetaGraphsNextIO.jl:218-232` |
| 14 | `add_edge_to_metagraph!` dispatches on `EdgeData<:Real`: coalesces `nothing` weight to `default_weight(graph)` | `ext/MetaGraphsNextIO.jl:234-248` |
| 15 | `add_edge_to_metagraph!` dispatches on `EdgeData<:EdgeRowRef`: calls `add_edge!` with edgedata rowref | `ext/MetaGraphsNextIO.jl:250-264` |
| 16 | `emit_basenode` override for `NodeTypeLoadRequest{<:MetaGraph}`: creates `default_metagraph()`, adds root, returns `MetaGraphsNextBuildCursor` | `ext/MetaGraphsNextIO.jl:307-316` |
| 17 | `bind_basenode!(graph::GraphT <: MetaGraph, ...)`: validates, adds root, returns `MetaGraphsNextBuildCursor{GraphT}` | `ext/MetaGraphsNextIO.jl:322-331` |
| 18 | `add_child` single-parent for `MetaGraphsNextBuildCursor{GraphT}`: adds node, adds edge, returns new cursor | `ext/MetaGraphsNextIO.jl:337-350` |
| 19 | `add_child` probe shim for `AbstractVector{<:MetaGraph}`: exists and throws a loud internal error if called | `ext/MetaGraphsNextIO.jl:364-377` |
| 20 | `add_child` multi-parent for `AbstractVector{MetaGraphsNextBuildCursor{GraphT}}`: adds node, iterates parents adding edges, returns cursor | `ext/MetaGraphsNextIO.jl:383-404` |
| 21 | Multi-parent `add_child` validates `length(parents) == length(edgeweights) == length(edgedata)` | `ext/MetaGraphsNextIO.jl:392-397` |
| 22 | `finalize_graph!(cursor::MetaGraphsNextBuildCursor)` returns `cursor.graph` | `ext/MetaGraphsNextIO.jl:410-412` |
| 23 | `validate_extension_load_target(::Type{<:MetaGraph}, graph_asset)`: rejects multi-parent source, passes single-parent | `ext/MetaGraphsNextIO.jl:274-287` |
| 24 | `validate_extension_load_target(graph::MetaGraph, ::LineageGraphAsset)`: calls `validate_empty_metagraph` | `ext/MetaGraphsNextIO.jl:289-295` |
| 25 | `MetaGraphsNextBuildCursor{GraphT}` struct with fields `graph::GraphT` and `nodekey::StructureKeyType` | `ext/MetaGraphsNextIO.jl:35-38` |
| 26 | `ConcreteMetaGraphsNextTreeView{GraphT,NodeTableT,EdgeTableT}` struct with fields `graph`, `nodekey`, `node_table`, `edge_table` | `ext/MetaGraphsNextIO.jl:55-64` |
| 27 | `MetaGraphsNextTreeView(asset::LineageGraphAsset{GraphT<:MetaGraph,...})` returns `ConcreteMetaGraphsNextTreeView` rooted at nodekey=1 | `ext/MetaGraphsNextIO.jl:421-440` |
| 28 | `MetaGraphsNextTreeView(graph, node_table, edge_table)` returns `ConcreteMetaGraphsNextTreeView` rooted at nodekey=1 | `ext/MetaGraphsNextIO.jl:442-462` |
| 29 | Both `MetaGraphsNextTreeView` constructors throw `ArgumentError` when `nv(graph) == 0` | `ext/MetaGraphsNextIO.jl:429-433`, `ext/MetaGraphsNextIO.jl:451-455` |
| 30 | `AbstractTrees.children` traverses `outneighbors` and returns `Vector{ViewT}` of child views | `ext/MetaGraphsNextAbstractTreesIO.jl:15-36` |
| 31 | `AbstractTrees.NodeType`, `AbstractTrees.nodetype`, `AbstractTrees.ChildIndexing`, `AbstractTrees.childtype`, `AbstractTrees.childrentype` all defined for `ConcreteMetaGraphsNextTreeView` | `ext/MetaGraphsNextAbstractTreesIO.jl:38-42` |
| 32 | Test: extension absent before MetaGraphsNext loaded; tables-only load works | `test/extensions/metagraphsnext_activation.jl:1-11` |
| 33 | Test: extension present after MetaGraphsNext loaded; `materialized isa MetaGraph`; nv=5, ne=4 | `test/extensions/metagraphsnext_activation.jl:13-33` |
| 34 | Test: parameterized type `typeof(asset.materialized)` accepted; nv=5, ne=4 | `test/extensions/metagraphsnext_activation.jl:28-32` |
| 35 | Test: library-created path; nv=5, ne=4; Symbol label round-trip for all 5 nodes | `test/extensions/metagraphsnext_simple_newick.jl:17-25` |
| 36 | Test: library-created path; child topology `1→[2,5]`, `2→[3,4]`, leaves empty | `test/extensions/metagraphsnext_simple_newick.jl:27-31` |
| 37 | Test: library-created path; edge weights via `Graphs.weights(graph)[i,j]` (Root→Inner≈2.0, Inner→A≈1.5, Inner→unnamed≈0.25, Root→C≈1.0 default) | `test/extensions/metagraphsnext_simple_newick.jl:34-37` |
| 38 | Test: supplied-instance Nothing/Nothing; nv=5, ne=4; `materialized === graph` | `test/extensions/metagraphsnext_supplied_root.jl:7-19` |
| 39 | Test: non-empty graph rejected; error contains "must be empty" | `test/extensions/metagraphsnext_supplied_root.jl:28-34` |
| 40 | Test: wrong Label type rejected; error contains "must use `Symbol`" | `test/extensions/metagraphsnext_supplied_root.jl:36-47` |
| 41 | Test: supplied-instance Float64 EdgeData; nv=5, ne=4; `graph[Symbol(1),Symbol(2)] ≈ 2.0` etc. | `test/extensions/metagraphsnext_supplied_root.jl:52-70` |
| 42 | Test: supplied-instance NodeRowRef/EdgeRowRef; nv=5; `node_property(...,:label)=="Root"`; `edge_property(...,:edgeweight)≈2.0` | `test/extensions/metagraphsnext_supplied_root.jl:71-91` |
| 43 | Test: multi-graph source rejected with error containing "exactly one graph" on supplied-instance path | `test/extensions/metagraphsnext_supplied_root.jl:22-26` |
| 44 | Test: library-created path rejects multi-parent source; error contains "multi-parent" | `test/extensions/metagraphsnext_network_rejection.jl:6-10` |
| 45 | Test: supplied-instance path accepts rooted network (`rooted_network_with_annotations.nwk`); nv=7, ne=7 | `test/extensions/metagraphsnext_network_rejection.jl:12-23` |
| 46 | Test: authoritative `node_table isa NodeTable`, `edge_table isa EdgeTable` retained after library-created load | `test/extensions/metagraphsnext_tables_after_load.jl:8-10` |
| 47 | Test: node annotations from authoritative table accessible by row index and column (`:posterior`) | `test/extensions/metagraphsnext_tables_after_load.jl:11-12`, `15` |
| 48 | Test: edge annotations from authoritative table accessible by row index and column (`:bootstrap`, `:phase`, `:edgeweight`) | `test/extensions/metagraphsnext_tables_after_load.jl:13-14`, `16` |
| 49 | Test: `MetaGraphsNextAbstractTreesIO` extension active; `AbstractTrees.children` returns correct child nodekeys `[2,5]` | `test/extensions/metagraphsnext_abstracttrees.jl:5`, `13-15` |
| 50 | Test: `PreOrderDFS` traversal produces nodekeys `[1,2,3,4,5]` in order | `test/extensions/metagraphsnext_abstracttrees.jl:17-19` |
| 51 | Test: `NodeType`, `ChildIndexing`, `nodetype`, `childtype` traits correct | `test/extensions/metagraphsnext_abstracttrees.jl:21-24` |

---

## Not Fulfilled

| # | What is absent | Where the gap is | Stipulation source | Stipulation text |
|---|---------------|-----------------|-------------------|-----------------|
| 1 | Return type annotation on `emit_basenode` | `ext/MetaGraphsNextIO.jl:307` — `function LineagesIO.emit_basenode(` has no `::ReturnType` | `STYLE-julia.md:578-580` | "All public and non-trivial functions must include explicit return type annotations. The return type is part of the function's contract and belongs at the point of definition." |
| 2 | Return type annotation on `bind_basenode!` | `ext/MetaGraphsNextIO.jl:322` — `function LineagesIO.bind_basenode!(` has no `::ReturnType` | `STYLE-julia.md:578-580` | "All public and non-trivial functions must include explicit return type annotations. The return type is part of the function's contract and belongs at the point of definition." |
| 3 | Return type annotation on `add_child` single-parent | `ext/MetaGraphsNextIO.jl:337` — `function LineagesIO.add_child(` has no `::ReturnType` | `STYLE-julia.md:578-580` | "All public and non-trivial functions must include explicit return type annotations. The return type is part of the function's contract and belongs at the point of definition." |
| 4 | Return type annotation on `add_child` probe shim | `ext/MetaGraphsNextIO.jl:364` — `function LineagesIO.add_child(` has no `::ReturnType` | `STYLE-julia.md:578-580` | "All public and non-trivial functions must include explicit return type annotations. The return type is part of the function's contract and belongs at the point of definition." |
| 5 | Return type annotation on `add_child` multi-parent | `ext/MetaGraphsNextIO.jl:383` — `function LineagesIO.add_child(` has no `::ReturnType` | `STYLE-julia.md:578-580` | "All public and non-trivial functions must include explicit return type annotations. The return type is part of the function's contract and belongs at the point of definition." |
| 6 | Return type annotation on `finalize_graph!` | `ext/MetaGraphsNextIO.jl:410` — `function LineagesIO.finalize_graph!(` has no `::ReturnType` | `STYLE-julia.md:578-580` | "All public and non-trivial functions must include explicit return type annotations. The return type is part of the function's contract and belongs at the point of definition." |
| 7 | Return type annotation on `MetaGraphsNextTreeView(asset)` | `ext/MetaGraphsNextIO.jl:421` — `function LineagesIO.MetaGraphsNextTreeView(` has no `::ReturnType` | `STYLE-julia.md:578-580` | "All public and non-trivial functions must include explicit return type annotations. The return type is part of the function's contract and belongs at the point of definition." |
| 8 | Return type annotation on `MetaGraphsNextTreeView(graph, node_table, edge_table)` | `ext/MetaGraphsNextIO.jl:442` — `function LineagesIO.MetaGraphsNextTreeView(` has no `::ReturnType` | `STYLE-julia.md:578-580` | "All public and non-trivial functions must include explicit return type annotations. The return type is part of the function's contract and belongs at the point of definition." |
| 9 | Test for non-directed graph rejected with error "must be directed" | Check is implemented at `ext/MetaGraphsNextIO.jl:142-147`; none of the six test files contains an undirected-graph rejection test | `.workflow-docs/runs/20260427--production01/03_tranche-03--tasking.md:393-400` (task 7) | "Verify that multi-graph sources and any other unsupported supplied-basenode combinations fail informatively rather than guessing." |
| 10 | Test for `graph[Symbol(n)]` returning `nothing` (VertexData=Nothing, library-created path) | `test/extensions/metagraphsnext_simple_newick.jl:1-38` and `test/extensions/metagraphsnext_activation.jl:1-33` contain no `graph[Symbol(n)]` assertion | `.workflow-docs/runs/20260427--production01/03_tranche-03--tasking.md:356-362` (task 5) | "Verify the actual contract boundary: the returned `materialized` type, MetaGraphsNext graph structure, stable mapping from `nodekey` to the extension-owned label wrapper, correct edge insertion, and continued direct access to `asset.node_table` and `asset.edge_table` after load." |
| 11 | Test for `MetaGraphsNextTreeView(graph, node_table, edge_table)` raw-components constructor | Constructor at `ext/MetaGraphsNextIO.jl:442-462`; `test/extensions/metagraphsnext_abstracttrees.jl:11` calls only `MetaGraphsNextTreeView(asset)` — three-argument form never called in any test file | `.workflow-docs/runs/20260427--production01/03_tranche-03--tasking.md:430-435` (task 9) | "verify the actual cross-package contract…Include at least one direct `children(...)` assertion in addition to traversal-level checks. If the wrapper claims `HasNodeType`, verify that the iteration element type and returned child shape honestly satisfy that trait." |
| 12 | Unrooted simple-Newick support with a distinguished basenode | No code in `ext/MetaGraphsNextIO.jl:1-464` or `ext/MetaGraphsNextAbstractTreesIO.jl:1-44` handles unrooted inputs; no unrooted fixture; no test file | `.workflow-docs/runs/20260427--production01/02_tranches.md:693-694` (Tranche 7 "What to build") | "any ratified unrooted simple-Newick `MetaGraphsNext.jl` path that still uses one distinguished `basenode`" |
| 13 | Table retention test after a network (multi-parent) load | `test/extensions/metagraphsnext_tables_after_load.jl:4` loads a tree fixture; `test/extensions/metagraphsnext_network_rejection.jl:18-23` loads the network fixture but asserts only `nv` and `ne` — no `node_table` or `edge_table` assertions after a network load exist in any test file | `.workflow-docs/runs/20260427--production01/02_tranches.md:695` and `710` (Tranche 7 "What to build" and "How to verify") | "continued authoritative-table retention after extension-based loads" / "Add and run `test/extensions/metagraphsnext_network_tables_after_load.jl`" |
