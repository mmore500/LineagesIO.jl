---
date-created: 2026-05-05T22:42:10-07:00
date-revised: 2026-05-05T23:04:00-07:00
status: ratified
---

# Tranche 3 public surface decision

## Authority

This document is the tranche 3 decision record required by:

- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`

If this document conflicts with the PRD, tranche file, tasking file, or
active governance authorities, the higher-priority authority controls and this
document must be revised before tranche 4 proceeds.

## Current status

This document closes the direct red state that existed when tranche 3 started:
the decision record file was missing entirely.

This document is now the ratified tranche 3 public-surface decision. It
inventories the current surfaces, records the verified current state and
upstream contract facts, captures the ratified public decisions, and defines
the exact authorization boundary that unblocks tranche 4.

## Governance and required reading

This decision record was prepared under the following active authorities:

- `AGENTS.md`
- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
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
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-1--tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-1a--remediation-tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-2--tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`

The bundled baseline style files under the `development-policies` skill
reference directory were also read and are byte-identical to the repo-local
`STYLE*.md` files above. Bundled `CONTRIBUTING.md` was not present there, so
repo-local `CONTRIBUTING.md` remains authoritative for contribution guidance.

Controlled vocabulary remains mandatory. This document uses `basenode`,
`package-owned public surface`, `compatibility wrapper`, `authoritative
tables`, `materialized graph or basenode result`, `source descriptor`,
`materialization descriptor`, `ownership boundary`, `lock item`, `red-state
repro`, and `verification artifact` consistently. It does not use `type
stable` as shorthand for universal exact inference.

## Settled decisions and non-negotiables

The following points are already settled by higher authorities and are not
being reopened in tranche 3:

- `FileIO.load(...)` is a compatibility wrapper, not the canonical
  package-owned owner of LineagesIO load semantics.
- The typed core, authoritative-table-first parse invariant, retained
  annotation behavior, single-parent and multi-parent validation semantics,
  and stable asset destructuring order `(graph, basenode, node_table,
  edge_table)` remain in force.
- No repo-owned public API removal, rename, export change, deprecation, or
  signature break is authorized until the user ratifies it explicitly here.
- The first-class package-owned file or stream verb is ratified as a distinct
  exported name: `LineagesIO.read_lineages`.
- The typed builder descriptor surface is ratified in principle as a
  first-class typed surface, and its exported public spelling is ratified as
  `LineagesIO.BuilderDescriptor`.
- `load_alife_table(...)` is ratified as a convenience wrapper over the
  canonical package-owned owner.
- No deprecations, renames, removals, or public breakage are ratified in this
  tranche. The tranche 4 rollout is additive only.

## Authorization boundary

In-scope work for tranche 3 is:

- create and revise this decision record
- inventory the current public and internal load surfaces
- classify the surfaces explicitly
- record either a ratified decision or an explicit deferral
- state whether tranche 4 is unblocked or remains blocked

Out of scope for tranche 3 is:

- implementing a new exported public verb
- changing exports in `src/LineagesIO.jl`
- repositioning README or docs as if the public decision were already shipped
- adding deprecations or migration behavior
- modifying examples or rollout tests

## Revalidated current state

The following facts were revalidated against the current repository before this
document was drafted:

- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  did not exist at tranche start.
- `src/load_owner.jl` already defines a non-exported typed canonical owner:
  `canonical_load(...)`.
- `src/load_owner.jl` already defines package-owned source descriptors:
  `NewickFilePathSourceDescriptor`, `NewickStreamSourceDescriptor`,
  `NewickTextSourceDescriptor`, `AlifeFilePathSourceDescriptor`,
  `AlifeStreamSourceDescriptor`, `AlifeTextSourceDescriptor`, and
  `AlifeTableSourceDescriptor`.
- `src/load_owner.jl` already defines typed request surfaces:
  `TablesOnlyLoadRequest`, `NodeTypeLoadRequest`, `BasenodeLoadRequest`, and
  `TypedBuilderLoadRequest`.
- `src/load_compat.jl` still owns the raw `builder = fn` compatibility story
  and still infers builder handle and parent-collection types through runtime
  method inspection and `reduce(typejoin, ...)`.
- `src/LineagesIO.jl` exports `load_alife_table` but does not export a
  package-owned `load` verb.
- `README.md` and `docs/src/index.md` still present `load(...)` wrapper flows
  as the primary public story.
