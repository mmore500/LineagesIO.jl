# Tasks for tranche 4: Multi-parent core protocol and rooted-network Newick owner

Parent tranche: Tranche 4 (`02_tranches.md`)
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
  `edgeweight`, `basenode`, `bind_basenode!`, `add_child`,
  `finalize_graph!`, `node_table`, `edge_table`, `NodeRowRef`, `EdgeRowRef`,
  `LineageGraphAsset`, and `LineageGraphStore` exactly where those concepts
  are in scope
- write "basenode" and "edge weight" in prose, but use `basenode` and
  `edgeweight` for project-owned identifiers
- rooted networks still have one `basenode`; multi-parent refers to one child
  node with multiple incoming parent edges, not to multiple roots
- use the exact multi-parent construction call shape ratified in
  `design/brief--user-stories.md` user story 8:
  `add_child(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)`
  rather than inventing a parallel public construction function
- retain raw `gamma` text in core under a stable edge-table field name; do not
  coerce it to `Float64` in core and do not rename it in an extension-driven
  way
- do not invent or reintroduce `LineageNetwork` or any other future format name
  in task-local code, tests, docs, or acceptance claims for this tranche
- when discussing upstream `PhyloNetworks.jl`, it is acceptable to use upstream
  terms such as `HybridNetwork`, `Node`, `Edge`, `major`, `minor`, and
  `gamma`, but do not substitute those terms for ratified LineagesIO core
  identifiers at the package boundary

## Upstream primary sources

The following upstream primary sources constrain tranche 4 and must be read in
full before implementation:

- `fileio.jl/`
  Read at minimum the contract-bearing material in `src/types.jl`,
  `src/loadsave.jl`, `src/query.jl`, and `src/registry_setup.jl` so the
  rooted-network work remains inside FileIO-owned load surfaces rather than
  inventing a second loader boundary.
- `Tables.jl`
  Read at minimum the installed Tables.jl interface documentation and source
  covering `Tables.AbstractColumns`, `Tables.AbstractRow`, `Tables.rows`,
  `Tables.columns`, `Tables.schema`, `Tables.getcolumn`, and
  `Tables.columnnames`, so the multi-parent core still treats the authoritative
  tables as first-class owners.
- `PhyloNetworks.jl/`
  Read at minimum
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/types.jl`,
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/readwrite.jl`,
  and
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/docs/src/man/introduction.md`.
  In `src/readwrite.jl`, read at minimum the contract-bearing logic around
  `readnewick_nodename`, `parsenewick_hybridnode!`,
  `parsenewick_edgedata!`, `synchronizepartnersdata!`,
  `readnewick_subtree!`, and `readnewick`. These sources define the
  rooted-network-capable extended-Newick conventions that tranche 4 is allowed
  to support.
- `PhyloNetworks.jl/` rooting and hybrid-edge constraints
  Read the `checkroot!`-relevant material in
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/graph_components.jl`
  or the corresponding documentation in
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/docs/src/man/dist_reroot.md`
  before implementing parent scheduling or cycle rejection. The purpose here is
  not to duplicate PhyloNetworks rooting logic in core, but to avoid emitting a
  fake multiple-root or impossible hybrid-parent interpretation.

When describing these upstream contracts downstream, distinguish verified
upstream fact from local inference.

## Current-state diagnosis

This repository now has the tranche 1 through tranche 3 foundation in place,
but the core owner is still explicitly tree-shaped. Tranche 4 must establish
the multi-parent construction tier and the rooted-network-capable `format"Newick"`
owner in core before any `PhyloNetworks.jl` extension work can be honest.

Revalidated observations on 2026-04-28:

- `src/construction.jl` currently hard-codes tree recursion:
  `materialize_graph_basenode` assumes `basenodekey == StructureKeyType(1)`,
  `build_child_edgekeys` stores only outgoing child edges by parent, and
  `construct_descendants!` emits one child call per incoming edge rather than
  one call per child node
- the only public construction protocol currently exercised in core is the
  single-parent shape
  `add_child(parent, nodekey, label, edgekey, edgeweight; edgedata, nodedata)`,
  and the default error path explicitly says
  "No single-parent `LineagesIO.add_child` method ..."
- `src/newick_format.jl` still uses a recursive `ParsedNewickNode` tree-only
  intermediate representation and rejects `#` hybrid labels in
  `parse_optional_label!` and `parse_unquoted_label!`
