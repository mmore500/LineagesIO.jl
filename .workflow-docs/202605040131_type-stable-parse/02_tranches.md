---
date-created: 2026-05-04T23:25:02-07:00
date-revised: 2026-05-04T23:25:02-07:00
status: proposed
---

# Typed package-owned load architecture tranches

## Authority

This document is the proposed tranche file derived from:

- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`

If this tranche document conflicts with the governing PRD or with active
governance authorities, the higher authority controls and this tranche
document must be revised before downstream implementation proceeds.

## Governance and required reading

All downstream tasking, implementation, review, and audit work derived from
this tranche document must require line-by-line reading of:

- `CONTRIBUTING.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-makie.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`

The current planning run also read the bundled baseline style authorities under
`/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/`.
Those bundled style files are byte-identical to the repo-local style files
named above. Bundled `CONTRIBUTING.md` was not present there, so downstream
work must continue to rely on the repo-local `CONTRIBUTING.md`.

The current run also operated under the workflow authorities
`development-policies` and `devflow-architecture-02--prd-to-tranches`.
Downstream artifacts must preserve the mandates those authorities introduced,
especially exact governance pass-forward, exact upstream-source naming,
controlled-vocabulary pass-forward, user-review gates, explicit green-state
gates, and explicit naming of removal targets and forbidden regressions.

This pass-forward obligation is mandatory at every downstream handoff.

## Controlled vocabulary

All downstream work must preserve the controlled vocabulary ratified in
`STYLE-vocabulary.md`.

For this repository and this redesign, downstream artifacts must use the
following terms consistently:

- `basenode`, not `root`, for the package abstraction
- `package-owned public surface`, not vague references to "the load API"
- `compatibility wrapper` for `FileIO.load(...)` and any other non-owning
  adapter surface
- `authoritative tables` for the canonical parse output
- `materialized graph or basenode result` for post-table construction output
- `typed core`, `source descriptor`, `materialization descriptor`,
  `parent collection`, `ownership boundary`, and `green state`

Downstream documents must not describe `FileIO.load(...)` as LineagesIO's
primary public contract, and must not use `type stable` as a euphemism for
universal exact inference when the actual contract is the absence of
package-owned erasure and runtime type recovery in owned paths.

## Upstream primary sources

The PRD names the following upstream primary sources as mandatory for
contract-sensitive downstream work:

- `fileio.jl/README.md`
- `fileio.jl/src/loadsave.jl`
- `fileio.jl/src/types.jl`
- `fileio.jl/src/query.jl`
- `Tables.jl/README.md`
- `Tables.jl/src/Tables.jl`

These sources establish the external facts this tranche file depends on:

- `FileIO` owns format detection, ambiguity handling, `File{fmt}` wrappers,
  `Stream{fmt}` wrappers, and formatted dispatch
- `Tables` owns the `Tables.AbstractColumns` and `Tables.AbstractRow`
  contracts, including optional typed `getcolumn` entrypoints and
  schema-driven column typing

Conditional extension upstreams remain mandatory for extension-touching work,
but exact file selection is still tranche-local. Before any downstream task
edits `ext/PhyloNetworksIO.jl`, `ext/MetaGraphsNextIO.jl`, or
`ext/MetaGraphsNextAbstractTreesIO.jl`, it must first identify and read the
exact upstream files in `PhyloNetworks.jl` and `MetaGraphsNext.jl` that define
the constructor, mutation, and view contracts it touches.

## Current-state diagnosis

Verified current-state observations from the PRD and codebase exploration:

- `src/construction.jl` already owns request types such as
  `TablesOnlyLoadRequest`, `NodeTypeLoadRequest`, `BasenodeLoadRequest`, and
  `BuilderLoadRequest`, but those owned request semantics are not yet exposed
  as the one canonical package-owned public owner
- `src/fileio_integration.jl` still acts as the practical semantic owner for
  request normalization through `build_load_request(...)` and `fileio_load(...)`
- `src/alife_format.jl` still provides a separate in-memory alife semantic path
  through `load_alife_table(...)` rather than delegating through one canonical
  owner for source and request normalization
- `src/construction.jl` still contains owned hot-path erasure and recovery,
  including `materialized_handles::Vector{Any}`, generic parent-handle
  collection recovery, and `typejoin`-based parent-type reconstruction
- the builder path still infers handle or parent-collection types from runtime
  callback signatures instead of requiring an honestly typed owned descriptor
- `ext/PhyloNetworksIO.jl` repeats runtime parent-collection recovery through a
  custom `build_parent_collection(...)` path
- `ext/MetaGraphsNextIO.jl` contains a multi-parent probe shim that exists
  because multi-parent capability is still inferred indirectly rather than
  expressed through one canonical owner-level request model
- `src/newick_format.jl` and `src/alife_format.jl` already preserve the right
  invariant: authoritative tables are built first, then materialization occurs
- `src/views.jl` already preserves typed `LineageGraphAsset` and
  `LineageGraphStore` ownership, including stable asset destructuring order
  `(graph, basenode, node_table, edge_table)`
- `README.md`, `docs/src/index.md`, and `docs/src/phylonetworks.md` still
  present `load(...)` and extension-specific wrapper stories as the primary
  public path, which blurs the package-owned ownership boundary the PRD wants
  to repair

## Ownership and invariant framing

This redesign has one foundational owner problem and one key invariant:

- owning layer to repair: the package-owned request and source normalization
  layer that should sit above authoritative table construction and below
  compatibility wrappers
- canonical invariant: every supported LineagesIO load surface must normalize
  into one package-owned typed owner, then build authoritative tables, then
  materialize through a typed core without package-owned erasure or runtime
  type recovery

This is a foundational-tranche-first plan. The public symptom in docs and API
shape cannot be repaired honestly until the owner and invariant in the typed
core are repaired first.

The public semantic enters through more than one supported surface, so
downstream work must preserve all of them explicitly:

- file-backed sources
- stream-backed sources
- in-memory alife table sources
- tables-only materialization
- node-type materialization
- supplied-basenode materialization
- builder-driven materialization
- compatibility wrappers such as `FileIO.load(...)`

Downstream implementation must normalize that semantic once at the owning
layer. It must not preserve multiple semantic owners behind apparently
equivalent wrappers.

## Authorization boundary

The following work is authorized by the PRD:

- deep internal refactoring in `src/fileio_integration.jl`, `src/alife_format.jl`,
  `src/newick_format.jl`, `src/construction.jl`, `src/views.jl`, tests, docs,
  and extension adapters as needed to create one canonical package-owned load
  owner and typed materialization core
- explicit migration of compatibility wrappers and extension adapters onto the
  canonical owner
- additive internal or non-breaking delegated rollout needed to prove the typed
  core before public naming is ratified

The following remain unauthorized unless a later user review explicitly
ratifies them:

- settling the final exported package-owned public load verb
- settling the final exported public spelling of the builder-driven descriptor
  surface
- removing, renaming, or breaking repo-owned public APIs
- changing authoritative table semantics, retained annotation semantics,
  single-parent or multi-parent validation semantics, or stable asset
  destructuring order

## Verification and green-state gates

Every downstream implementation tranche must begin and end in a green,
policy-compliant state.

Standing green-state requirements from the PRD:

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`

