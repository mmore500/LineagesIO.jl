---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 4: Newick parser

Parent tranche: Tranche 4
Parent PRD: `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

## Governance

All tasks in this file must comply, line by line, with the following governance
documents. Read every document in full before planning or writing a single line
of implementation. This obligation must be passed forward into any downstream
delegated work derived from these tasks.

**Governance documents (all mandatory, line by line):**

- `STYLE-architecture.md` — ownership boundaries; anti-fix prohibition;
  green-state discipline
- `STYLE-docs.md` — documentation formatting standards
- `STYLE-git.md` — commit style and branching model
- `STYLE-julia.md` — functional design; type annotations; return type
  annotations (§1.13.2); bare `using` prohibition (§5); module curation (§8)
- `STYLE-upstream-contracts.md` — host-framework contract reading; every
  design decision that diverges from established patterns in the upstream Newick
  parser references must be flagged in a code comment explaining why
- `STYLE-verification.md` — field-level value verification; weak-proxy
  prohibition; tests must verify individual node labels, edge lengths, and
  bootstrap values against fixtures — not just that parsing succeeds
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms. Key
  constraints: `node` not `vertex`; `edge` not `branch`; `leaf`/`leaves` not
  `tip`/`terminal`; `edgelength` not `branch_length`
- `STYLE-workflow-docs.md` — revalidation rule; pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` — §Parsing layer; §Builder protocol (Parse order);
  §Format support — Phase 1; §Newick submodule module design
- `design/brief--community-support-objectives.md` — §Phylo.jl parse approach
  (token-based recursive descent; NHX metadata; Newick grammar)
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §Newick format
  (user stories 28–31); §Testing and verification decisions — Newick parser;
  §Error handling (user stories 60–61)

