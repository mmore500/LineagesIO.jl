---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 6: LineageNetwork parser

Parent tranche: Tranche 6
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
  annotations (§1.13.2); bare `using` prohibition (§5); module curation (§8)
- `STYLE-upstream-contracts.md` — host-framework contract reading; divergence
  authorization; every design decision that diverges from established patterns
  in the PhyloNetworks and PhyloNetworksExt upstream references must be
  flagged in a code comment explaining why
- `STYLE-verification.md` — field-level value verification; weak-proxy
  prohibition; tests must verify individual node labels, edge lengths,
  bootstrap values, gamma values, and hybrid node identity against fixtures —
  not just that parsing succeeds
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms. Key
  constraints: `node` not `vertex`; `edge` not `branch`; `leaf`/`leaves` not
  `tip`/`terminal`; `edgelength` not `branch_length`; `rootnode` not `root`;
  `gamma` is the canonical name for hybrid edge inheritance proportion
- `STYLE-workflow-docs.md` — revalidation rule; pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` — §LineageNetwork format; §Network protocol (`:network`
  tier); §Builder protocol (Parse order; network dispatch level); §Hybrid node
  deduplication semantics; §Per-edge gamma at call time; §Implementation
  decisions 1–8
- `design/brief--community-support-objectives.md` — §PhyloNetworks parse
  approach; §PhyloNetworksNodeHandle; §Hybrid node `#H1` token semantics;
  §gamma flow table; §Network tier validation
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §LineageNetwork
  format (user stories 41–50); §Network protocol (user stories 6–8); §Hybrid
  node deduplication (user stories 51–53); §Per-edge gamma semantics (user
  stories 54–56); §Error handling (user stories 60–61)

