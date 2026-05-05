---
date-created: 2026-05-04T22:38:01
---

# PRD: Typed package-owned load architecture

## User statement

> I want LineagesIO to treat FileIO.load(...) as a compatibility wrapper only, and to define a first-class package-owned public load surface whose internals are cleanly typed and parameterized end to end. The goal is honest typed ownership, not forcing exact inference everywhere. Preserve flexibility and authoritative table semantics, remove internal type erasure from the core path, and clearly document which surfaces are compatibility-only versus truly typed.
>
> I want LineagesIO to have a clean package-owned load architecture where FileIO.load(...) is treated only as a thin compatibility wrapper, and the real first-class public surface inside this repo is fully typed and parameterized wherever the package owns the behavior. The redesign should remove internal type erasure and runtime type recovery from the core load/materialization path while preserving authoritative tables, retained annotations, flexible container/type-agnostic semantics, and extension support.
>
> FileIO.load(...): compatibility-only wrapper. No typed guarantee promised.
>
> Package-owned public typed API: This is the first-class public surface. It owns request and surface descriptors, typed load and materialization modes, the explicit compatibility story, and the documented guarantees.
>
> Internal typed core: no `Vector{Any}`, no runtime `typejoin` recovery, no request erasure in the hot path, and explicit handle, result, and parent-collection typing.
>
> Use `./.workflow-docs/202605040131_type-stable-parse/01_prd.md`.
>
> Repo-owned public API breakage must be escalated for user review rather than silently authorized.

## Problem statement

LineagesIO currently has strong typed ingredients, but it does not yet present a
clean package-owned load architecture.

User-facing, the package documentation and examples make `load(...)` look like
the main public surface, even though that path is fundamentally hosted by
`FileIO` format detection and dispatch. Internally, the package already owns the
real semantics that matter to LineagesIO users: authoritative table
construction, graph or basenode materialization, retained annotation behavior,
single-parent versus multi-parent validation, and extension hooks. Those owned
semantics are not yet surfaced as an explicit, typed public contract.

Architecturally, the current load path still contains type erasure and runtime
type recovery in the package-owned hot path. The current implementation uses
`Vector{Any}` handle storage in `src/construction.jl`, reconstructs parent
collection element types with `reduce(typejoin, map(typeof, ...))`, and repeats
the same pattern in the `PhyloNetworks` extension. The request side is also
implicitly shaped by legacy argument tuples and `FileIO` wrappers instead of a
first-class package-owned request model. The result is that LineagesIO owns the
behavior, but does not yet own it honestly in its public API or its internal
typing story.

## Target outcome

When this work is complete, LineagesIO will have one canonical package-owned
load architecture with a documented compatibility boundary.

The canonical package-owned public load surface will:

- define explicit public source descriptors and public materialization
  descriptors
- accept tables-only, node-type, supplied-basenode, and builder-driven load
  modes without implicit request recovery
- own the authoritative guarantees for what is typed, what is flexible, and
  what is compatibility-only
- serve as the single normalization point for both file or stream inputs and
  in-memory alife table inputs

The package-owned typed core will:

- preserve authoritative table construction as the canonical parse output
- preserve retained node and edge annotations
- preserve container-agnostic and extension-friendly materialization semantics
- remove package-owned `Any` storage and package-owned runtime type recovery
  from the core materialization path
- carry explicit request, handle, parent-collection, and result typing through
  the parts of the system that LineagesIO owns

The compatibility story will be explicit:

- `FileIO.load(...)` remains supported as a thin compatibility wrapper
- legacy package convenience surfaces may remain as wrappers if needed
- docs and examples will distinguish compatibility-only entry surfaces from the
  package-owned typed surface
- any repo-owned public API breakage will be surfaced for user review before it
  is executed

This effort is about honest typed ownership, not promising universal exact
compiler inference for every caller or every callback shape.

## User stories

1. As a LineagesIO caller, I can load from a path or stream through a
   package-owned public API without depending on `FileIO` to define LineagesIO's
   real semantics.
2. As a caller who wants authoritative tables only, I can request a tables-only
   load mode through the package-owned API and receive the same authoritative
   `node_table` and `edge_table` semantics the package already owns.
3. As a caller who wants a typed basenode collection, I can request materialized
   node objects by node type without going through an implicit legacy argument
   convention.
4. As a caller who already has a basenode instance, I can request binding into
   that basenode through an explicit, typed package-owned request surface.
