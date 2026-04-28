module LineagesIO

import FileIO
import Tables

export CollectionTable
export EdgeRowRef
export EdgeTable
export GraphTable
export LineageGraphAsset
export LineageGraphStore
export MetaGraphsNextTreeView
export NodeRowRef
export NodeTable
export SourceTable
export StructureKeyType
export add_child
export bind_rootnode!
export edge_property
export finalize_graph!
export node_property

"""
    MetaGraphsNextTreeView(asset)
    MetaGraphsNextTreeView(graph, node_table, edge_table)

Construct the extension-owned AbstractTrees-compatible wrapper for a
MetaGraphsNext-backed rooted-tree materialization.
"""
function MetaGraphsNextTreeView end

include("core_types.jl")
include("tables.jl")
include("views.jl")
include("construction.jl")
include("newick_format.jl")
include("fileio_integration.jl")

function __init__()::Nothing
    register_newick_format!()
    return nothing
end

end
