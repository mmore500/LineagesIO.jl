---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 3: Builder protocol orchestration

Parent tranche: Tranche 3
Parent PRD: `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

## Governance

All tasks in this file must comply, line by line, with the following governance
documents. Read every document in full before planning or writing a single line
of implementation. This obligation must be passed forward into any downstream
delegated work derived from these tasks.

**Governance documents (all mandatory, line by line):**

- `STYLE-architecture.md` — ownership boundaries; anti-fix prohibition;
  green-state discipline; one invariant, one owner
- `STYLE-docs.md` — documentation formatting standards
- `STYLE-git.md` — commit style and branching model
- `STYLE-julia.md` — functional design; type annotations; return type
  annotations (§1.13.2); bare `using` prohibition (§5); mutation contract (§4)
- `STYLE-upstream-contracts.md` — host-framework contract reading
- `STYLE-verification.md` — field-level value verification; weak-proxy
  prohibition
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms. Key
  constraints: `node_idx` (not `id`, `index`, `num`); `rootnode` not `root`;
  `add_child` (canonical function name); `finalize_graph!` (canonical hook name);
  `LineageGraphAsset`/`LineageGraphStore` (canonical return type names); `tranche` not `issue`
- `STYLE-workflow-docs.md` — revalidation rule; pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` — §Builder protocol (Protocol determination; Semantics;
  Parse order); §Builder protocol orchestration module design;
  §finalize_graph! as protocol function (Implementation decision 3);
  §Implementation decisions 1–8
- `design/brief--community-support-objectives.md` — full document; extension
  architecture context for `finalize_graph!` invocation
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §Protocol
  determination and builder validation (user stories 6–8); §Builder protocol
  method extension (user stories 1–3) and callback style (user stories 4–5);
  §Node index and label (user stories 17–18); §Builder protocol orchestration
  module design; §finalize_graph! protocol hook module design;
  §Implementation decisions 1–8

**Upstream primary sources (mandatory, line by line):**

- `fileio.jl/src/` — confirm the orchestration interface is compatible with
  how the FileIO adapter will invoke it in Tranche 5; in particular, understand
  how FileIO dispatches to backend `load` and what arguments are available

Read-only git and shell commands may be used freely. Mutating git operations
remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code:

1. Read all files added or modified by Tranches 1 and 2 in full, line by line.
   Do not assume any description matches the code — verify each independently.
2. Confirm `julia --project=test test/runtests.jl` passes with Aqua and JET
   clean. If it does not, stop and escalate before proceeding.
3. Verify that `add_child` signatures, `finalize_graph!` contract, and discovery
   pass output types in the existing code match `design/brief.md` and
   `01_prd.md` exactly. Flag any discrepancy before writing code.

## Tranche execution rule

The orchestration layer owns the following invariants exclusively: protocol tier
routing, builder validation, `node_idx` assignment, label passthrough,
`finalize_graph!` invocation timing, and `LineageGraphAsset` assembly. No other layer
may enforce or re-enforce these rules. Violations of this principle are
architectural smells that must be escalated per `STYLE-architecture.md`. The
tranche must begin and end with all tests passing, Aqua and JET clean.

## Tasks

### 1. Implement tier routing and builder validation gate

**Type**: WRITE
**Output**: `src/orchestration.jl` exists and is included from
`src/LineagesIO.jl`; the orchestration layer accepts a protocol tier declaration
(`:network` or `:single_parent`) from format parsers; it validates builder
compatibility before the first `add_child` call; incompatible builders raise
`ArgumentError` naming the builder type and the declared tier; `builder` kwarg
takes precedence over extended methods
**Depends on**: Tranches 1 and 2 complete and green

Add `src/orchestration.jl` and add `include("orchestration.jl")` in
`src/LineagesIO.jl`. Implement the tier routing logic as specified in
`design/brief.md §Protocol determination`: the tier is received from the format
parser as a symbol (`:network` or `:single_parent`), determined once, and fixed
for the entire load. Per `01_prd.md §Implementation decision 1`, per-call
dispatch based on `length(parents)` at call time is explicitly rejected — do
not implement it. Implement the builder validation gate: before the first
`add_child` call, inspect whether the user's builder (either extended methods
or the `builder` callback) is compatible with the declared tier. For `:network`
tier with a builder that defines only single-parent overloads, raise
`ArgumentError` with a message identifying the builder type and the tier
mismatch; this must happen before any parse work begins. When a `builder`
keyword argument is present, route all `add_child` calls to it directly and do
not dispatch to extended `LineagesIO.add_child` methods — per `01_prd.md
§Implementation decision 8`. Per `STYLE-julia.md §1.13`, annotate all public
functions at the correct level of abstraction; per `§1.13.2`, add explicit
return type annotations.

