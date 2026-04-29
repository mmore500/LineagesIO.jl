# Tasks for tranche 5: PhyloNetworks native rooted-network load surface

Parent tranche: Tranche 5 (`.workflow-docs/runs/20260427--production01/02_tranches.md`)
Parent PRD: `design/brief.md`, `design/brief--user-stories.md`, `design/brief--community-support-objectives.md`, `design/brief--community-support-user-stories.md`

## Governance

All tasks must comply with the following governance documents. Read each one
line by line before planning, implementing, reviewing, or delegating work from
this file. This obligation must be passed forward into every downstream task or
agent handoff.

All tasks must comply with:

- `CONTRIBUTING.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`
- `.workflow-docs/runs/20260427--production01/02_tranches.md`

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, and branch remain the human project owner's
responsibility unless the user explicitly instructs otherwise.

## Controlled vocabulary

All downstream work must preserve the controlled vocabulary already ratified in
`STYLE-vocabulary.md` and the governing briefs.

In particular:

- use `StructureKeyType`, `nodekey`, `edgekey`, `src_nodekey`, `dst_nodekey`,
  `edgeweight`, `rootnode`, `bind_rootnode!`, `add_child`,
  `finalize_graph!`, `node_table`, `edge_table`, `NodeRowRef`, `EdgeRowRef`,
  `LineageGraphAsset`, and `LineageGraphStore` exactly where those concepts
  are in scope
- write "root node" and "edge weight" in prose, but use `rootnode` and
  `edgeweight` for project-owned identifiers
- use upstream `PhyloNetworks.jl` terms such as `HybridNetwork`, `Node`,
  `Edge`, `gamma`, `ismajor`, and `RootMismatch` only at the extension
  boundary or when describing verified upstream contracts
- do not invent extension-private public target types, helper wrappers, or
  alternate graph-format names for tranche 5
- do not rename retained `gamma` in core and do not move semantic coercion of
  retained non-structural fields back into core
- do not substitute extension-local names for the authoritative LineagesIO core
  identifiers at the package boundary

## Upstream primary sources

The following upstream primary sources constrain tranche 5 and must be read in
full before implementation:

- `fileio.jl/`
  Read at minimum
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`,
  and
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/registry_setup.jl`.
  These define the `DataFormat`, `File`, `Stream`, `add_loader`,
  `add_format`, and backend-dispatch contracts that the extension path must
  preserve.
- `PhyloNetworks.jl/`
  Read at minimum
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/types.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/auxiliary.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/readwrite.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/manipulateNet.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/graph_components.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/docs/src/man/introduction.md`,
  and
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/docs/src/man/dist_reroot.md`.
  In these sources, verify the concrete construction and normalization helpers
  used by upstream itself: `HybridNetwork()`, `Node`, `Edge`,
  `pushNode!`, `pushEdge!`, `setNode!`, `setEdge!`, `setgamma!`,
  `storeHybrids!`, `checkNumHybEdges!`, `directedges!`, and `checkroot!`,
  together with the extended-Newick root and hybrid-edge semantics documented
  by `readnewick`.
- Julia package-extension and weak-dependency semantics
  Re-read the current repository's own extension pattern through
  `Project.toml`, `test/Project.toml`, `ext/MetaGraphsNextIO.jl`,
  `ext/MetaGraphsNextAbstractTreesIO.jl`, and the corresponding extension
  tests under `test/extensions/`. Tranche 5 must match the existing weakdep and
  extension activation model already used successfully in this repository.

When describing these upstream contracts downstream, distinguish verified
upstream fact from local inference.

## Current-state diagnosis

The tranche 4 core owner is now implemented and green. Tranche 5 therefore no
longer needs to establish network parsing or multi-parent protocol semantics in
core. It needs to build the first native `PhyloNetworks.jl` projection layer on
top of the current authoritative core owner.

Revalidated observations on 2026-04-28:

- `src/construction.jl` now owns multi-parent materialization, early
  compatibility validation, and no-partial-mutation failure boundaries for
  unsupported multi-parent supplied-root and builder loads
- `src/newick_format.jl` and the tranche-4 test suite already cover the
  rooted-network-capable `format"Newick"` core owner, repeated hybrid-label
  merge, and raw `gamma` retention in authoritative edge tables
