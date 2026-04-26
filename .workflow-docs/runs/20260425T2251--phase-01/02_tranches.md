---
date-created: 2026-04-25T00:00:00
version: 1.0
---

# LineagesIO.jl phase 1 — tranches

## Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

## Tranche sequence overview

| # | Title | Type | Blocked by |
|---|---|---|---|
| 1 | Protocol foundations and return types | AFK | — |
| 2 | Discovery pass and NamedTuple schema builder | AFK | 1 |
| 3 | Builder protocol orchestration | AFK | 1, 2 |
| 4 | Newick parser | AFK | 1, 2, 3 |
| 5 | FileIO adapter and view layer (Newick end-to-end) | AFK | 1, 2, 3, 4 |
| 6 | LineageNetwork parser and adapter registration | AFK | 1, 2, 3, 5 |
| 7 | LineageGraphML parser and adapter registration | AFK | 1, 2, 3, 5 |
| 8 | PhyloNetworksExt | AFK | 1, 2, 3, 4, 5, 6 |
| 9 | PhyloExt | AFK | 1, 2, 3, 4, 5 |
| 10 | Stabilization | AFK | all |

---

## Tranche 1: Protocol foundations and return types

**Type**: AFK
**Blocked by**: None — can start immediately

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line** before any planning, design, or
implementation work begins. Do not skim. Do not skip files. Do not assume that
documentation reflects the current state of the code, or that code reflects the
current state of the documentation — verify each independently. This obligation
must be passed forward into every downstream tasking document or delegated work
description derived from this tranche.

**Governance documents (all mandatory):**

- `STYLE-architecture.md` — ownership boundaries; deep-module design; anti-fix
  prohibition; green-state discipline
- `STYLE-docs.md` — documentation formatting standards
- `STYLE-git.md` — commit style and branching model
- `STYLE-julia.md` — functional design; naming; type annotations; mutation
  contract; testing; codebase curation rules; struct field concreteness rules
- `STYLE-makie.md` — Makie integration contracts (LineagesMakie interoperability
  constraints apply to how node types and return types are designed)
- `STYLE-upstream-contracts.md` — host-framework contract reading; divergence
  authorization; primary-source verification requirement
- `STYLE-verification.md` — what counts as a verification artifact; weak-proxy
  prohibition; field-level value verification requirement
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms;
  compound-word rules; canonical identifier table
- `STYLE-workflow-docs.md` — workflow document structure; revalidation rule;
  pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory):**

- `design/brief.md` (v2.0, 2026-04-25) — primary design authority; builder
  protocol signatures and dispatch levels; metadata architecture; return type
  field specifications; `finalize_graph!` hook contract; module design section
  for `add_child` protocol module, `LineageGraphAsset{NodeHandle}`, `LineageGraphStore{NodeHandle}`
- `design/brief--community-support-objectives.md` (v1.0, 2026-04-25) —
  extension architecture; `PhyloNetworksNodeHandle` and `PhyloNodeRef` stubs;
  finalization hook contract; resolved design questions
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — authoritative PRD;
  target outcome criteria; all user stories; tranche gates; testing and
  verification decisions

Neither design document is complete without the other. Read both before
implementing anything.