5. As a caller with a custom builder strategy, I can use a builder-driven load
   mode that makes the relevant handle and parent-collection types explicit
   instead of recovering them at runtime.
6. As a caller loading in-memory alife data, I can use the same canonical owner
   and request model as file-backed loads instead of entering a separate
   semantic path.
7. As a `FileIO` user, I can keep using `FileIO.load(...)`, but I can see in the
   docs that it is a compatibility wrapper rather than the primary LineagesIO
   API contract.
8. As a maintainer, I can look at one package-owned owner for request
   normalization instead of splitting public load semantics between `FileIO`
   wrappers, alife helpers, and construction internals.
9. As an extension author, I can integrate `PhyloNetworks` or `MetaGraphsNext`
   without reintroducing `Vector{Any}` or runtime `typejoin` recovery in the
   materialization path.
10. As a caller loading rooted networks, I keep the current validation and
    scheduler guarantees for single-parent versus multi-parent handling.
11. As a caller who depends on annotation retention, I keep the current retained
    node and edge annotation behavior in both authoritative tables and
    materialized callbacks.
12. As a caller who destructures assets, I keep the stable public asset order
    `(graph, basenode, node_table, edge_table)`.
13. As a reviewer, I can tell exactly which surfaces promise typed ownership and
    which ones are compatibility-only.
14. As a maintainer, I can verify the typed redesign with concrete tests, JET,
    and docs rather than blanket `@inferred` promises that exceed package
    ownership.
15. As a user reviewing public API changes, I can see any proposed repo-owned
    API breakage called out explicitly before implementation proceeds.

## Authorized disruption boundary

- internal redesign allowed: deep refactoring of `src/fileio_integration.jl`,
  `src/alife_format.jl`, `src/newick_format.jl`, `src/construction.jl`,
  `src/views.jl`, relevant docs, tests, and extension adapters as needed to
  create a canonical package-owned load API and typed materialization core
- internal redesign forbidden: weakening authoritative table semantics, retained
  annotation semantics, single-parent or multi-parent validation, extension hook
  ownership, or green-state discipline
- external breaking changes allowed: not yet authorized for execution; this PRD
  may identify candidate repo-owned API changes, but any break to repo-owned
  public names or signatures must stop for user review before implementation
- required migration or compatibility obligations: preserve `FileIO.load(...)`
  as a compatibility wrapper, preserve or wrap current package convenience
  surfaces until a reviewed migration plan says otherwise, update docs and tests
  whenever the public story changes, and provide an explicit compatibility
  narrative for any future reviewed breakage
- non-negotiable protections: package-owned typed public surface, `FileIO` as a
  thin compatibility layer, no package-owned hot-path `Vector{Any}`, no
  package-owned runtime `typejoin` recovery, no request erasure in the canonical
  owner, and no false promise of exact inference everywhere

## Current-state architecture

- Existing owners are split across `src/fileio_integration.jl` for `FileIO`
  entry adapters, `src/alife_format.jl` for in-memory alife entry,
  `src/newick_format.jl` and `src/alife_format.jl` for authoritative table
  construction, `src/construction.jl` for materialization and protocol hooks,
  and `src/views.jl` for typed asset and store result containers.
- Current typed foundations are real and valuable. `src/construction.jl` already
  defines concrete request types such as `TablesOnlyLoadRequest`,
  `NodeTypeLoadRequest{T}`, `BasenodeLoadRequest{T}`, and
  `BuilderLoadRequest{T}`. `src/tables.jl` already owns concrete
  `Tables.AbstractColumns` implementations. `src/views.jl` already owns typed
  `LineageGraphAsset` and `LineageGraphStore` containers.
- Current ownership of the public semantic is blurred. In practice,
  `src/fileio_integration.jl` and implicit argument tuples define the public
  load shape, while the package-owned request and materialization types remain
  internal and undocumented.
- Current docs reinforce that blur. `README.md` and `docs/src/index.md` present
  `load(...)` as the primary public happy path, while `LineagesIO` itself only
  exports `load_alife_table` from its own module namespace.
- The core materialization hot path still performs type erasure and recovery.
  `src/construction.jl` allocates `Any[nothing for _ in 1:node_count]`, creates
  `Any[...]` parent handle collections, and rebuilds element types with
  `reduce(typejoin, map(typeof, ...))`. `ext/PhyloNetworksIO.jl` repeats the
  same parent-collection recovery pattern.