---

### 2. Implement `node_idx` management and label passthrough

**Type**: WRITE
**Output**: The orchestration layer assigns 1-based sequential `node_idx`
values; `node_idx` resets to 1 at the start of each new graph; `label` is
passed through to `add_child` unchanged; parsers supply `""` for absent labels
**Depends on**: Task 1

Within `src/orchestration.jl`, implement a `node_idx` counter that starts at
1 for each new graph and increments by 1 for each `add_child` call. The counter
is owned by the orchestration layer — parsers do not assign `node_idx`. Pass
`label` from the parser through to `add_child` unchanged, per
`01_prd.md §Implementation decision 5`. Do not maintain a label collision set;
do not generate synthetic labels. When the parser supplies `""` for an absent
label, `""` is what `add_child` receives. `node_idx` is the sole join key;
`label` is informational.

---

### 3. Implement `finalize_graph!` invocation and `LineageGraphAsset` assembly

**Type**: WRITE
**Output**: `finalize_graph!` is called exactly once per graph, after the last
`add_child` call for that graph and before `LineageGraphAsset` is assembled; the
`LineageGraphAsset` is assembled from the accumulated node table rows, edge table rows,
index coordinates, labels, and the entry-point handle; all `LineageGraphAsset` fields
are correctly populated
**Depends on**: Task 2

Within `src/orchestration.jl`, after the format parser signals that the last
`add_child` for a graph has been made, call `finalize_graph!(entry_point_handle)`
and capture its return value (the same handle, or a replacement if the extension
returns a different object). Only after `finalize_graph!` returns, assemble the
`LineageGraphAsset{NodeT}` using the accumulated rows and the returned handle as
`graph_rootnode`. The `LineageGraphAsset` fields `index`, `source_idx`,
`collection_idx`, `collection_graph_idx`, `collection_label`, `graph_label`,
`node_table`, `edge_table`, `graph_rootnode`, and `source_path` must all be
populated correctly per `01_prd.md §Return types`. The node table must carry one
row per node with `node_idx` as its primary key; the edge table must carry one
row per directed edge with `src_node_idx`, `dst_node_idx`, and `edgelength`
columns at minimum. The assembly logic must be type-stable: the type of
`LineageGraphAsset{NodeT}` including all table type parameters must be fully
determined at compile time.

---

### 4. Write tests and verify green state

**Type**: TEST
**Output**: `test/test_orchestration.jl` created and included from
`test/runtests.jl`; all required tests pass; Aqua and JET report no issues
**Depends on**: Tasks 1, 2, 3

Create `test/test_orchestration.jl` with a named `@testset "orchestration"`
block. Define minimal test types and mock parsers within the test file. The
following tests are required:

(a) Incompatible builder detection: given a `:network` tier declaration and a
builder that defines only single-parent overloads, confirm `ArgumentError` is
raised before any `add_child` call is made; verify by counting calls — zero
`add_child` calls should occur.
(b) `builder` kwarg precedence: given both extended `LineagesIO.add_child`
methods and a `builder` callback in the same load call, confirm only the
callback is invoked.
(c) `node_idx` sequencing: given a graph with 5 nodes, confirm `node_idx`
values assigned are 1, 2, 3, 4, 5 in traversal order.
(d) `node_idx` reset: given two graphs in a multi-graph source, confirm the
second graph's first `node_idx` is 1.
(e) Empty label passthrough: given a node with empty label, confirm the
assembled node table entry has label `""`.
(f) `finalize_graph!` timing: define a mock extension that overrides
`finalize_graph!` and records when it is called; confirm it is called exactly
once per graph, after the last `add_child` but before the `LineageGraphAsset` is
returned.
(g) `LineageGraphAsset` field correctness: after a complete mock parse, verify
`graph_rootnode`, `node_table`, and `edge_table` fields contain the expected
values — not just that they exist.

Add `include("test_orchestration.jl")` to `test/runtests.jl`. Run
`julia --project=test test/runtests.jl` and confirm all tests pass,
`Aqua.test_all(LineagesIO)` reports no issues, and
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no issues.
Search all identifiers added in this tranche for proscribed vocabulary terms
from `STYLE-vocabulary.md` and confirm no matches.
