module MetaGraphsNextIO

using LineagesIO:
    LineagesIO,
    EdgeRowRef,
    EdgeWeightType,
    LineageGraphAsset,
    NodeRowRef,
    NodeTable,
    EdgeTable,
    StructureKeyType,
    graph_requires_multi_parent
using MetaGraphsNext: MetaGraph, MetaGraphsNext
using MetaGraphsNext.Graphs: SimpleDiGraph, add_edge!, add_vertex!, is_directed, nv

# ---------------------------------------------------------------------------
# Extension-private construction cursor.
#
# Carries the MetaGraph being built and the current node's StructureKeyType so
# that add_child can connect parent → child without receiving the parent
# nodekey again. Both fields are concrete at every instantiation.
# ---------------------------------------------------------------------------

"""
    MetaGraphsNextBuildCursor{GraphT <: MetaGraph}

Extension-private construction handle returned by `bind_basenode!` and
`add_child`. Carries the MetaGraph under construction and the nodekey of the
node most recently added, so that the next `add_child` call can draw the
parent → child edge correctly.

Not part of the public API. Users receive the completed `MetaGraph` from
`load`, never this type.
"""
struct MetaGraphsNextBuildCursor{GraphT <: MetaGraph}
    graph::GraphT
    nodekey::StructureKeyType
end

# ---------------------------------------------------------------------------
# Extension-private AbstractTrees compatibility wrapper.
#
# ConcreteMetaGraphsNextTreeView is accessed by name from
# MetaGraphsNextAbstractTreesIO via Base.get_extension, so its field names
# (graph, nodekey, node_table, edge_table) must not be changed.
# ---------------------------------------------------------------------------

"""
    ConcreteMetaGraphsNextTreeView{GraphT, NodeTableT, EdgeTableT}

Extension-private struct returned by `MetaGraphsNextTreeView`. Wraps a
constructed MetaGraph together with its authoritative tables and a current
nodekey, making it traversable by AbstractTrees.jl.
"""
struct ConcreteMetaGraphsNextTreeView{
    GraphT <: MetaGraph,
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    graph::GraphT
    nodekey::StructureKeyType
    node_table::NodeTableT
    edge_table::EdgeTableT
end

# ---------------------------------------------------------------------------
# Label conversion helpers.
#
# Symbol satisfies the MetaGraphsNext requirement that Label ≠ Code type
# (metagraph.jl:16), has interned equality (O(1) Dict lookups), and produces
# idiomatic user access: graph[Symbol(3)], graph[Symbol(1), Symbol(2)].
#
# node_label and label_nodekey are accessed by name from
# MetaGraphsNextAbstractTreesIO (lines 20 and 29 of that extension), so
# their names and signatures must be preserved.
# ---------------------------------------------------------------------------

"""
    node_label(nodekey) -> Symbol

Convert a `StructureKeyType` nodekey to the MetaGraph `Symbol` label used for
that node. For example, `1` becomes `Symbol(1)` and `2` becomes `Symbol(2)`.
"""
node_label(nodekey::StructureKeyType)::Symbol = Symbol(nodekey)

"""
    label_nodekey(label) -> StructureKeyType

Recover the `StructureKeyType` nodekey from a MetaGraph `Symbol` label.
"""
label_nodekey(label::Symbol)::StructureKeyType = StructureKeyType(parse(Int, String(label)))

# ---------------------------------------------------------------------------
# Default MetaGraph factory.
#
# Produces a directed MetaGraph with Symbol labels and Union{Nothing,Float64}
# edge data so that source edge weights are stored natively and immediately
# accessible via weights(graph)[i, j].
#
# Constructor form verified against metagraph.jl:61-89 (positional,
# type-stable). Keyword form (metagraph.jl:107-125) is type-unstable and
# is not used here.
# ---------------------------------------------------------------------------

"""
    default_metagraph() -> MetaGraph

Return an empty directed `MetaGraph` with `Symbol` labels, `Nothing` vertex
data, and `Union{Nothing, Float64}` edge data. The weight function extracts
the stored float, defaulting to `1.0` when no edge weight was present in the
source.

Used by the library-created `MetaGraph` construction path, including the
first-class `read_lineages(source, MetaGraph)` surface.
"""
function default_metagraph()::MetaGraph
    return MetaGraph(
        SimpleDiGraph{Int}(),
        Symbol,
        Nothing,
        Union{Nothing, Float64},
        nothing,
        ed -> ed === nothing ? 1.0 : ed,
        1.0,
    )
end

# ---------------------------------------------------------------------------
# Validation.
# ---------------------------------------------------------------------------

metagraph_label_type(::MetaGraph{<:Any, <:Any, LabelT}) where {LabelT} = LabelT

"""
    validate_empty_metagraph(graph) -> Nothing

Assert that `graph` is a directed, empty `MetaGraph` with `Symbol` as its
`Label` type parameter. Throws `ArgumentError` if any condition fails.

Called before the supplied-instance load path binds a basenode.
"""
function validate_empty_metagraph(graph::MetaGraph)::Nothing
    is_directed(graph) || throw(
        ArgumentError(
            "A supplied `MetaGraph` must be directed. Use `SimpleDiGraph` " *
            "as the underlying graph type.",
        ),
    )
    nv(graph) == 0 || throw(
        ArgumentError(
            "A supplied `MetaGraph` must be empty before loading into it.",
        ),
    )
    metagraph_label_type(graph) === Symbol || throw(
        ArgumentError(
            "A supplied `MetaGraph` must use `Symbol` as its `Label` type. " *
            "Construct it with `Symbol` as the second positional argument, e.g.: " *
            "`MetaGraph(SimpleDiGraph{Int}(), Symbol, VertexData, EdgeData, ...)`.",
        ),
    )
    return nothing
end

# ---------------------------------------------------------------------------
# Node addition — dispatch on VertexData type parameter.
#
# Verified against graphs.jl:181-183 (Nothing path) and graphs.jl:163-179
# (data path).
# ---------------------------------------------------------------------------

function add_node_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, Nothing},
    nodekey::StructureKeyType,
    ::NodeRowRef,
)::Nothing
    add_vertex!(graph, node_label(nodekey)) || throw(
        ArgumentError(
            "Failed to add node with nodekey $(nodekey) to the MetaGraph.",
        ),
    )
    return nothing