- The current pattern is especially problematic because it appears in the part
  of the system that LineagesIO fully owns: authoritative tables have already
  been built, and the package is now materializing user-facing graph or
  basenode results.
- The package already has one strong invariant worth preserving: the parse layer
  builds authoritative tables first, and only then materializes into graph or
  basenode structures. That invariant is good and should remain canonical.
- A foundational tranche is required before public-surface cleanup can be
  declared complete. The owner and invariant problem sits in the request and
  materialization core, not only in documentation wording.

## Target architecture

- There will be exactly one canonical package-owned owner for load semantics.
  Every repo-owned load surface will normalize into that owner before table
  materialization occurs.
- The canonical package-owned owner will define explicit public source
  descriptors and explicit public materialization descriptors. Source and
  materialization concerns will no longer be encoded as positional legacy tuples.
- The exact exported function name may be `LineagesIO.load` or another explicit
  package-owned verb chosen during execution, but the architecture must not
  depend on `FileIO` naming to express LineagesIO's primary contract.
- Candidate source descriptors include package-owned wrappers for file or path,
  stream, and in-memory alife table sources. A source descriptor may carry
  format or provenance data when LineagesIO owns that meaning.
- Candidate materialization descriptors include explicit tables-only, node-type,
  supplied-basenode, and builder-driven request types. These descriptors are the
  first-class public request model and replace implicit tuple recovery.
- Builder-driven materialization must become honestly typed. If a raw callback
  cannot make its handle and parent-collection types explicit, the public
  descriptor must require those types as parameters instead of recovering them
  at runtime.
- The canonical parse layer remains format-specific and authoritative.
  `src/newick_format.jl` and `src/alife_format.jl` continue to build
  authoritative `SourceTable`, `CollectionTable`, `GraphTable`, `NodeTable`, and
  `EdgeTable` values before any graph or basenode materialization.
- The canonical materialization core consumes authoritative table assets plus a
  typed public request and produces typed `LineageGraphAsset` and
  `LineageGraphStore` results without package-owned `Any` storage or package-
  owned runtime type recovery.
- The package-owned materialization contract owns handle typing, parent-
  collection typing, graph finalization, basenode binding, and result projection
  semantics. Those concerns are no longer allowed to float between wrappers and
  runtime recovery code.
- `FileIO.load(...)` becomes a thin compatibility adapter. It may still perform
  `FileIO`'s host-framework duties such as format inference and formatted-file
  dispatch, but it must not be the canonical owner of LineagesIO load semantics.
- `load_alife_table` may remain as a convenience surface, but if it does, it
  must delegate into the same canonical owner and share the same typed request
  model and documentation guarantees.
- Extension hooks remain package-owned through `add_child`, `bind_basenode!`,
  `finalize_graph!`, `graph_from_finalized`, and `basenode_from_finalized`.
  Extension code may specialize those hooks, but it may not reintroduce the
  erased-hot-path pattern the core is removing.
- A public guarantee matrix will document which surfaces are first-class and
  typed, which surfaces are convenience wrappers, and which surfaces are
  compatibility-only.

## Implementation decisions

- Preserve authoritative table construction as the canonical parse output and do
  not collapse the design into direct graph construction from parser callbacks.
- Preserve retained node and edge annotation semantics in both tables and
  materialization callbacks.
- Preserve container-agnostic and target-agnostic semantics. The redesign may
  improve typing, but it must not hard-code one graph representation or one
  basenode representation as the package's only valid target.
- Treat typed ownership as a LineagesIO contract about owned data flow and owned
  abstractions, not as a blanket contract about Julia compiler inference for all
  callers.
- Keep request, handle, parent-collection, and result typing explicit anywhere
  LineagesIO owns the behavior. If a surface cannot do that honestly, it is a
  compatibility surface, not the first-class typed surface.
- Prefer additive rollout and wrapper delegation first. Any repo-owned public API
  removal, rename, or signature break must be escalated for user review.
- Preserve current single-parent and multi-parent validation semantics unless a
  reviewed change explicitly says otherwise.
- Preserve `LineageGraphAsset` destructuring order and keep result typing aligned
  with actual graph, basenode, node-table, and edge-table ownership.
- Use a foundational tranche first. The first execution slice should establish
  the canonical owner and typed core while keeping compatibility wrappers in
  place.

## Module design

### Package-owned load API

