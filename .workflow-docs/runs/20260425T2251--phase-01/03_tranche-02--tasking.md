---
date-created: 2026-04-26T00:00:00
version: 1.0
---

# Tasks for Tranche 2: Discovery pass and NamedTuple schema builder

Parent tranche: Tranche 2
Parent PRD: `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md`

## Governance

All tasks in this file must comply, line by line, with the following governance
documents. Read every document in full before planning or writing a single line
of implementation. This obligation must be passed forward into any downstream
delegated work derived from these tasks.

**Governance documents (all mandatory, line by line):**

- `STYLE-architecture.md` — ownership boundaries; anti-fix prohibition;
  green-state discipline
- `STYLE-docs.md` — documentation formatting standards
- `STYLE-git.md` — commit style and branching model
- `STYLE-julia.md` — functional design; type-driven design; struct field
  concreteness (§1.12); return type annotations (§1.13.2); bare `using`
  prohibition (§5); module file curation (§8)
- `STYLE-upstream-contracts.md` — host-framework contract reading
- `STYLE-verification.md` — field-level value verification; weak-proxy
  prohibition
- `STYLE-vocabulary.md` — controlled terminology; proscribed terms. Key
  constraints: `node` not `vertex`; `edge` not `branch`; `edgeweight` not
  `branch_length`/`edge_length`; `src_node_idx`/`dst_node_idx` as canonical
  edge endpoint column names
- `STYLE-workflow-docs.md` — revalidation rule; pass-forward obligations
- `STYLE-writing.md` — prose style for documentation
- `CONTRIBUTING.md` — contribution process and expectations

**Companion design documents (all mandatory, line by line):**

- `design/brief.md` — §Metadata architecture; §Level 1 — Node metadata;
  §Level 2 — Edge metadata; discovery pass contract
- `design/brief--community-support-objectives.md` — full document; metadata
  flow tables for PhyloNetworks and Phylo
- `.workflow-docs/runs/20260425T2251--phase-01/01_prd.md` — §Discovery pass
  and metadata tables (user stories 9–16); §Discovery pass module design;
  §Testing and verification decisions

**Upstream primary sources (mandatory, line by line):**

- `fileio.jl/src/` (all files) — table types produced here flow through FileIO
  dispatch; verify no impedance with FileIO's expected return shapes

Read-only git and shell commands may be used freely. Mutating git operations
remain the human project owner's responsibility.

## Required revalidation before implementation

Before writing a single line of code:

1. Read all files added or modified by Tranche 1 in full. Do not assume
   docstrings or comments accurately reflect the code — verify each
   independently.
2. Confirm `julia --project=test test/runtests.jl` passes with Aqua and JET
   clean. If it does not, stop and escalate before proceeding.
3. Verify that `LineageGraphAsset{NodeT}` and `LineageGraphStore{NodeT}` field names and
   types match `01_prd.md §Return types` exactly. If any discrepancy is found,
   stop and escalate.

If the Tranche 1 green state cannot be confirmed, this tranche must not begin.

## Tranche execution rule

`src/discovery.jl` is an internal module — nothing in it is exported directly.
It is a shared service used by all three format parsers. The design decisions in
`design/brief.md §Metadata architecture` are authoritative; any apparent
ambiguity must be escalated rather than resolved unilaterally. The tranche must
begin and end with all tests passing, Aqua and JET clean.

## Tasks

### 1. Implement `build_schema`

**Type**: WRITE
**Output**: `src/discovery.jl` exists and is included from `src/LineagesIO.jl`;
`build_schema` is defined, not exported; it accepts a collection of annotation
dicts and returns a `NamedTuple` type reflecting the promoted schema; it is
type-stable; it accepts an optional `type_overrides` argument
**Depends on**: Tranche 1 complete and green