end

function add_node_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, <:NodeRowRef},
    nodekey::StructureKeyType,
    nodedata::NodeRowRef,
)::Nothing
    add_vertex!(graph, node_label(nodekey), nodedata) || throw(
        ArgumentError(
            "Failed to add node with nodekey $(nodekey) to the MetaGraph.",
        ),
    )
    return nothing
end

function add_node_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, NodeDataT},
    nodekey::StructureKeyType,
    nodedata::NodeRowRef,
)::Nothing where {NodeDataT}
    add_vertex!(graph, node_label(nodekey), NodeDataT(nodedata)) || throw(
        ArgumentError(
            "Failed to add node with nodekey $(nodekey) to the MetaGraph.",
        ),
    )
    return nothing
end

# ---------------------------------------------------------------------------
# Edge addition — dispatch on EdgeData type parameter.
#
# Verified against graphs.jl:215-219 (Nothing path) and graphs.jl:195-213
# (data paths).
# ---------------------------------------------------------------------------

function add_edge_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, <:Any, Nothing},
    src_nodekey::StructureKeyType,
    dst_nodekey::StructureKeyType,
    ::EdgeWeightType,
    ::EdgeRowRef,
)::Nothing
    add_edge!(graph, node_label(src_nodekey), node_label(dst_nodekey)) || throw(
        ArgumentError(
            "Failed to add edge $(src_nodekey) -> $(dst_nodekey) to the MetaGraph.",
        ),
    )
    return nothing
end

function add_edge_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, <:Any, Union{Nothing, Float64}},
    src_nodekey::StructureKeyType,
    dst_nodekey::StructureKeyType,
    edgeweight::EdgeWeightType,
    ::EdgeRowRef,
)::Nothing
    add_edge!(graph, node_label(src_nodekey), node_label(dst_nodekey), edgeweight) ||
        throw(
            ArgumentError(
                "Failed to add edge $(src_nodekey) -> $(dst_nodekey) to the MetaGraph.",
            ),
        )
    return nothing
end

