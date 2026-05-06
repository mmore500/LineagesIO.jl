---
date-created: 2026-05-05T22:42:10-07:00
date-revised: 2026-05-06T10:30:00-07:00
status: ratified
---

# Tranche 3 public surface decision

## Authority

This document is the tranche 3 decision record required by:

- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-3a--remediation-tasking.md`

If this document conflicts with the PRD, tranche file, tasking files, or
active governance authorities, the higher-priority authority controls and this
document must be revised before tranche 4 proceeds.

## Current status

This document closes the direct red state that existed when tranche 3 started:
the decision record file was missing entirely.

This document now also records the actual tranche 3 user-review outcome from
this workflow thread on 2026-05-06. Because all reserved decision clusters
were answered explicitly and the exact public identifiers approved in that
review are now synchronized into `STYLE-vocabulary.md`, this file is the
ratified tranche 3 public-surface decision artifact that unblocks tranche 4
within the additive-only boundary recorded below.

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
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-3a--remediation-tasking.md`

The bundled baseline style files under the `development-policies` skill
reference directory were also read and are byte-identical to the repo-local
`STYLE*.md` files above. Bundled `CONTRIBUTING.md` was not present there, so
repo-local `CONTRIBUTING.md` remains authoritative for contribution guidance.

Controlled vocabulary remains mandatory. This document uses `basenode`,
`package-owned public surface`, `compatibility wrapper`, `convenience wrapper`,
`authoritative tables`, `materialized graph or basenode result`,
`source descriptor`, `materialization descriptor`, `ownership boundary`,
`lock item`, `red-state repro`, and `verification artifact` consistently. It
does not use `type stable` as shorthand for universal exact inference.

## Recorded review outcome and provenance

This section is the tranche 3 user-review artifact that the original tasking
reserved as a human-in-the-loop decision gate.

Review date:

- 2026-05-06

Recorded user-reviewed answers from this workflow thread:

- First-class package-owned file or stream verb:
  `LineagesIO.read_lineages`
- First-class typed builder descriptor spelling:
  `LineagesIO.BuilderDescriptor`
- `load_alife_table(...)` role:
  convenience wrapper
- Migration and deprecation policy:
  no deprecations, renames, or removals yet
- Vocabulary synchronization decision:
  the exact public spellings `read_lineages` and `BuilderDescriptor` are
  approved for entry into `STYLE-vocabulary.md` for this rollout boundary
  only; no broader vocabulary amendment is authorized by this review

Approval provenance recorded in this workflow thread:

- The user answered the package-owned public-verb gate with
  `LineagesIO.read_lineages`.
- The user then approved `LineagesIO.BuilderDescriptor`,
  `load_alife_table(...)` as a convenience wrapper, and
  "no deprecations, renames, or removals yet."
- After review findings identified missing approval provenance, a stale
  workflow-only handoff packet, and unsynchronized vocabulary authority,
  including the finding that `STYLE-vocabulary.md` must be updated if these
  names were truly approved, the user directed execution of the remediation
  tasking against this artifact.
- This document uses those exact-identifier approvals as the explicit approval
  required by `STYLE-vocabulary.md` to record those same exact canonical API
  spellings. No alternate names or broader terminology changes are approved by
  implication.

## Settled decisions and non-negotiables

The following points are now settled and are not being reopened downstream:

- `FileIO.load(...)` is a compatibility wrapper, not the canonical
  package-owned owner of LineagesIO load semantics.
- The typed core, authoritative-table-first parse invariant, retained
  annotation behavior, single-parent and multi-parent validation semantics,
  and stable asset destructuring order `(graph, basenode, node_table,
  edge_table)` remain in force.
- No repo-owned public API removal, rename, export change, deprecation, or
  signature break is authorized unless the user explicitly ratifies it in a
  later review gate.
- The first-class package-owned file or stream verb is the distinct exported
  name `LineagesIO.read_lineages`.
