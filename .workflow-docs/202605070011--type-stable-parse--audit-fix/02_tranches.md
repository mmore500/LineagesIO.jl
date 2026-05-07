---
date-created: 2026-05-07T04:02:50-07:00
status: proposed
---

# Post-audit contract repair tranches

## Authority

This document is the proposed tranche file derived from:

- `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`

Supporting workflow inputs revalidated during this planning run:

- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`
- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`

If this tranche document conflicts with the governing PRD or with active
governance authorities, the higher authority controls and this tranche document
must be revised before downstream implementation proceeds.

## Governance and required reading

All downstream tasking, implementation, review, and audit work derived from
this tranche document must require line-by-line reading of:

- `AGENTS.md`
- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
- this tranche file

The bundled `development-policies` reference depot was also checked. The bundled
style files are byte-identical to the repo-local style files except for
`STYLE-vocabulary.md`, where the repo-local file is the higher-priority
project-specific authority. Bundled `CONTRIBUTING.md` was not present. The
repo-local `CONTRIBUTING.md` remains controlling.

`STYLE-makie.md` is not an active authority for this remedial workflow because
no Makie or rendering work is in scope. `STYLE-python.md` was not present in
the repo-local governance set.

## Active authorities

- Repo-local governance: `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  and `STYLE-writing.md`
- Parent workflow: `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`, and
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
- Remedial workflow: `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`, and
  this tranche file
- Upstream primary sources named in the parent PRD:
  `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/README.md`,
  `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/loadsave.jl`,
  `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/types.jl`,
  `/home/jeetsukumaran/.julia/packages/FileIO/9lYsu/src/query.jl`,
  `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`,
  `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`,
  `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`,
  `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`, and
  `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`

## Controlled vocabulary

All downstream work must preserve the controlled vocabulary ratified in
`STYLE-vocabulary.md`.

The following terms are mandatory in downstream artifacts for this workflow:

- `package-owned public surface`
- `compatibility wrapper`
- `convenience wrapper`
- `authoritative tables`
- `materialized graph or basenode result`
- `ownership boundary`
- `lock item`
- `red-state repro`
- `verification artifact`
- `read_lineages`
- `BuilderDescriptor`

Downstream documents must not describe `FileIO.load(...)` as the primary
LineagesIO contract, must not describe `load_alife_table(...)` as anything
other than the already-ratified convenience wrapper, and must not use
`type stable` as a euphemism for blanket inference guarantees when the actual
contract is owner-level type honesty.

## Revalidated current-state diagnosis

- `src/read_lineages.jl` currently validates only `ParentCollectionT` in
  `BuilderDescriptor(...)`. It does not reject `HandleT = Any` or other erased
  or abstract handle shapes at the first-class public boundary.
- `ext/MetaGraphsNextIO.jl` currently accepts any `Type{<:MetaGraph}` through
  `validate_extension_load_target(::Type{<:MetaGraph})`, but the
  library-created path always constructs `default_metagraph()`.
- The supplied-instance `MetaGraph` path currently has only narrow dispatch
  support for `VertexData` and `EdgeData` shapes, while `README.md` and
  `docs/src/index.md` still describe a broader custom-data story.
- Existing parity and activation tests do not yet fail the three direct audit
  bad shapes on their own: unsupported concrete library-created `MetaGraph`
  subtype requests, unsupported supplied-instance custom-data shapes, and
  `BuilderDescriptor(builder, Any)`.
- The ratified first-class public surfaces remain `read_lineages` and
  `BuilderDescriptor`. The remedial workflow does not reopen naming,
  compatibility classification, or broader migration policy.

## Primary-goal lock coverage

- Lock 1: governed remedial workflow integrity is closed at the tranche-design
  layer by this file's active-authorities block, pass-forward mandates, and
  handoff packets. Tranche 2 must preserve that closure by recording the
  reviewed supplied-instance contract branch explicitly. Tranche 4 must ensure
  final public docs and verification artifacts do not drift back to the design
  note alone.
- Lock 2: library-created MetaGraphsNext type-request honesty is owned by
  Tranche 3.
- Lock 3: supplied-instance MetaGraphsNext contract honesty is owned at the
  runtime-contract level by Tranche 2 and closed at the public-surface
  synchronization level by Tranche 4.
- Lock 4: first-class `BuilderDescriptor` concrete-handle guarantee is owned by
  Tranche 1.

## Tranche index

| Tranch id | Title | Status |
|---|---|---|
| 1 | `BuilderDescriptor` concrete-handle boundary repair | Proposed |
| 2 | Supplied-instance MetaGraphsNext contract ratification and owner repair | Proposed |
| 3 | Library-created MetaGraphsNext target tightening | Proposed |
| 4 | Public contract synchronization and audit closure | Proposed |

## Tranche summary

1. Title: `BuilderDescriptor` concrete-handle boundary repair
   Type: `AFK`
   Blocked by: `None -- can start immediately`
   User stories covered: `5`, `7`
2. Title: Supplied-instance MetaGraphsNext contract ratification and owner repair
   Type: `HITL`
   Blocked by: `None -- can start immediately`
   User stories covered: `1`, `3`, `4`, `7`, `8`, `10`
3. Title: Library-created MetaGraphsNext target tightening
   Type: `AFK`
   Blocked by: `Tranche 2`
   User stories covered: `2`, `6`, `7`, `8`, `10`
4. Title: Public contract synchronization and audit closure
   Type: `AFK`
   Blocked by: `Tranche 1`, `Tranche 2`, `Tranche 3`
   User stories covered: `1`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`