If a tranche changes examples or public docs examples under `examples/src/`,
it must also run the relevant example scripts under `examples/Project.toml` and
record which ones were exercised.

Minimum verification expectations across this tranche set:

- direct tests for the canonical package-owned owner across file, stream, and
  in-memory table sources
- direct tests for tables-only, node-type, supplied-basenode, and
  builder-driven request shapes through the canonical owner
- wrapper-parity tests that compare compatibility wrappers against the
  canonical owner for the same semantic request
- focused negative verification that would fail known bad implementations such
  as owned `Vector{Any}` storage, `typejoin`-based recovery, wrapper-owned
  semantics, or stale docs that still present compatibility surfaces as the
  primary contract
- continued extension verification for activation, rejection, annotation,
  rooted-network scheduling, and authoritative-table retention

Weak proxies are not sufficient. The tranche gates must verify the real public
contract and the real owner-level invariant, not only that "the suite passes".

## Tranche summary

1. `Foundational canonical load owner and typed core repair`
   Type: `AFK`
   Blocked by: none
   User stories: `2, 3, 4, 5, 8, 10, 11, 12, 14`

2. `Compatibility and extension migration onto the canonical owner`
   Type: `AFK`
   Blocked by: `Tranche 1`
   User stories: `6, 8, 9, 10, 11, 14`

