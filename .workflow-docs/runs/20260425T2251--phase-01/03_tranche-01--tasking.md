---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 1: Protocol foundations and return types

Parent tranche: Tranche 1
Parent PRD: `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

## Governance

All tasks in this file must comply, line by line, with the following governance
documents. Read every document in full before planning or writing a single line
of implementation. This obligation must be passed forward into any downstream
delegated work derived from these tasks.

**Governance documents (all mandatory, line by line):**

- `STYLE-architecture.md` — ownership boundaries; deep-module design; anti-fix
  prohibition; green-state discipline
- `STYLE-docs.md` — documentation formatting standards; sentence case headings;
  no separators between sections
- `STYLE-git.md` — commit style and branching model
- `STYLE-julia.md` — functional design; naming; type annotations; mutation
  contract; struct field concreteness rules (§1.12); return type annotations
  (§1.13.2); bare `using` prohibition (§5 anti-patterns); module file curation (§8)
- `STYLE-makie.md` — Makie integration contracts; LineagesMakie interoperability
  constraints apply to how node types and return types are designed
- `STYLE-upstream-contracts.md` — host-framework contract reading; divergence
  authorization; primary-source verification requirement
- `STYLE-verification.md` — what counts as a verification artifact; weak-proxy
  prohibition; field-level value verification requirement
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms;
  compound-word rules; canonical identifier table. Key constraints for this
  tranche: use `node` not `vertex`/`vertices`; `edge` not `branch`; `leaf`/`leaves`
  not `tip`/`terminal`; `rootnode` not `root`/`root_node`; `edgeweight` not
  `branch_length`/`edge_length`; `src`/`dst` not `fromnode`/`tonode`
- `STYLE-workflow-docs.md` — workflow document structure; revalidation rule;
  pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` (v2.0, 2026-04-25) — primary design authority; builder
  protocol signatures and dispatch levels; `LineageGraphAsset` and `LineageGraphStore` struct
  field specifications; `finalize_graph!` hook contract; module design sections
- `design/brief--community-support-objectives.md` (v1.0, 2026-04-25) —
  extension architecture; `PhyloNetworksNodeHandle` and `PhyloNodeRef` stubs;
  finalization hook contract; resolved design questions

Neither design document is complete without the other. Read both before
implementing anything.

