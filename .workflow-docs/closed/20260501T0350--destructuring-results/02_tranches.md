---
date-created: 2026-05-01T03:57:47-07:00
date-revised: 2026-05-01T03:57:47-07:00
status: proposed
---

# LineageGraphAsset destructuring tranches

## Authority

This document is the proposed tranche file derived from:

- `.workflow-docs/runs/20260501T0350--destructuring-results/prd--lineage-graph-asset-destructuring.md`

If this tranche document conflicts with the governing PRD or with active
governance authorities, the governing authority controls and this tranche
document must be revised before downstream implementation proceeds.

## Governance and required reading

All downstream tasking, implementation, review, and audit work derived from
this tranche document must require line-by-line reading of:

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
- `.workflow-docs/runs/20260501T0350--destructuring-results/prd--lineage-graph-asset-destructuring.md`

The current run also operated under user-supplied workflow authorities
`development-policies` and `devflow-feature-02--prd-to-tranches`. Downstream
artifacts must preserve the mandates those authorities introduced, especially
explicit governance pass-forward, exact upstream-source naming, controlled
vocabulary pass-forward, and explicit green-state gates.

`STYLE-makie.md` is not tranche-critical for this non-rendering change, but it
becomes mandatory immediately if scope expands into plotting code, example
renders, or Makie-facing documentation.

This pass-forward obligation is mandatory at every downstream handoff.

## Controlled vocabulary

All downstream work must preserve the controlled vocabulary ratified in
`STYLE-vocabulary.md`.

For this repository, the repo-local vocabulary file is controlling where it
differs from the workspace-level `../STYLE-vocabulary.md`.

In particular:

- use exact API names such as `LineageGraphAsset`, `GraphAssetIterator`,
  `LineageGraphStore`, `store.graphs`, `materialized`, `node_table`, and
  `edge_table`
- preserve repo-local canonical terms such as `basenode`
- do not introduce local synonyms or caller-side wrapper terminology for this
  destructuring semantic

## Upstream primary sources

The PRD depends on Julia iteration semantics, so the following upstream primary
sources are mandatory and were missing from the PRD:

- Julia 1.12.6 `stdlib/v1.12/LinearAlgebra/src/lu.jl`
  Contract point: standard-library factorization objects implement
  `Base.iterate` specifically for destructuring into components
- Julia 1.12.6 `stdlib/v1.12/LinearAlgebra/src/schur.jl`
  Contract point: multi-value destructuring over non-collection objects is an
  accepted public pattern implemented through `Base.iterate`
- Julia 1.12.6 `test/core.jl`
  Contract point: custom struct destructuring works by defining
  `Base.iterate(::MyType, state)`
- Julia 1.12.6 `test/syntax.jl`
  Contract point: destructuring assignment is a first-class language surface
  whose behavior must remain honest when callers discard positions or bind into
  tuple patterns

Any downstream task or review that depends on Julia iteration semantics must
name these sources explicitly rather than referring vaguely to "Julia
destructuring" or "Base behavior".

## Current-state diagnosis

Verified current-state observations:

- `src/views.jl` already owns the `LineageGraphAsset` and `GraphAssetIterator`
  view types
- `GraphAssetIterator` already implements `Base.IteratorSize`,
  `Base.length`, `Base.eltype`, and `Base.iterate`, so `store.graphs` itself is
  already a stable iterator surface
- `LineageGraphAsset` already centralizes the three values callers want
  together: `materialized`, `node_table`, and `edge_table`
- the missing behavior is owner-level iteration on `LineageGraphAsset` itself,
  which currently prevents destructuring assignment and tuple-pattern `for`
  loops from composing over yielded asset values
- both tables-only assets and materialized assets already converge on the same
  `LineageGraphAsset` owner through `src/newick_format.jl` and
  `src/construction.jl`
- existing tests already cover nearby tables-only, companion-table, and
  materialized-asset behavior, but they do not yet assert the public
  destructuring contract across those surfaces

## Ownership and invariant framing

This work has one clear owner and one shared contract:

- owning layer: `LineageGraphAsset` behavior in `src/views.jl`
- shared contract: every `LineageGraphAsset` must destructure in the stable
  order `(materialized, node_table, edge_table)` with `length(asset) == 3`

This is not a foundational tranche. No sibling module currently normalizes this
semantic independently, and no user-facing symptom requires a deeper owner
repair before implementation can proceed.

The public semantic enters through more than one supported surface, so
downstream work must preserve all of them explicitly:

- direct assignment destructuring from an asset
- tuple-pattern `for` loops over `store.graphs`
- tables-only assets with `materialized === nothing`
- materialized assets created through construction load surfaces

Downstream implementation must repair the owner once. It must not emulate the
semantic in callers, extensions, or tests through local compensations.

## Authorization boundary

The following work is authorized in this tranche:

- adding owner-level iteration and length support for `LineageGraphAsset`
- adding or extending core tests that verify the destructuring contract across
  tables-only and materialized asset surfaces
