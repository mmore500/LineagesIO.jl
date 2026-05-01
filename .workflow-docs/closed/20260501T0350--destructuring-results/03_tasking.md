# Tasks for tranche 1: LineageGraphAsset destructuring contract and verification

Parent tranche: Tranche 1 (`02_tranches.md`)
Parent PRD: `.workflow-docs/runs/20260501T0350--destructuring-results/prd--lineage-graph-asset-destructuring.md`

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
- `.workflow-docs/runs/20260501T0350--destructuring-results/02_tranches.md`
- `.workflow-docs/runs/20260501T0350--destructuring-results/prd--lineage-graph-asset-destructuring.md`

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, and branch remain the human project owner's
responsibility unless the user explicitly instructs otherwise.

## Controlled vocabulary

All downstream work must preserve the controlled vocabulary already ratified in
`STYLE-vocabulary.md`.

In particular:

- use `LineageGraphAsset`, `GraphAssetIterator`, `LineageGraphStore`,
  `store.graphs`, `materialized`, `node_table`, `edge_table`, and `basenode`
  exactly where those concepts are in scope
- write "edge table" and "node table" in prose, but use `edge_table` and
  `node_table` for project-owned identifiers
- do not introduce wrapper terminology or caller-side helper names for the
  destructuring semantic
- keep repo-local vocabulary controlling where it differs from the
  workspace-level vocabulary

## Upstream primary sources

The following upstream primary sources constrain this tranche and must be read
in full before implementation:

- Julia 1.12.6 `stdlib/v1.12/LinearAlgebra/src/cholesky.jl`
  Verified contract: standard-library factorization objects document and own
  destructuring through `Base.iterate` on the factorization type itself
- Julia 1.12.6 `stdlib/v1.12/LinearAlgebra/src/lu.jl`
  Verified contract: small fixed-arity objects may expose their public
  components directly through `Base.iterate`
- Julia 1.12.6 `stdlib/v1.12/LinearAlgebra/src/schur.jl`
  Verified contract: multi-value destructuring over non-collection objects is
  a supported public Julia pattern
- Julia 1.12.6 `test/core.jl`
  Verified contract: custom struct destructuring works by defining
  `Base.iterate(::MyType, state)`
- Julia 1.12.6 `test/syntax.jl`
  Verified contract: destructuring assignment and partial destructuring are
  first-class language surfaces whose behavior should be tested directly

When describing these upstream contracts downstream, distinguish verified
upstream fact from local inference.

## Current-state diagnosis

Revalidated observations on 2026-05-01:

- `src/views.jl` already owns `LineageGraphAsset` and `GraphAssetIterator`
- `GraphAssetIterator` already implements `Base.IteratorSize`,
  `Base.length`, `Base.eltype`, and `Base.iterate`, so the missing owner is
  the yielded asset, not the outer store iterator
- `LineageGraphAsset` already centralizes the exact three public values that
  should be destructured: `materialized`, `node_table`, and `edge_table`
- the current code still lacks `Base.iterate` on `LineageGraphAsset`, so the
  tranche diagnosis remains accurate
- `test/core/construction_protocol_single_parent.jl` already owns the existing
  materialized fixture path and protocol node type, making it the cleanest
  place to keep the materialized and tables-only destructuring contract
  together
- `README.md` and `docs/src/index.md` describe `LineageGraphAsset` and
  `store.graphs`, but they do not yet document the new destructuring surface
- this is a public API behavior addition, so `STYLE-verification.md` requires
  docs updates and a docs build in addition to direct regression tests

## Ownership and invariant framing

This tranche repairs one owner and one shared contract:

- owning layer: `LineageGraphAsset` behavior in `src/views.jl`
- shared contract: every asset destructures in the stable order
  `(materialized, node_table, edge_table)` and reports `length(asset) == 3`

The supported public surfaces are:

- assignment destructuring from an asset
- tuple-pattern iteration over `store.graphs`
- partial destructuring with discarded positions
- tables-only assets with `materialized === nothing`
- materialized assets created through existing construction load surfaces

Implementation must repair the owner once. It must not emulate destructuring in
callers, extension files, or test-only helper wrappers.

## Authorization boundary

Allowed in this tranche:

- modifying `src/views.jl` to add owner-level iteration and length support for
  `LineageGraphAsset`
- updating one existing core test file to verify the multi-surface contract
- updating `README.md` and `docs/src/index.md` to advertise the public API
  addition

Not allowed in this tranche without further approval:

- redesigning `GraphAssetIterator`
- altering load-request semantics or construction-protocol ownership
- making extension-layer changes unrelated to verifying this core asset
  contract