3. `Public surface ratification and migration decision`
   Type: `HITL`
   Blocked by: `Tranche 1`, `Tranche 2`
   User stories: `1, 7, 13, 15`

4. `Approved public rollout and contract synchronization`
   Type: `AFK`
   Blocked by: `Tranche 3`
   User stories: `1, 7, 13, 14`

## Tranche 1: foundational canonical load owner and typed core repair

**Type**: AFK
**Blocked by**: None -- can start immediately

### Parent PRD

`.workflow-docs/202605040131_type-stable-parse/01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of `CONTRIBUTING.md`,
  `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`,
  `STYLE-workflow-docs.md`, and `STYLE-writing.md`
- Mandated reading of `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
  and `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- Mandated reading of `fileio.jl/README.md`,
  `fileio.jl/src/loadsave.jl`, `fileio.jl/src/types.jl`,
  `fileio.jl/src/query.jl`, `Tables.jl/README.md`, and
  `Tables.jl/src/Tables.jl`
- Mandated preservation of the user-review gates in the PRD: no settled public
  exported load verb and no settled public builder-surface spelling may be
  chosen in this tranche

### What to build

Build the foundational owner repair for the package-owned typed load
architecture.

This tranche establishes one canonical package-owned owner for source and
request normalization behind non-breaking delegation. It must preserve the
existing authoritative-table-first invariant while moving owned semantics out of
`FileIO` adapters and split helper surfaces.

The canonical owner must support the full semantic request model named in the
PRD:

- tables-only requests
- node-type requests
- supplied-basenode requests
- builder-driven requests with explicit owned typing

This tranche may add an internal or non-exported canonical entrypoint if needed
to preserve the PRD's public-name review gate. It must not settle the final
public spelling on its own.

When this tranche is complete, the package-owned materialization core must carry
explicit request, handle, parent-collection, and result typing anywhere
LineagesIO owns the behavior. The owning core must no longer depend on package-
owned `Any` storage or package-owned runtime type recovery.

### Legacy artifacts to retire or demote

- `build_load_request(...)` in `src/fileio_integration.jl` as the practical
  owner of request semantics
- separate request normalization split between `fileio_load(...)`,
  `load_alife_table(...)`, and `src/construction.jl`
- `materialized_handles::Vector{Any}` in `src/construction.jl`
- generic parent-collection recovery through
  `build_parent_collection(::AbstractLoadRequest, parent_handles::Vector{Any})`
- `typejoin`-based parent-handle or builder-type recovery in the canonical
  owner path
- any builder-path design that recovers owned types from callback signatures
  instead of requiring an explicitly typed owned descriptor

Artifacts may survive only as thin compatibility delegators outside the
canonical owner. They must no longer remain a second implementation of the
owned semantics.

### Forbidden regressions

- moving the real semantic owner back into `FileIO` wrappers or positional
  argument tuples
- bypassing authoritative table construction in favor of direct parser-to-graph
  construction
- replacing `Vector{Any}` with another erased container and claiming the owner
  is now typed
- hiding runtime recovery behind helper functions instead of removing it
- proving builder typing only with post-hoc assertions while still recovering
  parent-collection types at runtime
- choosing or documenting the final public load verb or builder-surface spelling
  as if that decision were already ratified

### Environment and dependency baseline

- Use the existing root `Manifest.toml` and the existing `test/Project.toml`
  and `docs/Project.toml` environments
- Use the upstream workspace at
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`
  as the approved primary-source set for `FileIO` and `Tables`
