# Tasks for tranche 6: PhyloNetworks soft-release hardening and end-user workflow completion

Parent tranche: Tranche 6 (`.workflow-docs/runs/20260427--production01/02_tranches.md`)
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
- `.workflow-docs/runs/20260427--production01/03_tranche-05--tasking.md`

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
- describe the public surface in terms of native `HybridNetwork` loads rather
  than extension-private handles, cursors, or helper wrappers
- preserve authoritative `node_table` and `edge_table` wording throughout this
  tranche; do not demote those tables to implementation detail in docs,
  examples, or verification plans
- do not rename retained `gamma` in core or extension docs, and do not imply
  that semantic coercion moved back into LineagesIO core
- do not reintroduce future-scope format names, wrapper names, or provisional
  helper surfaces as if they were tranche-06 public contract

## Upstream primary sources

The following upstream primary sources constrain tranche 6 and must be read in
full before implementation:

- `fileio.jl/`
  Read at minimum
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`,
  and
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/registry_setup.jl`.
  These still constrain the public `load`, `File{format"..."}(...)`, and
  stream-based surfaces that tranche 6 will document and verify.
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
  In these sources, re-check the tranche-05 construction and finalization
  assumptions that now become public workflow contract, including
  `HybridNetwork()`, `writenewick`, `readnewick`, `addChild!`,
  `storeHybrids!`, `checkNumHybEdges!`, `directedges!`, and `checkroot!`.
- `Documenter.jl`
  Read the local documentation build entrypoint `docs/make.jl` together with
  the installed Documenter behavior that constrains doctests, page wiring, and
  docs-build verification for new public examples. If upstream semantics are
  uncertain, verify from the installed package sources or official docs before
  freezing assumptions into docs tasking.
- Julia package-extension and weak-dependency semantics
  Re-read the repository's current extension pattern through `Project.toml`,
  `examples/Project.toml`, `test/Project.toml`, `ext/MetaGraphsNextIO.jl`,
  `ext/PhyloNetworksIO.jl`, and the corresponding tests and examples. Tranche
  6 must preserve the existing weakdep model and must not convert the
  PhyloNetworks path into a hard dependency.

When describing these upstream contracts downstream, distinguish verified
upstream fact from local inference.

## Current-state diagnosis

Tranche 5 is now implemented and green. The `PhyloNetworksIO` extension exists,
native `HybridNetwork` loads work for rooted-network and tree-compatible rooted
`format"Newick"` inputs, and the extension tests cover field-level structure,
`gamma`, authoritative table retention, rejection paths, and supplied-target
binding. Tranche 6 no longer needs to establish the native materialization
owner. It needs to turn that owner into an honest soft-release workflow that a
user can follow from the public docs and examples without depending on
tranche-local knowledge.

Revalidated observations on 2026-04-28:

- `ext/PhyloNetworksIO.jl` is present and now owns the native
  `HybridNetwork` extension path over authoritative LineagesIO tables and
  construction events
- the repository already includes tranche-05 extension verification under
  `test/extensions/phylonetworks_activation.jl`,
  `test/extensions/phylonetworks_newick_networks.jl`,
  `test/extensions/phylonetworks_annotation_paths.jl`,
  `test/extensions/phylonetworks_tables_after_load.jl`,
  `test/extensions/phylonetworks_tree_compatible_newick.jl`, and
  `test/extensions/phylonetworks_rejection_paths.jl`
- `examples/src/phylonetworks_mwe01.jl` exists and runs successfully as an
  eager rooted-network happy path, but it is still a single-script example
  rather than a complete soft-release example surface
- `README.md` remains stale relative to the ratified phase-1 scope: it still
  frames the package mainly around simple rooted Newick and MetaGraphsNext and
  does not yet present the PhyloNetworks public workflow
- `docs/src/index.md` also does not yet present the tranche-06
  PhyloNetworks-centered soft-release path as a first-class public workflow
- there is currently no dedicated production-facing integration owner such as
  `test/integration/phylonetworks_soft_release.jl`; the existing PhyloNetworks
  tests are strong tranche-05 extension tests, but they are not yet the named
  soft-release verification owner requested by tranche 6
- the repository currently starts green:
  `julia --project=test test/runtests.jl` passes,
  `julia --project=docs docs/make.jl` builds successfully apart from the normal
  Documenter deployment warning, and
  `julia --project=examples examples/src/phylonetworks_mwe01.jl` runs
  successfully

The real remaining gap is therefore not implementation novelty. It is public
workflow hardening, production-facing verification, and documentation honesty.
The tranche must not pad itself with shallow re-tests of already-ratified
extension internals. It must verify and publish the real end-user contract.

## Ownership and invariant framing

Tranche 6 establishes the soft-release owner for:

- production-facing verification of the ratified `PhyloNetworks.jl` public
  happy paths
- the README and package-doc presentation of the native `HybridNetwork`
  workflow
- example scripts and fixtures that demonstrate the actual supported public
  surface rather than tranche-local experiments
