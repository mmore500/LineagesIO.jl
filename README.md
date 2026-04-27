# LineagesIO

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jeetsukumaran.github.io/LineagesIO.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jeetsukumaran.github.io/LineagesIO.jl/dev/)
[![Build Status](https://github.com/jeetsukumaran/LineagesIO.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jeetsukumaran/LineagesIO.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

LineagesIO.jl provides FileIO-compatible loading of rooted lineage graphs into
package-owned authoritative tables.

Phase 1 currently supports simple rooted Newick sources through:

- safe bare `load("tree.nwk")` loads for supported Newick extensions
- explicit overrides through `load(File{format"Newick"}(...))`
- stream-based loads through `load(Stream{format"Newick"}(...))`
- lazy `LineageGraphStore.graphs` iteration with authoritative `node_table`
  and `edge_table`
- informative explicit-override errors for ambiguous text extensions such as
  `.txt`

## Quick start

```julia
using FileIO: load
using LineagesIO

store = load("primates.nwk")
asset = first(store.graphs)

asset.graph_rootnode === nothing
asset.node_table
asset.edge_table
```

Use an explicit override when the source path is intentionally ambiguous:

```julia
using FileIO
using LineagesIO

store = load(File{format"Newick"}("primates.txt"))
```