- The first-class typed builder descriptor surface is the exported public
  spelling `LineagesIO.BuilderDescriptor`.
- `load_alife_table(...)` is a convenience wrapper over the canonical
  package-owned owner.
- `STYLE-vocabulary.md` now records `read_lineages` and `BuilderDescriptor` as
  the exact approved canonical API spellings for this rollout boundary.
- No deprecations, renames, removals, or public breakage are ratified in this
  tranche. The tranche 4 rollout is additive only.

## Authorization boundary

In-scope work for tranche 3 is:

- create and revise this decision record
- inventory the current public and internal load surfaces
- classify the surfaces explicitly
- record either a ratified decision or an explicit deferral
- state whether tranche 4 is unblocked or remains blocked
- if exact public identifiers are approved, synchronize those exact spellings
  into `STYLE-vocabulary.md`

Out of scope for tranche 3 is:

- implementing a new exported public verb
- changing exports in `src/LineagesIO.jl`
- repositioning README or docs as if the public decision were already shipped
- adding deprecations or migration behavior
- modifying examples or rollout tests

## Revalidated current state

The following facts were revalidated against the current repository before this
document was finalized:

- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  did not exist at tranche start.
- Before this remediation, the same decision record claimed ratified public
  names and an unblocked tranche 4 state without recording the user-review
  outcome that supported those claims.
- `STYLE-vocabulary.md` did not yet contain `read_lineages` or
  `BuilderDescriptor` before this remediation synchronized it.
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
- `docs/src/phylonetworks.md` still presents `load(path, HybridNetwork)` as
  the primary public happy path for that extension workflow.
- `test/core/canonical_load_owner.jl` already proves direct-owner entry for
  the internal typed owner surfaces and compares them against wrapper
  behavior.

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

## Guarantee and governance matrix for review

This matrix records the review-gated target classifications and governance
outcomes that tranche 3 had to resolve or explicitly defer.

| Surface or decision cluster | Allowed target classification or outcome in tranche 3 | Notes for review |
|---|---|---|
| Package-owned file or stream verb | First-class typed surface | Ratified as `LineagesIO.read_lineages` |
| Typed builder descriptor surface | First-class typed surface | Ratified as an exported typed descriptor surface with public spelling `LineagesIO.BuilderDescriptor`; distinct from raw `builder = fn` compatibility wrappers |
| `load_alife_table(...)` | Convenience wrapper | Ratified as a repo-owned convenience wrapper over the canonical owner, not as the first-class package-owned file or stream surface |
| `FileIO.load(...)` path and stream wrappers | Compatibility-only wrapper | Already settled by higher authority; tranche 3 must not relabel this as first-class |
| `load(src, NodeT)` and `load(src, basenode)` through FileIO wrapper entry | Compatibility-only wrapper unless and until a ratified package-owned public verb delegates to the same owner | These are user-facing today, but the host-framework entry is still `FileIO.load(...)` |
| `load(src; builder = fn)` | Compatibility-only wrapper | Current implementation in `src/load_compat.jl` uses runtime builder-type inference; that is outside the typed guarantee boundary |
| Internal owner surfaces in `src/load_owner.jl` | Internal owner surface, or promoted first-class typed surface only if a public rollout is ratified | Internal existence alone is not public ratification |
| Extension-backed `HybridNetwork` and `MetaGraph` stories | Inherit the classification of the entry surface that reaches them | They are not separate public owners; they are projections reached through wrapper or future package-owned entry surfaces |
| Controlled vocabulary authority for exact public identifiers | Synchronize exact approved spellings into `STYLE-vocabulary.md`, or keep tranche 4 blocked | Governance gate required by `STYLE-vocabulary.md` and the tranche-3a remediation tasking |

## Review gates

### Review gate 1

The first-class package-owned public verb must be classified explicitly.

Recorded user-approved outcome:

- a distinct exported package-owned name: `LineagesIO.read_lineages`

The following points remain part of the decision context:

