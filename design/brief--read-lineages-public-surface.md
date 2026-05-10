---
date-created: 2026-05-09T00:00:00
status: authoritative
---

# LineagesIO.jl — Public load surface contract

## Authority

This document is the authoritative design brief for the `read_lineages` and
`read_lineages!` public load surfaces. It governs caller-facing syntax, the
type-token/supplied-instance split, the mutation boundary, and the Branch Narrow
atomicity contract.

All downstream work that touches `read_lineages`, `read_lineages!`, error message
wording, keyword handling, or public-surface documentation must conform to this
document. If this document and any other design or workflow artifact conflict, this
document governs for the public surface contract. Conflicts must be raised with
the project owner before implementation continues.

## The two surfaces

LineagesIO exposes two first-class package-owned verbs for reading lineage data.

### `read_lineages` — the library-created path

`read_lineages` accepts one of three construction targets: no target (tables-only),
a **type token**, or a `BuilderDescriptor`. In every case, no caller-owned object
exists before the call begins. LineagesIO creates the result and returns it to
the caller.

A **type token** is a `Type` value passed as an argument — `MetaGraph`,
`HybridNetwork`, `DemoNode`. It is a specification, not an object. Passing
`MetaGraph` to `read_lineages` says "construct a graph of this kind and return it
to me." Nothing the caller owns is touched. The caller acquires ownership only
when the call returns.

A `BuilderDescriptor` is a descriptor struct — a typed construction-strategy
value. LineagesIO reads its fields and creates a new graph; it does not mutate
the descriptor. The returned graph is new. The descriptor is not the destination.

Because no caller-owned object is modified, `read_lineages` does not carry
Julia's `!` mutation marker.

### `read_lineages!` — the supplied-instance path

`read_lineages!` accepts an existing graph **instance** — a value the caller
already owns — as the construction destination. LineagesIO writes nodes and edges
directly into that instance during the call. The argument is the destination,
not a description of one.

Because a caller-owned object is modified in place, `read_lineages!` carries
Julia's `!` mutation marker. The `!` is the canonical signal that the argument
will differ after the call returns: the caller must keep a reference to their
instance, the call is not idempotent on that object, and retry safety requires
a fresh empty instance.

## The `!` boundary

The `!` boundary is drawn exactly at one question: **did the caller pass a value
that will be modified?**

| Argument shape | Kind | `!`? | Rationale |
|---|---|---|---|
| *(none)* | no target | no | nothing caller-owned is touched |
| `MetaGraph` (the type itself) | type token — recipe | no | the `Type` is not modified; a new `MetaGraph` is created and returned |
| `HybridNetwork` (the type itself) | type token — recipe | no | same |
| `BuilderDescriptor(builder, HandleT)` | descriptor value | no | a descriptor describes strategy, not destination; the returned graph is new |
| `my_graph` (a live instance) | caller-owned object — destination | yes | the graph is written into in place; the caller sees the change in the same object |

Note that `BuilderDescriptor` is itself a value (a struct), not a type token. But
it is not the construction destination. LineagesIO reads from it, does not write
into it. No `!`.

## Branch Narrow contract for `read_lineages!`

The supplied-instance path provides **first-edge atomicity only**.

Before any node is written into the supplied graph, LineagesIO pre-materializes
all edge payloads — it validates that each user-supplied edge constructor can be
called and gathers the results. If the first constructor call fails at this stage,
no node has been written and the graph remains empty. The same empty instance can
be retried.

**Later-edge failure is not covered.** Once nodes and earlier edges are committed,
a constructor failure on a subsequent edge leaves partial state — the graph will
contain the nodes and edges already committed. No rollback occurs.

Callers who need retry safety after any failure must discard the partially-populated
instance and supply a fresh empty graph.

The `!` naming makes this contract legible at the call site. A caller who writes
`read_lineages!(src, my_graph)` knows immediately that `my_graph` will be
modified, and knows to think about what retry means for a mutated object.

## `load(...)` and the compatibility wrapper

`FileIO.load(src, TargetType)` and `FileIO.load(src, target_instance)` are
retained as compatibility wrappers. They route internally to `canonical_load` and
do not call `read_lineages` or `read_lineages!` internally. The `load` surface
carries the same Branch Narrow contract for supplied instances.

`load(...)` is not the first-class primary surface. It is retained for FileIO
ecosystem compatibility. Error messages, docs, examples, and extension briefs must
center `read_lineages(...)` and `read_lineages!(...)` and identify `load(...)` as
the compatibility alternative.

## Surface summary

| Call form | Path | Returns |
|---|---|---|
| `read_lineages(src)` | tables-only | `LineageGraphStore` with tables, no graph object |
| `read_lineages(src, NodeT)` | library-created | `LineageGraphStore` with a new graph whose nodes are of type `NodeT` |
| `read_lineages(src, BuilderDescriptor(...))` | library-created, typed builder | `LineageGraphStore` with a new graph built through the descriptor |
| `read_lineages!(src, instance)` | supplied-instance | `LineageGraphStore`; `instance` is populated in place |
| `load(src, TargetType)` | compatibility → library-created | same as `read_lineages(src, TargetType)` |
| `load(src, target_instance)` | compatibility → supplied-instance | same as `read_lineages!(src, target_instance)` |

## Vocabulary compliance

All downstream documents must use the controlled vocabulary from `STYLE-vocabulary.md`:

- `read_lineages` — the library-created path; type token or `BuilderDescriptor` or
  no target; returns a new graph
- `read_lineages!` — the supplied-instance path; caller-owned destination; populates
  in place; Branch Narrow contract applies
- `load(...)` — compatibility wrapper only; not the primary surface
- type token — a `Type` value passed as a recipe for construction; the library
  creates a new object from it
- supplied instance — an existing caller-owned graph value passed as the construction
  destination

Proscribed: `read_lineages` for the supplied-instance path; `load(...)` as the
primary first-class public load surface in new documentation.