## Tranche 1: BuilderDescriptor concrete-handle boundary repair

**Type**: AFK
**Blocked by**: None -- can start immediately

### Parent PRD

`.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  and `STYLE-writing.md`
- Mandated line-by-line reading of
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`, and
  this tranche file
- Mandated reading of the installed upstream sources named in the parent PRD;
  no additional upstream contract beyond those sources is introduced by this
  tranche

### Primary-goal lock

- Owns Lock 4: the first-class `BuilderDescriptor` public boundary must reject
  erased or abstract `HandleT` shapes before request normalization reaches the
  canonical owner
- Preserves Lock 1: downstream tasking must keep the direct public-surface
  regression for `BuilderDescriptor(builder, Any)` explicit instead of treating
  the fix as a derivable cleanup
- The work is not complete if the first-class typed path can still admit
  `HandleT = Any` or equivalent erased handle storage

### What to build

Build the owner-level repair at the first-class typed builder boundary.

This tranche is a foundational boundary-hardening tranche. The owner that must
remain is the public `BuilderDescriptor(...)` constructor in
`src/read_lineages.jl`. That boundary must own the concrete-handle invariant
directly instead of allowing later layers to rediscover or reject erased handle
types after a typed request already exists.

When the tranche is complete, first-class typed builder requests succeed only
for concrete handle types. The retained raw `load(...; builder = fn)`
compatibility wrapper story remains untouched and must not be relabeled as the
first-class typed guarantee.

### Legacy artifacts to retire or demote

- `BuilderDescriptor(builder, Any)` and equivalent abstract or erased
  `HandleT` requests as accepted first-class typed inputs
- the current asymmetry where `ParentCollectionT` is guarded but `HandleT` is
  not
- any expectation that later `TypedBuilderLoadRequest` checks can substitute for
  a public-boundary rejection

### Forbidden regressions

- rejecting erased handle types only after canonical-owner normalization or
  multi-parent construction already began
- silently converting erased handle types into a different concrete wrapper and
  calling the path typed
- broadening `BuilderDescriptor` acceptance to preserve old behavior from the
  compatibility wrapper

### Environment and dependency baseline

- Use the current root, test, and docs environments without dependency changes
- Preserve the ratified `read_lineages` and `BuilderDescriptor` spellings and
  the retained `load(...; builder = fn)` compatibility classification
- Do not introduce new builder protocol names, new public descriptors, or new
  migration policy in this tranche

### Handoff packet