- Do not add dependencies or edit dependency declarations directly without
  user review, consistent with `STYLE-julia.md`
- Preserve all current repo-owned public names through this tranche unless a
  reviewed exception is recorded explicitly

### How to verify

- **Manual**: exercise the canonical owner directly for file-backed, stream-
  backed, and in-memory alife sources and confirm it can normalize tables-only,
  node-type, supplied-basenode, and builder-driven requests without routing the
  semantics through `FileIO` ownership
- **Manual**: inspect the canonical owner path and confirm authoritative tables
  are built before any graph or basenode materialization occurs
- **Automated**: add direct tests for the canonical owner across file, stream,
  and in-memory alife sources, with explicit coverage for tables-only,
  node-type, supplied-basenode, and builder-driven request descriptors
- **Automated**: add focused negative checks that fail if owned request
  normalization still depends on `FileIO` wrappers or if owned materialization
  still depends on `Vector{Any}` or `typejoin` recovery
- **Automated**: run `julia --project=test test/runtests.jl`
- **Automated**: run `julia --project=docs docs/make.jl`

### Acceptance criteria

- [ ] Given a file, stream, or in-memory alife source, when it is normalized by
      the canonical package-owned owner, then the same semantic request model is
      used before authoritative table construction regardless of entry surface
- [ ] Given a canonical tables-only request, when the owner completes, then it
      returns the same authoritative `node_table` and `edge_table` semantics as
      current format loaders
- [ ] Given a canonical node-type, supplied-basenode, or builder-driven
      materialization request, when the owner completes, then owned request,
      handle, parent-collection, and result typing are explicit rather than
      recovered at runtime
- [ ] Given the owned materialization core named above, when this tranche is
      complete, then package-owned `Vector{Any}` storage and package-owned
      `typejoin` recovery are removed or demoted out of the canonical owner
- [ ] Given the PRD's user-review gates, when this tranche ends, then no final
      exported public load verb or builder-surface spelling has been silently
      ratified
- [ ] Given a known anti-fix shape such as wrapper-owned semantics or hidden
      runtime recovery, when verification is run, then the tranche fails rather
      than reporting a fake green

### User stories addressed

- User story 2: authoritative tables-only load mode
- User story 3: typed basenode collection by node type
- User story 4: supplied-basenode request surface
- User story 5: builder-driven typed materialization
- User story 8: one owner for request normalization
- User story 10: rooted-network validation preserved
- User story 11: annotation retention preserved
- User story 12: stable public asset order preserved
- User story 14: verification through tests, JET, and docs

## Tranche 2: compatibility and extension migration onto the canonical owner

**Type**: AFK
**Blocked by**: Tranche 1

### Parent PRD

