---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 9: PhyloExt package extension

Parent tranche: Tranche 9
Parent PRD: `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

## Governance

All tasks in this file must comply, line by line, with the following governance
documents. Read every document in full before planning or writing a single line
of implementation. This obligation must be passed forward into any downstream
delegated work derived from these tasks.

**Governance documents (all mandatory, line by line):**

- `STYLE-architecture.md` — ownership boundaries; anti-fix prohibition;
  green-state discipline; extension isolation: the extension must not
  re-implement any logic owned by the orchestration layer
- `STYLE-docs.md` — documentation formatting standards
- `STYLE-git.md` — commit style and branching model
- `STYLE-julia.md` — functional design; type annotations; return type
  annotations (§1.13.2); bare `using` prohibition (§5); module curation (§8)
- `STYLE-upstream-contracts.md` — host-framework contract reading; divergence
  authorization; every design decision that diverges from established Phylo.jl
  API patterns must be flagged in a code comment explaining why
- `STYLE-verification.md` — field-level value verification; weak-proxy
  prohibition; integration tests must verify `RootedTree` topology and node
  labels — not just that loading returns something
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms. Key
  constraints: `node` not `vertex`; `edge` not `branch`; `leaf`/`leaves` not
  `tip`/`terminal`; `edgelength` not `branch_length`; `rootnode` not `root`
- `STYLE-workflow-docs.md` — revalidation rule; pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` — §PhyloExt; §PhyloNodeRef; §Single-parent protocol
  (`:single_parent` tier); §finalize_graph! hook (no-op for PhyloExt);
  §Implementation decisions 1–8
- `design/brief--community-support-objectives.md` — §Phylo.jl parse approach;
  §PhyloNodeRef struct design; §RootedTree construction API; §combinator-based
  Newick parsing in Phylo.jl (read for context on Phylo architecture, not to
  replicate); §NHX metadata handling (for context on Phylo node naming)
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §PhyloExt (user
  stories 1–5, extension-specific); §add_child overload signatures;
  §Package extension declaration (weak deps, [extensions] section);
  §Implementation decision 8 (builder kwarg precedence)