- **Active authorities**: `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  `STYLE-writing.md`, `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`, and
  this tranche file
- **Parent documents**: the parent type-stable parse PRD and tranche file, the
  tranche-3 decision record, the audit report, the audit-fix design note, the
  remedial PRD, and this tranche file
- **Settled decisions and non-negotiables**: `read_lineages` and
  `BuilderDescriptor` remain the ratified first-class package-owned public
  names; `FileIO.load(...)` remains compatibility-only; `load_alife_table(...)`
  remains the in-memory Tables.jl convenience wrapper; no broader public
  migration policy changes are authorized
- **Authorization boundary**: only the first-class builder boundary,
  immediately affected public-surface tests, and any directly required error
  wording are in scope
- **Current-state diagnosis**: `BuilderDescriptor(...)` currently guards only
  `ParentCollectionT`, leaving `HandleT = Any` free to reintroduce erased
  parent collections through the typed owner path
- **Primary-goal lock**: close Lock 4 directly and leave behind a regression
  that fails the old erased-handle shape
- **Direct red-state repros**: `BuilderDescriptor(builder, Any)` currently
  succeeds and lets `Vector{Any}` back into the first-class typed path
- **Owner and invariant under repair**: the public `BuilderDescriptor`
  constructor must own the concrete-handle invariant
- **Exact files or surfaces in scope**: `src/read_lineages.jl`,
  `test/core/read_lineages_public_surface.jl`, and any directly affected
  canonical-owner builder tests
- **Exact files or surfaces out of scope**: MetaGraphsNext owner repair, docs
  rewrite, README synchronization, and compatibility-wrapper contract changes
- **Required upstream primary sources**: the parent PRD's installed FileIO,
  MetaGraphsNext, and Tables sources; no new upstream source is needed
- **Green-state gates**: direct regression for `BuilderDescriptor(builder, Any)`,
  continued success for a concrete `HandleT`, `julia --project=test test/runtests.jl`,
  and `julia --project=docs docs/make.jl`
- **Stop conditions**: stop and escalate if the repair appears to require
  reopening the ratified builder spelling, changing compatibility-wrapper
  policy, or broadening the public load contract

### How to verify

- **Manual**: confirm `BuilderDescriptor(builder, ConcreteHandleT)` still
  succeeds and remains the first-class typed builder surface
- **Manual**: inspect the public constructor path and confirm erased or abstract
  `HandleT` shapes are rejected before a `TypedBuilderLoadRequest` is created
- **Automated**: add or strengthen a direct public-surface regression that
  `BuilderDescriptor(builder, Any)` and equivalent abstract handle requests
  throw `ArgumentError`
- **Automated**: preserve success coverage for concrete `HandleT` requests,
  including existing multi-parent typed-builder coverage
- **Automated**: run `julia --project=test test/runtests.jl`
- **Automated**: run `julia --project=docs docs/make.jl`

### Acceptance criteria

- [ ] Given `BuilderDescriptor(builder, Any)`, when the constructor is called,
      then it fails immediately with a precise `ArgumentError`
- [ ] Given `BuilderDescriptor(builder, ConcreteHandleT[, ParentCollectionT])`,
      when the constructor is called, then the first-class typed path still
      succeeds
- [ ] Given the legacy erased handle shape named above, when this tranche is
      complete, then it is removed or prevented from surviving as a first-class
      typed request
- [ ] Given a forbidden regression shape that delays the rejection until later
      normalization or materialization, when verification is run, then the
      tranche fails rather than reporting a fake green

### User stories addressed

- User story 5: first-class typed builder surface rejects erased handle types
- User story 7: each surviving audit finding gets a direct proof artifact

## Tranche 2: Supplied-instance MetaGraphsNext contract ratification and owner repair

**Type**: HITL
**Blocked by**: None -- can start immediately

### Parent PRD

`.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  and `STYLE-writing.md`
- Mandated line-by-line reading of
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`, and
  this tranche file
- Mandated reading of `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`,
  `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`,
  `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`,
  `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`, and
  `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`

### Primary-goal lock

- Owns Lock 3 at the reviewed runtime-contract layer: the supplied-instance
  `MetaGraph` path must have one explicit custom-data contract whose runtime
  behavior is honest
- Preserves Lock 1 by requiring a reviewed decision artifact that records the
  ratified supplied-instance contract branch before implementation claims the
  finding is closed
- The work is not complete if unsupported custom `VertexData` or `EdgeData`
  shapes still fail with a raw internal `MethodError`, or if downstream work
  still acts as though the contract branch was settled by the design note alone

### What to build

Build the HITL owner-repair tranche for the caller-supplied `MetaGraph` path.

This tranche must first produce an explicit reviewed decision artifact at:

- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`