- Name: package-owned load API
- Responsibility: define the canonical package-owned load entry surface and the
  public source and materialization descriptors that own LineagesIO semantics
- Interface: one canonical entry surface accepts typed source and typed request
  values; path, stream, and alife convenience helpers delegate to it; `FileIO`
  types do not leak into the owned core contract
- Tested: direct tests for tables-only, node-type, supplied-basenode, and
  builder-driven requests across file, stream, and in-memory table sources

### Compatibility adapters

- Name: compatibility adapters
- Responsibility: preserve `FileIO.load(...)` and any retained legacy package
  helpers as thin wrappers with explicit compatibility-only documentation
- Interface: wrappers only translate host-framework or legacy calling
  conventions into canonical package-owned source and request descriptors
- Tested: wrapper-parity tests compare compatibility outputs against the
  canonical owner for the same source and request

### Format ingestion and authoritative tables

- Name: format ingestion and authoritative tables
- Responsibility: parse Newick and alife inputs and build authoritative source,
  collection, graph, node, and edge tables before materialization
- Interface: format-specific loaders return authoritative table assets and any
  required load metadata for the typed materialization core
- Tested: current table, annotation, and table-only tests remain green; any new
  package-owned surface must demonstrate the same authoritative table semantics

### Typed materialization core

- Name: typed materialization core
- Responsibility: materialize authoritative table assets into typed graph or
  basenode results without package-owned type erasure
- Interface: request types or request traits determine handle type, parent-
  collection type, basenode binding path, graph finalization path, and result
  projection without `Vector{Any}` or runtime `typejoin` recovery
- Tested: current single-parent, basenode-binding, builder, network-validation,
  multi-parent scheduler, and integration tests remain green; add focused
  type-shape tests and JET coverage instead of overspecifying universal
  `@inferred` behavior

### Result views and store types

- Name: result views and store types
- Responsibility: preserve and clarify typed `LineageGraphAsset` and
  `LineageGraphStore` ownership and destructuring behavior
- Interface: asset order remains `(graph, basenode, node_table, edge_table)`,
  and result type parameters reflect the actual owned graph and basenode types
- Tested: current asset destructuring and graph-store coordinate tests remain
  green; canonical-surface tests confirm wrappers return equivalent result types

### Extension adapters

- Name: extension adapters
- Responsibility: integrate `PhyloNetworks` and `MetaGraphsNext` with the typed
  core without reintroducing erased materialization behavior
- Interface: extension-owned hook implementations may specialize package-owned
  protocols and request traits, but they must not recover parent collection
  types from `Vector{Any}` at runtime
- Tested: existing extension activation, rejection, annotation, tree-compatible,
  and integration tests remain green; any extension-specific tranche must first
  read the exact upstream API files it touches

## Governance and controlled vocabulary

- Repo-local governance documents that must be read line by line in all
  downstream tranche, tasking, review, and audit documents are
  `CONTRIBUTING.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, and
  `STYLE-writing.md`.
- Bundled policy baseline read for this PRD, and required for agent-produced
  downstream workflow work, lives under
  `/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/`.
  The required files there are `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`,
  `STYLE-upstream-contracts.md`, `STYLE-verification.md`,
  `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, and `STYLE-writing.md`.
  Bundled `CONTRIBUTING.md` was not present in that reference set.
- Controlled vocabulary constraints include using `basenode` rather than `root`
  for the package abstraction, distinguishing `compatibility wrapper` from
  `package-owned public surface`, and distinguishing `authoritative tables` from
  `materialized graph or basenode results`.
- The phrases `typed core`, `public materialization descriptor`, `source
  descriptor`, `parent collection`, `ownership boundary`, and `green state`
  should be used consistently downstream.
- Downstream docs must not describe `FileIO.load(...)` as LineagesIO's primary
  public surface, and must not use `type stable` as a euphemism for compiler-
  perfect inference when the real contract is absence of package-owned erasure.

## Primary upstream references