- broad API redesign beyond the destructuring and length behavior fixed by the
  parent PRD

No REVIEW task is required. The parent PRD and approved tranche already fix
the destructuring order, touched owner, and verification scope.

## Required revalidation before implementation

- Read the tranche and parent PRD in full
- Read the relevant code, tests, docs, and examples in full:
  `src/views.jl`, `src/construction.jl`, `src/newick_format.jl`,
  `test/core/construction_protocol_single_parent.jl`,
  `test/core/companion_tables.jl`, `test/core/graph_store_coordinates.jl`,
  `README.md`, and `docs/src/index.md`
- Read all cited upstream primary sources in full where they constrain the
  work
- Reconfirm that the tranche diagnosis still matches the repository state
  before editing
- If the diagnosis no longer matches reality, stop and raise that before
  changing code

## Tranche execution rule

The work must begin and end in the tranche's required green, policy-compliant
state.

Every code-bearing task in this tranche must end with
`julia --project=test test/runtests.jl` passing for the repository state at
that checkpoint.

Any task that edits `README.md`, `docs/src/index.md`, or other docs-owned
public usage surfaces must also end with
`julia --project=docs docs/make.jl` passing.

The implementation must preserve the tranche 1 scope boundary:

- `LineageGraphAsset` remains the only new owner of the destructuring contract
- `GraphAssetIterator` keeps its current responsibility as the outer store
  iterator
- destructuring order remains exactly
  `(materialized, node_table, edge_table)`
- both tables-only and materialized load surfaces remain supported through the
  same asset-level owner
- tests and docs must verify the public contract directly rather than through
  internal helper proxies

## Tasks

### 1. Add owner-level asset iteration in src/views.jl

**Type**: WRITE
**Output**: `LineageGraphAsset` defines public iteration and length behavior in
`src/views.jl`, and `julia --project=test test/runtests.jl` passes
**Depends on**: none

Modify `src/views.jl` immediately after `basenode(asset)` to add the public
docstring, `Base.IteratorSize`, `Base.length`, and `Base.iterate` methods for
`LineageGraphAsset`. Follow the parent PRD exactly: use a fixed three-position,
integer-state iterator where state `1` yields `materialized`, state `2` yields
`node_table`, state `3` yields `edge_table`, and any later state returns
`nothing`. This decision is fixed here because the parent PRD already ratifies
the integer-state contract, and the Julia upstream sources confirm that the
owner type itself should expose destructuring through `Base.iterate`. Touch only
`src/views.jl`; do not change `GraphAssetIterator`, `construction.jl`,
`fileio_integration.jl`, or any extension files. Verify by running
`julia --project=test test/runtests.jl`.

---

### 2. Add destructuring regressions in test/core/construction_protocol_single_parent.jl

**Type**: TEST
**Output**: one core test file directly covers assignment destructuring, loop
destructuring, partial destructuring, `length(asset) == 3`, and tables-only
behavior, and `julia --project=test test/runtests.jl` passes
**Depends on**: 1

Extend `test/core/construction_protocol_single_parent.jl` with a new public
contract `@testset` that uses the existing `annotated_simple_rooted.nwk`
fixture for both a materialized load and a tables-only load. Keep this coverage
in the existing single-parent file rather than splitting it across multiple
test files, because that file already owns the materialized fixture path and
`SingleParentProtocolNode`, and it lets the multi-surface contract stay in one
place. Assert direct assignment destructuring, tuple-pattern loop destructuring
over `store.graphs`, partial destructuring with `_`, and `length(asset) == 3`
using identity checks against `asset.materialized`, `asset.node_table`, and
`asset.edge_table`. Verify by running `julia --project=test test/runtests.jl`.

---

### 3. Document the new asset destructuring surface in README.md and docs/src/index.md

**Type**: WRITE
**Output**: top-level user-facing docs advertise `LineageGraphAsset`
destructuring, `julia --project=docs docs/make.jl` passes, and
`julia --project=test test/runtests.jl` still passes
**Depends on**: 2

Update `README.md` and `docs/src/index.md` where `LineageGraphAsset` and
`store.graphs` are already introduced so they show the new public destructuring
surface explicitly. Keep the documentation at the owner-level entry points
rather than adding extension-specific notes, because this is a core asset
contract shared by all load surfaces. Document the stable order as
`materialized`, `node_table`, then `edge_table`, and make the tables-only
`nothing` behavior clear where relevant. This docs task is mandatory rather
than optional because `STYLE-verification.md` requires documentation updates and
a docs build for public API behavior changes. Verify by running
`julia --project=docs docs/make.jl` and then
`julia --project=test test/runtests.jl`.

---