Add `src/discovery.jl` and add `include("discovery.jl")` in `src/LineagesIO.jl`
before any format parser includes. Implement `build_schema(records; type_overrides
= NamedTuple())` — `records` is a collection of annotation dicts (one per node
or edge record), each a `Dict{String,Any}` or similar. The function scans all
records in one pass to collect every key name and infer column types using the
following rules from `01_prd.md §Discovery pass`: all `String` values → `String`;
all numeric with no fractional part → `Int`; any fractional part or mixed
int/float → `Float64`; mixed presence (key absent on some records) → the
inferred type wrapped in `Union{T, Nothing}`; key present but all values missing
→ `Nothing`. The `type_overrides` argument is a `NamedTuple` mapping symbol
names to types that override the inferred type for those keys; format parsers
use this to enforce well-known types such as `gamma :: Union{Float64, Nothing}`
regardless of observed values. The function returns a `NamedTuple` type (not a
value) whose field names and types reflect the promoted schema. This type must
be fully determined at compile time given the type overrides. Per
`STYLE-julia.md §1.13.2`, add an explicit return type annotation. Per `§1.12`,
the produced type must be type-stable — the schema type itself is the return,
enabling downstream `@inferred` checks.

---

### 2. Implement `build_row`

**Type**: WRITE
**Output**: `src/discovery.jl` exports `build_row`; it accepts a schema type
and a single annotation dict and returns a `NamedTuple` value of the correct
type with `nothing` for absent keys; `@inferred` on `build_row` produces no
type instability
**Depends on**: Task 1

Implement `build_row(schema_type :: Type{T}, record_dict) :: T where {T}` in
`src/discovery.jl`. For each field in `schema_type`, look up the corresponding
key in `record_dict`; if absent, use `nothing`; if present, coerce the value to
the field type (handling `Union{T, Nothing}` correctly). The function must be
type-stable: the output type `T` must be fully determined by the `schema_type`
argument alone, not by the runtime values in `record_dict`. Verify this by
checking that `@inferred build_row(schema_type, dict)` in a test does not produce
a dynamic dispatch warning. Per `STYLE-julia.md §1.13`, annotate all arguments
at the correct level of abstraction. The function is internal and not exported.
Ensure the test suite still passes after adding this function.

---

### 3. Write tests and verify green state

**Type**: TEST
**Output**: `test/test_discovery.jl` created and included from
`test/runtests.jl`; all required tests pass; Aqua and JET report no issues
**Depends on**: Tasks 1, 2

Create `test/test_discovery.jl` with a named `@testset "discovery"` block.
The following tests are required — all must verify field-level values, not
merely that the function returns something:

(a) Single-type column inference: given records all containing key `"name"` with
`String` values, `build_schema` produces a schema with `name :: String`.
(b) Numeric inference: all integer values → `Int` column; any float value among
integer values → `Float64` column.
(c) `Union{T, Nothing}` promotion: given key `"bootstrap"` with `Float64`
values on some records and absent on others, the produced schema has
`bootstrap :: Union{Float64, Nothing}`.
(d) Schema stability: given the same collection in two different row
presentation orders, both calls to `build_schema` produce identical `NamedTuple`
types.
(e) Row construction: given a record dict with key `"gamma"` absent, `build_row`
produces a row where `row.gamma === nothing`.
(f) Empty annotation collection: `build_schema` on an empty collection returns
a type containing only `src_node_idx :: Int`, `dst_node_idx :: Int`, and
`edgeweight :: Union{Float64, Nothing}` at minimum (the fixed edge columns
guaranteed by the design).
(g) Tables.jl compliance: `Tables.istable([build_row(schema, dict)])` returns
`true` for a produced row wrapped in a single-element vector.
(h) Type stability: `@inferred build_row(schema_type, dict)` produces no
dynamic dispatch warning.
(i) Type overrides: given an override `(; gamma = Union{Float64, Nothing})`,
`build_schema` uses the override type for the `gamma` column regardless of
observed values.

Add `include("test_discovery.jl")` to `test/runtests.jl`. Run
`julia --project=test test/runtests.jl` and confirm all tests pass,
`Aqua.test_all(LineagesIO)` reports no issues, and
`JET.test_package(LineagesIO; target_defined_modules = true)` reports no issues.
Search all identifiers added in this tranche for proscribed vocabulary terms
from `STYLE-vocabulary.md` and confirm no matches.