- `src/newick_format.jl` also rejects extended edge fields after `:`,
  rejects incoming root edge data, and appends node and edge rows under the
  assumption that each non-basenode has exactly one parent edge
- `src/fileio_integration.jl` still registers only `format"Newick"` and uses a
  no-op `validate_extension_load_target(::Type)` hook, so there is no current
  structural-tier compatibility gate for multi-parent graphs
- the existing `MetaGraphsNext.jl` extension path in `ext/MetaGraphsNextIO.jl`
  and `ext/MetaGraphsNextAbstractTreesIO.jl` is a single-parent reference path
  only; tranche 4 must preserve that path for tree inputs and make any network
  rejection specific rather than accidental
- `docs/src/index.md` still says LineagesIO loads through a
  "single-parent graph-construction protocol" and still documents only simple
  rooted Newick public surfaces
- the repository starts green:
  `julia --project=test test/runtests.jl` passes and
  `julia --project=docs docs/make.jl` builds successfully apart from the normal
  Documenter deployment warning

The hardened phase-1 scope for this tranche is rooted-network-capable
`format"Newick"` only. `LineageNetwork` is no longer a current-scope format
owner and must not leak back into implementation or verification.

## Ownership and invariant framing

Tranche 4 establishes the core owner for:

- the exact multi-parent `add_child(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)` construction tier
- structural-tier validation for single-parent versus multi-parent loads
- rooted-network-capable `format"Newick"` parsing rules within the ratified
  phase-1 subset
- repeated hybrid-label merge into one structural node identity
- authoritative node and edge tables for rooted networks, including retained
  raw edge annotations such as `gamma`
- one-`basenode` semantics for rooted networks
- the graph-materialization scheduler that waits until all parent handles exist
  before emitting a multi-parent child

This tranche does not yet own:

- the `PhyloNetworks.jl` extension module or any native `HybridNetwork`
  materialization
- new weak dependencies or package-extension wiring in `Project.toml`
- `LineageGraphML`, additional native consumer-package work, or tranche 7
  unrooted-network work
- any new format registration beyond `format"Newick"`
- semantic coercion of retained `gamma`, support-like values, or other edge
  annotations in core
- any extension-local shadow parser stack, topology store, or metadata bag

The core package remains the only owner of parsing, structural key assignment,
authoritative table assembly, row-reference delivery, and protocol emission.
No extension should have to reconstruct hybrid-node identity, guess `gamma`
placement, or infer parent grouping from copied metadata.

The key architectural consequence is that materialization can no longer be
implemented as simple recursive tree descent. For a rooted network, the core
must own a DAG-aware scheduling step that:

- binds or creates the root once
- tracks materialized handles by `nodekey`
- groups incoming parent edges by child node
- waits until all parent handles exist before emitting a multi-parent child
- fails specifically if a cycle or impossible parent schedule remains

This design thinking is part of the tranche owner. Do not push it down into
the future `PhyloNetworks.jl` extension.

## Authorization boundary

The user-authorized disruption boundary allows tranche 4 to deeply refactor the
current tree-only core owner where needed to establish the correct multi-parent
owner.

Allowed in this tranche:

- deep refactor of `src/construction.jl` and `src/newick_format.jl`
- minimal supporting changes to `src/fileio_integration.jl`,
  `src/LineagesIO.jl`, `src/core_types.jl`, `src/tables.jl`, or `src/views.jl`
  if the new owner needs them
- minimal changes to `ext/MetaGraphsNextIO.jl` or
  `ext/MetaGraphsNextAbstractTreesIO.jl` only where required to preserve honest
  tree-path behavior and specific rejection of multi-parent loads