- The internal owner name `canonical_load(...)` exists today but is not by
  itself a suitable ratification signal.
- `LineagesIO.load` would align the package-owned and compatibility verb at the
  spelling level, but it would also blur the host-framework boundary unless the
  final docs and migration story were very explicit.
- The user ratified a distinct exported name, which preserves a cleaner
  ownership boundary between the package-owned surface and `FileIO`
  compatibility dispatch.

### Review gate 2

The builder public spelling and guarantee boundary must be classified
explicitly.

Recorded user-approved outcome:

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

Recorded user-approved outcome:

- `load_alife_table(...)` is a convenience wrapper

Current evidence weighs against treating it as the sole first-class surface:

- the PRD requires one canonical package-owned owner shared across file,
  stream, and in-memory alife sources
- `load_alife_table(...)` is already repo-owned and useful, but it is a
  specialized in-memory entry rather than the whole package-owned story

### Review gate 4

Migration and deprecation policy must be stated explicitly.

Recorded user-approved outcome:

- no deprecations, renames, removals, or public breakage are ratified yet
- tranche 4 rollout is additive only

Already-settled non-negotiable:

- no public breakage is authorized merely because the internal typed owner now
  exists

### Review gate 5

The controlled-vocabulary authority for any exact public identifiers must be
resolved explicitly.

Recorded user-approved outcome:

- `STYLE-vocabulary.md` is authorized to record `read_lineages` and
  `BuilderDescriptor` as the exact canonical spellings for this rollout
  boundary
- no broader vocabulary additions, alternate public spellings, or renamed
  public surfaces are approved by this review

Current governance constraint:

- new controlled vocabulary requires project-owner approval and explicit
  synchronization into `STYLE-vocabulary.md`

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
  descriptors remain internal owner surfaces until a later explicit public
  rollout expands them.
- `load_alife_table(...)` is a repo-owned convenience wrapper over the
  canonical owner, not a compatibility-only wrapper and not the first-class
  package-owned file or stream surface.
- `STYLE-vocabulary.md` records `read_lineages` and `BuilderDescriptor` as the
  exact approved public spellings for this boundary.
- The exact signature-level and format-policy details recorded in the
  `Ratified signature and format-policy supplement` section below are approved
  for tranche 4 implementation and are not left open for AFK redesign.
- No rename, deprecation, removal, export break, or public migration breakage
  is ratified in this tranche.

## Ratified signature and format-policy supplement

This supplement records additional explicit project-owner ratification from the
workflow thread on 2026-05-06 after tranche-4 review identified that the
name-level tranche-3 decision alone was being re-litigated as if these
signature-level details were still open.

These points are therefore not merely local implementation guesses or
"derivable defaults" for tranche 4. They are explicitly approved public
contract details for the additive rollout of the already-ratified names
`LineagesIO.read_lineages` and `LineagesIO.BuilderDescriptor`.

The following points are ratified:

- `LineagesIO.read_lineages` is a path-or-stream public surface only for this
  rollout boundary. Internal raw-text descriptors and internal source
  descriptor types remain internal and are not promoted to public API here.
- The package-owned path surface is
  `read_lineages(path::AbstractString, args...; format = nothing)`.
- The package-owned stream surface is
  `read_lineages(io::IO, args...; source_path = nothing, format = nothing)`.
- Package-owned path autodetection recognizes `.nwk`, `.newick`, `.tree`,
  `.tre`, and `.trees` as Newick and `.csv` as alife CSV.
- The ambiguous `.txt` extension is not auto-inferred on the package-owned
  surface. It requires explicit package-owned override through
  `format = :newick`.
- A package-owned stream load must succeed when `format` is supplied as
  `:newick` or `:alife`, or when `source_path` carries a non-ambiguous
  supported extension.
- A package-owned stream load with neither explicit `format` nor an inferable
  `source_path` must fail with a contract-level `ArgumentError` instead of
  guessing.
