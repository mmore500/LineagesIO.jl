---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 8: PhyloNetworksExt package extension

Parent tranche: Tranche 8
Parent PRD: `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

## Governance

All tasks in this file must comply, line by line, with the following governance
documents. Read every document in full before planning or writing a single line
of implementation. This obligation must be passed forward into any downstream
delegated work derived from these tasks.

**Governance documents (all mandatory, line by line):**

- `STYLE-architecture.md` — ownership boundaries; anti-fix prohibition;
  green-state discipline; one invariant, one owner; extension isolation: the
  extension must not re-implement any logic owned by the orchestration layer
- `STYLE-docs.md` — documentation formatting standards
- `STYLE-git.md` — commit style and branching model
- `STYLE-julia.md` — functional design; type annotations; return type
  annotations (§1.13.2); bare `using` prohibition (§5); module curation (§8);
  weak-dependency and extension declaration conventions (§9 if present)
- `STYLE-upstream-contracts.md` — host-framework contract reading; divergence
  authorization; every design decision that diverges from established
  PhyloNetworks API patterns must be flagged in a code comment explaining why
- `STYLE-verification.md` — field-level value verification; weak-proxy
  prohibition; integration tests must verify `HybridNetwork` and `Node`
  objects created by PhyloNetworks contain the correct topology — not just
  that loading returns something
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms. Key
  constraints: `node` not `vertex`; `edge` not `branch`; `gamma` for
  inheritance proportion; `rootnode` not `root`
- `STYLE-workflow-docs.md` — revalidation rule; pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` — §PhyloNetworksExt; §PhyloNetworksNodeHandle;
  §finalize_graph! override for PhyloNetworks; §Network protocol (`:network`
  tier); §Per-edge gamma at call time; §Implementation decisions 1–8
- `design/brief--community-support-objectives.md` — §PhyloNetworks parse
  approach; §PhyloNetworksNodeHandle struct design; §storeHybrids! and
  checkNumHybEdges! and directedges! finalization sequence; §Network tier
  validation; §Gamma flow table; §Entry-point vs non-entry-point add_child
  dispatch
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §PhyloNetworksExt
  (user stories 1–8, extension-specific); §finalize_graph! contract;
  §add_child overload signatures; §Package extension declaration (weak deps,
  [extensions] section); §Implementation decision 8 (builder kwarg precedence)

**Upstream primary sources (all mandatory, line by line, from
`/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`):**

Read all sources line by line before writing a single line of implementation.
Any design decision that diverges from established patterns must be flagged in
a code comment explaining why.

- `PhyloNetworks.jl/src/` — `HybridNetwork` struct; `Node` struct; `Edge`
  struct; how `addHybridEdge!`, `addEdge!`, and `addNode!` work; what
  `storeHybrids!`, `checkNumHybEdges!`, and `directedges!` do and when they
  must be called; which fields of `HybridNetwork` and `Node` are set during
  construction vs finalization
- `fileio.jl/src/` — confirm that the extension does not need to interact
  with FileIO registration; the adapter is already registered

**Important**: `[weakdeps]` and `[extensions]` sections cannot be added via
`Pkg.add`. They must be added by editing `Project.toml` directly, with
explicit project-owner approval. Stop and request approval before making any
`Project.toml` changes for this tranche.

Read-only git and shell commands may be used freely. Mutating git operations
remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code:

1. Read all files added or modified by Tranches 1 through 7 in full, line by
   line. Do not assume any description matches the code — verify each
   independently.
2. Confirm `julia --project=test test/runtests.jl` passes with Aqua and JET
   clean. If it does not, stop and escalate before proceeding.
3. Read `PhyloNetworks.jl/src/` in full. Understand the `HybridNetwork` and
   `Node` construction API before writing a single line of `add_child`.
4. Verify that the orchestration layer's `:network` tier path correctly handles
   `parents :: AbstractVector{NodeT}` for multi-parent `add_child` calls. If
   any discrepancy is found between the orchestration layer and the `add_child`
   signature expected by the PhyloNetworks API, escalate before proceeding.
5. **Stop before any `Project.toml` changes**: read the current
   `Project.toml`, confirm that `PhyloNetworks` is not already listed under
   `[weakdeps]` or `[extensions]`, and request project-owner approval to add
   both sections before proceeding with Task 1.