- final public-surface hardening only where the soft-release verification
  reveals a real owner-level gap
- explicit verification that the PhyloNetworks path remains a thin projection
  over authoritative LineagesIO core tables and protocol events

This tranche does not own:

- any new core parser, core table, or core protocol redesign
- any new extension architecture for other consumer packages
- unrooted-network support, serialization, or additional format owners
- speculative public surface expansion beyond the tranche-05-ratified
  `HybridNetwork` workflow
- user-facing contract claims that are broader than what the automated and
  manual soft-release verification actually prove

The key architectural rule is that tranche 6 may harden the public PhyloNetworks
workflow, but it must not smuggle a second extension-design tranche into the
soft-release umbrella. If a soft-release test exposes a real owner-level bug,
fix the owner. If the public workflow is already correct, do not churn the
extension internals merely to make the tranche look busier.

## Authorization boundary

Allowed in this tranche:

- adding production-facing PhyloNetworks verification under `test/`,
  including a new integration-style owner if that is the cleanest way to
  verify the public soft-release workflow
- updating `README.md`, `docs/src/`, `docs/make.jl`, `examples/src/`,
  `examples/data/`, and `examples/Project.toml` so the public surface matches
  the ratified tranche-05 behavior honestly
- narrow owner-level fixes in `ext/PhyloNetworksIO.jl`,
  `src/fileio_integration.jl`, `src/construction.jl`, `src/LineagesIO.jl`, or
  adjacent tests if tranche-06 verification reveals a real gap in the public
  workflow
- improving fixtures or adding new ones where the soft-release workflow needs a
  clearer rooted-network or tree-compatible rooted example

Not allowed in this tranche without further approval:

- redesigning the tranche-05 extension ownership model when the current owner
  already satisfies the public contract
- new hard dependencies in core for `PhyloNetworks.jl`
- new consumer-package work, new core formats, unrooted-network work, or
  serialization work
- broad speculative documentation that treats future-scope capabilities as
  current soft-release contract
- changing the parent tranche or any parent PRD

## Required revalidation before implementation

- Read this tranche and the four parent design briefs in full
- Read the tranche-05 tasking file in full to preserve the already-ratified
  PhyloNetworks contract and deferred-scope boundaries
- Read the relevant code, tests, docs, and examples in full:
  `Project.toml`, `examples/Project.toml`, `test/Project.toml`,
  `src/LineagesIO.jl`, `src/fileio_integration.jl`, `src/construction.jl`,
  `ext/PhyloNetworksIO.jl`, `README.md`, `docs/src/index.md`, `docs/make.jl`,
  `examples/src/phylonetworks_mwe01.jl`, all current
  `test/extensions/phylonetworks_*` files, and the PhyloNetworks fixtures
- Read all cited upstream primary sources in full where they constrain the
  documented or verified public workflow
- Re-check the user-authorized disruption boundary before making deep changes
- Re-confirm that the repository starts green by running
  `julia --project=test test/runtests.jl`
- Re-confirm that the docs build is green by running
  `julia --project=docs docs/make.jl`
- Re-confirm that the current PhyloNetworks example path runs by executing
  `julia --project=examples examples/src/phylonetworks_mwe01.jl`
- If the tranche diagnosis no longer matches reality, stop and raise that
  before changing code

## Tranche execution rule

The work may harden public docs, examples, and verification deeply where
authorized, and it may repair owner-level public workflow gaps if the tranche
verification exposes them, but it must begin and end in the tranche's required
green, policy-compliant state.

Every code-bearing or docs-bearing task in this tranche must end with
`julia --project=test test/runtests.jl` passing. Any task that touches public
docs, examples surfaced in docs, or doctest-bearing pages must also end with
`julia --project=docs docs/make.jl` passing. Tasks that modify the public
example workflow should also execute the relevant example script directly.

The tranche must leave behind stronger soft-release verification artifacts than
it started with. Passing the existing tranche-05 tests alone is not sufficient
proof of tranche-06 completion.

## Tasks

### 1. Ratify the tranche-06 PhyloNetworks soft-release surface and deferred scope

**Type**: REVIEW
**Output**: an explicit implementation note in the agent response that names
the tranche-06 public happy paths, the examples and docs surfaces to publish,
and the explicitly deferred capabilities that must not be implied by the soft
release
**Depends on**: none

Read tranche 06, tranche-05 tasking, the four governing design documents, the
current `README.md`, `docs/src/index.md`, `docs/make.jl`,
`examples/src/phylonetworks_mwe01.jl`, `examples/Project.toml`, and the current
`test/extensions/phylonetworks_*` files before changing anything. Re-read the
verified `FileIO.jl` and `PhyloNetworks.jl` primary sources that constrain the
public usage flow. Use that reading to lock the tranche-06 execution boundary.
State explicitly whether the documented happy path will include:

