---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 10: Stabilization, compliance audit, and release preparation

Parent tranche: Tranche 10
Parent PRD: `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

## Governance

All tasks in this file must comply, line by line, with the following governance
documents. Read every document in full before planning or writing a single line
of implementation. This obligation must be passed forward into any downstream
delegated work derived from these tasks.

**Governance documents (all mandatory, line by line):**

- `STYLE-architecture.md` — ownership boundaries; anti-fix prohibition;
  green-state discipline; one invariant, one owner; any fix that appears to
  cross ownership boundaries must be escalated, not silently patched
- `STYLE-docs.md` — documentation formatting standards; sentence case headings;
  no `---` separators between sections; complete docstrings on all exported
  symbols
- `STYLE-git.md` — commit style and branching model
- `STYLE-julia.md` — all sections; this tranche is the final compliance gate
  before release
- `STYLE-upstream-contracts.md` — host-framework contract reading; confirm
  FileIO, Tables.jl, AbstractTrees.jl, PhyloNetworks, and Phylo contracts are
  all satisfied
- `STYLE-verification.md` — field-level value verification; weak-proxy
  prohibition; all tests added in this tranche must use field-level checks, not
  existence checks
- `STYLE-vocabulary.md` — full vocabulary audit across every identifier in
  every source file; no proscribed terms may remain
- `STYLE-workflow-docs.md` — revalidation rule; pass-forward obligations
- `STYLE-writing.md` — prose style for all documentation
- `CONTRIBUTING.md` — contribution process; documentation requirements; test
  requirements

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` — full document; all sections; this tranche validates
  that the implementation matches the design
- `design/brief--community-support-objectives.md` — full document; confirm
  all community support objectives are satisfied
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — full document;
  all user stories and implementation decisions; this tranche validates that
  every user story is satisfied by the implementation

**Upstream primary sources (all mandatory, line by line):**

- `fileio.jl/src/` — final verification that the FileIO adapter conforms to
  all FileIO backend contracts
- `AbstractTrees.jl/` — verify all node handle types that LineagesMakie will
  consume satisfy AbstractTrees traversal traits

Read-only git and shell commands may be used freely. Mutating git operations
remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code:

1. Read every file in `src/` and `ext/` in full, line by line.
2. Read every file in `test/` in full, line by line.
3. Read `README.md`, `docs/` (if present), and `CONTRIBUTING.md` in full.
4. Confirm `julia --project=test test/runtests.jl` passes with Aqua and JET
   clean. If it does not, stop, document all failures, and escalate before
   proceeding.
5. Confirm both extension environments (PhyloNetworksExt, PhyloExt) pass their
   tests when loaded. If either fails, escalate before proceeding.

## Tranche execution rule

This tranche makes no new features. Its sole mandate is to bring the full
codebase to a documented, tested, policy-compliant, release-ready state.
Any substantive architectural issue found here — ownership boundary violation,
missing contract, incorrect invariant — must be escalated to the project owner
rather than silently fixed. Small, clearly isolated compliance issues (a
proscribed term in a single identifier, a missing return type annotation on a
private helper) may be fixed directly, with the fix described in the review
output. The tranche must begin and end with all tests passing, Aqua and JET
clean, and all documentation complete.

## Tasks

### 1. Full compliance audit

**Type**: REVIEW
**Output**: A written audit report (`03_tranche-10--audit.md` in this
directory) documenting every issue found across all governance dimensions;
issues are classified as (a) must-fix before release, (b) recommended fix,
or (c) known limitation with documented rationale
**Depends on**: Tranches 1–9 complete and green

Read every file in `src/`, `ext/`, `test/`, `docs/`, `README.md`, and
`CONTRIBUTING.md`. For each governance dimension below, check every applicable
file and record any violation or gap:

**Vocabulary**: search all identifiers, struct field names, function parameter
names, docstring text, and comment text for proscribed terms from
`STYLE-vocabulary.md`. Record every match with file and line number.

**Type annotations**: verify that every exported function has explicit argument
type annotations per `STYLE-julia.md §1.13` and explicit return type
annotations per `§1.13.2`. Record every missing annotation.

**Struct concreteness**: verify that no struct has abstractly typed fields per
`STYLE-julia.md §1.12`. Record any violation.

**Bare `using`**: verify that no source file uses bare `using Package` per
`STYLE-julia.md §5`. Record any violation.

**Module curation**: verify that `src/LineagesIO.jl` contains only the module
declaration, `using`/`import` statements, and `include` calls per
`STYLE-julia.md §8`. Record any implementation code in the module file.

**Docstrings**: verify that every exported function and every exported type has
a complete docstring describing its purpose, parameters, return value, and any
errors it may raise. Record every missing or incomplete docstring.

**Tables.jl compliance**: verify that `GraphAsset.node_table` and
`GraphAsset.edge_table` satisfy the Tables.jl interface by checking
`Tables.istable` returns `true`.

**AbstractTrees compatibility**: verify that `PhyloNetworksNodeHandle` and
`PhyloNodeRef` satisfy the AbstractTrees traversal traits required by
LineagesMakie.

**PRD coverage**: for each user story in `01_prd.md`, verify whether a
corresponding test exists that exercises it. Record every user story without
test coverage.

**Ownership boundaries**: verify that no parser file (`src/parsers/`) assigns
`node_idx`, modifies or synthesizes labels (labels must pass through unchanged),
calls `finalize_graph!`, or assembles `GraphAsset`. Verify that no extension file (`ext/`) performs
orchestration logic. Record any violation.

Write the results to `03_tranche-10--audit.md`. Group findings by dimension.
Mark each finding with its severity classification.