`.workflow-docs/202605040131_type-stable-parse/01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of `CONTRIBUTING.md`,
  `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`,
  `STYLE-workflow-docs.md`, and `STYLE-writing.md`
- Mandated reading of `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
  and `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- Mandated reading of `fileio.jl/README.md`,
  `fileio.jl/src/loadsave.jl`, `fileio.jl/src/types.jl`,
  `fileio.jl/src/query.jl`, `Tables.jl/README.md`, and
  `Tables.jl/src/Tables.jl`
- Before any extension-touching task begins, mandated identification and
  line-by-line reading of the exact `PhyloNetworks.jl` and `MetaGraphsNext.jl`
  upstream files that define the constructor, mutation, and view contracts
  touched by that task

### What to build

Build the migration tranche that makes wrappers and extensions consume the
canonical owner instead of acting as parallel semantic owners.

This tranche must move the following surfaces onto the canonical owner
established in Tranche 1:

- `FileIO` path and stream wrappers
- `load_alife_table(...)`
- extension-owned `PhyloNetworks` materialization adapters
- extension-owned `MetaGraphsNext` materialization adapters and views

After migration, compatibility wrappers may still exist, but they must be thin
delegators that translate host-framework or legacy calling conventions into the
canonical package-owned source and materialization descriptors.

Extension code may still specialize package-owned protocol hooks, but it must do
so as an extension of the canonical owner rather than as a shadow request model
or a second type-recovery implementation.

### Legacy artifacts to retire or demote

- `fileio_load(...)` as anything more than a compatibility wrapper
- `load_alife_table(...)` as a separate semantic owner
- extension-owned parent-collection recovery from erased handles
- `typejoin`-based parent-handle recovery in `ext/PhyloNetworksIO.jl`
- the `MetaGraphsNext` multi-parent probe shim if the canonical owner can
  replace indirect capability inference with an honest typed or trait-based
  contract

If any artifact must temporarily survive, it may do so only as a thin adapter
with no independent semantic rules.

### Forbidden regressions

- wrapper behavior that diverges semantically from the canonical owner for the
  same source and request
- extension-only request logic that reintroduces a second semantic owner
- reintroducing `Any` storage or runtime type recovery in extension paths
- compatibility wrappers that continue to define the user-facing semantics in
  docs or tests
- extension shims that silently persist as shadow implementations when the
  canonical owner could own the behavior directly

### Environment and dependency baseline

- Use the same root, test, and docs environments as Tranche 1
- Preserve `FileIO` integration and extension activation behavior throughout
- Use only approved upstream checkouts for `FileIO`, `Tables`,
  `PhyloNetworks.jl`, and `MetaGraphsNext.jl`
- Do not add extension-specific dependencies or rewrite extension contracts
  beyond what is required to align them with the canonical owner

### How to verify

- **Manual**: load the same rooted tree, rooted network, and in-memory alife
  sources through the canonical owner and through the compatibility wrappers and
  confirm that authoritative tables, result shapes, and validation behavior
  agree
- **Manual**: inspect extension paths and confirm they specialize package-owned
  hooks rather than rebuilding request semantics independently
- **Automated**: add wrapper-parity tests comparing `FileIO.load(...)` and
  `load_alife_table(...)` against the canonical owner for matching requests
- **Automated**: add or strengthen extension tests proving rooted-network
  validation, annotation retention, and authoritative-table retention remain
  green after migration
- **Automated**: add focused negative checks that fail if extension paths still
  recover parent-collection types from erased handles at runtime
- **Automated**: run `julia --project=test test/runtests.jl`
- **Automated**: run `julia --project=docs docs/make.jl`

### Acceptance criteria

- [ ] Given `FileIO.load(...)`, when a supported file or stream source is
      loaded, then it delegates into the canonical owner rather than owning a
      separate request-normalization path
- [ ] Given `load_alife_table(...)`, when an in-memory alife table is loaded,
      then it delegates into the same canonical owner used for file-backed or
      stream-backed loads
- [ ] Given the `PhyloNetworks` and `MetaGraphsNext` extensions, when they
      materialize results, then they extend package-owned protocols without
      reintroducing owned hot-path erasure or runtime type recovery
- [ ] Given any compatibility adapter or extension artifact named above, when
      this tranche is complete, then it is removed, demoted, or otherwise
      prevented from surviving as a second implementation of owned semantics
- [ ] Given a known anti-fix shape such as wrapper divergence or extension-side
      shadow typing, when verification is run, then the tranche fails rather
      than reporting a fake green

### User stories addressed

- User story 6: in-memory alife through the same canonical owner
- User story 8: one owner for request normalization
- User story 9: extension integration without erased materialization behavior
- User story 10: rooted-network validation preserved
- User story 11: annotation retention preserved
- User story 14: verification through tests, JET, and docs

## Tranche 3: public surface ratification and migration decision

**Type**: HITL
**Blocked by**: Tranche 1, Tranche 2

### Parent PRD

`.workflow-docs/202605040131_type-stable-parse/01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of `CONTRIBUTING.md`,
  `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`,
  `STYLE-workflow-docs.md`, and `STYLE-writing.md`