- adding a minimal documentation or README example only if revalidation shows
  that existing public examples should advertise the new destructuring surface

The following remain out of scope unless explicitly re-authorized:

- redesign of `GraphAssetIterator`
- changes to load-request semantics or construction-protocol ownership
- extension-layer changes unrelated to verifying this shared asset contract
- broader API redesign beyond the destructuring and length behavior named in
  the PRD

## Verification and green-state gates

Every downstream implementation task for this tranche must begin and end in a
green, policy-compliant state.

Minimum tranche-end verification rules:

- direct regression coverage for assignment destructuring on a materialized
  asset
- direct regression coverage for tuple-pattern loop destructuring over
  `store.graphs`
- direct regression coverage for tables-only assets where the first bound value
  is `nothing`
- direct assertions that the destructuring order is
  `(materialized, node_table, edge_table)` and that `length(asset) == 3`
- full test-suite verification via `julia --project=test test/runtests.jl`
- if implementation expands scope into docs or README examples, successful docs
  verification via `julia --project=docs docs/make.jl`

Weak proxies are not sufficient. Tests must assert the actual bound values and
the actual multi-surface public contract.

## Tranche summary

1. `LineageGraphAsset` destructuring contract and verification
   Type: `AFK`
   Blocked by: none

## Tranche 1: `LineageGraphAsset` destructuring contract and verification

**Type**: AFK
**Blocked by**: None -- can start immediately

### Parent PRD

`prd--lineage-graph-asset-destructuring.md`

### Governance and required reading

- Mandated line-by-line reading of `CONTRIBUTING.md`,
  `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`,
  `STYLE-workflow-docs.md`, and `STYLE-writing.md`
- Mandated reading of
  `.workflow-docs/runs/20260501T0350--destructuring-results/prd--lineage-graph-asset-destructuring.md`
- Mandated reading of the Julia 1.12.6 upstream primary sources named in this
  file before making claims about destructuring or iteration semantics
- Mandated preservation of repo-local controlled vocabulary, especially exact
  API names and repo-local canonical terms such as `basenode`

### What to build

Implement the PRD as one owner-level vertical slice. `LineageGraphAsset` in
`src/views.jl` should become the single normalized owner of the destructuring
contract so that any asset yielded through `store.graphs` can be destructured
as `(materialized, node_table, edge_table)` without caller-side shims.

The same contract must hold for:

- explicit assignment destructuring
- tuple-pattern `for` loops over `store.graphs`
- partial destructuring where some positions are discarded
- tables-only assets where the first value is `nothing`
- materialized assets produced by existing construction surfaces

The tranche should add or extend the most appropriate `test/core/` coverage to
verify those surfaces directly. It should not spread compensating logic into
`construction.jl`, `fileio_integration.jl`, extension files, or downstream
callers.

### How to verify

- Manual: load an existing fixture through a materialized surface, destructure
  the first asset, and confirm the three bindings are exactly
  `asset.materialized`, `asset.node_table`, and `asset.edge_table`
- Manual: iterate `for (graph, node_table, edge_table) in store.graphs` and
  confirm the bound values match each yielded asset without extra adapters
- Manual: load the same fixture through the tables-only surface, destructure
  the first asset, and confirm the first value is `nothing`
- Automated: add direct core tests for assignment destructuring, loop
  destructuring, partial destructuring, and `length(asset) == 3` across both
  materialized and tables-only assets
- Automated: run `julia --project=test test/runtests.jl`
- Automated: if docs or README examples change during implementation, also run
  `julia --project=docs docs/make.jl`

### Acceptance criteria

- [ ] Given a materialized `LineageGraphAsset`, when it is destructured by
      assignment, then the three bindings equal `materialized`, `node_table`,
      and `edge_table` in that order
- [ ] Given tuple-pattern iteration `for (graph, node_table, edge_table) in store.graphs`,
      when the loop executes, then each yielded asset binds through the same
      owner-level contract without caller-side wrappers
- [ ] Given partial destructuring with `_`, when one or more positions are
      discarded, then the remaining bindings still reflect the same stable
      order
- [ ] Given a tables-only `LineageGraphAsset`, when it is destructured, then
      the first bound value is `nothing` and the second and third bound values
      remain the authoritative `node_table` and `edge_table`
- [ ] Given `length(asset)`, when called on either a materialized or
      tables-only asset, then it returns `3`

### User stories addressed

The PRD does not include an explicit numbered user-story annex, so this tranche
uses the following derived story numbering from the PRD's required-behavior
sections:

- User story 1: Destructure a `LineageGraphAsset` by assignment into
  `materialized`, `node_table`, and `edge_table`
- User story 2: Use the same destructuring contract directly inside
  `for (graph, node_table, edge_table) in store.graphs`
- User story 3: Preserve partial destructuring behavior and the explicit
  `length(asset) == 3` contract
- User story 4: Preserve the same destructuring shape for tables-only assets