- rooted-network-capable `load(path, HybridNetwork)`
- explicit override through `load(File{format"Newick"}(...), HybridNetwork)`
- tree-compatible rooted `HybridNetwork` loads through the same workflow
- supplied-target `HybridNetwork()` binding as first-class or secondary

Also state explicitly which items remain out of scope after this tranche so the
soft release does not over-claim support.

Verification for this task:

- no repository changes are required
- preserve current green state if any incidental probes are run

### 2. Create the production-facing PhyloNetworks soft-release verification owner

**Type**: TEST
**Output**: a new production-facing verification file, wired into the
repository test suite, that exercises the ratified end-user PhyloNetworks
workflow rather than only extension-local field checks
**Depends on**: 1

Add a dedicated verification owner such as
`test/integration/phylonetworks_soft_release.jl` and include it from
`test/runtests.jl`, or choose a nearby equivalent path if repository patterns
show a better home. This verification must exercise the actual public API
surfaces ratified in task 1 and must verify the real contract boundary called
for by `STYLE-verification.md`.

At minimum, verify:

- the rooted-network public happy path through native `HybridNetwork`
- the tree-compatible rooted path through the same native `HybridNetwork`
  surface
- retained authoritative `node_table` and `edge_table` usability after load
- source and collection coordinates that remain attached to each
  `LineageGraphAsset`
- ordinary downstream `PhyloNetworks.jl` participation after load, not merely
  field existence
- target-specific rejection or limitation paths that belong in the published
  soft-release contract

Touch `test/runtests.jl`, the new integration file, and any supporting fixture
files needed. Do not simply duplicate existing tranche-05 extension assertions
unless that duplication is required to verify a public contract-level workflow.

Verification for this task:

- `julia --project=test test/runtests.jl`

### 3. Harden the public PhyloNetworks workflow only where the production checks reveal a real gap

**Type**: WRITE
**Output**: either a narrow owner-level hardening patch for the public
PhyloNetworks path or an explicit no-op note that task 2 already proved the
workflow complete without further code changes
**Depends on**: 2

Use task 2 as the scope driver. If the new soft-release verification exposes a
real owner-level gap in `ext/PhyloNetworksIO.jl`, `src/fileio_integration.jl`,
`src/construction.jl`, `src/LineagesIO.jl`, or closely related tests, fix that
gap at the owning layer. Preserve the tranche-05 rule that the extension stays
a thin projection over authoritative core tables and protocol events. Do not
reconstruct graph structure from text, invent shadow stores, or move retained
annotation semantics back into core.

If task 2 remains green without exposing a real owner-level gap, complete this
task with an explicit implementation note and no code churn. This tranche is
not allowed to invent busywork refactors.

Verification for this task:

- `julia --project=test test/runtests.jl`
- if docs-facing behavior changes, also run `julia --project=docs docs/make.jl`

### 4. Publish the ratified PhyloNetworks soft-release workflow in examples, README, and package docs

**Type**: WRITE
**Output**: runnable examples and public docs that present the actual
tranche-06 PhyloNetworks workflow honestly and build cleanly
**Depends on**: 1, 2, 3

Refresh the public-facing artifacts so they match the ratified workflow and the
verified behavior. Touch `examples/src/`, `examples/data/`,
`examples/Project.toml`, `README.md`, `docs/src/index.md`, and `docs/make.jl`.
If a dedicated docs page such as `docs/src/phylonetworks.md` produces a cleaner
public surface than overloading the home page, create it and wire it into the
Documenter pages list.

The published workflow should show, as ratified in task 1:

- the native `HybridNetwork` happy path
- the rooted-network focal case
- the tree-compatible rooted case if it remains in scope
- retained authoritative table access after load
- any explicit override or supplied-target usage that is truly part of the
  soft-release contract

Keep wording precise and honest. The docs and README must not imply unrooted
network support, other format owners, or broader PhyloNetworks integration than
the tranche actually verifies.

Verification for this task:

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- execute any newly documented example script directly, including the
  PhyloNetworks example path

### 5. Run the tranche-06 manual soft-release walkthrough and final green-state review

**Type**: REVIEW
**Output**: a tranche-end review note that records the manual workflow run, the
automated verification artifacts, and the conclusion that the package now
behaves like a soft-release-ready PhyloNetworks component
**Depends on**: 2, 3, 4

Walk through the documented end-user workflow manually using the exact commands,
examples, and docs surfaces published in task 4. Confirm that:

- the documented syntax works as written
- the resulting `HybridNetwork` can participate in ordinary
  `PhyloNetworks.jl` workflow behavior
- the authoritative `node_table` and `edge_table` remain directly usable after
  load
- the public workflow feels complete at the soft-release level rather than like
  an internal tranche prototype
- the extension still behaves as a thin projection over the core owner rather
  than a shadow parser or shadow network owner

Record the concrete verification artifacts in the final note. Do not settle for
`"tests pass"` as the only conclusion.

Verification for this task:

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- direct execution of the tranche-06 PhyloNetworks example workflow