That artifact must record which of the two parent-PRD branches is ratified:

- constructor-based extension on user-owned `VertexData` and `EdgeData` types
- narrowed supported-shape contract with precise early rejection

After the user ratifies the branch, this tranche implements only that branch in
`ext/MetaGraphsNextIO.jl` and the directly affected tests. The owner that must
remain is the supplied-instance MetaGraphsNext path itself. The runtime must not
rely on broad docs promises, raw internal dispatch failure, or a hidden second
extension protocol.

Public README and docs synchronization may be staged into Tranche 4, but this
tranche must leave behind the runtime support matrix and direct tests that make
that later sync mechanical rather than interpretive.

### Legacy artifacts to retire or demote

- the current broad but unratified custom-data story for supplied-instance
  `MetaGraph` loads
- raw `MethodError` from `add_node_to_metagraph!` or `add_edge_to_metagraph!`
  as a user-facing unsupported-shape failure surface
- any shadow constructor or validation path that exists only to preserve the
  appearance of broad support without an explicit contract decision

### Forbidden regressions

- implementing both contract branches simultaneously and leaving two competing
  public stories alive
- preserving raw internal dispatch failures for unsupported shapes and calling
  them the reviewed contract
- claiming constructor-based extension without direct tests that prove supported
  custom types succeed
- claiming a narrowed contract without early validation that rejects
  unsupported shapes precisely at the public boundary

### Environment and dependency baseline

- Use the installed MetaGraphsNext and Tables sources actually named in the
  parent PRD and do not substitute the missing older upstream checkout path
- Preserve the ratified `read_lineages`, `BuilderDescriptor`,
  `FileIO.load(...)`, and `load_alife_table(...)` classification boundaries
- Do not widen this tranche into a broader MetaGraph factory redesign or a new
  public naming decision

### Handoff packet