**Upstream primary sources (all mandatory, line by line, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read all three sources line by line before writing a single line of
implementation. Understand where they agree and diverge. Any design decision
that diverges from established patterns in these sources must be flagged in a
code comment explaining why.

- `NewickTree.jl/src/` — stack-based Julia Newick parser; tokenization
  strategy; traversal approach; multi-tree file handling; label and edge-length
  parsing
- `DendroPy/` — Python reference for Newick parsing architecture; builder
  pattern design; tokenizer design; how the builder is decoupled from the parser
- `Phylo.jl/src/` — combinator-based Julia Newick parser; NHX/beast
  `[&key=value]` metacomment parsing via `parsedict`; bootstrap as internal
  node number before first branch; `parsenewick`, `parsenewick!` structure

Read-only git and shell commands may be used freely. Mutating git operations
remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code:

1. Read all files added or modified by Tranches 1, 2, and 3 in full, line
   by line. Do not assume any description matches the code — verify each
   independently.
2. Confirm `julia --project=test test/runtests.jl` passes with Aqua and JET
   clean. If it does not, stop and escalate before proceeding.
3. Verify that the orchestration layer interface in `src/orchestration.jl`
   matches the description in `01_prd.md §Builder protocol orchestration module
   design` — specifically, how the format parser signals the tier and emits
   `add_child` calls. If any discrepancy is found, escalate before proceeding.

## Tranche execution rule

The Newick parser is an internal submodule; users access it through the FileIO
adapter (Tranche 5), not directly. The parser owns no architectural invariants
beyond Newick format semantics — all node indexing, label passthrough,
`finalize_graph!` invocation, and `LineageGraphAsset` assembly are owned by the
orchestration layer. The tranche must begin and end with all tests passing,
Aqua and JET clean.

## Tasks

### 1. Create Newick test fixtures

**Type**: WRITE
**Output**: `test/fixtures/newick/` directory exists with exactly five fixture
files, each with a documented comment header stating its structure and expected
parse results
**Depends on**: none

Create the directory `test/fixtures/newick/` and add the following files:

`simple.nwk` — a basic rooted tree with at least 4 nodes, all with explicit
edge lengths and leaf labels. Document the expected node count, each leaf label,
and each edge length in a comment at the top of the file.

`internal_labels.nwk` — a tree with internal node labels in addition to leaf
labels. Document which nodes have labels and what those labels are.

`multitree.nwk` — a file containing at least 3 trees separated by `;`. Each
tree should have a distinct structure. Document the expected tree count and the
node count of each tree.

`empty_labels.nwk` — a tree where at least 2 nodes have empty labels (i.e.,
no label text). Document which nodes are empty-labeled. The expected node table
entry for each empty-label node has `label == ""`; no synthetic label is
generated by the orchestration layer.

`bootstrap.nwk` — a tree with bootstrap values as numbers at internal node
positions (the Phylo.jl convention: a number at an internal node position
before the first `:` is interpreted as a bootstrap value). Document the expected
bootstrap values and at which nodes they appear.

These fixtures are the authoritative ground truth for all Newick parser tests.
Do not modify them after the parser tests are written.

---

### 2. Implement Newick discovery pass

**Type**: WRITE
**Output**: `src/parsers/Newick.jl` exists and is included from
`src/LineagesIO.jl`; it declares `:single_parent` protocol before any parsing;
it performs a discovery pass over the full source before emitting any
`add_child` calls; it produces `R` and `RE` types via `src/discovery.jl`
**Depends on**: Tranches 1, 2, 3 complete and green

Add `src/parsers/Newick.jl` and add `include("parsers/Newick.jl")` to
`src/LineagesIO.jl`. The parser submodule is internal — it is not a Julia
module with its own `module` declaration; it is an included file inside the
`LineagesIO` module. Implement the discovery pass as specified in `design/
brief.md §Level 1 — Node metadata` and `§Level 2 — Edge metadata`: scan the
entire source (all trees in a multi-tree file) before calling any `add_child`.
Collect every annotation key name present across all nodes (e.g., bootstrap
values stored as internal node annotations) and all edges (always include
`edgelength :: Union{Float64, Nothing}`). Use `build_schema` from
`src/discovery.jl` to produce `R` (node row type) and `RE` (edge row type).
The protocol declaration (`:single_parent`) must be communicated to the
orchestration layer before the discovery pass begins. Read the three upstream
Newick parser references before implementing any tokenization or traversal
logic — understand their approaches and note any deliberate divergences in
comments.

---

### 3. Implement Newick parser

**Type**: WRITE
**Output**: `src/parsers/Newick.jl` parses standard Newick notation including
edge lengths, internal node labels, multi-tree files, empty labels, and
bootstrap values; `add_child` is emitted via the orchestration layer in
pre-order (top-down) traversal; parse errors include source file name and
location
**Depends on**: Task 2

After the discovery pass completes and `R`/`RE` types are fixed, parse the
source and emit `add_child` calls via the orchestration layer. Traversal must be
pre-order (top-down): for each node, call `add_child` for the node before
calling it for any of its children. Per `design/brief.md §Parse order`, for
inside-out formats like Newick the parser completes tokenization and builds full
internal state before emitting any `add_child` calls — do not interleave
tokenization with `add_child` emission. Required parsing features: edge lengths
after `:` tokens; internal node labels before `:` or after `)`;  multi-tree
files with trees separated by `;`; empty labels (parser passes `""` to orchestration layer; label is unchanged); bootstrap values at internal node
positions as per Phylo.jl convention (a number before the first `:` at an
internal node is bootstrap). Track source location (line and character offset)
during tokenization and include the source file path and location in all error
messages. For malformed Newick, raise an error naming the source file.
Implement source-location tracking as specified in `01_prd.md §Error handling
(user stories 60–61)`.

---

### 4. Write tests and verify green state

**Type**: TEST
**Output**: `test/test_newick.jl` created and included from `test/runtests.jl`;
all required tests pass with field-level value verification; Aqua and JET
report no issues
**Depends on**: Tasks 1, 3

Create `test/test_newick.jl` with a named `@testset "newick"` block. All tests
must verify field-level values against the fixtures from Task 1 — tests that
only verify that parsing succeeds (without checking specific values) do not
satisfy the requirement. Define a minimal `TestNode` type and `add_child`
extension within the test file. The following tests are required:

(a) Simple tree: parse `simple.nwk`; verify node count, each leaf label
individually, each edge length individually against the documented fixture
values.
(b) Internal labels: parse `internal_labels.nwk`; verify that internal node
labels appear in the node table rows with correct values.
(c) Multi-tree: parse `multitree.nwk`; verify exactly 3 `LineageGraphAsset` values
are produced and each has the documented node count.
(d) Empty labels: parse `empty_labels.nwk`; verify that the node table entries
for the empty-label nodes have `label == ""`, and that a join on `node_idx`
from those rows against the node table works correctly.
(e) Bootstrap: parse `bootstrap.nwk`; verify that `nodedata.bootstrap` at each
`add_child` call site for the bootstrap-annotated nodes contains the correct
value as documented in the fixture; verify the value is present in the
assembled node table.
(f) Pre-order invariant: verify that for each non-root node's `add_child` call,
`parent` is the handle returned by the `add_child` call for its direct ancestor.
(g) Error: given a malformed Newick string, verify an error is raised that
includes the source location information.

Note: at this tranche, there is no FileIO adapter yet — tests must invoke the
parser directly through the orchestration layer's internal API, not via `load`.

Add `include("test_newick.jl")` to `test/runtests.jl`. Run
`julia --project=test test/runtests.jl` and confirm all tests pass,
`Aqua.test_all(LineagesIO)` reports no issues, and
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no issues.
Search all identifiers added in this tranche for proscribed vocabulary terms
from `STYLE-vocabulary.md` and confirm no matches.
