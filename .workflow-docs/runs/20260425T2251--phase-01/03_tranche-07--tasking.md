---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 7: LineageGraphML parser

Parent tranche: Tranche 7
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
- `STYLE-upstream-contracts.md` — host-framework contract reading; divergence
  authorization; every design decision that diverges from established GraphML
  structural patterns must be flagged in a code comment explaining why
- `STYLE-verification.md` — field-level value verification; weak-proxy
  prohibition; tests must verify individual node labels, edge lengths, and all
  phylogeny-profile attributes against fixtures — not just that parsing succeeds
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms. Key
  constraints: `node` not `vertex`; `edge` not `branch`; `leaf`/`leaves` not
  `tip`/`terminal`; `edgelength` not `branch_length`; `rootnode` not `root`
- `STYLE-workflow-docs.md` — revalidation rule; pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` — §LineageGraphML format; §GraphML profile (phylogeny
  namespace attributes); §Single-parent protocol (`:single_parent` tier);
  §Format detection policy (content sniffing for `.xml` ambiguity); §Builder
  protocol (Parse order); §Discovery pass contract; §Implementation decisions
  1–8
- `design/brief--community-support-objectives.md` — §GraphML content sniffing
  approach; §phylogeny namespace declaration as detection signal; community
  context for GraphML use in phylogenetics
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §LineageGraphML
  format (user stories 57–59); §Format detection policy (ambiguous `.xml`
  handling); §Error handling (user stories 60–61)

**Upstream primary sources (all mandatory, line by line, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read all sources line by line before writing a single line of implementation.
Any design decision that diverges from established patterns must be flagged in
a code comment explaining why.

- `fileio.jl/src/` — `magic` argument in `add_format`; how FileIO supports
  content sniffing for ambiguous extensions (e.g., `.xml`); confirm that the
  format detection policy for `.xml` can be implemented without modifying the
  Newick or LineageNetwork adapter code

Read-only git and shell commands may be used freely. Mutating git operations
remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code:

1. Read all files added or modified by Tranches 1, 2, 3, 4, 5, and 6 in full,
   line by line. Do not assume any description matches the code — verify each
   independently.
2. Confirm `julia --project=test test/runtests.jl` passes with Aqua and JET
   clean. If it does not, stop and escalate before proceeding.
3. Read the FileIO `magic` / content-sniffing API in `fileio.jl/src/query.jl`
   and `types.jl` to confirm how format sniffing works for `.xml` files.
   If FileIO does not support content sniffing in the expected way, escalate
   before designing the detection policy.
4. Verify that the orchestration layer and the existing FileIO adapter can
   accommodate `format"LineageGraphML"` without modification. If any
   modification is needed, escalate before proceeding.

## Tranche execution rule

The LineageGraphML parser operates under the `:single_parent` protocol tier,
identical to the Newick parser in that respect. Its distinguishing complexity
is (a) XML parsing, (b) phylogeny-profile attribute extraction into the
discovery schema, and (c) content-sniffing for `.xml` extension disambiguation.
The parser owns no architectural invariants beyond LineageGraphML format
semantics. The tranche must begin and end with all tests passing, Aqua and JET
clean.

## Tasks

### 1. Create LineageGraphML test fixtures

**Type**: WRITE
**Output**: `test/fixtures/lineagegraphml/` directory exists with exactly four
fixture files, each with a documented comment header stating its structure,
phylogeny-profile attributes, and expected parse results
**Depends on**: none

Create the directory `test/fixtures/lineagegraphml/` and add the following
files:

`simple_tree.graphml` — a valid LineageGraphML file encoding a rooted tree
with at least 4 nodes, all with explicit edge lengths and leaf labels. Include
the phylogeny namespace declaration. Document the expected node count, leaf
labels, and edge lengths.

`phylo_attributes.graphml` — a tree with phylogeny-profile attributes on nodes
(e.g., `taxon`, `population_size`, or other phylogeny-specific keys). Document
each attribute key, which nodes carry it, and the expected values.

`internal_labels.graphml` — a tree with labels on internal nodes as well as
leaves. Document which nodes have internal labels.

`ambiguous_xml.graphml` — a valid LineageGraphML file with a `.xml` extension
(rename or symlink from `simple_tree.graphml`). Document the expected behavior:
the format sniffer must identify it as `format"LineageGraphML"` based on the
phylogeny namespace declaration in its content.

These fixtures are the authoritative ground truth for all LineageGraphML parser
tests. Do not modify them after the parser tests are written.

---

### 2. Implement LineageGraphML discovery pass

**Type**: WRITE
**Output**: `src/parsers/LineageGraphML.jl` exists and is included from
`src/LineagesIO.jl`; it declares `:single_parent` protocol before any parsing;
it performs a discovery pass over the entire XML source before emitting any
`add_child` calls; it produces `R` and `RE` types via `src/discovery.jl`
including all phylogeny-profile attribute keys found in the document
**Depends on**: Tranches 1, 2, 3, 4, 5, 6 complete and green

Add `src/parsers/LineageGraphML.jl` and add
`include("parsers/LineageGraphML.jl")` to `src/LineagesIO.jl`. The file is
an included file inside the `LineagesIO` module, not a standalone Julia module.
Implement the discovery pass: parse the XML structure once to identify all
`<node>` elements, all `<edge>` elements, and all phylogeny-profile attribute
keys present across any node or edge. Use `build_schema` from `src/discovery.jl`
with appropriate `type_overrides` for well-known typed attributes (e.g.,
`edgelength :: Union{Float64, Nothing}`). Declare `:single_parent` protocol to
the orchestration layer before the discovery pass begins. Use only Julia
standard library XML parsing (e.g., `EzXML.jl` if already a dependency, or
the standard-library approach) — do not introduce new dependencies without
explicit project-owner approval and discussion. If the XML parsing approach
requires a new dependency, stop and escalate.

---

### 3. Implement LineageGraphML parser

**Type**: WRITE
**Output**: `src/parsers/LineageGraphML.jl` parses LineageGraphML documents
including edge lengths, internal node labels, and phylogeny-profile attributes;
`add_child` is emitted in pre-order (top-down) traversal; parse errors include
source file name and location; the parser reads the tree structure from GraphML
`<edge>` elements and reconstructs parent-child relationships in traversal
order
**Depends on**: Task 2

After the discovery pass completes and `R`/`RE` types are fixed, parse the
XML and emit `add_child` calls via the orchestration layer. Per
`design/brief.md §Parse order`, for inside-out or structured formats like
GraphML, the parser completes its structural analysis before emitting any
`add_child` calls — do not interleave XML reading with `add_child` emission.
Reconstruct the parent-child traversal order from the GraphML `<edge>`
elements. Extract phylogeny-profile attributes from each `<node>` element and
pass them in `nodedata` at each `add_child` call site. Extract `edgelength`
from each `<edge>` element and pass it in `edgedata`. Track source location
(line and element path) during parsing and include the source file path and
location in all error messages. For malformed GraphML or non-phylogeny `.xml`
files that pass the format sniffer but fail structural validation, raise an
error naming the source file and the specific structural violation.

---

### 4. Register LineageGraphML in the FileIO adapter with content sniffing

**Type**: WRITE
**Output**: `add_format` for `format"LineageGraphML"` is registered with `.graphml`
extension and a content sniffer for `.xml`; a file whose extension is `.xml`
and whose content contains the phylogeny namespace declaration is loaded as
`format"LineageGraphML"`; files with `.xml` extension that do not contain the
namespace declaration raise an `ArgumentError`; no existing adapter code is
modified
**Depends on**: Tasks 1, 2, 3

Add `add_format` registration for `format"LineageGraphML"` in `src/fileio.jl`
with `.graphml` as its primary extension and a `magic` content sniffer for
`.xml` ambiguity per the FileIO sniffer API. Read `fileio.jl/src/query.jl` to
understand the exact `magic` argument format before implementing. A `.xml` file
that contains the LineageGraphML phylogeny namespace declaration must route to
`format"LineageGraphML"`; a `.xml` file that does not match must fall through
and raise `ArgumentError`. Do not modify any existing Newick or LineageNetwork
adapter code.

---

### 5. Write tests and verify green state

**Type**: TEST
**Output**: `test/test_lineagegraphml.jl` created and included from
`test/runtests.jl`; all required tests pass with field-level value
verification; Aqua and JET report no issues
**Depends on**: Tasks 1, 2, 3, 4

Create `test/test_lineagegraphml.jl` with a named `@testset "lineagegraphml"`
block. All tests must verify field-level values against the fixtures from Task
1. The following tests are required:

(a) Simple tree: parse `simple_tree.graphml`; verify node count, each leaf
label, and each edge length individually against fixture ground truth.
(b) Phylogeny attributes: parse `phylo_attributes.graphml`; verify that each
documented attribute key appears in the assembled `node_table` rows with the
correct values.
(c) Internal labels: parse `internal_labels.graphml`; verify that internal
node labels appear in the node table with correct values.
(d) Content sniffing: load `ambiguous_xml.graphml` (with `.xml` extension)
via `load(path)` without an explicit format override; verify it routes to
`format"LineageGraphML"` and returns a correct `LineageGraphStore`.
(e) Non-phylogeny XML error: given a `.xml` file that does not contain the
phylogeny namespace declaration, verify `ArgumentError` is raised.
(f) Pre-order invariant: verify that for each non-root node's `add_child`
call, `parent` is the handle returned by the `add_child` call for its direct
ancestor.
(g) FileIO end-to-end: load `simple_tree.graphml` via `load(path)`; verify
`LineageGraphStore` is returned and `LineageGraphAsset` fields match fixture ground truth.

Add `include("test_lineagegraphml.jl")` to `test/runtests.jl`. Run
`julia --project=test test/runtests.jl` and confirm all tests pass,
`Aqua.test_all(LineagesIO)` reports no issues, and
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no
issues. Search all identifiers added in this tranche for proscribed vocabulary
terms from `STYLE-vocabulary.md` and confirm no matches.