- Mandated reading of `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
  and `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- Mandated preservation of the PRD's explicit user-review gates for public
  naming, builder-surface spelling, and any repo-owned public API breakage

### What to build

Build the explicit user-review gate required by the PRD before any final public
API naming or migration policy is implemented.

This tranche must produce the ratification material needed for an honest
decision on:

- whether the first-class package-owned public verb is `LineagesIO.load` or a
  distinct exported name
- what exported public spelling, if any, will represent the builder-driven
  descriptor surface
- whether `load_alife_table(...)` remains a public convenience wrapper,
  becomes a transitional wrapper, or moves more clearly into a compatibility
  story
- whether any deprecations, renames, or explicit migration notes are approved

This tranche is not authorized to silently ship the decision. Its job is to
surface the decision clearly, explain the compatibility consequences, and
capture the user's ratification.

### Legacy artifacts to retire or demote

- unresolved ambiguity about the final first-class public load verb
- unresolved ambiguity about the builder-driven public spelling
- unresolved ambiguity about the long-term public role of `load_alife_table(...)`
- any stale assumption that wrapper-first docs can persist without an explicit
  approved compatibility story

### Forbidden regressions

- shipping a new exported public verb, public rename, or deprecation without
  explicit user approval
- collapsing typed surfaces and compatibility surfaces into one undocumented
  blur to avoid making the decision
- documenting a public guarantee that the user has not ratified
- treating the absence of a decision as permission to preserve the status quo
  indefinitely without an explicit compatibility statement

### Environment and dependency baseline

- Preserve additive rollout only. No public breakage is authorized until the
  user ratifies it explicitly
- If this tranche changes only workflow artifacts, keep the repository otherwise
  unchanged and inherit the prior green state
- If this tranche touches repo-owned docs or code to support the decision
  record, it must still satisfy the standing docs and test gates

### How to verify

- **Manual**: produce a guarantee matrix and migration note that explicitly
  names first-class typed surfaces, convenience wrappers, compatibility-only
  wrappers, and any candidate deprecations or breaks
- **Manual**: review that matrix and migration note with the user and record the
  explicit ratified decision
- **Manual**: confirm the ratified decision scopes any approved exception
  precisely instead of broadening it into a new default rule
- **Automated**: if this tranche changes repo-owned docs or code, run
  `julia --project=test test/runtests.jl`
- **Automated**: if this tranche changes repo-owned docs or code, run
  `julia --project=docs docs/make.jl`

### Acceptance criteria

- [ ] Given the PRD's open public-surface questions, when this tranche
      completes, then the user has explicitly ratified the final public naming
      and migration direction or has explicitly deferred it with scope and
      constraints recorded
- [ ] Given any proposed repo-owned public API breakage, when this tranche
      completes, then a migration and compatibility note exists and has been
      reviewed by the user before implementation proceeds
- [ ] Given `FileIO.load(...)`, `load_alife_table(...)`, and the package-owned
      typed surface, when the guarantee matrix is reviewed, then it is clear
      which surfaces are first-class, which are convenience wrappers, and which
      are compatibility-only
- [ ] Given a known anti-fix shape such as silently shipping an unapproved
      public decision, when verification is run, then the tranche fails rather
      than reporting a fake green

### User stories addressed

- User story 1: package-owned file or stream public API
- User story 7: explicit `FileIO` compatibility story
- User story 13: typed versus compatibility surfaces are explicit
- User story 15: repo-owned API breakage is surfaced for review

## Tranche 4: approved public rollout and contract synchronization

**Type**: AFK
**Blocked by**: Tranche 3

### Parent PRD