## Tranche execution rule

The `PhyloNetworksExt` extension implements the `add_child` and
`finalize_graph!` overloads that build a live `HybridNetwork` object during
loading. It owns no orchestration logic — all `node_idx` assignment, label
disambiguation, `finalize_graph!` invocation timing, and `LineageGraphAsset` assembly
remain owned by the orchestration layer. The extension must be loadable only
when `PhyloNetworks` is present in the user's environment; it must not affect
any behavior when `PhyloNetworks` is absent. The tranche must begin and end
with all tests passing, Aqua and JET clean in both the standard environment
and the extension-active environment.

## Tasks

### 1. Declare PhyloNetworks as a weak dependency

**Type**: CONFIG
**Output**: `PhyloNetworks` appears under `[weakdeps]` in `Project.toml`;
`PhyloNetworksExt` appears under `[extensions]` mapping to
`ext/PhyloNetworksExt.jl`; `Project.toml` changes require explicit
project-owner approval before this task begins; the test suite still passes
after the change
**Depends on**: Tranches 1–7 complete and green; project-owner approval for
`Project.toml` modification

**This task requires project-owner approval before any action.** Do not edit
`Project.toml` until the project owner explicitly approves. When approval is
given, add `PhyloNetworks` under `[weakdeps]` with its UUID (look up the
registered UUID from the Julia General registry or the upstream source — do not
guess; if uncertain, ask). Add `PhyloNetworksExt = ["PhyloNetworks"]` under
`[extensions]`. Do not use `Pkg.add` for this step — `[weakdeps]` and
`[extensions]` cannot be managed by `Pkg.add`; edit `Project.toml` directly
with the approval. After editing, run `julia --project=test test/runtests.jl`
and confirm the test suite still passes.

---

### 2. Implement `PhyloNetworksNodeHandle` and the entry-point `add_child`

**Type**: WRITE
**Output**: `ext/PhyloNetworksExt.jl` exists; `PhyloNetworksNodeHandle` wraps
a `HybridNetwork` and a `Node`; the entry-point `add_child(parent :: Nothing,
...) :: PhyloNetworksNodeHandle` creates a new `HybridNetwork`, adds the root
node, and returns a `PhyloNetworksNodeHandle`; the struct is not exported
**Depends on**: Task 1

Create `ext/PhyloNetworksExt.jl` as a Julia module named `PhyloNetworksExt`.
Define `PhyloNetworksNodeHandle` as a struct wrapping `network :: HybridNetwork`
and `node :: Node` — the network reference is needed because `add_child` calls
for subsequent nodes must add to the same `HybridNetwork` object. Per
`design/brief--community-support-objectives.md §PhyloNetworksNodeHandle`: the
network field is the shared container; the node field is the per-call handle.
Implement `LineagesIO.add_child(parent :: Nothing, node_idx, label, nodedata,
edgedata) :: PhyloNetworksNodeHandle` — this is the entry-point overload
(root node); it must construct a new `HybridNetwork`, add the root node via
the PhyloNetworks API, and return a `PhyloNetworksNodeHandle` wrapping both.
Read the PhyloNetworks upstream source to confirm the correct API calls for
creating a `HybridNetwork` and adding a root node before writing any code.
Per `STYLE-julia.md §1.13.2`, add return type annotations. Per
`STYLE-julia.md §5`, no bare `using PhyloNetworks`.

---

### 3. Implement the non-entry-point `add_child` and gamma handling

**Type**: WRITE
**Output**: The non-entry-point `add_child` overloads for both single-parent
and network (vector parents) dispatch levels are implemented in
`PhyloNetworksExt.jl`; gamma values from `edgedata.gamma` are passed to the
PhyloNetworks edge when present; hybrid nodes are added via the network
protocol path
**Depends on**: Task 2