- The only package-owned `format` keyword values approved in this rollout are
  `:newick` and `:alife`.
- `FileIO.File{...}` and `FileIO.Stream{...}` wrappers remain
  compatibility-only surfaces and are not part of the `read_lineages`
  contract.
- The first-class typed builder descriptor shape is
  `BuilderDescriptor(builder, HandleT[, ParentCollectionT])`.
- `read_lineages(source, BuilderDescriptor(...))` is the first-class typed
  builder path.
- Raw `builder = fn` remains compatibility-only and must not be accepted on
  `read_lineages`.
- `load_alife_table(table, BuilderDescriptor(...); source_path = ...)` is
  approved as the additive typed convenience-wrapper counterpart for in-memory
  Tables.jl input so the convenience wrapper stays aligned with the same
  canonical typed owner.
- `read_lineages(source, basenode)` is a typed supplied-basenode path only. It
  must translate directly to the internal typed supplied-basenode request.
- If `construction_handle_type(basenode)` is `nothing`, the first-class
  package-owned surface must fail honestly with a precise error that points the
  caller to the compatibility wrapper story or to implementing
  `construction_handle_type`. It must not silently revive the legacy
  single-parent compatibility fallback.

## Ratified decisions

This section records the tranche 3 decisions ratified by the actual user
review outcome above.

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

### Vocabulary synchronization decision

Ratified.

- Exact public identifiers approved for vocabulary entry:
  `read_lineages` and `BuilderDescriptor`
- Scope meaning: `STYLE-vocabulary.md` may record these exact spellings as the
  canonical API names for this rollout boundary
- Constraint: no additional or alternate public names are approved by
  implication

## Tranche 4 status

Current status: unblocked.

Unblock conditions satisfied:

- all five reserved decision clusters are answered explicitly in the recorded
  user-review artifact above
- `STYLE-vocabulary.md` now records the exact approved public identifiers
- the handoff packet below now matches the actual tranche 4 rollout scope and
  gates from `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`

Tranche 4 authorization boundary:

- implement the exported package-owned public surface
  `LineagesIO.read_lineages`
- implement the exported first-class typed builder descriptor spelling
  `LineagesIO.BuilderDescriptor`
- preserve `FileIO.load(...)` as a compatibility-only wrapper
- preserve `load_alife_table(...)` as a convenience wrapper
- keep rollout additive only
- do not introduce deprecations, renames, removals, or public breakage unless
  a later explicit review ratifies them

## Lock coverage

This repaired decision record closes the tranche-3a remediation locks as
follows:

- Lock 1: closed by recording the actual user-review outcome and explicit
  approval provenance inside this artifact
- Lock 2: closed by replacing the stale workflow-only handoff packet with a
  real tranche-4 rollout handoff packet
- Lock 3: closed by synchronizing `STYLE-vocabulary.md` to the exact approved
  public identifiers and by recording that synchronization decision here

This artifact also closes the original tranche 3 decision locks as follows:

- Lock 1: the required decision record file exists and no longer relies on
  unsupported ratification prose
- Lock 2: closed by ratifying `LineagesIO.read_lineages` as the first-class
  package-owned public verb
- Lock 3: closed by ratifying `LineagesIO.BuilderDescriptor` and preserving
  raw `builder = fn` as compatibility-only
- Lock 4: closed by classifying `load_alife_table(...)` as a convenience
  wrapper
- Lock 5: closed by recording the additive-only tranche 4 authorization
  boundary, the vocabulary synchronization decision, and the tranche-4-scoped
  handoff packet below

## Handoff packet

