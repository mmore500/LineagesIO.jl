module LineagesIO

import FileIO
import Tables

export CollectionTable
export EdgeRowRef
export EdgeTable
export GraphTable
export LineageGraphAsset
export LineageGraphStore
export NodeRowRef
export NodeTable
export SourceTable
export StructureKeyType
export add_child
export bind_rootnode!
export edge_property
export finalize_graph!
export node_property

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
