module LineagesIO

import DelimitedFiles
import FileIO
import Tables

export CollectionTable
export BuilderDescriptor
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
export basenode
export basenode_from_finalized
export bind_basenode!
export edge_property
export finalize_graph!
export graph_from_finalized
export load_alife_table
export node_property
export read_lineages
export read_lineages!

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
include("load_owner.jl")
include("read_lineages.jl")
include("load_compat.jl")
include("construction.jl")
include("newick_format.jl")
include("alife_format.jl")
include("fileio_integration.jl")

function __init__()::Nothing
    register_newick_format!()
    return nothing
end

end