- **Active authorities**: `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  `STYLE-writing.md`, `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`, and
  this tranche file
- **Parent documents**: the parent type-stable parse PRD and tranche file, the
  tranche-3 decision record, the audit report, the audit-fix design note, the
  remedial PRD, this tranche file, and the decision artifact this tranche must
  create
- **Settled decisions and non-negotiables**: the ratified public names and
  wrapper classifications remain fixed; the supplied-instance custom-data branch
  is not settled by the design note and must be reviewed explicitly here; no
  broader redesign or migration policy change is authorized
- **Authorization boundary**: only the supplied-instance MetaGraphsNext owner,
  the required decision artifact, directly affected tests, and narrowly
  required internal wording are in scope
- **Current-state diagnosis**: the supplied-instance path currently supports a
  narrow hard-coded set of `VertexData` and `EdgeData` shapes while public docs
  still imply a broader custom-data contract
- **Primary-goal lock**: review and implement one honest supplied-instance
  support matrix, eliminate raw internal failure as the unsupported-shape
  contract, and pass that decision forward explicitly
- **Direct red-state repros**: caller-supplied custom `MetaGraph` types outside
  the narrow built-in method set currently fail with raw internal dispatch while
  docs still suggest broader support
- **Owner and invariant under repair**: the supplied-instance MetaGraphsNext
  path must be the single honest owner of custom-data behavior for caller-
  supplied `MetaGraph` targets
- **Exact files or surfaces in scope**: `ext/MetaGraphsNextIO.jl`,
  directly affected MetaGraphsNext tests, and the workflow decision artifact
- **Exact files or surfaces out of scope**: library-created `MetaGraph` target
  validation, README and index docs synchronization, and broader public-surface
  migration
- **Required upstream primary sources**: the installed MetaGraphsNext
  `metagraph.jl`, `graphs.jl`, and `weights.jl` sources, plus the installed
  Tables README and `Tables.jl` source
- **Green-state gates**: reviewed decision artifact exists, supported and
  unsupported supplied-instance shapes are directly tested, `julia --project=test test/runtests.jl`,
  and `julia --project=docs docs/make.jl`
- **Stop conditions**: stop and escalate if the reviewed branch would require
  reopening the ratified public naming boundary, changing wrapper
  classification, or widening this remediation into a broader MetaGraph factory
  redesign

### How to verify

- **Manual**: produce and review
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
  before implementation continues
- **Manual**: confirm the implemented runtime branch matches the reviewed
  support matrix exactly
- **Automated**: if constructor-based extension is ratified, add direct tests
  that supported custom `VertexData` and `EdgeData` types succeed and that a
  missing user constructor fails at the user-owned constructor entrypoint rather
  than as a hidden extension mismatch
- **Automated**: if the narrowed contract is ratified, add direct tests that
  unsupported custom-data shapes fail early with precise `ArgumentError`s
- **Automated**: preserve wrapper parity for the same supplied-instance
  semantics through retained `load(...)` entry surfaces
- **Automated**: run `julia --project=test test/runtests.jl`
- **Automated**: run `julia --project=docs docs/make.jl`

### Acceptance criteria

- [ ] Given the open supplied-instance contract question in the parent PRD,
      when this tranche proceeds, then a reviewed decision artifact records the
      ratified branch explicitly before implementation claims the finding is
      closed
- [ ] Given the ratified branch, when a caller supplies a supported custom
      `MetaGraph` shape, then the runtime behaves according to that branch
- [ ] Given an unsupported custom `MetaGraph` shape, when verification is run,
      then the public failure surface is explicit and contract-level rather than
      a raw internal `MethodError`
- [ ] Given the legacy broad-but-unratified custom-data story named above, when
      this tranche is complete, then it is removed, narrowed, or otherwise
      prevented from surviving as an implicit second contract
- [ ] Given a forbidden regression shape that leaves the branch ambiguous or
      keeps raw dispatch failure as the unsupported-shape story, when
      verification is run, then the tranche fails rather than reporting a fake
      green

### User stories addressed

- User story 1: one governed remedial workflow instead of scattered notes
- User story 3: custom `VertexData` and `EdgeData` support is honest
- User story 4: no broad promise followed by raw internal `MethodError`
- User story 7: each surviving audit finding gets a direct proof artifact
- User story 8: downstream agents receive exact authorities and stop conditions
- User story 10: the remediation stays inside the authorized contract-repair
  boundary

## Tranche 3: Library-created MetaGraphsNext target tightening

**Type**: AFK
**Blocked by**: Tranche 2

### Parent PRD

`.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  and `STYLE-writing.md`
- Mandated line-by-line reading of
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`, and
  this tranche file
- Mandated reading of `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`,
  `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`, and
  `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`

### Primary-goal lock

- Owns Lock 2: the library-created MetaGraphsNext path must be exact and honest
  about accepted target requests and the concrete graph type it returns
- Preserves the reviewed supplied-instance branch from Tranche 2: any redirect
  to the caller-supplied path is only honest after that path has been ratified
  and repaired
- The work is not complete if the owner can still accept an unsupported
  concrete `MetaGraph` subtype request and silently return a different graph
  type

### What to build

Build the owner repair for the library-created `MetaGraph` path.

This tranche is migration-oriented and cleanup-oriented. The owner that must
remain is the library-created validation and construction boundary in
`ext/MetaGraphsNextIO.jl`. The broad `validate_extension_load_target(::Type{<:MetaGraph})`
acceptance must be retired or narrowed so the accepted request family matches
the real owner that constructs the graph.

The accepted library-created target family must be derived from the actual
owner, such as `default_metagraph()` or `typeof(default_metagraph())`, not from
hand-written partial type literals. Unsupported concrete `MetaGraph` subtype
requests must fail before construction with a precise `ArgumentError` that
directs callers to the now-ratified supplied-instance path.

If satisfying that contract would require reopening the already-ratified public
token shape `read_lineages(src, MetaGraph)` or another broader external
compatibility choice, this tranche must stop and escalate rather than silently
freeze a new public interpretation.

### Legacy artifacts to retire or demote

- broad `validate_extension_load_target(::Type{<:MetaGraph})` acceptance
- silent mismatch between an accepted library-created concrete request and the
  actual graph type returned by `default_metagraph()`
- any hand-written partial default-type literal that substitutes for the real
  owner-derived accepted family

### Forbidden regressions

- post-hoc casting, wrapping, or reinterpretation that still returns the wrong
  concrete graph type for an accepted request
- redirecting callers to the supplied-instance path before Tranche 2 made that
  path honest
- changing docs alone without a runtime validator that enforces the narrowed
  accepted family

### Environment and dependency baseline

- Use the installed MetaGraphsNext upstream sources actually named in the
  parent PRD
- Preserve the ratified first-class public names and wrapper classifications
- Do not widen this tranche into a broader factory protocol or a new public
  naming change unless a stop condition is triggered

### Handoff packet

- **Active authorities**: `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  `STYLE-writing.md`, `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`, and
  this tranche file