function add_edge_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, <:Any, <:Real},
    src_nodekey::StructureKeyType,
    dst_nodekey::StructureKeyType,
    edgeweight::EdgeWeightType,
    ::EdgeRowRef,
)::Nothing
    w = edgeweight === nothing ? MetaGraphsNext.default_weight(graph) : edgeweight
    add_edge!(graph, node_label(src_nodekey), node_label(dst_nodekey), w) || throw(
        ArgumentError(
            "Failed to add edge $(src_nodekey) -> $(dst_nodekey) to the MetaGraph.",
        ),
    )
    return nothing
end

function add_edge_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, <:Any, <:EdgeRowRef},
    src_nodekey::StructureKeyType,
    dst_nodekey::StructureKeyType,
    ::EdgeWeightType,
    edgedata::EdgeRowRef,
)::Nothing
    add_edge!(graph, node_label(src_nodekey), node_label(dst_nodekey), edgedata) ||
        throw(
            ArgumentError(
                "Failed to add edge $(src_nodekey) -> $(dst_nodekey) to the MetaGraph.",
            ),
        )
    return nothing
end

function add_edge_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, <:Any, EdgeDataT},
    src_nodekey::StructureKeyType,
    dst_nodekey::StructureKeyType,
    edgeweight::EdgeWeightType,
    edgedata::EdgeRowRef,
)::Nothing where {EdgeDataT}
    add_edge!(
        graph,
        node_label(src_nodekey),
        node_label(dst_nodekey),
        EdgeDataT(edgeweight, edgedata),
    ) || throw(
        ArgumentError(
            "Failed to add edge $(src_nodekey) -> $(dst_nodekey) to the MetaGraph.",
        ),
    )
    return nothing
end

# ---------------------------------------------------------------------------
# Protocol: validate_extension_load_target
# ---------------------------------------------------------------------------

function LineagesIO.validate_extension_load_target(::Type{<:MetaGraph})::Nothing
    return nothing
end

function LineagesIO.validate_extension_load_target(
    ::Type{<:MetaGraph},
    graph_asset::LineageGraphAsset,
)::Nothing
    graph_requires_multi_parent(graph_asset) || return nothing
    throw(
        ArgumentError(
            "The MetaGraphsNext extension does not support the multi-parent " *
            "construction tier for the library-created `MetaGraph` target " *
            "path. Construct an empty `MetaGraph` with `Symbol` labels " *
            "and use the caller-supplied target path instead, which " *
            "supports both single-parent and multi-parent sources.",
        ),
    )
end

function LineagesIO.validate_extension_load_target(
    graph::MetaGraph,
    ::LineageGraphAsset,
)::Nothing
    validate_empty_metagraph(graph)
    return nothing
end

function LineagesIO.construction_handle_type(
    ::GraphT,
)::Type where {GraphT <: MetaGraph}
    return MetaGraphsNextBuildCursor{GraphT}
end

function LineagesIO.construction_handle_type(
    ::Type{GraphT},
)::Type where {GraphT <: MetaGraph}
    return MetaGraphsNextBuildCursor
end

# ---------------------------------------------------------------------------
# Protocol: emit_basenode (library-created path only).
#
# The generic emit_basenode in construction.jl checks basenode_handle isa NodeT
# (construction.jl:528-529). Since NodeT = MetaGraph and our handles are
# MetaGraphsNextBuildCursor, the check would fail without this override.
# This override is the correct and necessary extension point for the
# library-created (NodeTypeLoadRequest) path.
# ---------------------------------------------------------------------------

function LineagesIO.emit_basenode(
    ::LineagesIO.NodeTypeLoadRequest{<:MetaGraph, <:Any},
    nodekey::StructureKeyType,
    _label::AbstractString,
    nodedata::NodeRowRef,
)
    graph = default_metagraph()
    add_node_to_metagraph!(graph, nodekey, nodedata)
    return MetaGraphsNextBuildCursor{typeof(graph)}(graph, nodekey)
end

# ---------------------------------------------------------------------------
# Protocol: bind_basenode! (supplied-instance path).
# ---------------------------------------------------------------------------