- Core upstream checkouts for this redesign are located under
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`.
- The required `FileIO` primary sources for downstream work are
  `fileio.jl/README.md`, `fileio.jl/src/loadsave.jl`,
  `fileio.jl/src/types.jl`, and `fileio.jl/src/query.jl`.
- The required `Tables` primary sources for downstream work are
  `Tables.jl/README.md` and `Tables.jl/src/Tables.jl`.
- These sources establish the external host-framework and tabular-contract facts
  this PRD depends on: `FileIO` owns format detection and dispatch; `FileIO`
  provides `File{fmt}` and `Stream{fmt}` wrappers plus `load(...)` dispatch;
  `Tables` owns the `Tables.AbstractColumns` and `Tables.AbstractRow` contracts,
  including the optional typed `getcolumn` entrypoint.
- Conditional upstreams for extension tranches are `PhyloNetworks.jl` and
  `MetaGraphsNext.jl` in the same upstream workspace. Before any tranche changes
  LineagesIO behavior in `ext/PhyloNetworksIO.jl`,
  `ext/MetaGraphsNextIO.jl`, or `ext/MetaGraphsNextAbstractTreesIO.jl`, that
  tranche must identify and read the exact upstream files that define the
  relevant constructor, mutation, and view contracts.

## Tranche gates

- Every tranche must begin from a green state and end at a green state.
- The required test gate is `julia --project=test test/runtests.jl`, which
  includes core tests, extension tests, integration tests, Aqua, and JET.
- The required docs gate is `julia --project=docs docs/make.jl`.
- If a tranche changes examples, public docs examples, or source-specific
  loading behavior demonstrated under `examples/src/`, it must run the relevant
  example scripts under `examples/Project.toml` and record which ones were
  exercised.
- A foundational tranche is required before wrapper cleanup or documentation
  repositioning is considered complete.
- Any tranche that proposes repo-owned public API breakage, including renaming
  or deprecating package-owned load surfaces, must stop for user review with an
  explicit migration and compatibility note before implementation proceeds.
- No tranche may reintroduce package-owned hot-path erasure or runtime type
  recovery as a shortcut to keep compatibility green.

## Testing and verification decisions

- Keep the full test suite green throughout via `julia --project=test
  test/runtests.jl`.
- Keep the docs build green throughout via `julia --project=docs docs/make.jl`.
- Preserve current tests for file-backed loads, in-memory alife loads,
  authoritative tables, annotation retention, basenode binding, builder
  callbacks, multi-parent validation, extension activation, extension rejection,
  and soft-release integration behavior.
- Add focused tests for the canonical package-owned load surface so that tables-
  only, node-type, supplied-basenode, and builder-driven requests are all
  verified directly without depending on `FileIO` wrappers as the only entry
  path.
- Add focused type-shape verification for the owned core. The goal is to prove
  that owned request and parent-collection typing no longer depend on
  `Vector{Any}` and runtime `typejoin` recovery, not to require blanket
  `@inferred` success for every wrapper and every callback.
- Keep wrapper-parity verification. `FileIO.load(...)` and any retained
  convenience wrappers must be verified against the canonical owner for the same
  source and request.
- If an extension tranche occurs, add or update extension tests to prove the
  extension path does not reintroduce erased core behavior.

## Out of scope

- redesigning save or write architecture
- changing Newick or alife file-format semantics
- changing authoritative table schemas beyond what is required to support typed
  ownership
- removing `FileIO` integration
- promising universal exact compiler inference for arbitrary user builders
- extension-specific redesign that is not required to preserve compatibility
  with the new canonical typed core

## Open questions

- Owner: implementation review. Question: should the first-class package-owned
  public verb be exported as `LineagesIO.load` or given a distinct exported name
  to keep the compatibility story maximally explicit. Suggested resolution path:
  decide during the foundational tranche, then stop for user review if the
  answer changes repo-owned public naming.
- Owner: implementation review. Question: should `load_alife_table` remain a
  public convenience wrapper over the canonical owner, or be repositioned more
  strongly as a compatibility or transitional surface. Suggested resolution
  path: keep it as a delegating wrapper unless and until a reviewed migration
  plan says otherwise.
- Owner: implementation review. Question: what is the most ergonomic builder
  descriptor spelling that still makes handle and parent-collection types
  explicit. Suggested resolution path: prototype the foundational typed request
  layer first, then select the smallest honest public surface.

## Further notes

- The repo-governed workflow-doc location for this effort is
  `./.workflow-docs/202605040131_type-stable-parse/01_prd.md`.
- The top-level upstream workspace at
  `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`
  is authoritative for the technological-context projects named above.
- This redesign is not a clean-room replacement of LineagesIO's parse and table
  stack. The package already has the right high-level invariant, namely
  authoritative table construction before materialization. The work is to move
  public ownership and internal typing into alignment with that invariant.
