---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 5: FileIO adapter and view layer (Newick end-to-end)

Parent tranche: Tranche 5
Parent PRD: `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

## Governance

All tasks in this file must comply, line by line, with the following governance
documents. Read every document in full before planning or writing a single line
of implementation. This obligation must be passed forward into any downstream
delegated work derived from these tasks.

**Governance documents (all mandatory, line by line):**

- `STYLE-architecture.md` — ownership boundaries; anti-fix prohibition;
  green-state discipline; deep-module design
- `STYLE-docs.md` — documentation formatting standards
- `STYLE-git.md` — commit style and branching model
- `STYLE-julia.md` — functional design; type annotations; return type
  annotations (§1.13.2); bare `using` prohibition (§5); module curation (§8);
  mutation contract (§4)
- `STYLE-upstream-contracts.md` — host-framework contract reading; divergence
  authorization; the FileIO framework contract is the primary upstream contract
  for this tranche — every design decision that diverges from established FileIO
  patterns must be flagged in a code comment explaining why
- `STYLE-verification.md` — field-level value verification; weak-proxy
  prohibition; end-to-end tests must verify individual node labels, edge
  lengths, and `LineageGraphAsset` structure against fixture ground truth — not just
  that loading returns something
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms. Key
  constraints: `node` not `vertex`; `edge` not `branch`; `leaf`/`leaves` not
  `tip`/`terminal`; `edgeweight` not `branch_length`; `rootnode` not `root`
- `STYLE-workflow-docs.md` — revalidation rule; pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` — §FileIO integration; §Format detection policy; §View
  layer design; §Builder protocol (Parse order); §LineageGraphStore lazy iterator
  design; §Implementation decisions 1–8
- `design/brief--community-support-objectives.md` — §FileIO backend contract;
  extension architecture context for how the adapter must remain open to
  PhyloNetworksExt and PhyloExt without coupling to them
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §FileIO adapter
  (user stories 19–27); §View layer (user stories 32–40); §Error handling
  (user stories 60–61); §Format detection policy; §LineageGraphStore module design;
  §Implementation decisions 1–8