**Upstream primary sources (all mandatory, line by line, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read all sources line by line before writing a single line of implementation.
Any design decision that diverges from established patterns must be flagged in
a code comment explaining why.

- `Phylo.jl/src/` — `RootedTree` struct; node name / label API; how
  `createnode!`, `addbranch!`, and related mutating functions work; which
  functions build the tree incrementally and what arguments they require;
  `RecursiveTree.jl` for traversal; `newick.jl` for how Phylo itself parses
  Newick (read for structural understanding, not to replicate)

**Important**: `[weakdeps]` and `[extensions]` sections cannot be added via
`Pkg.add`. They must be added by editing `Project.toml` directly, with
explicit project-owner approval. Stop and request approval before making any
`Project.toml` changes for this tranche.

Read-only git and shell commands may be used freely. Mutating git operations
remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code:

1. Read all files added or modified by Tranches 1 through 7 in full, line by
   line. Tranche 8 (PhyloNetworksExt) may run in parallel with this tranche;
   if Tranche 8 changes any shared files, read those changes too.
2. Confirm `julia --project=test test/runtests.jl` passes with Aqua and JET
   clean. If it does not, stop and escalate before proceeding.
3. Read `Phylo.jl/src/` in full. Understand the `RootedTree` and node
   construction API before writing a single line of `add_child`.
4. Verify that the orchestration layer's `:single_parent` tier path correctly
   handles both `parent :: Nothing` and `parent :: NodeHandle` overloads. If any
   discrepancy is found, escalate before proceeding.
5. **Stop before any `Project.toml` changes**: read the current
   `Project.toml`, confirm that `Phylo` is not already listed under
   `[weakdeps]` or `[extensions]`, and request project-owner approval to add
   both sections before proceeding with Task 1.

## Tranche execution rule

The `PhyloExt` extension implements the `add_child` overloads that build a
live `RootedTree` object during loading. It owns no orchestration logic — all
`node_idx` assignment, label passthrough, `finalize_graph!` invocation
timing, and `LineageGraphAsset` assembly remain owned by the orchestration layer. The
default `finalize_graph!` no-op is sufficient for Phylo — the extension does
not override it unless a concrete need is identified and escalated. The
extension must be loadable only when `Phylo` is present in the user's
environment. The tranche must begin and end with all tests passing, Aqua and
JET clean in both environments.

## Tasks

### 1. Declare Phylo as a weak dependency

**Type**: CONFIG
**Output**: `Phylo` appears under `[weakdeps]` in `Project.toml`; `PhyloExt`
appears under `[extensions]` mapping to `ext/PhyloExt.jl`; `Project.toml`
changes require explicit project-owner approval before this task begins; the
test suite still passes after the change
**Depends on**: Tranches 1–7 complete and green; project-owner approval for
`Project.toml` modification

**This task requires project-owner approval before any action.** Do not edit
`Project.toml` until the project owner explicitly approves. When approval is
given, add `Phylo` under `[weakdeps]` with its UUID (look up the registered
UUID from the Julia General registry or the upstream source — do not guess; if
uncertain, ask). Add `PhyloExt = ["Phylo"]` under `[extensions]`. Do not use
`Pkg.add` for this step — edit `Project.toml` directly with the approval.
After editing, run `julia --project=test test/runtests.jl` and confirm the
test suite still passes.

---

### 2. Implement `PhyloNodeRef` and the entry-point `add_child`

**Type**: WRITE
**Output**: `ext/PhyloExt.jl` exists; `PhyloNodeRef` wraps a `RootedTree`
and a node name (or handle type as used by Phylo); the entry-point
`add_child(parent :: Nothing, ...) :: PhyloNodeRef` creates a new
`RootedTree`, adds the root node, and returns a `PhyloNodeRef`; the struct
is not exported
**Depends on**: Task 1

Create `ext/PhyloExt.jl` as a Julia module named `PhyloExt`. Define
`PhyloNodeRef` as a struct wrapping `tree :: RootedTree` and a node reference
(the exact type depends on the Phylo API — read `Phylo.jl/src/` to determine
the correct node handle type before defining the struct; do not guess). Per
`design/brief--community-support-objectives.md §PhyloNodeRef`: the tree
field is the shared container that must be passed between `add_child` calls;
the node field is the per-call handle for the parent reference. Implement
`LineagesIO.add_child(parent :: Nothing, node_idx, label, nodedata, edgedata)
:: PhyloNodeRef` — this is the entry-point overload (root node); it must
construct a new `RootedTree`, add the root node with the given label, and
return a `PhyloNodeRef` wrapping both. Read the Phylo upstream source to
confirm the correct API calls for creating a `RootedTree` and adding a root
node before writing any code. Per `STYLE-julia.md §1.13.2`, add return type
annotations. Per `STYLE-julia.md §5`, no bare `using Phylo`.

---

### 3. Implement the non-entry-point `add_child`

**Type**: WRITE
**Output**: The non-entry-point `add_child(parent :: PhyloNodeRef, ...) ::
PhyloNodeRef` is implemented in `PhyloExt.jl`; it adds a child node and
edge via the Phylo API; edge lengths from `edgedata.edgelength` are applied
when present
**Depends on**: Task 2

Implement `LineagesIO.add_child(parent :: PhyloNodeRef, node_idx, label,
nodedata, edgedata) :: PhyloNodeRef` in `ext/PhyloExt.jl`. Add a child node
to `parent.tree` with the given label using the Phylo API. Add the
corresponding edge (branch) from parent to child; when
`edgedata.edgelength !== nothing`, set the edge length on the branch.  Read
the Phylo upstream source for the correct API calls for `createnode!`,
`addbranch!`, and setting branch lengths before implementing. Return a new
`PhyloNodeRef` wrapping the same tree and the new child node reference. Any
divergence from the Phylo API must be explained in a code comment.
The `PhyloExt` extension operates under `:single_parent` protocol only —
do not implement a `parents :: AbstractVector{PhyloNodeRef}` overload;
if one is needed, escalate.

**Extension-local label uniqueness**: the orchestration layer passes `label`
through unchanged; when `label` is `""`, use `"node_$node_idx"` as the Phylo
node name. When a non-empty label would collide with an existing node name
already in the `RootedTree` (because Phylo uses node names as dictionary keys),
use `"$(label)_$node_idx"` as the node name. This uniqueness handling is
extension-internal logic, not a core guarantee.

---

### 4. Write tests and verify green state in extension environment

**Type**: TEST
**Output**: `test/test_phyloext.jl` created; an extension-specific test
environment is configured; all required integration tests pass with field-level
value verification against Phylo objects; Aqua and JET report no issues in
both environments
**Depends on**: Tasks 1, 2, 3

Create `test/test_phyloext.jl` with a named `@testset "phyloext"` block. The
test file must be conditionally included: only include it if `Phylo` is loaded
in the test environment. Configure the test environment in `test/Project.toml`
to include `Phylo` as a test dependency. The following tests are required:

(a) Entry-point: loading a Newick file returns a `LineageGraphAsset` whose
`graph_rootnode` is a `PhyloNodeRef`; verify that `graph_rootnode.tree` is a
`RootedTree`.
(b) Tree topology: load `test/fixtures/newick/simple.nwk`; verify that the
resulting `RootedTree` has the correct node count and that leaf names match
the fixture ground truth.
(c) Internal labels: load `test/fixtures/newick/internal_labels.nwk`; verify
that internal node labels appear in the `RootedTree` with the correct values.
(d) Edge lengths: load `test/fixtures/newick/simple.nwk`; verify that branch
lengths in the `RootedTree` match the fixture values.
(e) Multi-tree: load `test/fixtures/newick/multitree.nwk`; verify that the
`LineageGraphStore` contains exactly 3 `LineageGraphAsset` values each wrapping a separate
`RootedTree`.
(f) Extension isolation: confirm that when `Phylo` is not loaded, loading a
Newick file with a plain `add_child` extension (not `PhyloNodeRef`) works
correctly — the extension does not affect non-extension behavior.

Add `include("test_phyloext.jl")` (conditionally) to `test/runtests.jl`. Run
`julia --project=test test/runtests.jl` and confirm all tests pass,
`Aqua.test_all(LineagesIO)` reports no issues, and
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no
issues. Search all identifiers added in this tranche for proscribed vocabulary
terms from `STYLE-vocabulary.md` and confirm no matches.