- Active authorities:
  `AGENTS.md`, `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`,
  `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`,
  `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`,
  `STYLE-workflow-docs.md`, `STYLE-writing.md`,
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/03_tranche-3--tasking.md`,
  `.workflow-docs/202605040131_type-stable-parse/03_tranche-3a--remediation-tasking.md`,
  and this decision record
- Parent documents:
  `01_prd.md`, `02_tranches.md`, `03_tranche-3--tasking.md`,
  `03_tranche-3a--remediation-tasking.md`, and this decision record
- Settled decisions and non-negotiables:
  `FileIO.load(...)` is compatibility-only; `LineagesIO.read_lineages` is the
  ratified first-class package-owned public verb;
  `LineagesIO.BuilderDescriptor` is the ratified first-class typed builder
  descriptor spelling; `load_alife_table(...)` is a convenience wrapper; no
  deprecations, renames, removals, or public breakage are authorized under
  this record; typed-core and authoritative-table semantics are not being
  reopened
- Authorization boundary:
  tranche 4 is authorized only for additive rollout of the ratified public
  surfaces across repo-owned API, docs, README, examples, tests, and exports
- Current-state diagnosis:
  the internal typed owner already exists, `FileIO` compatibility wrappers are
  still the primary documented story, `load_alife_table(...)` is already
  exported as a repo-owned convenience wrapper, and the approved package-owned
  public rollout is still pending
- Primary-goal lock:
  implement the approved first-class package-owned typed surface consistently
  across repo-owned API, docs, README, examples, and direct public-surface
  tests without leaving a second wrapper-first public contract in place
- Direct red-state repros:
  `README.md` and `docs/src/index.md` still present `FileIO.load(...)` wrapper
  flows as the primary public story; the approved `LineagesIO.read_lineages`
  and `LineagesIO.BuilderDescriptor` surfaces are not yet rolled out in
  exports, user docs, examples, or public-surface tests; existing public
  documentation still leaves wrapper and ownership boundaries implicit
- Owner and invariant under repair:
  the repo-owned public load contract must name one first-class package-owned
  typed surface (`LineagesIO.read_lineages`), keep `load_alife_table(...)` as
  a convenience wrapper, keep `FileIO.load(...)` as compatibility-only, and
  preserve additive-only compatibility while exposing the typed builder
  descriptor surface as `LineagesIO.BuilderDescriptor`
- Exact scope in:
  `src/*` and export lists necessary to introduce
  `LineagesIO.read_lineages` and `LineagesIO.BuilderDescriptor`; `README.md`;
  `docs/src/index.md`; touched source-specific docs such as
  `docs/src/phylonetworks.md`; loading examples under `examples/*`; direct
  public-surface tests and wrapper-parity tests under `test/*`; and any
  additive-only compatibility glue required to keep existing wrappers working
- Exact scope out:
  deprecations, renames, removals, export breakage beyond the additive
  rollout; changes to authoritative table semantics, retained annotation
  semantics, stable asset destructuring order, or host-framework ownership
  boundaries; and vocabulary changes beyond the already approved
  `read_lineages` and `BuilderDescriptor` spellings
- Required upstream primary sources:
  `FileIO` `README.md`, `src/loadsave.jl`, `src/query.jl`, `src/types.jl`;
  `Tables` `README.md`, `src/Tables.jl`
- Green-state gates:
  manual inspection of `README.md`, `docs/src/index.md`, and any touched
  source-specific docs for consistency with this decision record; manual
  exercise of the approved first-class public surface for tables-only,
  node-type, supplied-basenode, and builder-driven flows; direct public-surface
  tests and wrapper-parity tests for retained compatibility wrappers;
  `julia --project=test test/runtests.jl`; `julia --project=docs docs/make.jl`;
  and, if touched, `julia --project=examples examples/src/alife_standard_mwe.jl`,
  `julia --project=examples examples/src/phylonetworks_mwe01.jl`, and
  `julia --project=examples examples/src/phylonetworks_mwe02.jl`
- Stop conditions:
  stop and escalate if tranche 4 appears to require a different public name,
  deprecations, removals, public breakage, or broader vocabulary changes; stop
  if rollout work would blur the ownership boundary between the package-owned
  public surface and `FileIO` compatibility dispatch again