- new core tests under `test/core/` and new fixtures under `test/fixtures/`
- minimal docstring or package-doc wording changes needed to avoid false public
  claims once the core is network-capable

Not allowed in this tranche without further approval:

- adding `PhyloNetworks.jl` as a weak dependency or creating a
  `PhyloNetworks` extension module
- introducing a `LineageNetwork` format owner or any other new format
- `LineageGraphML`, additional native consumer-package work, `Nexus`,
  `TskitTrees`, or serialization work
- semantic interpretation of `gamma` or support-like edge values in core
- broad end-user docs, README workflow polish, or soft-release packaging work
  that belongs to tranche 6
- silent export of new helper names or public wrappers that were not already
  ratified in the governing briefs

## Required revalidation before implementation

- Read this tranche and the four parent design briefs in full
- Read the relevant code, tests, docs, and examples in full:
  `Project.toml`, `test/Project.toml`, `src/LineagesIO.jl`,
  `src/core_types.jl`, `src/tables.jl`, `src/views.jl`,
  `src/construction.jl`, `src/newick_format.jl`,
  `src/fileio_integration.jl`, `ext/MetaGraphsNextIO.jl`,
  `ext/MetaGraphsNextAbstractTreesIO.jl`, `test/runtests.jl`,
  all existing files under `test/core/` and `test/extensions/`,
  `docs/src/index.md`, and any current files under `test/fixtures/`
- Read all cited upstream primary sources in full where they constrain the work
- Re-check the user-authorized disruption boundary before making deep changes
- Re-confirm that the repository starts green by running
  `julia --project=test test/runtests.jl`
- Re-confirm that the current docs build is green by running
  `julia --project=docs docs/make.jl`
- If the rooted-network-capable Newick subset still leaves ambiguity about
  hybrid-label merge, positional edge-field naming, or root-edge handling,
  stop and ratify those points before implementation rather than letting them
  drift inside parser code
- If the work would require widening the current implicit `basenodekey == 1`
  invariant into a new graph-level root storage contract, stop and raise that
  before changing the public data model
- If the tranche diagnosis no longer matches reality, stop and raise that
  before changing code

## Tranche execution rule

The work may redesign, replace, or deeply refactor internal core mechanics
where authorized, but it must begin and end in the tranche's required green,
policy-compliant state.

Every code-bearing task in this tranche must end with
`julia --project=test test/runtests.jl` passing for the repository state at
that checkpoint. Any task that edits `docs/src/index.md` or public docstrings
must also end with `julia --project=docs docs/make.jl` passing.

Because `test/runtests.jl` includes `Aqua.test_all(LineagesIO)` and
`JET.test_package(LineagesIO; target_modules = (LineagesIO,))`, the tranche-end
green state also includes the current code-quality and linting gates.

The implementation must preserve the tranche 4 scope boundary:

- `format"Newick"` remains the only format owner touched in this tranche
- tree inputs and the existing MetaGraphsNext extension path remain green
- rooted-network-capable inputs must use the exact multi-parent `add_child`
  contract rather than an alternate public protocol
- the core must emit one `basenode`; it must not duplicate hybrid nodes to fake
  a tree
- raw `gamma` text and other retained edge annotations remain in the
  authoritative `edge_table`; no semantic coercion belongs in core
- root incoming edge data must not be silently discarded
- unmatched hybrid labels, structurally ambiguous hybrid reuse, or cycle-like
  schedules must fail specifically rather than being normalized into a fake
  graph
- no `LineageNetwork` references, tests, or format registrations may appear

## Tasks

### 1. Ratify the rooted-network-capable Newick subset and tranche-04 owner boundary

**Type**: REVIEW
**Output**: an explicit implementation note in the agent response that names
the supported rooted-network-capable `Newick` subset, the chosen stable field
name for the positional support-like edge value if one is retained, the
retention rule for raw `gamma`, and the rejection cases that remain out of
scope for tranche 4
**Depends on**: none