- **Parent documents**: the parent type-stable parse PRD and tranche file, the
  tranche-3 decision record, the audit report, the audit-fix design note, the
  supplied-instance contract decision artifact, the remedial PRD, and this
  tranche file
- **Settled decisions and non-negotiables**: the first-class public names,
  wrapper classifications, and supplied-instance branch from Tranche 2 remain
  fixed; no broader MetaGraph factory redesign is authorized by default
- **Authorization boundary**: only the library-created MetaGraphsNext target
  validator, constructor boundary, directly affected tests, and narrowly
  required wording are in scope
- **Current-state diagnosis**: the library-created path currently accepts any
  `Type{<:MetaGraph}` but always constructs `default_metagraph()`
- **Primary-goal lock**: close Lock 2 with direct proof that accepted requests
  and returned concrete graph types are honest
- **Direct red-state repros**: a library-created concrete MetaGraph subtype
  request currently succeeds and returns a different graph type than the one
  requested
- **Owner and invariant under repair**: the library-created MetaGraphsNext path
  must normalize accepted target requests exactly once and construct only the
  types it honestly supports
- **Exact files or surfaces in scope**: `ext/MetaGraphsNextIO.jl`, directly
  affected MetaGraphsNext public-surface and canonical-owner tests, and any
  narrow error wording needed for the rejected path
- **Exact files or surfaces out of scope**: supplied-instance contract branch
  selection, README and index docs synchronization, and broader migration
  policy
- **Required upstream primary sources**: the installed MetaGraphsNext
  `metagraph.jl`, `graphs.jl`, and `weights.jl` sources
- **Green-state gates**: direct positive and negative library-created
  regressions, wrapper parity for the retained compatibility path, `julia --project=test test/runtests.jl`,
  and `julia --project=docs docs/make.jl`
- **Stop conditions**: stop and escalate if the honest accepted-family repair
  requires reopening the ratified public token story or broader external
  compatibility assumptions

### How to verify

- **Manual**: inspect the accepted library-created target family and confirm it
  is derived from the real owner that constructs the graph
- **Manual**: confirm any rejected concrete `MetaGraph` subtype request now
  fails before construction and directs the caller to the supplied-instance path
- **Automated**: add or strengthen a direct positive regression for the
  supported library-created target path
- **Automated**: add or strengthen a direct negative regression for an
  unsupported concrete `MetaGraph` subtype request
- **Automated**: preserve wrapper parity for the retained `load(...)`
  compatibility path over the same supported library-created semantics
- **Automated**: run `julia --project=test test/runtests.jl`
- **Automated**: run `julia --project=docs docs/make.jl`

### Acceptance criteria

- [ ] Given a supported library-created MetaGraphsNext target request, when the
      owner accepts it, then the request family and the constructed concrete
      graph type are explicitly honest