- `Project.toml` currently declares weak dependencies only for
  `MetaGraphsNext.jl` and `AbstractTrees.jl`; there is no `PhyloNetworks.jl`
  weakdep, no extension entry, and no test-environment dependency yet
- `ext/MetaGraphsNextIO.jl` is the current reference extension owner. It uses
  `validate_extension_load_target`, a private build cursor, extension-owned
  `emit_rootnode` and `bind_rootnode!` behavior, and `finalize_graph!` to turn
  public LineagesIO protocol events into a native target package graph
- there is currently no `PhyloNetworks` extension module and no
  `test/extensions/phylonetworks_*` verification layer
- the community brief still mentions `ext/PhyloNetworksExt.jl`, but the
  implemented phase-1 extension pattern in this repository is `*IO.jl`
  (`MetaGraphsNextIO.jl`, `MetaGraphsNextAbstractTreesIO.jl`). Tranche 5 must
  ratify the module filename before code changes so work does not split across
  stale and current naming patterns
- upstream `PhyloNetworks.jl` exposes mutable network assembly primitives
  directly on `HybridNetwork`, `Node`, and `Edge`, and its own `readnewick`
  path finalizes networks with `storeHybrids!`, `checkNumHybEdges!`,
  `directedges!`, and rootedness updates. This makes extension-owned
  incremental construction plausible, but the exact finalization sequence and
  whether a supplied-target `HybridNetwork()` path is clean enough to ratify
  still require tranche-5 review
- `docs/src/index.md` and `README.md` do not yet provide the end-user-ready
  PhyloNetworks workflow. Broad documentation and soft-release polish still
  belong to tranche 6
- the repository currently starts green:
  `julia --project=test test/runtests.jl` passes and
  `julia --project=docs docs/make.jl` builds successfully apart from the normal
  Documenter deployment warning

## Ownership and invariant framing

Tranche 5 establishes the first native `PhyloNetworks.jl` extension owner for:

- the `PhyloNetworks` weak dependency and package-extension wiring
- native `HybridNetwork` materialization through the existing LineagesIO public
  load surfaces
- extension-private cursor and lookup state needed to map `nodekey`,
  `edgekey`, `label`, `edgeweight`, and selected retained fields such as
  `gamma` into upstream `HybridNetwork`, `Node`, and `Edge` objects
- extension-owned finalization and validation steps required by upstream
  `PhyloNetworks.jl` after incremental construction
- target-specific rejection behavior for unsupported or not-yet-ratified load
  surfaces

This tranche does not own:

- any new core parser, core table, or core protocol redesign
- broad docs, README, or soft-release packaging polish
- tranche-6 workflow completion or production-facing user guide work
- `Phylo.jl`, `LineageGraphML`, or tranche-7 MetaGraphsNext network completion

The key architectural rule is that the extension must stay a thin projection
over authoritative LineagesIO tables and the existing public protocol events.
It must not reconstruct graph structure by reparsing Newick text, guessing
hybrid partners from copied metadata, or carrying a shadow graph store outside
the upstream `HybridNetwork` plus minimal extension-private lookup state.

The domain-focal execution order for tranche 5 is rooted-network-first. Tree-
compatible rooted inputs are part of the same extension owner, but they should
be verified as a second step through the same `HybridNetwork` path rather than
driving the design toward a tree-only adapter first.

## Authorization boundary

Allowed in this tranche:

- adding `PhyloNetworks.jl` as a weak dependency in `Project.toml`
- adding `PhyloNetworks.jl` to the test environment in `test/Project.toml`
- creating the PhyloNetworks extension module under `ext/`
- adding extension-specific tests under `test/extensions/` and any needed
  fixtures under `test/fixtures/`
- minimal supporting changes to `src/fileio_integration.jl`,
  `src/construction.jl`, `src/LineagesIO.jl`, or `test/runtests.jl` if the
  extension hook or validation boundary requires them
- implementing a supplied-target `HybridNetwork()` binding path only if the
  revalidated upstream construction contract is clean enough to ratify without
  speculative divergence

Not allowed in this tranche without further approval:

- broad README or docs workflow polish that belongs to tranche 6
- shadow parsing, shadow table storage, or any extension-local replacement for
  the core rooted-network owner
- reworking core `format"Newick"` semantics except for minimal bug fixes
  surfaced by honest extension integration
- introducing extension-private public target types or requiring
  `Base.get_extension(...)` in the public happy path
- adding support for other consumer packages, new core formats, unrooted
  network work, or serialization work