- `docs/src/phylonetworks.md` still presents `load(path, HybridNetwork)` as the
  primary public happy path for that extension workflow.
- `test/core/canonical_load_owner.jl` already proves direct-owner entry for the
  internal typed owner surfaces and compares them against wrapper behavior.

## Upstream contract facts

The following host-framework facts were re-read from upstream primary sources:

- Verified from `FileIO` `README.md`, `src/loadsave.jl`, `src/query.jl`, and
  `src/types.jl`: `FileIO` owns `load(...)`, format inference, ambiguity
  handling, `File{fmt}` wrappers, `Stream{fmt}` wrappers, and formatted
  dispatch.
- Verified from `Tables` `README.md` and `src/Tables.jl`: `Tables` owns the
  in-memory table contract used by `load_alife_table(...)`, including
  `Tables.istable`, `Tables.columns`, `Tables.columnnames`, `Tables.getcolumn`,
  and the optional typed `getcolumn` entrypoint.
- Local inference from those verified upstream facts: a first-class
  LineagesIO-owned public surface must be classified separately from `FileIO`
  host dispatch, and `load_alife_table(...)` must be judged as a repo-owned
  surface over Tables-compatible input rather than as a `FileIO` surface.

## Current surface inventory

The table below names every current surface that a user or maintainer could
reasonably treat as part of the LineagesIO load story.

| Surface | Current code reality | Current docs reality | Current classification |
|---|---|---|---|
| `load(path)` / `load(File{fmt}(...))` / `load(Stream{fmt}(...))` tables-only flows | Hosted by `FileIO` and delegated through `src/fileio_integration.jl` and `src/load_compat.jl` into `canonical_load(...)` | Primary public happy path in README and docs | Compatibility wrapper |
| `load(src, NodeT)` | Hosted by `FileIO` wrapper entry and normalized through compatibility helpers before reaching typed owner requests | Documented as standard construction load | Compatibility wrapper |
| `load(src, basenode)` | Hosted by `FileIO` wrapper entry and normalized through compatibility helpers before reaching typed owner requests | Documented as standard supplied-target load | Compatibility wrapper |
| `load(src; builder = fn)` | Hosted by `FileIO` wrapper entry and normalized through compatibility helpers; still uses runtime builder-type recovery | Documented as public builder surface | Compatibility wrapper |
| `load_alife_table(table)` and companions | Repo-owned convenience entry in `src/alife_format.jl`; delegates through `src/load_compat.jl` into canonical owner | Documented directly as the in-memory alife entry surface | Convenience wrapper |
| `canonical_load(descriptor, request)` | Non-exported typed owner in `src/load_owner.jl`; exercised directly in tests | Not documented as public API | Internal owner surface |
| Source descriptors such as `NewickFilePathSourceDescriptor` and `AlifeTableSourceDescriptor` | Non-exported package-owned source model in `src/load_owner.jl` | Not documented as public API | Internal owner surface |
| Request descriptors such as `TablesOnlyLoadRequest`, `NodeTypeLoadRequest`, and `BasenodeLoadRequest` | Non-exported typed request model in `src/load_owner.jl` | Not documented as public API | Internal owner surface |
| `TypedBuilderLoadRequest(...)` | Non-exported typed builder descriptor in `src/load_owner.jl`; direct-owner tests prove it | Not documented as public API | Internal owner surface |
| `load(path, HybridNetwork)` and `load(path, HybridNetwork())` | Extension-backed materialization reached through `FileIO` wrapper entry surfaces | Documented as the PhyloNetworks public workflow | Compatibility wrapper over extension-backed materialization |
| `load(path, MetaGraph)` and `load(path, metagraph_instance)` | Extension-backed materialization reached through `FileIO` wrapper entry surfaces | Documented as the MetaGraphsNext public workflow | Compatibility wrapper over extension-backed materialization |

## Guarantee matrix for review

This matrix records the review-gated target classifications that tranche 3
must resolve or explicitly defer.