**Upstream primary sources (all mandatory, line by line, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

- `fileio.jl/` — FileIO backend contract; `DataFormat` and `File`/`Stream`
  types; `add_format` registration pattern; private `load`/`save` naming inside
  a module. Read now even though the FileIO adapter is built in Tranche 5:
  `LineageGraphAsset` and `LineageGraphStore` must be designed to be compatible with FileIO
  dispatch from the start.
- `AbstractTrees.jl/` — traversal traits and iteration interface; constraints
  on how node types must behave for LineagesMakie interoperability

Read-only git and shell commands may be used freely. Mutating git operations
(commit, merge, push, branch) remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code, read and verify:

- `src/LineagesIO.jl` — current state (stub module)
- `test/runtests.jl` — current test suite (Aqua and JET only)
- `test/Project.toml` — test environment
- `Project.toml` — current dependencies (none beyond Julia version)
- `README.md`, `AUTHORS.md`, `LICENSE.md`
- All files in `docs/` and `examples/`

Confirm that `julia --project=test test/runtests.jl` passes before making any
change. If it does not pass, stop and escalate before proceeding. Do not assume
the repository is in green state.

Verify that the `add_child` signatures, `LineageGraphAsset` field names, and
`LineageGraphStore` field names match `design/brief.md §Builder protocol` and
`01_prd.md §Return types` exactly. If any discrepancy is found between design
documents and the PRD, stop and escalate rather than adapting silently.

## Tranche execution rule

This tranche establishes the architectural contracts on which every subsequent
tranche depends. Nothing else can proceed until these are in place and verified.
The work must begin and end with all tests passing, Aqua and JET clean.
Any deviation from the `add_child` signature, `LineageGraphAsset` field names, or
`finalize_graph!` contract must be escalated to the project owner before
proceeding.

## Tasks

### 1. Add hard dependencies

**Type**: CONFIG
**Output**: `FileIO` and `Tables` appear under `[deps]` in `Project.toml` with
UUIDs written by `Pkg.add`; no manual edits to `Project.toml` for this step;
no `[weakdeps]` or `[extensions]` sections added
**Depends on**: none

Open a Julia session with `--project=.` from the repository root. Run
`using Pkg; Pkg.add("FileIO"); Pkg.add("Tables")`. Verify both packages appear
under `[deps]` in `Project.toml` after the commands complete. Do not edit
`Project.toml` directly for this step. Do not add `[weakdeps]` or `[extensions]`
sections — those are added in Tranches 8 and 9 with explicit project owner
approval. After adding, run `julia --project=test test/runtests.jl` and confirm
the test suite still passes.

---

### 2. Restructure module file and create included stubs

**Type**: WRITE
**Output**: `src/LineagesIO.jl` contains only the module declaration,
`using`/`import` statements, and `include` calls; `src/protocol.jl` and
`src/types.jl` exist as empty stub files (module-level comment only); no
implementation code in the module file
**Depends on**: Task 1

Per `STYLE-julia.md §8`, the module file must declare only the module and its
imports plus `include` calls. Create `src/protocol.jl` and `src/types.jl` as
empty stubs (a single comment line is sufficient for now). Update
`src/LineagesIO.jl` to include both via `include("protocol.jl")` and
`include("types.jl")`. Do not add any `using` statements for FileIO or Tables
until the source files that actually use them exist. Verify the test suite still
passes after this restructure.

---

### 3. Define `add_child` generic function

**Type**: WRITE
**Output**: `src/protocol.jl` defines and exports `add_child` with all three
overload signatures exactly as specified; the function has no default method
bodies; complete docstring present; test suite passes
**Depends on**: Task 2

In `src/protocol.jl`, define `add_child` as a generic function with exactly
three overload stubs, matching the signatures in `design/brief.md §Builder
protocol` and `01_prd.md §add_child protocol module` character-for-character.
Do not provide any default method bodies — this function is implemented by
users, not the library. The three signatures are: (1) network level with
`parents :: AbstractVector{NodeT}`, (2) single-parent entry-point with
`parent :: Nothing`, and (3) single-parent non-entry-point with
`parent :: NodeT`. All three take `edgedata = nothing` and `nodedata = nothing`
as optional keyword arguments (after the `;` separator). Add `add_child` to the module exports. Write a complete
docstring on the generic function describing the protocol contract, both
dispatch levels, all parameter semantics, the relationship to `finalize_graph!`,
and a minimal usage example showing method extension. Per `STYLE-julia.md §1.13`,
all arguments must be annotated; per `§1.13.2`, return type annotations are
mandatory. Per `STYLE-vocabulary.md`, use `node` not `vertex`, `edgewidth` not
`branch_length`, `src`/`dst` not `fromnode`/`tonode` in any documentation prose
that references identifiers. Run the test suite and verify it still passes.

---

### 4. Define `finalize_graph!` hook

**Type**: WRITE
**Output**: `src/protocol.jl` defines and exports `finalize_graph!` with a
no-op default that returns `handle` unchanged; complete docstring present; test
suite passes
**Depends on**: Task 3

In `src/protocol.jl`, define and export `finalize_graph!(handle :: NodeT) ::
NodeT where {NodeT}` with a no-op default body that returns `handle` unchanged.
Per `STYLE-julia.md §4`, a `!`-function must return the mutated argument —
`finalize_graph!` follows this contract even though the default is a no-op.
Write a complete docstring describing: called once per graph after the last
`add_child` call for that graph and before `LineageGraphAsset` assembly; default
implementation is a no-op that returns `handle` unchanged; extensions override
this function for their concrete node handle types to perform post-build
cleanup; `PhyloNetworksExt` uses it to call `storeHybrids!`,
`checkNumHybEdges!`, and `directedges!`. Run the test suite and verify it passes.

---

### 5. Define `LineageGraphAsset{NodeT}` struct

**Type**: WRITE
**Output**: `src/types.jl` defines and exports `LineageGraphAsset{NodeT}` as an
immutable struct with exactly the fields and types specified in the PRD; all
fields concretely typed or concretized through type parameters; complete
docstring; test suite passes
**Depends on**: Task 2

In `src/types.jl`, define `LineageGraphAsset` as an immutable `struct`. The struct
must carry at minimum two additional type parameters beyond `NodeT` to
concretize `node_table` and `edge_table`, because per `STYLE-julia.md §1.12`,
struct fields must not be abstractly typed. Choose a representation for
`node_table` and `edge_table` that is Tables.jl-compliant and type-stable.
Read the Tables.jl source in the upstream resources to confirm the chosen
representation satisfies the Tables.jl interface before committing to it.
The exact field names and types are specified in `01_prd.md §Return types` and
`design/brief.md §LineageGraphAsset` — match them exactly. Export `LineageGraphAsset`. Add
`using Tables: Tables` (or the specific qualified import needed) only in the
file that requires it, per `STYLE-julia.md §5` (no bare `using Tables`). Write
a complete docstring. Run the test suite and verify it passes.

---

### 6. Define `LineageGraphStore{NodeT}` struct

**Type**: WRITE
**Output**: `src/types.jl` defines and exports `LineageGraphStore{NodeT}` as an
immutable struct with exactly the fields and types specified in the PRD; all
fields concretely typed or concretized through type parameters; complete
docstring; test suite passes
**Depends on**: Task 5

In `src/types.jl`, define `LineageGraphStore` as an immutable `struct` with type
parameters for each concretely typed field beyond `NodeT`. The `graphs` field
must be a lazy iterator type (not a `Vector`) — choose a concrete iterator type
that is non-materializing and can be typed at compile time. The exact field
names are specified in `01_prd.md §Return types` and `design/brief.md
§LineageGraphStore`. Export `LineageGraphStore`. Write a complete docstring. Run the test
suite and verify it passes.

---

### 7. Write test scaffolding and verify green state

**Type**: TEST
**Output**: `test/test_protocol.jl` and `test/test_types.jl` created and
included from `test/runtests.jl`; all new tests pass; Aqua and JET report no
issues
**Depends on**: Tasks 3, 4, 5, 6

Create `test/test_protocol.jl` with a named `@testset "protocol"` block.
Required tests: (a) `finalize_graph!` default no-op — define a minimal
`struct MyTestNode` within the test, call `finalize_graph!` on an instance,
assert the returned value is identical to the input and no error is raised;
(b) `add_child` generic function exists and is exported. Create
`test/test_types.jl` with a named `@testset "types"` block. Required tests:
(a) `LineageGraphAsset{MyTestNode}` can be constructed with all fields; (b)
`@inferred` applied to accessing `graph_rootnode` on a `LineageGraphAsset{MyTestNode}`
returns `MyTestNode` without instability; (c) `Tables.istable(asset.node_table)`
returns `true`; (d) `Tables.istable(asset.edge_table)` returns `true`;
(e) `LineageGraphStore{MyTestNode}` can be constructed; (f) `@inferred` on
`LineageGraphStore` field access produces no instability. Add `include("test_protocol.jl")`
and `include("test_types.jl")` to `test/runtests.jl`. Run
`julia --project=test test/runtests.jl` and confirm all tests pass,
`Aqua.test_all(LineagesIO)` reports no issues, and
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no issues.
Search all added identifiers, field names, and type names for proscribed
vocabulary terms from `STYLE-vocabulary.md` and confirm no matches.