## Required revalidation before implementation

- Read this tranche and the four parent design briefs in full
- Read the relevant code, tests, docs, and examples in full:
  `Project.toml`, `test/Project.toml`, `src/LineagesIO.jl`,
  `src/fileio_integration.jl`, `src/construction.jl`,
  `src/newick_format.jl`, `ext/MetaGraphsNextIO.jl`,
  `ext/MetaGraphsNextAbstractTreesIO.jl`, `test/runtests.jl`,
  all current files under `test/extensions/`, the network-core tests under
  `test/core/`, `docs/src/index.md`, `README.md`, and the existing rooted
  network fixtures
- Read all cited upstream primary sources in full where they constrain the work
- Re-check the user-authorized disruption boundary before making changes
- Re-confirm that the repository starts green by running
  `julia --project=test test/runtests.jl`
- Re-confirm that the current docs build is green by running
  `julia --project=docs docs/make.jl`
- Re-confirm the extension module filename before code changes so a stale
  `PhyloNetworksExt.jl` reference does not leak into implementation
- Re-confirm whether supplied-target `HybridNetwork()` binding is truly
  upstream-clean before ratifying it as public tranche-5 scope
- If the tranche diagnosis no longer matches reality, stop and raise that
  before changing code

## Tranche execution rule

The work may add a new extension owner and may reshape extension-layer internals
deeply where authorized, but it must begin and end in the tranche's required
green, policy-compliant state.

Every code-bearing task in this tranche must end with
`julia --project=test test/runtests.jl` passing for the repository state at
that checkpoint. Any task that touches package docs or public docstrings in a
way that affects the docs build must also end with
`julia --project=docs docs/make.jl` passing.

Do not spend tranche-5 task budget on tranche-6 documentation polish. Minimal
docstrings or error-message wording changes are acceptable only if they are
required to keep the new public surface honest.

## Tasks

### 1. Ratify the tranche-5 PhyloNetworks contract, module filename, and public load surfaces

**Type**: REVIEW
**Output**: an explicit implementation note in the agent response that names
the chosen extension module filename, the tranche-5 public load surfaces that
are in scope, the upstream finalization steps that will be used, and whether
supplied-target `HybridNetwork()` binding is ratified now or deferred
**Depends on**: none

Read the parent tranche, the four governing design documents, the current
extension pattern, and the cited `PhyloNetworks.jl` upstream sources before
making any code changes. Use that reading to lock the tranche-5 execution
boundary. Resolve the naming inconsistency between the community brief's
`PhyloNetworksExt.jl` mention and the repository's current `*IO.jl` extension
pattern. Also ratify the tranche-5 public surface: `load(src, HybridNetwork)`
is mandatory, while `load(src, target::HybridNetwork)` is only in scope if the
upstream mutation path can be supported without speculative wrapper behavior or
leaky partial-state conventions. Do not change project files in this task
unless the diagnosis is wrong and the workflow document itself must be
escalated.

### 2. Add the weakdep wiring, extension skeleton, and activation harness

**Type**: CONFIG
**Output**: `Project.toml`, `test/Project.toml`, the PhyloNetworks extension
module file, `test/runtests.jl`, and
`test/extensions/phylonetworks_activation.jl` are in place, the extension
activates automatically when `PhyloNetworks.jl` is loaded, and the repository
is green
**Depends on**: 1

Touch `Project.toml`, `test/Project.toml`, `test/runtests.jl`, and the new
extension file under `ext/`. Follow the existing MetaGraphsNext weakdep and
activation pattern rather than inventing a second extension model. Add the
minimum target-validation scaffolding needed for `HybridNetwork` to become a
known extension-owned load target, but do not try to finish native
materialization in this task. If the tranche-1 review decision deferred
supplied-target binding, encode that boundary explicitly in target validation
or clear rejection paths instead of leaving a vague method failure. Add an
activation test that proves the extension stays inactive until `PhyloNetworks`
is loaded and activates automatically afterwards. End this task with
`julia --project=test test/runtests.jl`.

### 3. Implement rooted-network-native `HybridNetwork` materialization first

**Type**: WRITE
**Output**: representative rooted-network-capable `Newick` input loads through
`load(path, HybridNetwork)` into a native `HybridNetwork` using an
extension-private cursor and an upstream-verified finalization path, while the
authoritative LineagesIO tables remain unchanged and first-class
**Depends on**: 2