**Upstream primary sources (all mandatory, line by line, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read all three sources line by line before writing a single line of
implementation. Understand where they agree and diverge. Any design decision
that diverges from established patterns in these sources must be flagged in a
code comment explaining why.

- `PhyloNetworks.jl/src/` — how PhyloNetworks reads extended Newick with
  `#H1` hybrid tokens; how it tracks hybrid nodes by name to detect second
  occurrences; how `gamma` is associated with edges; `readwrite.jl` and
  related parsing files
- `NewickTree.jl/src/` — tokenization approach and stack-based traversal as
  a baseline reference for Newick-extended parsing
- `fileio.jl/src/` — confirm adapter registration pattern is consistent with
  what Tranche 5 established

Read-only git and shell commands may be used freely. Mutating git operations
remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code:

1. Read all files added or modified by Tranches 1, 2, 3, 4, and 5 in full,
   line by line. Do not assume any description matches the code — verify each
   independently.
2. Confirm `julia --project=test test/runtests.jl` passes with Aqua and JET
   clean. If it does not, stop and escalate before proceeding.
3. Verify that the orchestration layer's `:network` tier path in
   `src/orchestration.jl` accepts `parents :: AbstractVector{NodeT}` at each
   `add_child` call site. If the network tier path is absent or incomplete,
   escalate before proceeding.
4. Verify that the FileIO adapter in `src/fileio.jl` can accept a second
   `add_format` call for `format"LineageNetwork"` without modification — confirm
   the adapter's dispatch architecture is open to extension.

## Tranche execution rule

The LineageNetwork parser introduces the `:network` protocol tier and hybrid
node deduplication. The parser owns no architectural invariants beyond
LineageNetwork format semantics and hybrid token recognition — all node
indexing, deduplication across occurrences of the same hybrid token, and
`LineageGraphAsset` assembly remain owned by the orchestration layer. The tranche
must begin and end with all tests passing, Aqua and JET clean.

## Tasks

### 1. Create LineageNetwork test fixtures

**Type**: WRITE
**Output**: `test/fixtures/lineagenetwork/` directory exists with exactly four
fixture files, each with a documented comment header stating its structure,
hybrid nodes, gamma values, and expected parse results
**Depends on**: none

Create the directory `test/fixtures/lineagenetwork/` and add the following
files:

`simple_network.lnw` — a basic network with at least one hybrid node (using
`#H1` token syntax). Document the expected node count, hybrid node label,
both parent edges of the hybrid node, and the gamma value on each parent edge.

`multi_hybrid.lnw` — a network with at least two distinct hybrid nodes
(`#H1`, `#H2`). Document each hybrid's label, its two parents, and the gamma
values on all hybrid edges.

`gamma_values.lnw` — a network where gamma values are explicitly present on
hybrid edges and absent on tree edges. Document which edges carry gamma values
and which do not; document the expected `edgedata.gamma` value at each
`add_child` call site for hybrid edges.

`no_hybrids.lnw` — a valid LineageNetwork file that contains no hybrid nodes
(a pure tree in extended Newick syntax). Document that this should parse
successfully via the `:network` protocol tier with no hybrid deduplication
events.

These fixtures are the authoritative ground truth for all LineageNetwork
parser tests. Do not modify them after the parser tests are written.

---

### 2. Implement LineageNetwork discovery pass

**Type**: WRITE
**Output**: `src/parsers/LineageNetwork.jl` exists and is included from
`src/LineagesIO.jl`; it declares `:network` protocol before any parsing; it
performs a discovery pass identifying all unique hybrid tokens and all
annotation keys; it produces `R` and `RE` types via `src/discovery.jl` with
`gamma :: Union{Float64, Nothing}` as a forced override on edge schema
**Depends on**: Tranches 1, 2, 3, 4, 5 complete and green

Add `src/parsers/LineageNetwork.jl` and add `include("parsers/LineageNetwork.jl")`
to `src/LineagesIO.jl`. The parser file is an included file inside the
`LineagesIO` module, not a standalone Julia module. Implement the discovery
pass as specified in `design/brief.md §LineageNetwork format`: scan the entire
source before calling any `add_child`. The discovery pass must identify every
unique hybrid node token (e.g., `#H1`) — these are nodes that appear twice in
the source; the discovery pass establishes that `add_child` will be called once
for each unique hybrid node but the parser will encounter its token twice.
Collect all annotation keys; pass `type_overrides = (; gamma = Union{Float64,
Nothing})` to `build_schema` for the edge schema so `gamma` is always present
in `RE` regardless of observed values. Declare `:network` protocol to the
orchestration layer before the discovery pass begins. Read the PhyloNetworks
upstream source for how `#H1` tokens are recognized and how second occurrences
are identified.

---

### 3. Implement LineageNetwork parser with hybrid deduplication

**Type**: WRITE
**Output**: `src/parsers/LineageNetwork.jl` parses extended Newick with `#H`
hybrid tokens; `add_child` is emitted exactly once per unique hybrid node
despite the token appearing twice in the source; both parent edges of a hybrid
node trigger `add_child` calls with the correct `parents` vector; gamma values
are present in `edgedata.gamma` at each `add_child` call site for hybrid edges
**Depends on**: Task 2

After the discovery pass completes and `R`/`RE` types are fixed, parse the
source and emit `add_child` calls via the orchestration layer. Per
`design/brief.md §Hybrid node deduplication semantics`: when the parser
encounters a hybrid token (`#H1`) for the first time, it stores the handle
returned by `add_child`; when it encounters the same token a second time, it
uses the stored handle as the `parents` element rather than calling `add_child`
again — the orchestration layer sees exactly one `add_child` call per unique
hybrid node. Per `design/brief.md §Per-edge gamma at call time`: `gamma` must
be present in `edgedata` at the `add_child` call site for each parent edge of
a hybrid node; tree edges carry `edgedata.gamma = nothing`. Traversal must be
pre-order (top-down) after internal state is fully built, consistent with
Tranche 4. Track source location during tokenization and include file path and
location in all error messages. For malformed LineageNetwork input (e.g.,
mismatched hybrid token count, invalid `#H` syntax), raise an error naming the
source file and location. Read the PhyloNetworks upstream source for how it
handles gamma association with edges before implementing this.

---

### 4. Register LineageNetwork in the FileIO adapter

**Type**: WRITE
**Output**: `add_format` for `format"LineageNetwork"` is registered with its
file extensions (`.lnw`, `.lineagenetwork`) in `src/fileio.jl`; the private
`load(::File{format"LineageNetwork"}, ...)` and
`load(::Stream{format"LineageNetwork"}, ...)` methods dispatch to the
orchestration layer; ambiguous-extension error policy applies; no existing
Newick adapter code is modified
**Depends on**: Tasks 1, 2, 3

Add `add_format` registration for `format"LineageNetwork"` in `src/fileio.jl`.
Add the corresponding private `load` methods for `File{format"LineageNetwork"}`
and `Stream{format"LineageNetwork"}`. Do not modify any existing Newick adapter
code — if modification is required, escalate. Verify that the ambiguous-extension
error policy works correctly when a path has an extension shared between two
formats (the policy implemented in Tranche 5 must apply to the new format
without modification).

---

### 5. Write tests and verify green state

**Type**: TEST
**Output**: `test/test_lineagenetwork.jl` created and included from
`test/runtests.jl`; all required tests pass with field-level value
verification; Aqua and JET report no issues
**Depends on**: Tasks 1, 2, 3, 4

Create `test/test_lineagenetwork.jl` with a named `@testset "lineagenetwork"`
block. All tests must verify field-level values against the fixtures from Task
1. The following tests are required:

(a) Simple network: parse `simple_network.lnw`; verify node count, hybrid node
label, and that `add_child` was called exactly once for the hybrid node despite
two token occurrences.
(b) Gamma values: parse `gamma_values.lnw`; verify `edgedata.gamma` at each
hybrid parent edge contains the correct value from the fixture; verify tree
edges have `edgedata.gamma === nothing`.
(c) Multiple hybrids: parse `multi_hybrid.lnw`; verify that each of `#H1` and
`#H2` triggered exactly one `add_child` call; verify their labels and gamma
values individually.
(d) No-hybrid tree: parse `no_hybrids.lnw`; verify it parses successfully
under `:network` protocol with a pure-tree result.
(e) Network protocol tier: confirm that the orchestration layer received a
`:network` declaration before any `add_child` call.
(f) Error: given a malformed LineageNetwork string (e.g., unmatched `#H`
token), verify an error is raised that includes source location information.
(g) FileIO end-to-end: load `simple_network.lnw` via `load(path)` (using
auto-detection); verify `LineageGraphStore` is returned and `LineageGraphAsset` fields match
fixture ground truth.

Add `include("test_lineagenetwork.jl")` to `test/runtests.jl`. Run
`julia --project=test test/runtests.jl` and confirm all tests pass,
`Aqua.test_all(LineagesIO)` reports no issues, and
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no
issues. Search all identifiers added in this tranche for proscribed vocabulary
terms from `STYLE-vocabulary.md` and confirm no matches.