**Upstream primary sources (all mandatory, line by line, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read the entire FileIO source line by line before writing a single line of
the adapter. Understand how FileIO dispatches to backend `load`, what
`DataFormat`, `File`, and `Stream` types are, how `add_format` registers a
backend, and how the private `load`/`save` naming convention inside a module
works. Any design decision that diverges from established FileIO patterns must
be flagged in a code comment explaining why.

- `fileio.jl/src/` — all files; `DataFormat`, `File`, `Stream`; `add_format`
  registration; private `load`/`save` naming; how FileIO calls backend `load`
  with a `File{fmt}` or `Stream{fmt}` argument; format override via
  `File{format"..."}(...)`; ambiguous extension behavior

Read-only git and shell commands may be used freely. Mutating git operations
remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code:

1. Read all files added or modified by Tranches 1, 2, 3, and 4 in full, line
   by line. Do not assume any description matches the code — verify each
   independently.
2. Confirm `julia --project=test test/runtests.jl` passes with Aqua and JET
   clean. If it does not, stop and escalate before proceeding.
3. Verify that the Newick parser in `src/parsers/Newick.jl` exposes the
   internal API the FileIO adapter must call. If the adapter cannot reach the
   orchestration layer through the Newick parser without exposing internal
   symbols, escalate before proceeding.
4. Verify that `LineageGraphStore{NodeT}` field types and `LineageGraphAsset{NodeT}` field
   types match what the view layer will assemble — confirm `LineageGraphStore.graphs`
   is a lazy non-materializing iterator type and that its type is fully
   determined at compile time.

## Tranche execution rule

The FileIO adapter and view layer are the primary user-facing interface of
LineagesIO. They own the following invariants: format detection (extension
to `DataFormat` mapping), ambiguous-extension error policy, lazy
`LineageGraphStore.graphs` assembly, `loadfirst` / `loadone` semantics, and
multi-source `load([...], ...)` behavior. The tranche must begin and end with
all tests passing, Aqua and JET clean.

## Tasks

### 1. Implement the FileIO adapter

**Type**: WRITE
**Output**: `src/fileio.jl` exists and is included from `src/LineagesIO.jl`;
`add_format` registers `format"Newick"` for `.nwk`, `.newick`, and `.tre`
extensions; the private `load(::File{format"Newick"}, ...)` and
`load(::Stream{format"Newick"}, ...)` methods dispatch to the orchestration
layer; ambiguous extension raises `ArgumentError` naming the path and the
conflicting formats; a `save` stub exists and raises `NotImplementedError`
with a useful message; the adapter design is open to extension without
modification when LineageNetwork and LineageGraphML are registered in
Tranches 6 and 7
**Depends on**: Tranches 1, 2, 3, 4 complete and green

Add `src/fileio.jl` and add `include("fileio.jl")` in `src/LineagesIO.jl`.
Read the entire `fileio.jl/src/` upstream source before touching any code.
Implement `add_format` registration for `format"Newick"` with the correct
MIME type and file extensions (`.nwk`, `.newick`, `.tre`). Implement the
private `load` method following the FileIO backend naming convention — the
method must be `load(f :: File{format"Newick"}, ...)` inside the
`LineagesIO` module (not extending `FileIO.load` directly). Implement the
corresponding `load` for `Stream{format"Newick"}` to support stream I/O.
Both methods accept the `builder` keyword argument (passed through to the
orchestration layer) and any other keyword arguments the orchestration layer
accepts. Implement the ambiguous-extension error: if a file extension maps to
more than one registered format and no explicit `File{format"..."}` override
is present, raise `ArgumentError` naming the file path and the conflicting
format names. Implement a `save` stub that raises a descriptive error stating
that Newick serialization is not yet implemented. Per `design/brief.md
§Implementation decisions`, the adapter must not hard-code format-specific
logic that would require modification when new formats are registered — use
the `add_format` dispatch architecture to keep the adapter open. Per
`STYLE-julia.md §1.13.2`, add return type annotations on all public-facing
functions.

---

### 2. Implement the view layer

**Type**: WRITE
**Output**: `src/views.jl` exists and is included from `src/LineagesIO.jl`;
`loadfirst`, `loadone`, and the multi-source `load([paths...], ...)` form are
implemented; `loadfirst` raises an error if the source contains no graphs;
`loadone` raises an error if the source contains zero or more than one graph;
`LineageGraphStore.graphs` is a lazy non-materializing iterator whose type is fully
determined at compile time; all public functions have complete docstrings;
test suite still passes
**Depends on**: Task 1

Add `src/views.jl` and add `include("views.jl")` in `src/LineagesIO.jl`.
Implement `loadfirst(path; builder=nothing, kwargs...) :: LineageGraphAsset` — loads
the source and returns the first `LineageGraphAsset`; raises an error if the source
yields zero graphs. Implement `loadone(path; builder=nothing, kwargs...) ::
LineageGraphAsset` — loads the source, asserts exactly one graph is present, and
returns it; raises `ArgumentError` if the count is zero or greater than one.
Implement the multi-source `load([path1, path2, ...], format; builder=nothing,
kwargs...) :: LineageGraphStore` form as specified in `01_prd.md §View layer (user
stories 32–40)`. In all forms, `LineageGraphStore.graphs` must be a lazy iterator:
it must not materialize all graphs into a `Vector` eagerly. Choose a concrete
lazy iterator type whose type parameters are fully determined at compile time,
so the return type of `load` is type-stable. Per `STYLE-julia.md §1.13.2`,
add return type annotations on all public functions. Per `STYLE-julia.md §1.13`,
annotate all arguments at the correct level of abstraction. Write complete
docstrings on all three public functions describing their semantics, error
conditions, and the laziness guarantee of `LineageGraphStore.graphs`.

---

### 3. Write tests and verify green state

**Type**: TEST
**Output**: `test/test_fileio.jl` and `test/test_views.jl` created and
included from `test/runtests.jl`; all required tests pass with field-level
value verification; Aqua and JET report no issues; this tranche completes the
first end-to-end path: `.nwk` file → `LineageGraphStore` → `LineageGraphAsset`
**Depends on**: Tasks 1, 2

Create `test/test_fileio.jl` with a named `@testset "fileio"` block. Required
tests: (a) auto-detection: `load("test/fixtures/newick/simple.nwk")` returns a
`LineageGraphStore`; verify it without the `File{format"Newick"}` wrapper; (b)
explicit format override: `load(File{format"Newick"}("path"), ...)` routes to
the Newick backend regardless of extension; (c) stream I/O: `open(path) do io;
load(Stream{format"Newick"}(io)); end` returns a `LineageGraphStore`; (d) ambiguous
extension error: given a path whose extension maps to multiple formats (set up
two formats in the test, or simulate the condition), confirm `ArgumentError` is
raised naming the conflicting formats; (e) save stub: calling `save` on a
Newick path raises the expected error. Create `test/test_views.jl` with a named
`@testset "views"` block. Required tests: (f) `loadfirst` on `simple.nwk`:
verify the returned `LineageGraphAsset` has the correct node count, leaf labels, and
edge lengths against fixture ground truth (field-level verification, not just
existence); (g) `loadone` on `simple.nwk`: same field-level verification; (h)
`loadone` error on multi-tree: given `multitree.nwk`, confirm `loadone` raises
an error; (i) `loadfirst` error on empty source: given a file that produces
zero graphs, confirm `loadfirst` raises an error; (j) multi-source `load`:
given two `.nwk` paths, confirm the returned `LineageGraphStore` contains graphs from
both sources; (k) `LineageGraphStore.graphs` laziness: confirm the iterator type is
not `Vector` and does not eagerly materialize. Add
`include("test_fileio.jl")` and `include("test_views.jl")` to
`test/runtests.jl`. Run `julia --project=test test/runtests.jl` and confirm
all tests pass, `Aqua.test_all(LineagesIO)` reports no issues, and
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no
issues. Search all identifiers added in this tranche for proscribed vocabulary
terms from `STYLE-vocabulary.md` and confirm no matches.