`.workflow-docs/202605040131_type-stable-parse/01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of `CONTRIBUTING.md`,
  `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`,
  `STYLE-workflow-docs.md`, and `STYLE-writing.md`
- Mandated reading of `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
  and `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- Mandated reading of the user-ratified public naming and migration decision
  produced by Tranche 3
- Mandated reading of the same `FileIO` and `Tables` upstream primary sources
  used in Tranches 1 and 2

### What to build

Build the approved public rollout after the user-review gate is complete.

This tranche applies the ratified public naming and compatibility policy to the
repo-owned API, docs, README, examples, and direct public-surface tests. It may
export the approved package-owned public surface, preserve approved wrappers,
introduce approved deprecations, and synchronize the guarantee story everywhere
the repository describes loading.

When this tranche completes, a reader of `README.md`, `docs/src/index.md`, and
any source-specific documentation must be able to tell immediately:

- what the first-class package-owned typed surface is
- what remains a convenience wrapper
- what remains compatibility-only
- what migration or deprecation story applies, if any

### Legacy artifacts to retire or demote

- README and docs language that presents `FileIO.load(...)` as the primary
  LineagesIO contract when that is no longer the ratified story
- README and docs language that leaves the typed and compatibility boundaries
  implicit
- examples that demonstrate only compatibility wrappers when a first-class
  package-owned surface has been ratified
- any unapproved transitional naming or wrapper narrative superseded by the
  Tranche 3 decision

### Forbidden regressions

- user-facing docs that blur typed ownership and compatibility wrappers again
- public rollout that contradicts the user-ratified decision from Tranche 3
- removing compatibility wrappers without the approved migration story
- changing authoritative table semantics, annotation retention semantics, or
  stable asset order while updating the public surface
- reintroducing `FileIO` host-framework types into the canonical owned contract

### Environment and dependency baseline

- Follow the exact public naming and migration scope ratified in Tranche 3
- Preserve `FileIO.load(...)` support unless the user explicitly ratifies a
  narrower compatibility contract
- Use the existing root, test, docs, and examples environments
- If examples change, run only the examples relevant to the touched surfaces and
  record them explicitly

### How to verify

- **Manual**: inspect `README.md`, `docs/src/index.md`, and any touched
  source-specific docs and confirm the public contract story is consistent with
  the Tranche 3 decision
- **Manual**: exercise the approved first-class public surface and confirm it
  matches the documented tables-only, node-type, supplied-basenode, and
  builder-driven story
- **Automated**: add or update direct public-surface tests for the ratified
  first-class package-owned API and wrapper-parity tests for any retained
  compatibility wrappers
- **Automated**: run `julia --project=test test/runtests.jl`
- **Automated**: run `julia --project=docs docs/make.jl`
- **Automated**: if touched, run `julia --project=examples examples/src/alife_standard_mwe.jl`
- **Automated**: if touched, run `julia --project=examples examples/src/phylonetworks_mwe01.jl`
- **Automated**: if touched, run `julia --project=examples examples/src/phylonetworks_mwe02.jl`

### Acceptance criteria

- [ ] Given the Tranche 3 ratified decision, when this tranche completes, then
      the approved first-class package-owned public surface is implemented and
      documented consistently across repo-owned API, docs, README, and examples
- [ ] Given `FileIO.load(...)` and any retained convenience wrappers, when this
      tranche completes, then they are documented and tested as wrappers rather
      than as the primary LineagesIO contract
- [ ] Given the public contract documents named above, when they are reviewed,
      then a user can distinguish first-class typed surfaces, convenience
      wrappers, and compatibility-only surfaces without inferring hidden policy
- [ ] Given any artifact named above as legacy documentation or wrapper
      positioning, when this tranche is complete, then it is removed, demoted,
      or otherwise prevented from surviving as a second public contract
- [ ] Given a known anti-fix shape such as stale wrapper-first docs or silent
      divergence from the ratified public decision, when verification is run,
      then the tranche fails rather than reporting a fake green

### User stories addressed

- User story 1: package-owned file or stream public API
- User story 7: explicit `FileIO` compatibility story
- User story 13: typed versus compatibility surfaces are explicit
- User story 14: verification through tests, JET, docs, and examples