Touch the new PhyloNetworks extension module first, and touch core files only
if the extension hook points are insufficient. Build the implementation around
the existing public LineagesIO protocol rather than around reparsing or copied
metadata. Use upstream `HybridNetwork`, `Node`, and `Edge` primitives together
with verified helpers such as `pushNode!`, `pushEdge!`, `setNode!`,
`setEdge!`, and `setgamma!` where appropriate. Introduce only the minimal
private cursor and lookup state needed to map `nodekey` and `edgekey` into
upstream node and edge identity cleanly. Start with the representative rooted
network fixture and make the multi-parent path the design driver. If final
network normalization requires `storeHybrids!`, `checkNumHybEdges!`,
`directedges!`, `checkroot!`, or another upstream step, use only the steps that
are directly justified by upstream code or docs and record that reasoning in
the agent response. Do not invent a tree-only intermediate owner. End this task
with `julia --project=test test/runtests.jl`.

### 4. Add field-level rooted-network extension tests for structure, gamma, and retained tables

**Type**: TEST
**Output**: `test/extensions/phylonetworks_newick_networks.jl`,
`test/extensions/phylonetworks_annotation_paths.jl`, and
`test/extensions/phylonetworks_tables_after_load.jl` exist, are included from
`test/runtests.jl`, and verify the rooted-network native path at field level
**Depends on**: 3

Add focused extension tests that exercise `load(path, HybridNetwork)` on the
existing rooted-network fixture. Verify the actual `HybridNetwork` structure
through upstream fields and helpers, not through pretty-print or existence-only
checks. At minimum, assert rooted-network counts, hybrid-node detection,
edge-level `gamma` behavior where the extension claims semantic interpretation,
and stable authoritative-table availability after load. Also verify that
LineagesIO's authoritative `node_table` and `edge_table` remain the primary
source of retained annotations after materialization, and that the extension
does not require any extension-private public handle types. End this task with
`julia --project=test test/runtests.jl`.

### 5. Broaden the same owner to tree-compatible rooted inputs and settle the supplied-target boundary

**Type**: WRITE
**Output**: the tranche-5 PhyloNetworks surface is complete and explicit:
tree-compatible rooted `Newick` inputs load through the same verified
`HybridNetwork` owner, and supplied-target `HybridNetwork()` binding is either
implemented cleanly with direct tests or rejected specifically before mutation
with direct tests
**Depends on**: 3, 4

Extend the same extension owner rather than creating a second tree-only path.
Add `test/extensions/phylonetworks_tree_compatible_newick.jl` and
`test/extensions/phylonetworks_rejection_paths.jl`. If the tranche-1 review
confirmed that mutating an empty caller-supplied `HybridNetwork()` is clean and
upstream-aligned, implement `bind_rootnode!` and any required empty-target
validation plus a focused supplied-target test. If that path is not clean
enough, keep the public support to `load(src, HybridNetwork)` and add a
specific rejection that fires before partial mutation or vague downstream
method failure. In either case, verify that tree-compatible rooted inputs use
the same native `HybridNetwork` owner, preserve authoritative tables, and do
not reintroduce a tree-first design bias into the network-focused extension.
End this task with `julia --project=test test/runtests.jl`.

### 6. Review the native PhyloNetworks contract, manual happy paths, and tranche-end green state

**Type**: REVIEW
**Output**: the agent response records manual verification artifacts for one
rooted-network input and one tree-compatible rooted input, states whether
supplied-target binding was ratified or deferred, and confirms the tranche-end
green state
**Depends on**: 5

Run the tranche-end manual review that the tranche file requires. Load a
representative rooted-network input and a representative tree-compatible rooted
input through the ratified public PhyloNetworks surface. Inspect the resulting
`HybridNetwork` directly enough to confirm that rooted structure, hybrid-edge
semantics, and any claimed `gamma` interpretation path are real rather than
proxy-based. Also confirm that the authoritative tables remain useful after
load and that no public workflow requires extension-private handles or
`Base.get_extension(...)`. End this task with
`julia --project=test test/runtests.jl` and
`julia --project=docs docs/make.jl`. If the extension still requires
speculative divergence from verified upstream assembly semantics, or if the
remaining work is really tranche-6 soft-release polish rather than tranche-5
native-surface completion, stop and surface that explicitly instead of
quietly widening tranche 5.