Read the parent tranche, the four governing design documents, the current core
implementation, and the cited `PhyloNetworks.jl` upstream sources before making
any code changes. Use that reading to lock the tranche 4 execution boundary.
At minimum, explicitly ratify whether the supported subset includes only the
`PhyloNetworks.jl`-style repeated hybrid-label convention with one retained
structural node and whether the current tranche continues to reject incoming
root-edge data because it cannot yet be preserved honestly in the core tables.
Also ratify the stable table-field name for the second positional extended
edge field before coding it. Do not change project files in this task unless
the diagnosis is wrong and the workflow document itself must be escalated.

### 2. Introduce the exact multi-parent construction tier and structural-tier validation hooks

**Type**: WRITE
**Output**: core load-request and validation machinery recognizes the
single-parent versus multi-parent distinction, and the exact public
multi-parent `add_child(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)`
surface exists alongside the current single-parent surface without breaking
tree-path callers
**Depends on**: 1

Touch `src/construction.jl`, `src/fileio_integration.jl`, and only minimal
supporting files such as `src/LineagesIO.jl` if required. Implement the exact
multi-parent call shape ratified by core user story 8. Do not invent a second
public construction function and do not move this contract into an extension.
Add any internal trait, helper, or validation hook needed to distinguish
single-parent targets from multi-parent-compatible targets for `load(src, NodeT)`,
`load(src, basenode)`, and `load(src; builder = fn)`. If a sound preflight
check is impossible for one of these surfaces, define the earliest honest
failure point and make the resulting error specific rather than relying on a
generic method error or partial graph mutation. Keep the current tree-only
extension path working unchanged for simple rooted Newick inputs. End this task
with `julia --project=test test/runtests.jl`.

### 3. Verify structural-tier validation and the new public protocol shape with synthetic graph assets

**Type**: TEST
**Output**: `test/core/network_target_validation.jl` exists, is included from
`test/runtests.jl`, and proves the structural-tier gate and public call shape
against synthetic authoritative tables
**Depends on**: 2

Add focused tests that use dummy node-handle types, supplied-basenode handles, and
builder callbacks to verify the new validation boundary without waiting for the
parser refactor. It is acceptable in this task to construct `NodeTable`,
`EdgeTable`, and `LineageGraphAsset` values directly and exercise internal
materialization helpers if that is the most honest way to isolate the
construction-tier contract. Confirm that multi-parent-compatible targets are
recognized, that single-parent-only targets are rejected specifically once a
multi-parent graph is known, and that the exact aligned vector contract for
`parent_collection`, `edgekeys`, `edgeweights`, and `edgedata` is what the
core exposes. End this task with `julia --project=test test/runtests.jl`.

### 4. Replace recursive tree descent with DAG-aware authoritative-table materialization

**Type**: WRITE
**Output**: the core can materialize a rooted DAG from authoritative tables by
emitting each non-basenode exactly once after all parent handles exist, while
preserving the current tree-path behavior for single-parent graphs
**Depends on**: 2, 3

Refactor `src/construction.jl` so materialization is no longer hard-wired to
recursive tree descent over outgoing child edges only. The new owner should
build both incoming-edge and outgoing-edge structure, track materialized node
handles by `nodekey`, and schedule node emission with a parent-count or
equivalent topological algorithm. Emit the `basenode` once, then emit each
child node only after all its parent handles exist, passing parent handles and
incoming edge metadata in aligned vectors. Detect cycle-like or impossible
parent schedules and raise a specific core error instead of looping or
duplicating nodes. Preserve basenode binding, builder callbacks, and the
single-parent fast path where it keeps the implementation clearer. If this work
would require widening the current implicit `basenodekey == 1` invariant into a
new public graph-level root storage contract, stop and raise that before
proceeding. End this task with `julia --project=test test/runtests.jl`.

### 5. Add synthetic multi-parent materialization tests for scheduler behavior and regressions

**Type**: TEST
**Output**: `test/core/network_protocol_multi_parent.jl` exists, is included
from `test/runtests.jl`, and verifies multi-parent event ordering, parent-edge
alignment, finalization, and single-parent regressions against the new
materializer
**Depends on**: 4