function LineagesIO.bind_basenode!(
    graph::GraphT,
    nodekey::StructureKeyType,
    ::AbstractString;
    nodedata::NodeRowRef,
) where {GraphT <: MetaGraph}
    validate_empty_metagraph(graph)
    add_node_to_metagraph!(graph, nodekey, nodedata)
    return MetaGraphsNextBuildCursor{GraphT}(graph, nodekey)
end

# ---------------------------------------------------------------------------
# Protocol: add_child — single-parent.
# ---------------------------------------------------------------------------

function LineagesIO.add_child(
    parent::MetaGraphsNextBuildCursor{GraphT},
    nodekey::StructureKeyType,
    ::AbstractString,
    ::StructureKeyType,
    edgeweight::EdgeWeightType;
    edgedata::EdgeRowRef,
    nodedata::NodeRowRef,
) where {GraphT <: MetaGraph}
    graph = parent.graph
    add_node_to_metagraph!(graph, nodekey, nodedata)
    add_edge_to_metagraph!(graph, parent.nodekey, nodekey, edgeweight, edgedata)
    return MetaGraphsNextBuildCursor{GraphT}(graph, nodekey)
end

# ---------------------------------------------------------------------------
# Protocol: add_child — multi-parent (supplied-instance path only).
# ---------------------------------------------------------------------------

function LineagesIO.add_child(
    parents::AbstractVector{MetaGraphsNextBuildCursor{GraphT}},
    nodekey::StructureKeyType,
    ::AbstractString,
    ::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType};
    edgedata::AbstractVector{<:EdgeRowRef},
    nodedata::NodeRowRef,
) where {GraphT <: MetaGraph}
    length(parents) == length(edgeweights) == length(edgedata) || throw(
        ArgumentError(
            "Multi-parent construction requires equal-length `parents`, " *
            "`edgeweights`, and `edgedata` collections.",
        ),
    )
    graph = first(parents).graph
    add_node_to_metagraph!(graph, nodekey, nodedata)
    for (parent, edgeweight, edgeref) in zip(parents, edgeweights, edgedata)
        add_edge_to_metagraph!(graph, parent.nodekey, nodekey, edgeweight, edgeref)
    end
    return MetaGraphsNextBuildCursor{GraphT}(graph, nodekey)
end

# ---------------------------------------------------------------------------
# Protocol: finalize_graph!
# ---------------------------------------------------------------------------

function LineagesIO.finalize_graph!(cursor::MetaGraphsNextBuildCursor)
    return cursor.graph
end

# ---------------------------------------------------------------------------
# Finalized-result projections.
# ---------------------------------------------------------------------------

function LineagesIO.graph_from_finalized(graph::GraphT)::GraphT where {GraphT <: MetaGraph}
    return graph
end

LineagesIO.basenode_from_finalized(::MetaGraph)::Symbol = Symbol(StructureKeyType(1))

# ---------------------------------------------------------------------------
# MetaGraphsNextTreeView — AbstractTrees compatibility entry points.
#
# MetaGraphsNextTreeView is declared as an extensible function in
# src/LineagesIO.jl:30. These methods extend it for MetaGraph-backed assets.
# ---------------------------------------------------------------------------

function LineagesIO.MetaGraphsNextTreeView(
    asset::LineageGraphAsset{GraphT, <:Any, NodeTableT, EdgeTableT},
) where {
    GraphT <: MetaGraph,
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    graph = asset.graph
    nv(graph) > 0 || throw(
        ArgumentError(
            "`MetaGraphsNextTreeView` requires a non-empty MetaGraph-backed asset.",
        ),
    )
    return ConcreteMetaGraphsNextTreeView(
        graph,
        StructureKeyType(1),
        asset.node_table,
        asset.edge_table,
    )
end

function LineagesIO.MetaGraphsNextTreeView(
    graph::GraphT,
    node_table::NodeTableT,
    edge_table::EdgeTableT,
) where {
    GraphT <: MetaGraph,
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    nv(graph) > 0 || throw(
        ArgumentError(
            "`MetaGraphsNextTreeView` requires a non-empty MetaGraph.",
        ),
    )
    return ConcreteMetaGraphsNextTreeView(
        graph,
        StructureKeyType(1),
        node_table,
        edge_table,
    )
end

end