- [ ] Given an unsupported concrete `MetaGraph` subtype request, when the owner
      receives it, then it throws a precise `ArgumentError` before construction
- [ ] Given the broad validator artifact named above, when this tranche is
      complete, then it is removed, narrowed, or otherwise prevented from
      surviving as a second unsupported accepted-family story
- [ ] Given a forbidden regression shape that still returns the wrong concrete
      type for an accepted request, when verification is run, then the tranche
      fails rather than reporting a fake green

### User stories addressed

- User story 2: library-created MetaGraph path becomes honest
- User story 6: retained wrapper paths stay aligned with the repaired owner
- User story 7: each surviving audit finding gets a direct proof artifact
- User story 8: downstream agents inherit exact upstream and stop conditions
- User story 10: the remediation stays inside the authorized contract-repair
  boundary

## Tranche 4: Public contract synchronization and audit closure

**Type**: AFK
**Blocked by**: Tranche 1, Tranche 2, Tranche 3

### Parent PRD

`.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  and `STYLE-writing.md`
- Mandated line-by-line reading of
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`, and
  this tranche file
- Mandated reading of the installed FileIO, MetaGraphsNext, and Tables sources
  named in the parent PRD, with special attention to any public-facing
  behaviors described in touched docs or examples

### Primary-goal lock

- Closes the remaining public-surface synchronization portion of Lock 3
- Preserves the planning-layer closure for Lock 1 by making the final public
  docs, examples, and verification artifacts agree with the reviewed runtime
  repairs and the governing workflow
- Preserves Locks 2 and 4 by ensuring public examples, wrapper parity tests,
  and audit-facing proofs cannot drift back to the old bad shapes
- The work is not complete if `README.md`, `docs/src/index.md`, retained wrapper
  tests, or other touched public artifacts still promise unsupported MetaGraph
  shapes or fail to expose the repaired contract boundaries honestly

### What to build

Build the stabilization tranche that synchronizes the repaired contract across
public artifacts and closes the audit honestly.

This tranche is stabilization-focused. After the owner repairs land, it updates
the public contract story in `README.md`, `docs/src/index.md`, and any touched
extension docs or examples so they describe exactly the repaired supported
library-created path, the reviewed supplied-instance custom-data story, the
retained `FileIO.load(...)` compatibility wrapper, the retained
`load_alife_table(...)` convenience wrapper, and the first-class
`BuilderDescriptor` boundary.

This tranche must also leave behind direct proof artifacts for all three audit
findings so a later green suite cannot hide stale docs, stale wrapper parity,
or stale public error stories.

### Legacy artifacts to retire or demote

- stale README or index-doc MetaGraphsNext prose that promises broader
  custom-data support than the repaired runtime actually offers
- stale README or index-doc MetaGraphsNext prose that implies any
  `Type{<:MetaGraph}` is a supported library-created target family
- stale public-surface tests or examples that do not fail the three direct
  audit repros
- any touched public artifact that effectively reintroduces the audit-fix
  design note as the sole source of truth instead of the reviewed workflow

### Forbidden regressions

- doc-only fixes without runtime-proof tests
- runtime fixes without public contract synchronization
- wrapper parity that remains green while a direct audit repro can still
  survive through a retained public surface
- reclassifying `FileIO.load(...)` or `load_alife_table(...)` away from the
  already-ratified compatibility and convenience roles

### Environment and dependency baseline

- Preserve the ratified public names and wrapper classifications
- Preserve `FileIO.load(...)` support and `load_alife_table(...)` support
- Use the current root, test, docs, and examples environments
- If examples are touched, run only the examples relevant to those touched
  public surfaces and record them explicitly

### Handoff packet

- **Active authorities**: `AGENTS.md`, `CONTRIBUTING.md`,
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  `STYLE-writing.md`, `.workflow-docs/202605040131_type-stable-parse/01_prd.md`,
  `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`,
  `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`, and
  this tranche file
- **Parent documents**: the parent type-stable parse PRD and tranche file, the
  tranche-3 decision record, the audit report, the audit-fix design note, the
  supplied-instance contract decision artifact, the remedial PRD, and this
  tranche file