| Surface | Allowed target classifications in tranche 3 | Notes for review |
|---|---|---|
| Package-owned file or stream verb | First-class typed surface | Ratified as `LineagesIO.read_lineages` |
| Typed builder descriptor surface | First-class typed surface | Ratified as an exported typed descriptor surface with public spelling `LineagesIO.BuilderDescriptor`; distinct from raw `builder = fn` compatibility wrappers |
| `load_alife_table(...)` | Convenience wrapper | Ratified as a repo-owned convenience wrapper over the canonical owner, not as the first-class package-owned file or stream surface |
| `FileIO.load(...)` path and stream wrappers | Compatibility-only wrapper | Already settled by higher authority; tranche 3 must not relabel this as first-class |
| `load(src, NodeT)` and `load(src, basenode)` through FileIO wrapper entry | Compatibility-only wrapper unless and until a ratified package-owned public verb delegates to the same owner | These are user-facing today, but the host-framework entry is still `FileIO.load(...)` |
| `load(src; builder = fn)` | Compatibility-only wrapper | Current implementation in `src/load_compat.jl` uses runtime builder-type inference; that is outside the typed guarantee boundary |
| Internal owner surfaces in `src/load_owner.jl` | Internal owner surface, or promoted first-class typed surface only if a public rollout is ratified | Internal existence alone is not public ratification |
| Extension-backed `HybridNetwork` and `MetaGraph` stories | Inherit the classification of the entry surface that reaches them | They are not separate public owners; they are projections reached through wrapper or future package-owned entry surfaces |

## Review gates

### Review gate 1

The first-class package-owned public verb must be classified explicitly.

Ratified outcome:

- a distinct exported package-owned name: `LineagesIO.read_lineages`

The following points are already known:

- The internal owner name `canonical_load(...)` exists today but is not by
  itself a suitable ratification signal.
- `LineagesIO.load` would align the package-owned and compatibility verb at the
  spelling level, but it would also blur the host-framework boundary unless the
  final docs and migration story were very explicit.
- The user has now ratified a distinct exported name, which preserves a
  cleaner ownership boundary between the package-owned surface and `FileIO`
  compatibility dispatch.

### Review gate 2

The builder public spelling and guarantee boundary must be classified
explicitly.

Ratified outcome:

- exported typed builder descriptor spelling: `LineagesIO.BuilderDescriptor`

Already-settled non-negotiable:

- raw `builder = fn` remains compatibility-only unless and until a later
  approved public rollout says otherwise

Current code fact that constrains this decision:

- `TypedBuilderLoadRequest(...)` already proves the internal typed path
- `load(src; builder = fn)` still enters through compatibility normalization
  that infers handle and parent-collection types at runtime

### Review gate 3

The long-term public role of `load_alife_table(...)` must be classified
explicitly.

Ratified outcome:

- `load_alife_table(...)` is a convenience wrapper

Current evidence weighs against treating it as the sole first-class surface:

- the PRD requires one canonical package-owned owner shared across file,
  stream, and in-memory alife sources
- `load_alife_table(...)` is already repo-owned and useful, but it is a
  specialized in-memory entry rather than the whole package-owned story

### Review gate 4

Migration and deprecation policy must be stated explicitly.

Ratified outcome:

- no deprecations, renames, removals, or public breakage are ratified yet
- tranche 4 rollout is additive only

Already-settled non-negotiable:

- no public breakage is authorized merely because the internal typed owner now
  exists

## Ratified decision positions

These positions are ratified for tranche 4 rollout:

- `LineagesIO.read_lineages` is the ratified first-class package-owned public
  file or stream verb.
- `LineagesIO.BuilderDescriptor` is the ratified first-class typed builder
  descriptor spelling.
- `FileIO.load(...)` path and stream entry surfaces remain compatibility-only
  wrappers.
- `load(src; builder = fn)` remains compatibility-only because its current
  wrapper path still relies on runtime builder-type recovery.
- `canonical_load(...)`, the source descriptors, and the typed request
  descriptors remain internal owner surfaces until a public rollout is ratified.
- `load_alife_table(...)` is a repo-owned convenience wrapper over the
  canonical owner, not a compatibility-only wrapper and not the first-class
  package-owned file or stream surface.
- No rename, deprecation, removal, export break, or public migration breakage
  is ratified in this tranche.

## Ratified decisions

This section records the user-ratified tranche 3 decisions.

### Public verb decision

Ratified.

- First-class package-owned file or stream verb: `LineagesIO.read_lineages`
- Classification: first-class typed surface
- Tranche 4 implication: rollout may implement this exact exported name within
  the additive-only boundary recorded below

### Builder public spelling decision

Ratified.

- First-class typed builder descriptor spelling:
  `LineagesIO.BuilderDescriptor`
- Classification: first-class typed surface
- Compatibility boundary: raw `builder = fn` remains a compatibility wrapper
  and does not become the typed guarantee surface