Implement `LineagesIO.add_child(parent :: PhyloNetworksNodeHandle, node_idx,
label, nodedata, edgedata) :: PhyloNetworksNodeHandle` — the single-parent
non-entry-point overload; adds a child node and edge via the PhyloNetworks
API using the network from `parent.network`; returns a new
`PhyloNetworksNodeHandle` wrapping the same network and the new child node.
Implement `LineagesIO.add_child(parents :: AbstractVector{PhyloNetworksNodeHandle},
node_idx, label, nodedata, edgedata) :: PhyloNetworksNodeHandle` — the network
tier overload for hybrid nodes with multiple parents; adds a hybrid node to the
network. Per `design/brief.md §Per-edge gamma at call time`: when
`edgedata.gamma !== nothing`, pass the gamma value to the PhyloNetworks edge
constructor for the parent-to-hybrid edge. Read the PhyloNetworks upstream
source for how hybrid nodes and their parent edges are added before
implementing. Any divergence from the PhyloNetworks API must be explained in a
code comment.

**Extension-local label uniqueness**: the orchestration layer passes `label`
through unchanged. When `label` is `""`, set `Node.name` to `"node_$node_idx"`.
When `label` is non-empty, set `Node.name` to `label` directly. This is
extension-internal logic, not a core guarantee from LineagesIO.

---

### 4. Implement `finalize_graph!` override for PhyloNetworks

**Type**: WRITE
**Output**: `LineagesIO.finalize_graph!(handle :: PhyloNetworksNodeHandle) ::
PhyloNetworksNodeHandle` is implemented in `PhyloNetworksExt.jl`; it calls
`storeHybrids!`, `checkNumHybEdges!`, and `directedges!` on the wrapped
`HybridNetwork` in the correct order; it returns `handle` unchanged
**Depends on**: Task 3

Implement `LineagesIO.finalize_graph!(handle :: PhyloNetworksNodeHandle) ::
PhyloNetworksNodeHandle` in `ext/PhyloNetworksExt.jl`. Per
`design/brief--community-support-objectives.md §storeHybrids! finalization
sequence`: call `storeHybrids!(handle.network)`, then
`checkNumHybEdges!(handle.network)`, then `directedges!(handle.network)` in
that exact order. Read the PhyloNetworks upstream source to understand what
each call does and why the ordering matters before implementing. Return
`handle` unchanged after finalization. Per `STYLE-julia.md §4`, a
`!`-function returns the mutated argument — this function must return `handle`.
Any deviation from the documented call order must be explained in a code
comment.

---

### 5. Write tests and verify green state in extension environment

**Type**: TEST
**Output**: `test/test_phylonetworksext.jl` created; an extension-specific
test environment is configured; all required integration tests pass with
field-level value verification against PhyloNetworks objects; Aqua and JET
report no issues in both environments
**Depends on**: Tasks 1, 2, 3, 4

Create `test/test_phylonetworksext.jl` with a named
`@testset "phylonetworksext"` block. The test file must be conditionally
included: only include it if `PhyloNetworks` is loaded in the test
environment. Configure the test environment in `test/Project.toml` to include
`PhyloNetworks` as a test dependency (not a weak dep — the test environment
actively loads it). The following tests are required:

(a) Entry-point: loading a single-node LineageNetwork file returns a
`LineageGraphAsset` whose `graph_rootnode` is a `PhyloNetworksNodeHandle`; verify
that `graph_rootnode.network` is a `HybridNetwork`.
(b) Tree topology: load `test/fixtures/lineagenetwork/no_hybrids.lnw`; verify
that the resulting `HybridNetwork` has the correct node count and that leaf
node names match the fixture.
(c) Hybrid node: load `test/fixtures/lineagenetwork/simple_network.lnw`;
verify the `HybridNetwork` has exactly one hybrid node; verify its name
matches the fixture.
(d) Gamma: load `test/fixtures/lineagenetwork/gamma_values.lnw`; verify that
the hybrid edge in the `HybridNetwork` carries the correct gamma value from
the fixture.
(e) `finalize_graph!` invocation: confirm that `storeHybrids!` was called on
the network (verify via the state of `HybridNetwork.hybrid` after loading).
(f) Extension isolation: confirm that when `PhyloNetworks` is not loaded,
loading a LineageNetwork file with a plain `add_child` extension (not
`PhyloNetworksNodeHandle`) works correctly — the extension does not affect
non-extension behavior.

Add `include("test_phylonetworksext.jl")` (conditionally) to
`test/runtests.jl`. Run `julia --project=test test/runtests.jl` and confirm
all tests pass, `Aqua.test_all(LineagesIO)` reports no issues, and
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no
issues. Search all identifiers added in this tranche for proscribed vocabulary
terms from `STYLE-vocabulary.md` and confirm no matches.