- **Settled decisions and non-negotiables**: the public names and wrapper
  classifications remain fixed; the supplied-instance branch from Tranche 2 and
  the library-created accepted-family repair from Tranche 3 must be treated as
  settled input here
- **Authorization boundary**: public docs, README, touched examples, and the
  direct proof artifacts needed to show the repaired contracts honestly are in
  scope; broader migration policy and unrelated extension redesign are out of
  scope
- **Current-state diagnosis**: the runtime owner repairs may be green, but
  stale public artifacts can still preserve the old broad custom-data promise,
  the old broad library-created target promise, or the lack of direct audit
  proofs
- **Primary-goal lock**: finish the public-surface synchronization needed so
  the three repaired findings cannot survive behind stale docs or weak tests
- **Direct red-state repros**: README and index docs currently describe a
  broader supplied-instance story than the runtime honors, and current tests do
  not yet directly fail all three audit bad shapes
- **Owner and invariant under repair**: the public contract story must agree
  with the repaired package-owned owners and retained wrapper classifications
- **Exact files or surfaces in scope**: `README.md`, `docs/src/index.md`, any
  directly affected extension docs or examples, and the proof-oriented tests
  that lock those public claims to the repaired runtime
- **Exact files or surfaces out of scope**: broader marketing docs refresh,
  unrelated example redesign, and any new public migration policy
- **Required upstream primary sources**: the installed FileIO, MetaGraphsNext,
  and Tables sources named in the parent PRD
- **Green-state gates**: direct proof artifacts for all three audit findings,
  wrapper parity for retained public surfaces, `julia --project=test test/runtests.jl`,
  `julia --project=docs docs/make.jl`, and any touched example runs
- **Stop conditions**: stop and escalate if final public synchronization
  appears to require reopening the ratified public naming boundary, wrapper
  classification, or the reviewed Tranche 2 contract branch

### How to verify

- **Manual**: inspect `README.md`, `docs/src/index.md`, and any touched
  extension docs or examples and confirm they match the repaired runtime
  contracts exactly
- **Manual**: exercise the retained public surfaces and confirm the docs no
  longer promise unsupported library-created or supplied-instance MetaGraph
  shapes
- **Automated**: add or strengthen direct regressions for all three audit bad
  shapes so stale docs or stale wrapper behavior cannot survive behind a green
  suite
- **Automated**: preserve wrapper parity for retained `load(...)` and
  `load_alife_table(...)` surfaces affected by the repaired semantics
- **Automated**: run `julia --project=test test/runtests.jl`
- **Automated**: run `julia --project=docs docs/make.jl`
- **Automated**: if touched, run the relevant examples under
  `examples/Project.toml`

### Acceptance criteria

- [ ] Given the repaired `BuilderDescriptor` boundary and MetaGraphsNext owner
      paths, when this tranche completes, then the public docs and examples
      describe those repaired contracts exactly
- [ ] Given the retained `FileIO.load(...)` and `load_alife_table(...)`
      surfaces, when this tranche completes, then wrapper parity and wrapper
      classification remain explicit and honest
- [ ] Given the stale public artifacts named above, when this tranche is
      complete, then they are removed, narrowed, or otherwise prevented from
      surviving as a second public contract
- [ ] Given a forbidden regression shape such as stale broad docs or weak proof
      artifacts, when verification is run, then the tranche fails rather than
      reporting a fake green

### User stories addressed

- User story 1: one governed remedial workflow instead of scattered notes
- User story 3: custom `VertexData` and `EdgeData` support is honest in docs
  and runtime
- User story 4: no broad promise followed by raw internal failure
- User story 5: first-class typed builder surface stays honest at the boundary
- User story 6: retained wrapper paths stay aligned with the repaired owner
- User story 7: each surviving audit finding gets a direct proof artifact
- User story 8: downstream agents inherit exact authorities and verification
  obligations
- User story 9: ratified public-surface decisions remain settled during audit
  cleanup
- User story 10: the remediation stays inside the authorized contract-repair
  boundary