**Upstream primary sources (all mandatory, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

- `fileio.jl/` — FileIO backend contract; `DataFormat` and `File`/`Stream`
  types; `add_format` registration pattern; how private `load`/`save` are
  structured. Read now even though the FileIO adapter is built in Tranche 5:
  `LineageGraphAsset` and `LineageGraphStore` must be designed to work correctly with FileIO
  dispatch from the start.
- `AbstractTrees.jl/` — traversal traits and iteration interface; constraints
  on how node types must behave for LineagesMakie interoperability
- `Phylogenies.jl/` — minimal Julia core type reference; ecosystem context

**Codebase review (mandatory before touching any file):**

Read every currently tracked file in the repository line by line without
exception. Do not skip any file on the grounds that it seems irrelevant.

- `src/LineagesIO.jl`
- `test/runtests.jl`
- `test/Project.toml`
- `Project.toml`
- `README.md`
- All files in `docs/` (if any exist)
- All files in `examples/` (if any exist)
- All `STYLE-*.md` files
- `CONTRIBUTING.md`, `AUTHORS.md`, `LICENSE.md`

Do not assume any file accurately describes the current state of any other file.
Verify each independently. Flag any discrepancy before proceeding.

### What to build

This tranche establishes the architectural contracts on which every subsequent
tranche depends. Nothing else can proceed until these are in place and verified.

**1. Hard dependencies**

Add `FileIO` and `Tables` as hard dependencies using `Pkg.add`. Do not edit
`Project.toml` directly for this step. Do not add `[weakdeps]` or `[extensions]`
sections in this tranche — those are added in Tranches 8 and 9. Confirm both
packages appear under `[deps]` in `Project.toml` after `Pkg.add` completes.

**2. Module file structure**

Restructure `src/LineagesIO.jl` so the module file only contains the module
declaration, `using`/`import` statements, and `include` calls. No implementation
code in the module declaration file (per `STYLE-julia.md §8`). All implementation
lives in included files:

- `src/protocol.jl` — `add_child` generic function and `finalize_graph!` hook
- `src/types.jl` — `LineageGraphAsset{NodeHandle}` and `LineageGraphStore{NodeHandle}` structs

Subsequent tranches will add further `include` calls.

**3. `add_child` generic function**

Define and export `add_child` as a generic function in `src/protocol.jl`.
Declare the function only — do not provide any default method bodies. The library
calls it; users supply the methods. This function is the central protocol
boundary of the entire package.

Three overload signatures as specified in `design/brief.md §Builder protocol`
and `01_prd.md §add_child protocol module`. Argument names, types, and ordering
must match the PRD exactly:

```julia
# NodeHandle     = node handle type; dispatch target for user extensions
# EdgeUnit = edge length element type (unconstrained; Nothing for absent lengths)
# NodeRow         = row type of node_table, fixed by discovery pass
# EdgeRow        = row type of edge_table, fixed by discovery pass

# Network level — general case (baseline)
function add_child(
    :: AbstractVector{NodeHandle},                      # parents
    :: Int,                                         # node_idx
    :: AbstractString,                              # label
    :: AbstractVector{Union{EdgeUnit, Nothing}},  # edgelengths
    :: AbstractVector{EdgeRow},                          # edgedata
    :: NodeRow,                                           # nodedata
) :: NodeHandle where {NodeHandle, EdgeUnit, NodeRow, EdgeRow} end

# Single-parent level — entry-point node
function add_child(
    :: Nothing,                      # parent
    :: Int,                           # node_idx
    :: AbstractString,                # label
    :: Union{EdgeUnit, Nothing},     # edgelength
    :: Nothing,                       # edgedata
    :: NodeRow,                             # nodedata
) :: NodeHandle where {NodeHandle, EdgeUnit, NodeRow} end

# Single-parent level — subsequent nodes
function add_child(
    :: NodeHandle,                         # parent
    :: Int,                           # node_idx
    :: AbstractString,                # label
    :: Union{EdgeUnit, Nothing},     # edgelength
    :: EdgeRow,                            # edgedata
    :: NodeRow,                             # nodedata
) :: NodeHandle where {NodeHandle, EdgeUnit, NodeRow, EdgeRow} end
```

Write a complete docstring on `add_child` describing the protocol contract,
both dispatch levels, all parameter semantics, the `finalize_graph!` hook
relationship, and include a minimal usage example.

**4. `finalize_graph!` hook**

Define and export `finalize_graph!` in `src/protocol.jl` with a no-op default:

```julia
finalize_graph!(handle :: NodeHandle) :: NodeHandle where {NodeHandle} = handle
```

The default must return `handle` unchanged. This is the public protocol function;
extensions override it for their concrete node handle types. Write a complete
docstring describing the contract: called once per graph after the last
`add_child`, before `LineageGraphAsset` assembly; default is no-op; extensions override
for post-build cleanup.

**5. `LineageGraphAsset{NodeHandle}` struct**

Define and export `LineageGraphAsset{NodeHandle}` in `src/types.jl` as an immutable struct
with exactly the fields and types specified in `01_prd.md §Return types` and
`design/brief.md §LineageGraphAsset`:

```julia
struct LineageGraphAsset{NodeHandle}
    index                :: Int
    source_idx           :: Int
    collection_idx       :: Int
    collection_graph_idx :: Int
    collection_label     :: Union{String, Nothing}
    graph_label          :: Union{String, Nothing}
    node_table           :: <Tables.jl compliant — concretely typed via type param>
    edge_table           :: <Tables.jl compliant — concretely typed via type param>
    graph_rootnode       :: NodeHandle
    source_path          :: Union{String, Nothing}
end
```

`node_table` and `edge_table` must be concretely typed through additional type
parameters on the struct — not abstractly typed, not `Any`. Per
`STYLE-julia.md §1.12`, every field must be either concretely typed or
concretized through type parameters at instantiation. Choose a representation
that is Tables.jl-compliant and type-stable. Read the Tables.jl source to
confirm the chosen representation satisfies the interface.

Write a complete docstring.

**6. `LineageGraphStore{NodeHandle}` struct**

Define and export `LineageGraphStore{NodeHandle}` in `src/types.jl` with exactly the fields
specified in `01_prd.md §Return types`:

```julia
struct LineageGraphStore{NodeHandle}
    source_table     :: <Tables.jl compliant — concretely typed>
    collection_table :: <Tables.jl compliant — concretely typed>
    graph_table      :: <Tables.jl compliant — concretely typed>
    graphs           :: <lazy iterator of LineageGraphAsset{NodeHandle} — concretely typed>
end
```

Same type-stability and concreteness requirements as `LineageGraphAsset`. Write a
complete docstring.

**7. Test file scaffolding**

Add `test/test_protocol.jl` and `test/test_types.jl`. Include both from
`test/runtests.jl`. Each file must contain a named `@testset`. Tests must be
runnable now and passing.

Tests for `finalize_graph!`: no-op default must not error and must return the
input handle unchanged for an arbitrary test node type defined within the test.

Tests for `LineageGraphAsset` and `LineageGraphStore`: type stability via `@inferred` on
field access; correct parameterization; Tables.jl interface compliance via
`Tables.istable(...)`.

Aqua and JET checks must pass at tranche end.

### How to verify

**Manual:**

1. `using LineagesIO` in a Julia REPL loads without error.
2. `@doc LineagesIO.add_child` — complete docstring visible.
3. `@doc LineagesIO.finalize_graph!` — complete docstring visible.
4. Define a minimal `MyNode` type, extend `add_child`, construct a
   `LineageGraphAsset{MyNode}` manually; confirm no `@code_warntype` instability.
5. `Tables.istable(asset.node_table)` and `Tables.istable(asset.edge_table)`
   both return `true`.

**Automated:**

```
julia --project=test test/runtests.jl
```

All tests pass. `Aqua.test_all(LineagesIO)` reports no issues.
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no issues.

### Acceptance criteria

- [ ] Given `Pkg.add` is used to add `FileIO` and `Tables`, when `Project.toml`
  is inspected, then both packages appear under `[deps]` with no manual edits
  to `Project.toml` beyond what `Pkg.add` wrote.
- [ ] Given a user defines `LineagesIO.add_child(parent::Nothing, ...) :: MyNode`,
  when the method is called with `parent = nothing`, then Julia dispatches to the
  correct method without dynamic dispatch.
- [ ] Given `finalize_graph!(handle)` is called with no user-defined override,
  when it returns, then the returned value is identical to `handle` and no error
  is raised.
- [ ] Given `LineageGraphAsset{MyNode}` is constructed, when `@inferred` is applied to
  accessing `graph_rootnode`, then `MyNode` is inferred without instability.
- [ ] Given `Tables.istable(asset.node_table)`, when called, then `true` is
  returned.
- [ ] Given `Tables.istable(asset.edge_table)`, when called, then `true` is
  returned.
- [ ] Given `Aqua.test_all(LineagesIO)` is run, then no issues are reported.
- [ ] Given `JET.test_package(LineagesIO; target_defined_modules = true)` is
  run, then no issues are reported.
- [ ] Given a search for proscribed vocabulary terms (per `STYLE-vocabulary.md`)
  in all identifiers, field names, and type names added by this tranche, then
  no matches are found.

### User stories addressed

- User story 1: user can define and dispatch `add_child` via method extension
- User story 2: user can define the network-level `add_child` overload
- User story 3: compiler specializes pipeline on `NodeHandle` at compile time
- User story 19: `load` always returns `LineageGraphStore{NodeHandle}` (struct defined)
- User story 20: `LineageGraphStore` fields correctly named and typed
- User story 21: `LineageGraphAsset` fields correctly named and typed
- User story 22: `graph_rootnode :: NodeHandle` is the entry-point handle
- User story 23: `LineageGraphStore{NodeHandle}` and `LineageGraphAsset{NodeHandle}` are fully type-stable
- User story 44: `finalize_graph!` exported with no-op default
- User story 45: `finalize_graph!` contract established (called once per graph)
- User story 46: extensions can override `finalize_graph!` for their handle type

---

## Tranche 2: Discovery pass and NamedTuple schema builder

**Type**: AFK
**Blocked by**: Tranche 1

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line** before any planning or
implementation. Pass all mandates forward into any downstream tasking document.

**Governance documents (all mandatory):**

- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `CONTRIBUTING.md`

**Companion design documents (all mandatory):**

- `design/brief.md` — §Metadata architecture; §Discovery pass; §Level 1 — Node
  metadata; §Level 2 — Edge metadata
- `design/brief--community-support-objectives.md` — full document
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §Discovery pass and
  metadata tables (user stories 9–16); §Discovery pass module design; §Testing
  and verification decisions

**Upstream primary sources (mandatory):**

- `fileio.jl/` (line by line) — the table types produced here flow through
  FileIO dispatch; verify no impedance with FileIO's expected return shapes

**Codebase review (mandatory, line by line, before touching any file):**

Read all files added or modified by Tranche 1. Confirm the struct definitions
match the PRD. Do not assume comments or docstrings accurately reflect the code.
Confirm `Aqua.test_all` and `JET.test_package` pass before starting.

### What to build

Add `src/discovery.jl` included from `src/LineagesIO.jl`. This is an internal
module — nothing in it is exported. All three format parsers (Tranches 4, 6, 7)
will call into it.

**Discovery pass contract (authoritative: `design/brief.md §Metadata architecture`
and `01_prd.md §Discovery pass`):**

- Runs before any `add_child` calls, as a full pre-scan of the source.
- Collects every annotation key name present across all nodes and all edges.
- Every discovered key becomes a typed column — no overflow dictionaries anywhere.
- Column types are inferred from observed values; optional keys (absent on some
  records) produce `Union{T, Nothing}` columns; absent rows carry `nothing`.
- The node row type `NodeRow` and the edge row type `EdgeRow` are fixed `NamedTuple` types
  built from these schemas; they are stable for the entire load of a source.
- The edge schema always includes at minimum: `src_node_idx :: Int`,
  `dst_node_idx :: Int`, `edgelength :: Union{Float64, Nothing}`.

**What `src/discovery.jl` must provide:**

1. `build_schema(records)` — accepts a collection of annotation dicts (one per
   node or edge record), returns a `NamedTuple` type reflecting the promoted
   schema. Type-stable: the produced type is fully determined at compile time.

2. `build_row(schema_type, record_dict)` — accepts a schema type and an
   annotation dict for a single record, returns a `NamedTuple` value of the
   correct type with `nothing` for absent keys. Type-stable.

3. Format parsers may override inferred types for well-known keys (e.g.,
   `gamma :: Union{Float64, Nothing}` regardless of observed values). Provide
   a mechanism for passing type overrides to `build_schema`.

**Type inference rules:**

- All `String` values → `String`
- All numeric, no fractional part → `Int`; any fractional part or mixed
  int/float → `Float64`
- Mixed presence → `Union{T, Nothing}`
- Empty column (key declared but no values) → `Nothing`

**Add `test/test_discovery.jl`** covering:

- Single-type column inference (String, Int, Float64)
- `Union{T, Nothing}` promotion for optionally present keys
- Schema stability: same type produced regardless of row presentation order
- Row construction: absent key → `nothing` in the produced row
- Empty annotation collection → schema containing only the fixed edge columns
- Tables.jl compliance: `Tables.istable([row])` returns `true` for produced rows
- `@inferred` on `build_row` produces no type instability warning

### How to verify

**Manual:**

1. Construct a mock annotation dict collection in the REPL; call `build_schema`;
   confirm the produced `NamedTuple` type matches expectations.
2. `@inferred build_row(schema_type, dict)` — no instability.

**Automated:**

```
julia --project=test test/runtests.jl
```

All tests pass. Aqua and JET pass.

### Acceptance criteria

- [ ] Given annotation dicts where key `"bootstrap"` has `Float64` values on
  some records and is absent on others, when `build_schema` runs, then the
  produced row type has field `bootstrap :: Union{Float64, Nothing}`.
- [ ] Given the same annotation dict collection in two different row orders,
  when `build_schema` runs on each, then both produce identical `NamedTuple`
  types.
- [ ] Given a record dict with key `"gamma"` absent, when `build_row` runs,
  then `row.gamma === nothing`.
- [ ] Given an empty annotation dict collection, when `build_schema` runs, then
  the produced schema contains `src_node_idx :: Int`, `dst_node_idx :: Int`,
  and `edgelength :: Union{Float64, Nothing}` at minimum.
- [ ] Given `Tables.istable([build_row(schema, dict)])`, when called, then
  `true` is returned.
- [ ] Given `@inferred` applied to `build_row`, then no dynamic-dispatch warning
  is raised.
- [ ] Given Aqua and JET are run, then no issues are reported.
- [ ] Given a search for proscribed vocabulary terms in identifiers added by
  this tranche, then no matches are found.

### User stories addressed

- User story 9: discovery pass collects every annotation key from the source
- User story 10: every key promoted to typed column; no overflow dicts
- User story 11: optional keys produce `Union{T, Nothing}` columns
- User story 12: node row type `NodeRow` is a fixed `NamedTuple` type
- User story 13: edge row type `EdgeRow` is a fixed `NamedTuple` type
- User story 14: `nodedata :: NodeRow` gives typed access to node annotations
- User story 15: `edgedata :: EdgeRow` gives typed access to edge annotations
- User story 16: edge table always contains fixed columns plus format columns

---

## Tranche 3: Builder protocol orchestration

**Type**: AFK
**Blocked by**: Tranches 1, 2

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line**. Pass all mandates forward.

**Governance documents (all mandatory):**

- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `CONTRIBUTING.md`

**Companion design documents (all mandatory):**

- `design/brief.md` — §Builder protocol (Protocol determination; Semantics;
  Parse order); §Builder protocol orchestration module design;
  §finalize_graph! as protocol function (Implementation decision 3)
- `design/brief--community-support-objectives.md` — full document
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §Protocol
  determination and builder validation (user stories 6–8); §Builder protocol —
  method extension (user stories 1–3) and callback style (user stories 4–5);
  §Node index and label (user stories 17–18); §Builder protocol orchestration
  module design; §finalize_graph! protocol hook module design; §Implementation
  decisions 1–8

**Upstream primary sources (mandatory):**

- `fileio.jl/` (line by line) — confirm the orchestration interface is
  compatible with how the FileIO adapter will invoke it in Tranche 5

**Codebase review (mandatory, line by line, before touching any file):**

Read all files added or modified by Tranches 1 and 2. Do not assume any
description matches implementation — read each independently. Confirm Aqua and
JET pass before starting.

### What to build

Add `src/orchestration.jl` included from `src/LineagesIO.jl`. This layer sits
between format parsers and user builders. It has no knowledge of specific
formats — it works solely against the tier declaration received from parsers.

**Protocol tier routing:**

Receives a protocol tier declaration from the format parser before any
`add_child` call. Two tiers, as specified in `design/brief.md §Protocol
determination`:

- `:network` — general case; calls `add_child(parents::AbstractVector{NodeHandle}, ...)`
- `:single_parent` — restricted case; calls `add_child(parent::Nothing/NodeHandle, ...)`

The tier is determined once, before any `add_child` call is made, and is fixed
for the duration of the load. Per-call dispatch based on `length(parents)` at
call time is explicitly rejected by the design.

**Builder validation gate:**

Before the first `add_child` call, validate builder compatibility with the
declared tier:

- `:network` tier + builder with only single-parent overloads → raise
  `ArgumentError` with an informative message naming the builder type and the
  declared tier. This must happen before any parse work.
- `:single_parent` tier → call only single-parent methods; no error if
  network-level methods are also defined.
- Explicit `builder` kwarg present → validate the callback's signature instead.

**`builder` kwarg precedence:**

An explicit `builder` keyword argument always takes precedence over any extended
`LineagesIO.add_child` methods. When present, the orchestration layer calls the
callback directly.

**`node_idx` management:**

- 1-based sequential integer, assigned by the orchestration layer.
- Resets to 1 at the start of each new graph within a source load.
- The parser does not assign `node_idx`; the orchestration layer does.

**Node label passthrough:**

The orchestration layer passes `label` through to `add_child` unchanged.
Parsers supply `""` for absent labels. No disambiguation is performed in
the orchestration layer. `node_idx` is the unique identifier; all joins
use `node_idx`.

**`finalize_graph!` invocation:**

Called exactly once per graph, after the last `add_child` call for that graph,
and before `LineageGraphAsset` is assembled. The default no-op returns silently;
extension overrides are dispatched through standard Julia multiple dispatch.

**`LineageGraphAsset` assembly:**

After `finalize_graph!` returns, assemble the `LineageGraphAsset{NodeHandle}` from the
collected node table rows, edge table rows, index coordinates, labels, and the
`graph_rootnode` handle returned by the first `add_child` call.

**Add `test/test_orchestration.jl`** covering:

- Error raised at load time (before any parse work) for incompatible builder
- `builder` kwarg takes precedence over extended methods
- `node_idx` is 1-based and sequential per graph
- `node_idx` resets to 1 for each new graph in a multi-graph source
- Empty label → `""` passed through unchanged
- `finalize_graph!` called after last `add_child`, before `LineageGraphAsset` assembly
- `LineageGraphAsset` fields correctly populated after assembly

### How to verify

**Manual:**

1. Define a builder with only single-parent overloads; attempt to use it with
   a `:network` format declaration; confirm `ArgumentError` is raised before
   any parse work begins, with message identifying the mismatch.
2. Define both extended methods and pass `builder` kwarg; confirm kwarg wins.
3. Run a mock parse through the orchestration layer; inspect the assembled
   `LineageGraphAsset` field by field.

**Automated:**

```
julia --project=test test/runtests.jl
```

All tests pass. Aqua and JET pass.

### Acceptance criteria

- [ ] Given a `:network` format declaration and a builder with only
  single-parent overloads, when `load` is called, then `ArgumentError` is
  raised before any `add_child` call is made, with a message identifying the
  incompatibility.
- [ ] Given both extended `LineagesIO.add_child` methods and a `builder` kwarg
  in the same `load` call, when `add_child` calls are emitted, then the
  `builder` callback is invoked, not the extended methods.
- [ ] Given a graph with 5 nodes, when `node_idx` values are assigned, then
  they are 1, 2, 3, 4, 5 in pre-order assignment sequence.
- [ ] Given a second graph in a multi-graph source, when `node_idx` assignment
  begins for that graph, then it restarts at 1.
- [ ] Given a source node with an empty label, when the orchestration layer
  processes it, then the resulting node table entry has label `""`.
- [ ] Given a complete single-graph parse, when the last `add_child` returns,
  then `finalize_graph!` is called exactly once before `LineageGraphAsset` is assembled.
- [ ] Given an extension that overrides `finalize_graph!` for `MyHandle`, when
  a graph with `NodeHandle = MyHandle` is loaded, then the extension override is
  invoked.
- [ ] Given Aqua and JET are run, then no issues are reported.

### User stories addressed

- User story 1: builder dispatched via standard Julia multiple dispatch
- User story 2: network-level `add_child` invoked for `:network` format tier
- User story 3: compiler specializes pipeline on `NodeHandle` at compile time
- User story 4: `builder` callback invoked when provided
- User story 5: `builder` kwarg takes precedence over extended methods
- User story 6: protocol tier determined once before any `add_child` call
- User story 7: incompatible builder raises informative error at load time
- User story 8: `:single_parent` format with network-level builder calls vector
  overload with `parents = []` (root) or `parents = [parent]` (others)
- User story 17: `node_idx` is 1-based sequential integer assigned by library
- User story 18: parser supplies `""` for absent labels; orchestration passes labels through unchanged
- User story 44: `finalize_graph!` invoked after last `add_child` per graph
- User story 45: invoked before `LineageGraphAsset` is assembled
- User story 46: extension overrides dispatched correctly

---

## Tranche 4: Newick parser

**Type**: AFK
**Blocked by**: Tranches 1, 2, 3

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line**. Pass all mandates forward.

**Governance documents (all mandatory):**

- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `CONTRIBUTING.md`

**Companion design documents (all mandatory):**

- `design/brief.md` — §Parsing layer; §Builder protocol (Parse order); §Format
  support — Phase 1; §Newick submodule module design
- `design/brief--community-support-objectives.md` — §Phylo.jl parse approach
  (token-based recursive descent; NHX metadata; Newick grammar)
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §Newick format
  (user stories 28–31); §Testing and verification decisions — Newick parser;
  §Error handling (user stories 60–61)

**Upstream primary sources (all mandatory, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read all three sources line by line before writing a single line of
implementation. Understand where they agree and diverge. Any design decision
that diverges from established patterns in these sources must be flagged in a
code comment explaining why.

- `NewickTree.jl/` — stack-based Julia Newick parser; tokenization strategy;
  traversal approach; multi-tree file handling; label and edge-length parsing
- `DendroPy/` — Python reference for Newick parsing architecture; builder
  pattern design; tokenizer design; how the builder is decoupled from the parser
- `Phylo.jl/` — combinator-based Julia Newick parser using `Tokenize.jl`;
  NHX/beast `[&key=value]` metacomment parsing via `parsedict`; bootstrap as
  internal node number before first branch; `parsenewick`, `parsenewick!`
  structure

**Codebase review (mandatory, line by line, before touching any file):**

Read all files added or modified by Tranches 1, 2, and 3. Confirm Aqua and JET
pass before starting.

### What to build

Add `src/parsers/Newick.jl` included from `src/LineagesIO.jl`. This submodule
is internal — users access it through the FileIO adapter (Tranche 5), not
directly.

**Protocol declaration:**

`format"Newick"` declares `:single_parent` protocol to the orchestration layer
before the discovery pass begins.

**Discovery pass:**

Before any `add_child` calls, scan the entire source (all trees in a multi-tree
file). Use the shared schema builder from `src/discovery.jl`:

- Collect all node annotation key names (e.g., `bootstrap`, NHX keys)
- Build node row type `NodeRow`
- Collect all edge annotation key names; always include `edgelength`
- Build edge row type `EdgeRow` with at minimum `src_node_idx`, `dst_node_idx`,
  `edgelength :: Union{Float64, Nothing}`

**Parsing:**

After the discovery pass, parse the source. Emit `add_child` calls via the
orchestration layer in pre-order (top-down) traversal. At every `add_child`
call, all ancestor nodes have already been created and their handles are in
scope.

Required support:

- Edge lengths (`:length` after node name or closing parenthesis)
- Internal node labels (name before `:` or after `)`)
- Multi-tree files (multiple trees separated by `;`)
- Empty/absent labels (parser passes `""` to orchestration layer; label is unchanged)
- Bootstrap values as internal node annotations (number at internal node
  position, as per `Phylo.jl` convention)

**Source-location tracking:**

Track file name and line/character offset during parsing. Include this
information in all parse error messages.

**Error handling:**

- Malformed parentheses → informative error with source location
- Unsupported constructs → informative error naming the construct and location

**Test fixtures:**

Add test fixture files under `test/fixtures/newick/`:

- `simple.nwk` — basic tree with edge lengths
- `internal_labels.nwk` — tree with internal node labels
- `multitree.nwk` — file with three or more trees
- `empty_labels.nwk` — tree with at least two nodes having empty labels
- `bootstrap.nwk` — tree with bootstrap values as internal node annotations

**Add `test/test_newick.jl`** covering all tests specified in `01_prd.md
§Testing and verification decisions — Newick parser`. Tests must verify
field-level values, not merely that parsing succeeds:

- Simple tree: node count, each leaf label, each edge length verified
  individually against fixture
- Internal labels: internal node labels present in node table rows
- Multi-tree: correct count of `LineageGraphAsset` values; each tree's node count
  correct
- Empty labels: node table entries have `label == ""`; join works on `node_idx`
- Bootstrap: `nodedata.bootstrap` contains the correct value at the `add_child`
  call site; value present in node table

### How to verify

**Manual:**

1. Invoke the Newick parser directly through the orchestration layer against
   `test/fixtures/newick/simple.nwk`; confirm `LineageGraphAsset` fields match fixture.
2. Inspect `edge_table` on the result; confirm `edgelength` values match fixture.

*(FileIO adapter not yet present; test through the parser's internal API.)*

**Automated:**

```
julia --project=test test/runtests.jl
```

All tests pass. Aqua and JET pass.

### Acceptance criteria

- [ ] Given a Newick file with edge lengths, when parsed, then each `add_child`
  call receives the correct `edgelength` value matching the fixture file.
- [ ] Given a Newick file with internal node labels, when parsed, then internal
  labels appear in the node table rows with correct values.
- [ ] Given a multi-tree Newick file with 3 trees, when parsed, then exactly 3
  `LineageGraphAsset` values are produced.
- [ ] Given a node with an empty label, when processed by the orchestration
  layer, then the node table entry has label `""`.
- [ ] Given a Newick file with bootstrap value `95.0` on an internal node, when
  parsed, then `nodedata.bootstrap === 95.0` at the corresponding `add_child`
  call.
- [ ] Given a non-root node's `add_child` call, when `parent` is inspected,
  then it is the handle returned by the `add_child` call for its direct ancestor
  (pre-order invariant).
- [ ] Given a malformed Newick file, when parsed, then an error is raised with
  the source file name in the message.
- [ ] Given Aqua and JET are run, then no issues are reported.

### User stories addressed

- User story 28: `format"Newick"` correctly parses standard Newick notation
- User story 29: Newick parser declares single-parent protocol
- User story 30: Newick parser performs discovery pass and produces schemas
- User story 31: `add_child` called in pre-order traversal
- User story 60: parse errors include source location
- User story 61: unsupported constructs raise informative errors

---

## Tranche 5: FileIO adapter and view layer (Newick end-to-end)

**Type**: AFK
**Blocked by**: Tranches 1, 2, 3, 4

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line**. Pass all mandates forward.

**Governance documents (all mandatory):**

- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md` — critical for this tranche; FileIO contract
  must be verified against the upstream source, not assumed from summaries
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `CONTRIBUTING.md`

**Companion design documents (all mandatory):**

- `design/brief.md` — §FileIO contract constraints; §FileIO adapter layer;
  §Convenience wrappers; §Lazy access design; §Return types — Convenience
  wrappers table; §Registration readiness; §Detection policy
- `design/brief--community-support-objectives.md` — §load calling convention
  for both extensions (PhyloNetworks and Phylo sections)
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §FileIO adapter
  (user stories 39–43); §Convenience wrappers (user stories 24–26); §Lazy
  iteration (user story 27); §Return types (user stories 19–26); §Error handling
  (user stories 62–64); §FileIO adapter module design; §Implementation decision 7
  (GraphML policy)

**Upstream primary sources (all mandatory):**

- `fileio.jl/` — read the **entire** FileIO source line by line before writing
  a single line of the adapter: implementing a backend; the private `load`/`save`
  function contract and how they are named inside the module; how
  `File{format"..."}(path)` and `Stream{fmt}(io)` are typed and dispatched; how
  `add_format` registers a format with magic bytes, extensions, and library
  references; how FileIO dispatches to backend `load`; magic-byte detection
  mechanisms; the `DataFormat` type. The adapter design must be verified against
  the actual FileIO source. Do not rely on documentation summaries or memory.

**Codebase review (mandatory, line by line, before touching any file):**

Read all files added or modified by Tranches 1–4. Do not assume any description
matches the code. Confirm Aqua and JET pass before starting.

### What to build

This tranche delivers the first complete end-to-end path: a Newick file on disk
→ `LineageGraphStore{NodeHandle}`. Tranches 6 and 7 extend the adapter to additional formats
without changing its core structure. Design the adapter's dispatch architecture
to be extension-friendly from the start.

Add `src/fileio.jl` and `src/view.jl`, both included from `src/LineagesIO.jl`.

**FileIO adapter (`src/fileio.jl`):**

Implement private `load` and `save` inside the `LineagesIO` module following the
FileIO backend contract exactly. Do not extend `FileIO.load` or `FileIO.save`
directly.

Supported for this tranche (Newick only):

- Format auto-detection: `.nwk`, `.newick`, `.tre` → `format"Newick"`
- Explicit format override: `load(File{format"Newick"}("file.txt"), MyNode)`
- Stream-based I/O: `load(Stream{format"Newick"}(io), MyNode)`
- No-`NodeHandle` call: `load("file.nwk")` returns `LineageGraphStore` with tables only,
  no builder invoked
- Error on ambiguous format (unmapped extension, no explicit override):
  `ArgumentError` requesting explicit override

`save` is a stub that raises `"save not yet implemented for this format"` —
do not leave it unimplemented in a way that would cause Aqua method-existence
failures.

The adapter must be designed so Tranches 6 and 7 can register additional
formats by adding dispatch cases without modifying the core routing logic.
Design for `add_format` registration readiness: use the same stable format
identifiers, extension strings, and detection approach that `add_format`
would use, even though registration itself is out of scope.

**View layer (`src/view.jl`):**

Export and implement:

- `loadfirst(src, ...)` — returns the first `LineageGraphAsset`; does not error if
  source contains multiple graphs
- `loadone(src, ...)` — returns a single `LineageGraphAsset`; raises informative
  `ArgumentError` if source contains zero or more than one graph, naming the
  actual count
- Multi-source `load([f1, f2, ...], ...)` — loads multiple sources; each
  `LineageGraphAsset` carries `source_idx` identifying its origin file

`LineageGraphStore.graphs` is declared as a lazy iterator in Tranche 1. Ensure the
concrete iterator type assigned during `LineageGraphAsset` assembly is correctly
iterable and non-materializing.

Write complete docstrings for `load`, `loadfirst`, `loadone`.

**Add `test/test_fileio.jl`** and **`test/test_view.jl`** covering all tests
specified in `01_prd.md §Testing and verification decisions — FileIO adapter`.
All tests must verify field-level values:

- Auto-detection: `.nwk` → Newick, correct `LineageGraphAsset` fields
- Explicit override: `File{format"Newick"}` loads correctly
- Stream I/O: `Stream{format"Newick"}` loads correctly
- Ambiguous extension: `ArgumentError` raised
- `loadfirst`: returns first `LineageGraphAsset` from multi-tree without error
- `loadone`: returns single `LineageGraphAsset` from single-tree file
- `loadone`: `ArgumentError` for multi-tree (more than one graph)
- `loadone`: `ArgumentError` for empty source (zero graphs)
- Multi-source: two files, `source_idx` values are 1 and 2 respectively
- Lazy iteration: `LineageGraphStore.graphs` iteration yields `LineageGraphAsset{NodeHandle}` values

### How to verify

**Manual:**

1. `using LineagesIO`
2. Define `MyNode` with `add_child` extensions.
3. `store = load("test/fixtures/newick/simple.nwk", MyNode)` — returns
   `LineageGraphStore{MyNode}`.
4. `asset = loadone("test/fixtures/newick/simple.nwk", MyNode)` — returns
   `LineageGraphAsset{MyNode}`.
5. `asset.graph_rootnode isa MyNode` — `true`.
6. `Tables.istable(asset.node_table)` — `true`.
7. `load(File{format"Newick"}("test/fixtures/newick/simple.nwk"), MyNode)` —
   explicit override works.
8. `open("test/fixtures/newick/simple.nwk") do io; load(Stream{format"Newick"}(io), MyNode); end`
   — stream I/O works.

**Automated:**

```
julia --project=test test/runtests.jl
```

All tests pass. Aqua and JET pass.

### Acceptance criteria

- [ ] Given `load("file.nwk", MyNode)`, when called, then a `LineageGraphStore{MyNode}`
  is returned.
- [ ] Given `load(File{format"Newick"}("file.txt"), MyNode)`, when called, then
  parsing succeeds and returns `LineageGraphStore{MyNode}`.
- [ ] Given `load(Stream{format"Newick"}(io), MyNode)`, when called, then
  parsing succeeds.
- [ ] Given a file with an unmapped extension and no explicit override, when
  `load` is called, then `ArgumentError` is raised requesting explicit format
  override.
- [ ] Given `loadone` on a single-tree file, when called, then a single
  `LineageGraphAsset` is returned with no error.
- [ ] Given `loadone` on a multi-tree file, when called, then `ArgumentError`
  is raised naming the graph count.
- [ ] Given `loadone` on an empty source, when called, then `ArgumentError` is
  raised.
- [ ] Given `loadfirst` on a multi-tree file, when called, then the first
  `LineageGraphAsset` is returned without error.
- [ ] Given `load([f1, f2], MyNode)`, when called, then `LineageGraphAsset` values
  from `f1` have `source_idx == 1` and those from `f2` have `source_idx == 2`.
- [ ] Given `LineageGraphStore.graphs` iteration, when consumed lazily, then each
  element is a `LineageGraphAsset{NodeHandle}` and the full collection is not materialized
  until `collect` is called.
- [ ] Given Aqua and JET are run, then no issues are reported.

### User stories addressed

- User story 19: `load` always returns `LineageGraphStore{NodeHandle}`
- User story 24: `loadfirst` returns first `LineageGraphAsset`; no error on multiple
- User story 25: `loadone` returns single `LineageGraphAsset`; errors if count ≠ 1
- User story 26: `load([...], ...)` with `source_idx` distinguishing origins
- User story 27: `LineageGraphStore.graphs` is a lazy iterator
- User story 39: `load` and `save` are private methods inside `LineagesIO`
- User story 40: format auto-detection for unambiguous extensions
- User story 41: explicit format override works
- User story 42: stream-based I/O works
- User story 43: designed to support `add_format` registration
- User story 62: ambiguous format raises informative error
- User story 64: `loadone` raises informative error for wrong count

---

## Tranche 6: LineageNetwork parser and adapter registration

**Type**: AFK
**Blocked by**: Tranches 1, 2, 3, 5

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line**. Pass all mandates forward.

**Governance documents (all mandatory):**

- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `CONTRIBUTING.md`

**Companion design documents (all mandatory):**

- `design/brief.md` — §LineageNetwork submodule module design; §Parsing layer
  format table; §Implementation decision 4 (per-edge metadata at `add_child`
  call time); §Builder protocol (network level)
- `design/brief--community-support-objectives.md` — §PhyloNetworks.jl: all
  subsections; parse approach; `parsenewick_edgedata!` behavior; hybrid node
  deduplication; gamma on the third colon field; `synchronizepartnersdata!`;
  metadata flow table
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §LineageNetwork
  format (user stories 32–35); §Implementation decision 4; §Testing and
  verification decisions — LineageNetwork parser

**Upstream primary sources (all mandatory, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read both sources line by line before implementing:

- `PhyloNetworks.jl/` — complete relevant source: `readnewick`,
  `parsenewick_edgedata!`, `parsenewick_hybridnode!`, `synchronizepartnersdata!`,
  `readnewick_nodename`, `readmultinewick`; the `#H1`-style hybrid node notation;
  how gamma is extracted from the third colon field (`:length:support:gamma`);
  how the parser deduplicates hybrid nodes (first occurrence creates, second
  merges); the `HybridNetwork`, `Node`, `Edge` type field contracts. This source
  is mandatory for understanding the format semantics, not just the extension API.
- `DendroPy/` — tokenizer design; how the builder is decoupled from the parser;
  contrast with the PhyloNetworks single-pass approach

**Codebase review (mandatory, line by line, before touching any file):**

Read all files added or modified by Tranches 1–5. Do not assume any file is
current. Confirm Aqua and JET pass before starting.

### What to build

Add `src/parsers/LineageNetwork.jl` included from `src/LineagesIO.jl`. Register
`format"LineageNetwork"` in `src/fileio.jl` — modify the existing adapter to
add dispatch for the new format without changing its core routing logic.

**Protocol declaration:**

`format"LineageNetwork"` declares `:network` (general) protocol to the
orchestration layer before the discovery pass begins.

**Discovery pass:**

Scan the entire source using `src/discovery.jl`. Always include in the edge
schema: `edgelength :: Union{Float64, Nothing}`, `gamma :: Union{Float64,
Nothing}`, `support :: Union{Float64, Nothing}`. Gamma values are extracted
from the third colon field (`:length:support:gamma`) during the discovery scan
so they are available in `EdgeRow` before any `add_child` calls.

**Parsing:**

Extended Newick with `#H1`-style hybrid markers. After the discovery pass:

- Identify hybrid nodes by `#` prefix in node names
- Deduplicate hybrid nodes: first occurrence creates the node and its handle;
  subsequent occurrences add parent edges to that same handle using the
  `parents` vector
- For each hybrid node with `n` parent edges, call
  `add_child(parents, node_idx, label, edgelengths, edgedata, nodedata)` with
  `parents`, `edgelengths`, `edgedata` as parallel vectors of length `n`
- `edgedata[i].gamma` must contain the gamma value for the edge from `parents[i]`
  to the hybrid node, available directly at the `add_child` call site — no
  two-phase pass is required or permitted
- For tree nodes (single parent): single-element vectors
- For entry-point root node: empty vectors for all three parallel arguments

**Adapter registration:**

Extend `src/fileio.jl` to dispatch `format"LineageNetwork"` to this parser.
Choose conservative, unambiguous file extensions (e.g., `.lnw`) that cannot
conflict with generic Newick. Document the extension choices.

**Test fixtures under `test/fixtures/lineagenetwork/`:**

- `simple_tree.lnw` — extended Newick with no hybrid nodes
- `hybrid.lnw` — network with at least one hybrid node with known gamma values

**Add `test/test_lineagenetwork.jl`** — all tests must verify field-level values:

- Tree-shaped source (no hybrid nodes): correct node count, edge count, edge
  lengths; single-element `parents` vectors throughout
- Network with hybrid node: `length(parents) == 2` at the hybrid `add_child`
  call; `edgedata[1].gamma` and `edgedata[2].gamma` match fixture values exactly
- Gamma available without any post-parse pass (verify at call time, not from
  the assembled edge table)
- Protocol declared as `:network` before any `add_child` call

### How to verify

**Manual:**

1. `load("test/fixtures/lineagenetwork/hybrid.lnw", MyNode)` returns
   `LineageGraphStore{MyNode}`.
2. Inspect the assembled `edge_table`; confirm `gamma` column is present and
   populated with fixture values.
3. Confirm `add_child` was called with `length(parents) == 2` for the hybrid
   node.

**Automated:**

```
julia --project=test test/runtests.jl
```

All tests pass. Aqua and JET pass.

### Acceptance criteria

- [ ] Given a LineageNetwork file with no hybrid nodes, when parsed, then all
  `add_child` calls have single-element `parents` vectors (tree behaviour).
- [ ] Given a LineageNetwork file with a hybrid node with gamma values `0.3`
  and `0.7`, when parsed, then `add_child` is called with `length(parents) == 2`
  and `edgedata[i].gamma` values match the fixture exactly.
- [ ] Given the gamma values in `edgedata` at `add_child` call time, then they
  are the final values — no second pass is required or performed.
- [ ] Given `format"LineageNetwork"` is invoked, when the protocol tier is
  declared, then it is `:network`, declared before the discovery pass begins.
- [ ] Given Aqua and JET are run, then no issues are reported.

### User stories addressed

- User story 32: `format"LineageNetwork"` correctly parses extended Newick with
  hybrid notation
- User story 33: LineageNetwork parser declares general (network) protocol
- User story 34: hybrid nodes threaded through `add_child(parents::AbstractVector, ...)`
- User story 35: gamma available in `edgedata[i].gamma` at `add_child` call site

---

## Tranche 7: LineageGraphML parser and adapter registration

**Type**: AFK
**Blocked by**: Tranches 1, 2, 3, 5

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line**. Pass all mandates forward.

**Governance documents (all mandatory):**

- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `CONTRIBUTING.md`

**Companion design documents (all mandatory):**

- `design/brief.md` — §LineageGraphML submodule module design; §GraphML policy;
  §Detection policy; §Ecosystem and interface constraints (GraphIO context)
- `design/brief--community-support-objectives.md` — full document
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §LineageGraphML
  format (user stories 36–38); §Implementation decision 7 (GraphML policy);
  §Testing and verification decisions — LineageGraphML parser

**Upstream primary sources (mandatory):**

The phylogeny-specific GraphML profile is project-owned; there is no single
external primary source. Before implementing:

- `fileio.jl/` (line by line) — confirm how the adapter registers this format
  and that the detection policy (no auto-detect for `.graphml`) is correctly
  implementable with the existing adapter architecture
- Inspect all existing `.graphml` files in `examples/` and `test/` (if any
  exist) — these are authoritative format specimens
- If no fixture files exist, `design/brief.md` is the sole format authority
- Review the GraphML XML Schema specification
  (`http://graphml.graphdrawing.org/specification.html`) for base format
  structure: `<graphml>`, `<graph>`, `<node>`, `<edge>`, `<key>`, `<data>`
  element semantics. This is context, not implementation authority — the
  project-specific profile governs.

**Codebase review (mandatory, line by line, before touching any file):**

Read all files added or modified by Tranches 1–5. Read all existing `.graphml`
files in the project. Do not assume any file is current. Confirm Aqua and JET
pass before starting.

### What to build

Add `src/parsers/LineageGraphML.jl` included from `src/LineagesIO.jl`. Extend
`src/fileio.jl` to register `format"LineageGraphML"`.

**Protocol declaration:**

`format"LineageGraphML"` declares `:single_parent` protocol before any parsing
begins.

**Discovery pass:**

Scan `<key>` element declarations and all `<data>` elements on nodes and edges.
Build `NodeRow` and `EdgeRow` from the promoted attribute schema via `src/discovery.jl`.

**Parsing:**

Parse the phylogeny-specific GraphML profile. After the discovery pass, emit
`add_child` calls in pre-order traversal.

**Detection policy (mandatory, non-negotiable):**

- `.lineagegraphml` → auto-detects as `format"LineageGraphML"`
- `.graphml` → **does not auto-detect** under any circumstances
- A `.graphml` file passed to `load` without explicit format override must raise
  an `ArgumentError` explaining that generic `.graphml` is ambiguous and explicit
  format override is required (`File{format"LineageGraphML"}(...)`)
- Explicit `File{format"LineageGraphML"}("file.graphml")` works correctly

**Adapter registration:**

Extend `src/fileio.jl` with `format"LineageGraphML"` dispatch.

**Test fixtures under `test/fixtures/lineagegraphml/`:**

- `simple.lineagegraphml` — basic tree with node labels and edge lengths
- `attributes.lineagegraphml` — tree with multiple custom `<key>`-declared
  attributes to test column promotion

**Add `test/test_lineagegraphml.jl`** — all tests must verify field-level values:

- Basic round-trip: node count, labels, edge lengths correct individually
- Attribute promotion: custom `<key>` elements produce typed columns in node
  and edge tables
- `.lineagegraphml` auto-detects correctly
- `.graphml` without override raises `ArgumentError`
- `File{format"LineageGraphML"}("file.graphml")` override works

### How to verify

**Manual:**

1. `load("test/fixtures/lineagegraphml/simple.lineagegraphml", MyNode)` — succeeds.
2. `load("anything.graphml", MyNode)` — raises `ArgumentError` naming the
   ambiguity.
3. `load(File{format"LineageGraphML"}("anything.graphml"), MyNode)` — succeeds.

**Automated:**

```
julia --project=test test/runtests.jl
```

All tests pass. Aqua and JET pass.

### Acceptance criteria

- [ ] Given a `.lineagegraphml` file, when `load` is called without explicit
  override, then parsing succeeds as `format"LineageGraphML"`.
- [ ] Given a `.graphml` file without explicit override, when `load` is called,
  then `ArgumentError` is raised explaining the ambiguity.
- [ ] Given `File{format"LineageGraphML"}("file.graphml")`, when `load` is
  called, then parsing succeeds.
- [ ] Given a LineageGraphML file with custom node attributes, when parsed,
  then each attribute appears as a typed column in the node table.
- [ ] Given `format"LineageGraphML"` is invoked, when the protocol tier is
  declared, then it is `:single_parent`, declared before the discovery pass.
- [ ] Given Aqua and JET are run, then no issues are reported.

### User stories addressed

- User story 36: `format"LineageGraphML"` correctly parses the phylogeny-specific
  GraphML profile
- User story 37: LineageGraphML parser declares single-parent protocol
- User story 38: generic `.graphml` requires explicit format override
- User story 41: explicit format override works for ambiguous extensions

---

## Tranche 8: PhyloNetworksExt

**Type**: AFK
**Blocked by**: Tranches 1, 2, 3, 4, 5, 6

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line**. Pass all mandates forward.

**Governance documents (all mandatory):**

- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md` — critical for this tranche; every PhyloNetworks
  API call must be verified from the upstream source before use; do not rely on
  the brief's stubs as the final authority on function signatures
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `CONTRIBUTING.md`

**Companion design documents (all mandatory):**

- `design/brief.md` — §Package extension architecture; §PhyloNetworksExt module
  design; §Implementation decision 3 (`finalize_graph!`); §Implementation
  decision 4 (per-edge metadata)
- `design/brief--community-support-objectives.md` — §PhyloNetworks.jl: all
  subsections including the concrete `add_child` and `finalize_graph!` stubs.
  These stubs are the **starting point** — verify every field name and function
  signature against the upstream source before using them. If any discrepancy is
  found between the stub and the current upstream source, flag it before
  implementing.
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §PhyloNetworksExt
  (user stories 47–52); §finalize_graph! protocol hook; §Testing and verification
  decisions — PhyloNetworksExt

**Upstream primary sources (all mandatory, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read the PhyloNetworks source line by line before writing a single line of
implementation. Do not use field names or function signatures from memory or
from the brief's stubs without verification against the actual source.

- `PhyloNetworks.jl/` — read completely:
  - `HybridNetwork` struct: all fields (`node`, `edge`, `rooti`, `hybrid`,
    `numhybrids`, `leaf`, `isrooted`, `numnodes`, `numedges`, `numtaxa`,
    `names`); confirm field names exactly
  - `Node` struct: all fields (`number`, `name`, `leaf`, `hybrid`, `edge`,
    `booln1`); missing sentinels; constructor signature `Node(number, isleaf)`
  - `Edge` struct: all fields (`length`, `y`, `z`, `gamma`, `hybrid`,
    `ismajor`, `ischild1`, `containroot`); missing sentinel `-1.0`; constructor
    signature `Edge(number, length)`
  - `pushNode!`, `pushEdge!` — signatures, return values, state mutations
  - `setNode!(edge, nodes_vector)` — exact argument order; what `nodes_vector`
    must contain
  - `setEdge!(node, edge)` — signature and semantics
  - `storeHybrids!` — what it does; pre-conditions
  - `checkNumHybEdges!` — what it validates; what error it raises on failure
  - `directedges!` — what it does; what fields it sets (confirm `isrooted`)
  - `HybridNetwork()` constructor — how an empty network is created
  - Correct calling order for the three post-build functions

**Codebase review (mandatory, line by line, before touching any file):**

Read all files added or modified by Tranches 1–6. Pay particular attention to
the orchestration layer (Tranche 3) — understand exactly what `add_child` will
receive at each call. Confirm Aqua and JET pass before starting.

### What to build

**Dependency setup:**

Add `PhyloNetworks` as a weak dependency. `Pkg.add` cannot add `[weakdeps]` or
`[extensions]` sections to `Project.toml` — this requires direct editing of
`Project.toml`. Per `STYLE-julia.md §7` and `CONTRIBUTING.md`, direct
`Project.toml` editing is an acknowledged exception; bring this to the project
owner's attention before editing. Add to `Project.toml`:

```toml
[weakdeps]
PhyloNetworks = "<uuid>"

[extensions]
PhyloNetworksExt = "PhyloNetworks"
```

Obtain the correct UUID via `Pkg.status` or `Pkg.METADATA` — do not guess or
copy from memory. If `Phylo` has already been added in Tranche 9, merge both
entries under the same `[weakdeps]` and `[extensions]` sections — do not create
duplicate section headers.

Create `ext/PhyloNetworksExt.jl`. Julia loads this extension automatically when
both `LineagesIO` and `PhyloNetworks` are loaded in the same session.

**`PhyloNetworksNodeHandle` struct:**

```julia
struct PhyloNetworksNodeHandle
    net  :: PhyloNetworks.HybridNetwork
    node :: PhyloNetworks.Node
end
```

**Network-level `add_child` — entry-point (empty `parents`):**

Called exactly once per graph. Creates the `HybridNetwork`, creates the root
`Node`, sets `net.rooti` to the correct index. Returns `PhyloNetworksNodeHandle(net, root)`.
Missing sentinels for unused fields must match PhyloNetworks conventions
(verified from source, not assumed).

**Network-level `add_child` — non-entry-point:**

For hybrid nodes (`length(parents) > 1`): one `Edge` per parent. Assign
`e.gamma` from `edgedata[i].gamma` directly in a single pass — no two-phase
gamma assignment is used or needed. For tree nodes (`length(parents) == 1`):
single edge with `gamma = 1.0`. Missing sentinels: edge length `-1.0` when
`edgelength` is `nothing`; bootstrap `-1.0` when `nodedata.bootstrap` is
`nothing` or absent.

**`finalize_graph!` override:**

Call the three post-build functions in the correct order as verified from the
PhyloNetworks source:

```julia
function LineagesIO.finalize_graph!(handle :: PhyloNetworksNodeHandle) :: PhyloNetworksNodeHandle
    PhyloNetworks.storeHybrids!(handle.net)
    PhyloNetworks.checkNumHybEdges!(handle.net)
    PhyloNetworks.directedges!(handle.net)
    return handle
end
```

**Extension test environment:**

Add `test/ext/PhyloNetworksExt/` with its own `Project.toml` that lists
`PhyloNetworks` as a dependency alongside the main package via `[sources]`.
Add `test/ext/PhyloNetworksExt/runtests.jl`.

**Test fixtures under `test/ext/PhyloNetworksExt/fixtures/`:**

- A simple Newick tree file with known structure
- A LineageNetwork file with at least one hybrid node with known gamma values

**Integration tests — geometry checks are necessary but not sufficient:**

- Newick → `HybridNetwork`: verify `numnodes`, `numedges`, root label —
  field-level values against fixture
- LineageNetwork with hybrid nodes → `HybridNetwork`: verify
  `graph_rootnode.net.numhybrids > 0`; verify gamma values on hybrid edges
  match fixture values exactly (not just that they are non-zero)
- `graph_rootnode.net.isrooted == true` (set by `directedges!` in `finalize_graph!`)
- `finalize_graph!` called exactly once per graph (observable via `net.isrooted`
  which `directedges!` sets to `true`)

### How to verify

**Manual:**

1. `using LineagesIO, PhyloNetworks`
2. `asset = loadone("test/ext/PhyloNetworksExt/fixtures/hybrid.lnw", PhyloNetworksNodeHandle)`
3. `net = asset.graph_rootnode.net`
4. Verify `net.numhybrids`, `net.isrooted`, hybrid edge gamma values

**Automated:**

```
julia --project=test/ext/PhyloNetworksExt test/ext/PhyloNetworksExt/runtests.jl
```

All tests pass. Aqua and JET pass for the extension.

### Acceptance criteria

- [ ] Given `using LineagesIO, PhyloNetworks`, when
  `loadone("file.nwk", PhyloNetworksNodeHandle)` is called, then a
  `LineageGraphAsset{PhyloNetworksNodeHandle}` is returned.
- [ ] Given a Newick file with 5 nodes and 4 edges, when loaded, then
  `asset.graph_rootnode.net.numnodes == 5` and
  `asset.graph_rootnode.net.numedges == 4`.
- [ ] Given a LineageNetwork file with a hybrid node whose parent edges have
  gamma values `g1` and `g2`, when loaded, then the corresponding edges in
  `net.edge` have `e.gamma ≈ g1` and `e.gamma ≈ g2` respectively (values from
  fixture, verified to two decimal places).
- [ ] Given a loaded `HybridNetwork`, when `net.isrooted` is inspected, then
  `true` is returned (set by `directedges!`).
- [ ] Given `finalize_graph!` is invoked, when `net.hybrid` is inspected, then
  it is populated with hybrid node pointers (by `storeHybrids!`).
- [ ] Given Aqua and JET are run for the extension, then no issues are reported.
- [ ] Given a search for proscribed vocabulary terms in identifiers added by
  this tranche, then no matches are found.

### User stories addressed

- User story 47: `using LineagesIO, PhyloNetworks` activates `PhyloNetworksExt`
- User story 48: `PhyloNetworksNodeHandle` bundles `HybridNetwork` and `Node`
- User story 49: entry-point creates `HybridNetwork`, root `Node`, returns handle
- User story 50: non-entry-point adds nodes and edges; gamma assigned in one pass
- User story 51: `finalize_graph!` calls `storeHybrids!`, `checkNumHybEdges!`,
  `directedges!`
- User story 52: integration test verifies file → `HybridNetwork` structure and
  gamma values

---

## Tranche 9: PhyloExt

**Type**: AFK
**Blocked by**: Tranches 1, 2, 3, 4, 5

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line**. Pass all mandates forward.

**Governance documents (all mandatory):**

- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md` — critical; all Phylo API calls must be verified
  from the upstream source before use
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `CONTRIBUTING.md`

**Companion design documents (all mandatory):**

- `design/brief.md` — §Package extension architecture; §PhyloExt module design
- `design/brief--community-support-objectives.md` — §Phylo.jl: all subsections;
  `RootedTree` type alias and full parametric expansion; `RecursiveTree` fields;
  `RecursiveBranch` fields; `RecursiveNode` fields; metadata flow table;
  integration requirements; concrete `add_child` stubs. The stubs are the
  **starting point** — verify every function signature against the upstream
  source before using. Flag any discrepancy before implementing.
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §PhyloExt (user
  stories 53–58); §Testing and verification decisions — PhyloExt

**Upstream primary sources (all mandatory, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read the Phylo source line by line before writing a single line of implementation.

- `Phylo.jl/` — read completely:
  - `RootedTree` type alias — full parametric expansion
    (`RecursiveTree{OneRoot, String, Dict{String,Any}, Dict{String,Any},
    PolytomousBranching, Float64, Dict{String,Any}}`)
  - `RootedTree()` constructor — exact calling convention
  - `createnode!(tree, nodename)` — signature, return value, what state it
    creates; whether node name must be unique
  - `createbranch!(tree, src_name, dst_name, length)` — signature; exact type
    of the `length` argument (`Union{Float64, Missing}` or `Union{Number, Missing}`
    — verify); return value
  - `setnodedata!(tree, nodename, data)` — signature; what `data` type is
    expected (`Dict{String,Any}` vs. `NamedTuple`); whether it overwrites or
    merges existing node data
  - `getnodedata(tree, nodename)` — how node data is accessed post-construction
  - How Phylo handles `nothing` vs `missing` for branch lengths — verify the
    correct sentinel for absent branch lengths
  - `parsenewick` and `parsenewick!` structure — for context on how Phylo builds
    trees internally

**Codebase review (mandatory, line by line, before touching any file):**

Read all files added or modified by Tranches 1–5. Do not assume any file is
current. Confirm Aqua and JET pass before starting.

### What to build

**Dependency setup:**

Add `Phylo` as a weak dependency via direct `Project.toml` editing (same process
as Tranche 8). Obtain UUID via `Pkg.status` — do not guess. If `PhyloNetworks`
entries are already present from Tranche 8, add `Phylo` alongside them in the
same `[weakdeps]` and `[extensions]` sections — do not create duplicate section
headers:

```toml
[weakdeps]
PhyloNetworks = "<uuid>"
Phylo = "<uuid>"

[extensions]
PhyloNetworksExt = "PhyloNetworks"
PhyloExt = "Phylo"
```

Create `ext/PhyloExt.jl`.

**`PhyloNodeRef` struct:**

```julia
struct PhyloNodeRef
    tree     :: Phylo.RootedTree
    nodename :: String
end
```

**Single-parent `add_child` — entry-point (`parent :: Nothing`):**

Creates the `RootedTree` via the verified constructor; creates the root node via
`createnode!`; stores `node_idx` in node data dict as `"node_idx" => node_idx`;
stores all `nodedata` fields via `Dict(pairs(nodedata))`. Returns
`PhyloNodeRef(tree, nodename)`.

**Single-parent `add_child` — non-entry-point (`parent :: PhyloNodeRef`):**

Creates child node via `createnode!`; calls `createbranch!` from
`parent.nodename` to child `nodename` with
`length = isnothing(edgelength) ? missing : edgelength`; stores `node_idx` and
all `nodedata` fields in node data dict via `setnodedata!`. Returns
`PhyloNodeRef(tree, nodename)`.

No `finalize_graph!` override — Phylo validates lazily.

**Extension test environment:**

Add `test/ext/PhyloExt/` with its own `Project.toml`. Add
`test/ext/PhyloExt/runtests.jl`.

**Test fixtures under `test/ext/PhyloExt/fixtures/`:**

- A Newick tree with edge lengths, internal node labels, and bootstrap values
  as internal node annotations; include at least one branch with an absent edge
  length

**Integration tests — geometry checks are necessary but not sufficient:**

- Newick → `RootedTree`: verify each node label matches fixture; verify each
  branch length matches fixture value to floating-point equality
- Absent edge length in source → `missing` branch length in `RecursiveBranch`
  (not `nothing`, not `-1.0`, not `0.0`)
- `node_idx` present in each node's data dict at the correct value
- `node_idx` values in node data dicts enable round-trip join to
  `LineageGraphAsset.node_table` — demonstrate this with at least one join in the tests

### How to verify

**Manual:**

1. `using LineagesIO, Phylo`
2. `asset = loadone("test/ext/PhyloExt/fixtures/tree.nwk", PhyloNodeRef)`
3. `tree = asset.graph_rootnode.tree` — is a `Phylo.RootedTree`
4. Inspect node labels and branch lengths against fixture

**Automated:**

```
julia --project=test/ext/PhyloExt test/ext/PhyloExt/runtests.jl
```

All tests pass. Aqua and JET pass for the extension.

### Acceptance criteria

- [ ] Given `using LineagesIO, Phylo`, when
  `loadone("file.nwk", PhyloNodeRef)` is called, then a
  `LineageGraphAsset{PhyloNodeRef}` is returned.
- [ ] Given a Newick file with node label `"taxon_A"`, when loaded, then
  `"taxon_A"` appears as a node name in `asset.graph_rootnode.tree`.
- [ ] Given a Newick file with branch length `1.5`, when loaded, then the
  corresponding `RecursiveBranch.length == 1.5`.
- [ ] Given a Newick file with an absent branch length on a particular edge,
  when loaded, then the corresponding `RecursiveBranch.length === missing`.
- [ ] Given a loaded node, when its node data dict is inspected for `"node_idx"`,
  then the integer assigned by the orchestration layer is found.
- [ ] Given `node_idx` values from the node data dicts, when used to join
  against `asset.node_table` rows, then every node is located in the table with
  matching `node_idx`.
- [ ] Given Aqua and JET are run for the extension, then no issues are reported.
- [ ] Given a search for proscribed vocabulary terms in identifiers added by
  this tranche, then no matches are found.

### User stories addressed

- User story 53: `using LineagesIO, Phylo` activates `PhyloExt`
- User story 54: `PhyloNodeRef` bundles `RootedTree` and node name string
- User story 55: entry-point creates `RootedTree`, root node, stores `node_idx`
- User story 56: non-entry-point uses `createnode!` + `createbranch!`;
  `nothing` → `missing` conversion
- User story 57: `node_idx` stored in node data dict for round-trip join
- User story 58: integration test verifies file → `RootedTree` with correct
  labels, branch lengths, node data

---

## Tranche 10: Stabilization

**Type**: AFK
**Blocked by**: All tranches (1–9)

### Parent PRD

`.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

### Governance and required reading

All items below must be read **line by line**. Pass all mandates forward.

**Governance documents (all mandatory):**

- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-makie.md` — verify that loaded graphs are immediately consumable by
  LineagesMakie's accessor protocol with user-supplied accessors
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `CONTRIBUTING.md`

**Companion design documents (all mandatory):**

- `design/brief.md` — full re-read against the completed implementation
- `design/brief--community-support-objectives.md` — full re-read
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — full re-read;
  verify all 64 user stories against the implementation; verify all 11 target
  outcome criteria; verify all testing and verification decisions

**Upstream primary sources (mandatory):**

- `AbstractTrees.jl/` — verify LineagesMakie interoperability: loaded graphs
  with user-supplied `children` and `edgelength` accessors must be immediately
  consumable
- All previously read upstream sources: re-read as needed to verify
  implementation matches contracts

**Codebase review (mandatory, line by line, before making any changes):**

Read **every** tracked file in the repository without exception:

- All of `src/` (every `.jl` file)
- All of `ext/` (every `.jl` file)
- All of `test/` and `test/ext/` (every `.jl` and `Project.toml` file)
- All of `docs/` (if any)
- All of `examples/` (if any)
- `README.md`
- `Project.toml`
- `CHANGELOG.md` (if present)
- All `STYLE-*.md`, `CONTRIBUTING.md`, `AUTHORS.md`, `LICENSE.md`

This is a full audit. Do not assume any file is consistent with any other file.
Read each independently and flag every discrepancy before making changes.

Specifically verify before making changes:

1. Every exported function and type has a complete docstring
2. No proscribed vocabulary term appears anywhere in project-owned identifiers,
   field names, keyword arguments, type names, or symbols
3. All struct fields are concretely typed or concretized through type parameters
4. All public functions have explicit return type annotations
5. All `!`-functions return the mutated argument, not `Nothing`
6. No bare `using Package` imports in library or extension code
7. All test assertions verify field-level values, not only geometry or existence

### What to build

This tranche adds no new functionality. It hardens, documents, and fully verifies
everything built in Tranches 1–9.

**Full automated quality gates — all must pass with zero issues:**

- `Aqua.test_all(LineagesIO)` — code quality
- `JET.test_package(LineagesIO; target_defined_modules = true)` — type inference
- All functional tests: `julia --project=test test/runtests.jl`
- Extension tests: `julia --project=test/ext/PhyloNetworksExt test/ext/PhyloNetworksExt/runtests.jl`
- Extension tests: `julia --project=test/ext/PhyloExt test/ext/PhyloExt/runtests.jl`

**Docstrings (mandatory on all exported names):**

Complete docstrings for: `add_child`, `finalize_graph!`, `LineageGraphAsset`,
`LineageGraphStore`, `load`, `loadfirst`, `loadone`. Each docstring must include:

- What the function or type does
- All parameters with types and semantics
- Return value with type
- Errors raised (if any)
- At least one usage example

**Vocabulary audit:**

Search the entire codebase for every proscribed term in `STYLE-vocabulary.md`.
At minimum search for: `vertex`, `vertices`, `branch` (as identifier), `tip`,
`terminal`, `root` (as standalone identifier, not `rootnode`), `root_node`,
`rootvertex`, `branch_length`, `edge_length` (underscored), `weight`, `len`,
`topology` (unqualified). Fix all occurrences in project-owned identifiers.

**Tables.jl compliance verification:**

For `node_table` and `edge_table` in every `LineageGraphAsset` variant, confirm:
`Tables.istable(...)`, `Tables.schema(...)`, `Tables.rows(...)` all work.

**LineagesMakie interoperability verification (user story 59):**

Demonstrate that a loaded `LineageGraphAsset` (with a user-defined `NodeHandle` that
implements `children` and `edgelength` accessors) is immediately consumable by
LineagesMakie's accessor protocol without additional transformation. This does
not require LineagesMakie as a dependency — a documentation example or test
using a minimal accessor-compliant node type is sufficient. Verify by consulting
`LineagesMakie.jl/` source in the local workspace to confirm the required
accessor signatures.

**README:**

Ensure `README.md` contains: package synopsis, motivation, installation
instructions, and a minimal working example demonstrating
`load("file.nwk", MyNode)` that can be copy-pasted into a Julia session.

**CHANGELOG:**

Add an `[UNRELEASED]` section to `CHANGELOG.md` summarizing phase 1 additions.

### How to verify

**Automated:**

```
julia --project=test test/runtests.jl
julia --project=test/ext/PhyloNetworksExt test/ext/PhyloNetworksExt/runtests.jl
julia --project=test/ext/PhyloExt test/ext/PhyloExt/runtests.jl
```

All pass with zero failures, zero Aqua issues, zero JET issues.

**Manual:**

1. `@doc LineagesIO.add_child` — complete docstring with example visible.
2. `@doc LineagesIO.LineageGraphAsset` — complete docstring visible.
3. Vocabulary search:
   `grep -r "branch_length\|tip\|vertex\|root_node\|edge_length" src/ ext/`
   returns no matches in project-owned identifiers.
4. `Tables.istable(asset.node_table)` → `true`.
5. `Tables.istable(asset.edge_table)` → `true`.

### Acceptance criteria

- [ ] Given `Aqua.test_all(LineagesIO)` is run, then no issues are reported.
- [ ] Given `JET.test_package(LineagesIO; target_defined_modules = true)` is
  run, then no inference failures are reported.
- [ ] Given every exported name, when `@doc` is called, then a complete
  docstring is returned with parameters, return type, and at least one example.
- [ ] Given a search for all proscribed vocabulary terms in project-owned
  identifiers across `src/` and `ext/`, then no matches are found.
- [ ] Given all 64 user stories in `01_prd.md`, when each is evaluated against
  the implementation, then all are satisfied.
- [ ] Given all 11 target outcome criteria in `01_prd.md §Target outcome`, when
  each is evaluated, then all are satisfied.
- [ ] Given `Tables.istable(asset.node_table)` and
  `Tables.istable(asset.edge_table)` for any loaded `LineageGraphAsset`, then both
  return `true`.
- [ ] Given a user-defined `NodeHandle` with `children` and `edgelength` accessors,
  when `asset.graph_rootnode` is used with LineagesMakie's accessor protocol,
  then no additional transformation is required.
- [ ] Given `README.md`, when read, then it contains a working `load` example.

### User stories addressed

- All 64 user stories — this tranche is the final verification gate for all of them
- User story 59: loaded graphs immediately consumable by LineagesMakie via
  accessor protocol

---