### load_alife_table role decision

Ratified.

- `load_alife_table(...)` classification: convenience wrapper
- Scope meaning: it remains a repo-owned, documented wrapper over the same
  canonical package-owned owner, specialized for in-memory Tables.jl input
- It is not ratified as the first-class package-owned file or stream surface
- It is not ratified as compatibility-only in the same sense as
  `FileIO.load(...)`

### Migration and deprecation decision

Ratified.

- No deprecations, renames, removals, or public breakage are approved yet
- Tranche 4 may add the ratified public surfaces and synchronize docs, tests,
  and examples accordingly
- Tranche 4 may not remove or deprecate existing repo-owned public surfaces
  under this decision record

## Tranche 4 status

Current status: unblocked.

Unblock condition satisfied:

- the public verb, builder public spelling, `load_alife_table(...)` role, and
  migration policy are now all ratified explicitly

Tranche 4 authorization boundary:

- implement the exported package-owned public surface `LineagesIO.read_lineages`
- implement the exported first-class typed builder descriptor spelling
  `LineagesIO.BuilderDescriptor`
- preserve `FileIO.load(...)` as a compatibility-only wrapper
- preserve `load_alife_table(...)` as a convenience wrapper
- keep rollout additive only
- do not introduce deprecations, renames, removals, or public breakage unless a
  later explicit review ratifies them

## Primary-goal lock coverage

This decision record addresses the tranche 3 locks as follows:

- Lock 1: the required decision record file now exists
- Lock 2: closed in principle by ratifying `LineagesIO.read_lineages` as the
  first-class package-owned public verb
- Lock 3: closed by ratifying `LineagesIO.BuilderDescriptor` and preserving raw
  `builder = fn` as compatibility-only
- Lock 4: closed by classifying `load_alife_table(...)` as a convenience
  wrapper
- Lock 5: closed by recording the tranche 4 authorization boundary and
  explicitly unblocking tranche 4 within that boundary

## Handoff packet

- Active authorities:
  `AGENTS.md`, `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`,
  `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`,
  `STYLE-workflow-docs.md`, `STYLE-writing.md`,
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/03_tranche-1--tasking.md`,
  `.workflow-docs/202605040131_type-stable-parse/03_tranche-1a--remediation-tasking.md`,
  `.workflow-docs/202605040131_type-stable-parse/03_tranche-2--tasking.md`,
  `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`
- Parent documents:
  `01_prd.md`, `02_tranches.md`, and `03_tranche-3--tasking.md`
- Settled decisions and non-negotiables:
  `FileIO.load(...)` is compatibility-only; `LineagesIO.read_lineages` is the
  ratified first-class package-owned public verb;
  `LineagesIO.BuilderDescriptor` is the ratified first-class typed builder
  descriptor spelling; `load_alife_table(...)` is a convenience wrapper; no
  deprecations, renames, removals, or public breakage are authorized under
  this record; typed-core and authoritative-table semantics are not being
  reopened
- Authorization boundary:
  tranche 3 itself changed only a workflow decision artifact; tranche 4 is now
  authorized for additive public rollout only
- Current-state diagnosis:
  internal typed owner exists, wrapper-first docs still exist, `load_alife_table`
  remains exported, and the rollout work is still pending
- Primary-goal lock:
  locks 1 through 5 from tranche 3 tasking
- Direct red-state repros:
  missing decision file at tranche start; wrapper-first public docs and
  unimplemented ratified public surfaces still remain for tranche 4 rollout
- Owner and invariant under repair:
  the review-gated public contract and compatibility-policy boundary; no public
  rollout may proceed beyond the ratified additive boundary until a later
  explicit review says otherwise
- Exact scope in:
  this decision record
- Exact scope out:
  `src/*`, `README.md`, `docs/src/*`, `examples/*`, `test/*`, export lists,
  deprecations, migration behavior
- Required upstream primary sources:
  `FileIO` `README.md`, `src/loadsave.jl`, `src/query.jl`, `src/types.jl`;
  `Tables` `README.md`, `src/Tables.jl`
- Green-state gates:
  because this decision record changes only a workflow artifact, inherit the repository's
  prior green state
- Stop conditions:
  do not use this decision record to justify deprecations, renames, removals,
  or public breakage; if tranche 4 pressures imply those changes, stop and
  escalate for a fresh user review