---

### 2. Fix must-fix issues

**Type**: WRITE
**Output**: All issues classified as must-fix in Task 1 are resolved; no new
issues are introduced; the test suite continues to pass
**Depends on**: Task 1

Address every must-fix issue from the audit in Task 1. For each fix:

- Make the smallest change that resolves the issue without touching unrelated
  code.
- If a fix requires changing a function signature or struct field name, verify
  all call sites before making the change.
- If a fix appears to require crossing an ownership boundary (e.g., moving
  logic between the parser and the orchestration layer), stop and escalate
  rather than making the change unilaterally.
- After each fix, run `julia --project=test test/runtests.jl` to confirm the
  test suite still passes.
- Document each fix in the audit report: add a "Resolution" note to the
  corresponding finding.

After all fixes are applied, run the full test suite one final time and confirm
all tests pass, Aqua and JET are clean.

---

### 3. Tables.jl compliance verification tests

**Type**: TEST
**Output**: `test/test_tables_compliance.jl` exists; it verifies
`Tables.istable`, `Tables.schema`, column access, and row iteration on both
`node_table` and `edge_table` for all three format parsers; Aqua and JET
report no issues
**Depends on**: Task 2

Create `test/test_tables_compliance.jl` with a named `@testset "tables_compliance"`
block. For each of the three format parsers (Newick, LineageNetwork,
LineageGraphML), load a fixture file and run the following checks on the
resulting `GraphAsset`: (a) `Tables.istable(asset.node_table)` returns `true`;
(b) `Tables.istable(asset.edge_table)` returns `true`; (c)
`Tables.schema(asset.node_table)` returns a schema with the expected column
names and types (field-level verification against fixture ground truth); (d)
`Tables.schema(asset.edge_table)` returns a schema including `src_node_idx`,
`dst_node_idx`, and `edgelength` columns; (e) iterating rows of
`asset.node_table` yields rows with the correct field values for each node;
(f) `@inferred` on column access produces no type instability. Add
`include("test_tables_compliance.jl")` to `test/runtests.jl`.

---

### 4. LineagesMakie interoperability verification

**Type**: TEST
**Output**: `test/test_makie_interop.jl` exists; it verifies that node handle
types returned by each format parser satisfy the AbstractTrees traversal traits
required by LineagesMakie; the tests do not load LineagesMakie itself but
verify the interface contracts that LineagesMakie depends on
**Depends on**: Task 2

Create `test/test_makie_interop.jl` with a named `@testset "makie_interop"`
block. Per `STYLE-makie.md` and `AbstractTrees.jl/` upstream source, verify
that the node handle types produced by each format parser satisfy the
AbstractTrees interface: (a) for a loaded Newick `GraphAsset`, verify that
`AbstractTrees.children(handle)` is defined and returns the correct children;
(b) for a loaded LineageNetwork `GraphAsset`, same check; (c) for a loaded
LineageGraphML `GraphAsset`, same check; (d) for `PhyloNetworksNodeHandle`
(if PhyloNetworks is available), verify AbstractTrees compatibility; (e) for
`PhyloNodeRef` (if Phylo is available), same check. All checks must verify
field-level values, not merely that the method is defined. Add
`include("test_makie_interop.jl")` to `test/runtests.jl`.

---

### 5. Update README and write CHANGELOG entry

**Type**: WRITE
**Output**: `README.md` describes the `add_child` protocol, both dispatch
levels, `finalize_graph!`, `GraphAsset`, `GraphStore`, all three supported
formats, both extensions, and the `loadfirst`/`loadone`/`load` view functions;
`CHANGELOG.md` has a `[1.0.0]` entry listing all user-facing features
delivered in Phase 1; all prose follows `STYLE-writing.md`; all identifiers
in prose match `STYLE-vocabulary.md`
**Depends on**: Tasks 1, 2

Update `README.md` to cover: (a) installation; (b) the `add_child` protocol
with a minimal usage example showing method extension for a custom node type;
(c) `finalize_graph!` hook with a brief description and when to override it;
(d) `GraphAsset` and `GraphStore` — what they are, how to access `node_table`,
`edge_table`, and `graph_rootnode`; (e) supported formats and their extensions;
(f) `loadfirst`, `loadone`, and multi-source `load` with brief examples;
(g) PhyloNetworksExt and PhyloExt — how to trigger them and what they return.
Write `CHANGELOG.md` (or add a `[1.0.0]` section if the file exists) listing
all user-facing features delivered in this phase. Per `STYLE-writing.md`,
use active voice, present tense, and economy. Per `STYLE-docs.md`, use
sentence case headings and no `---` separators between sections.

---

### 6. Final gate: complete test suite and policy confirmation

**Type**: TEST
**Output**: `julia --project=test test/runtests.jl` passes with zero failures;
`Aqua.test_all(LineagesIO)` reports no issues; `JET.test_package(LineagesIO;
target_defined_modules = true)` reports no issues; vocabulary audit shows zero
proscribed terms across all files; every exported symbol has a complete
docstring
**Depends on**: Tasks 1, 2, 3, 4, 5

Run `julia --project=test test/runtests.jl` and report the full output.
Run `Aqua.test_all(LineagesIO)` and report any issues. Run
`JET.test_package(LineagesIO; target_defined_modules = true)` and report any
issues. Perform a final vocabulary search across all files in `src/`, `ext/`,
and `test/` for every proscribed term listed in `STYLE-vocabulary.md`; report
any remaining matches. Verify that every symbol in the module's public API
(everything in `export` statements) has a complete docstring. If any issues
remain, classify them and escalate — do not declare the tranche done until
all gates pass.