Add focused scheduler tests using synthetic authoritative tables so the
materialization owner is verified independently of parsing. Include at minimum
one rooted DAG with a hybrid node receiving two parents, one ordinary rooted
tree regression case, and one failure case for impossible scheduling. Record
the exact `add_child` events from a test-only multi-parent-compatible handle
type and assert that parent order aligns with `edgekeys`, `edgeweights`, and
`edgedata`, that `NodeRowRef` and `EdgeRowRef` values point at the expected
rows, and that `finalize_graph!` still runs exactly once per graph. End this
task with `julia --project=test test/runtests.jl`.

### 6. Refactor `format"Newick"` parsing and table assembly for rooted-network-capable sources

**Type**: WRITE
**Output**: rooted-network-capable `format"Newick"` sources load tables-only
through the core owner, repeated hybrid labels merge into one structural node,
multi-parent edges land in authoritative tables, and raw `gamma` text is
retained under a stable edge-table field name
**Depends on**: 1, 5

Refactor `src/newick_format.jl` away from the current tree-only
`ParsedNewickNode` representation. Implement an intermediate representation or
direct table-building path that can parse the ratified rooted-network-capable
subset, merge repeated hybrid labels within one graph, preserve ordinary rooted
tree behavior, and still support multiple `;`-terminated graphs in one source.
Repeated hybrid labels must merge only within the current graph; their
namespace must reset between graphs. Preserve one structural root. Retain raw
edge annotations, especially `gamma`, in the authoritative `edge_table` and do
not coerce them semantically in core. Keep the second positional extended edge
field under the ratified stable table-field name from task 1. Continue to
reject incoming root-edge data or ambiguous hybrid reuse patterns if they
cannot yet be represented honestly in the core tables. Touch only minimal
supporting files outside `src/newick_format.jl` if the new owner requires them.
End this task with `julia --project=test test/runtests.jl`.

### 7. Verify rooted-network-capable Newick parsing, authoritative tables, and public core load surfaces

**Type**: TEST
**Output**: `test/core/network_newick_format.jl`,
`test/core/network_annotation_retention.jl`, and any needed rooted-network
fixtures exist and prove both tables-only and custom-target public loads at
field level
**Depends on**: 6

Add representative rooted-network fixtures under `test/fixtures/` and new core
tests under `test/core/`. Cover at minimum: tables-only rooted-network-capable
`Newick` loads; custom multi-parent-compatible target loads through
`load(path, NodeT)` and `load(path; builder = fn)`; raw `gamma` retention;
retention of the ratified support-like positional edge field if present;
repeated hybrid-label merge into one structural node; and specific rejection of
unsupported inputs such as unmatched hybrid names, repeated internal-only
hybrid occurrences, incoming root-edge data, or single-parent-only targets.
Also verify that existing single-parent consumers such as the current
MetaGraphsNext extension path now fail specifically on multi-parent loads
rather than through accidental method errors. Assert actual `node_table` and
`edge_table` field contents and actual protocol payloads, not just load success
or row counts. End this task with `julia --project=test test/runtests.jl`.

### 8. Migrate public wording to the tier-aware rooted-network-capable core without doing tranche-06 docs work

**Type**: MIGRATE
**Output**: public docstrings, minimal package docs text, and error surfaces no
longer falsely describe the core as simple-tree-only or single-parent-only,
while the repository finishes with tests and docs green
**Depends on**: 7

Update only the minimum public-owned wording that becomes false after tranche 4.
This may include relevant docstrings in `src/construction.jl` and
`src/newick_format.jl`, specific error messages, and the scope wording in
`docs/src/index.md`. Keep this limited to honesty and compatibility. Do not
turn it into tranche 6 soft-release documentation or public workflow polish.
The package docs may remain modest, but they must no longer state that `#`
hybrid labels or rooted-network-capable Newick are out of scope once the core
owner exists. Confirm that tree-oriented examples remain valid, that the
MetaGraphsNext extension still owns only the single-parent path, and that the
package now reports network-capable scope accurately at the core level. End
this task with both `julia --project=test test/runtests.jl` and
`julia --project=docs docs/make.jl`.

---
