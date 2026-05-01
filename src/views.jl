"""
    LineageGraphAsset{MaterializedT}

Single-graph load result that carries authoritative package-owned tables and
graph/source coordinates together with any optional materialized graph result.
"""
struct LineageGraphAsset{
    MaterializedT,
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    index::Int
    source_idx::Int
    collection_idx::Int
    collection_graph_idx::Int
    collection_label::OptionalString
    graph_label::OptionalString
    node_table::NodeTableT
    edge_table::EdgeTableT
    materialized::MaterializedT
    source_path::OptionalString
end

struct GraphAssetIterator{GraphAssetVectorT <: AbstractVector}
    graph_assets::GraphAssetVectorT
end

"""
    LineageGraphStore{MaterializedT}

Top-level load result. `graphs` is a lazy iterator of
`LineageGraphAsset{MaterializedT}` values.
"""
struct LineageGraphStore{
    MaterializedT,
    SourceTableT <: SourceTable,
    CollectionTableT <: CollectionTable,
    GraphTableT <: GraphTable,
    GraphsT,
}
    source_table::SourceTableT
    collection_table::CollectionTableT
    graph_table::GraphTableT
    graphs::GraphsT
end

function LineageGraphStore(
    source_table::SourceTableT,
    collection_table::CollectionTableT,
    graph_table::GraphTableT,
    graphs::GraphAssetIterator{GraphAssetVectorT},
) where {
    SourceTableT <: SourceTable,
    CollectionTableT <: CollectionTable,
    GraphTableT <: GraphTable,
    GraphAssetVectorT <: AbstractVector,
}
    graph_asset_type = eltype(GraphAssetVectorT)
    materialized_type = fieldtype(graph_asset_type, 9)
    graph_iterator_type = typeof(graphs)
    return LineageGraphStore{materialized_type, SourceTableT, CollectionTableT, GraphTableT, graph_iterator_type}(
        source_table,
        collection_table,
        graph_table,
        graphs,
    )
end

Base.IteratorSize(::Type{<:GraphAssetIterator}) = Base.HasLength()
Base.length(iterator::GraphAssetIterator)::Int = length(iterator.graph_assets)
Base.eltype(::Type{GraphAssetIterator{GraphAssetVectorT}}) where {GraphAssetVectorT <: AbstractVector} = eltype(GraphAssetVectorT)

function Base.iterate(iterator::GraphAssetIterator, state::Int = 1)
    state > length(iterator) && return nothing
    return iterator.graph_assets[state], state + 1
end

"""
    NodeRowRef

Tables.jl-compatible row reference into an authoritative `NodeTable`.
"""
struct NodeRowRef{NodeTableT <: NodeTable} <: Tables.AbstractRow
    table::NodeTableT
    nodekey::StructureKeyType
    function NodeRowRef{NodeTableT}(table::NodeTableT, nodekey::StructureKeyType) where {NodeTableT <: NodeTable}
        assert_rowkey(table, nodekey, "nodekey")
        return new{NodeTableT}(table, nodekey)
    end
end

"""
    EdgeRowRef

Tables.jl-compatible row reference into an authoritative `EdgeTable`.
"""
struct EdgeRowRef{EdgeTableT <: EdgeTable} <: Tables.AbstractRow
    table::EdgeTableT
    edgekey::StructureKeyType
    function EdgeRowRef{EdgeTableT}(table::EdgeTableT, edgekey::StructureKeyType) where {EdgeTableT <: EdgeTable}
        assert_rowkey(table, edgekey, "edgekey")
        return new{EdgeTableT}(table, edgekey)
    end
end

function Base.getproperty(rowref::NodeRowRef, nm::Symbol)
    if nm === :table || nm === :nodekey
        return getfield(rowref, nm)
    end
    return getfield(rowref, nm)
end

function Base.getproperty(rowref::EdgeRowRef, nm::Symbol)
    if nm === :table || nm === :edgekey
        return getfield(rowref, nm)
    end
    return getfield(rowref, nm)
end

function NodeRowRef(node_table::NodeTableT, nodekey::StructureKeyType) where {NodeTableT <: NodeTable}
    return NodeRowRef{NodeTableT}(node_table, nodekey)
end

function EdgeRowRef(edge_table::EdgeTableT, edgekey::StructureKeyType) where {EdgeTableT <: EdgeTable}
    return EdgeRowRef{EdgeTableT}(edge_table, edgekey)
end

Tables.schema(rowref::NodeRowRef)::Tables.Schema = Tables.schema(getfield(rowref, :table))
Tables.schema(rowref::EdgeRowRef)::Tables.Schema = Tables.schema(getfield(rowref, :table))
Tables.columnnames(rowref::NodeRowRef)::Tuple = Tables.columnnames(getfield(rowref, :table))
Tables.columnnames(rowref::EdgeRowRef)::Tuple = Tables.columnnames(getfield(rowref, :table))

function Tables.getcolumn(rowref::NodeRowRef, ::Type{T}, i::Int, nm::Symbol) where {T}
    return Tables.getcolumn(getfield(rowref, :table), T, i, nm)[getfield(rowref, :nodekey)]
end

function Tables.getcolumn(rowref::EdgeRowRef, ::Type{T}, i::Int, nm::Symbol) where {T}
    return Tables.getcolumn(getfield(rowref, :table), T, i, nm)[getfield(rowref, :edgekey)]
end

Tables.getcolumn(rowref::NodeRowRef, i::Int) = Tables.getcolumn(getfield(rowref, :table), i)[getfield(rowref, :nodekey)]
Tables.getcolumn(rowref::EdgeRowRef, i::Int) = Tables.getcolumn(getfield(rowref, :table), i)[getfield(rowref, :edgekey)]
Tables.getcolumn(rowref::NodeRowRef, nm::Symbol) = Tables.getcolumn(getfield(rowref, :table), nm)[getfield(rowref, :nodekey)]
Tables.getcolumn(rowref::EdgeRowRef, nm::Symbol) = Tables.getcolumn(getfield(rowref, :table), nm)[getfield(rowref, :edgekey)]

function node_property(
    node_table::NodeTable,
    nodekey::StructureKeyType,
    propertykey,
)::NodePropertyValueType
    normalized_propertykey = normalize_propertykey(propertykey)
    has_property(node_table, normalized_propertykey) || throw(ArgumentError("Requested node property `$(repr(normalized_propertykey))` is not present in the authoritative node table."))
    assert_rowkey(node_table, nodekey, "nodekey")
    return Tables.getcolumn(node_table, normalized_propertykey)[nodekey]
end

function node_property(
    nodedata::NodeRowRef,
    propertykey,
)::NodePropertyValueType
    return node_property(getfield(nodedata, :table), getfield(nodedata, :nodekey), propertykey)
end

function edge_property(
    edge_table::EdgeTable,
    edgekey::StructureKeyType,
    propertykey,
)::EdgePropertyValueType
    normalized_propertykey = normalize_propertykey(propertykey)
    has_property(edge_table, normalized_propertykey) || throw(ArgumentError("Requested edge property `$(repr(normalized_propertykey))` is not present in the authoritative edge table."))
    assert_rowkey(edge_table, edgekey, "edgekey")
    return Tables.getcolumn(edge_table, normalized_propertykey)[edgekey]
end

function edge_property(
    edgedata::EdgeRowRef,
    propertykey,
)::EdgePropertyValueType
    return edge_property(getfield(edgedata, :table), getfield(edgedata, :edgekey), propertykey)
end

"""
    basenode(asset::LineageGraphAsset)

Return the root node (basenode) of the graph from a construction load.

The concrete return type depends on the load surface used:

- **Native LineagesIO protocol**: returns the user-supplied root node object
  (the type passed to `load` or returned by the `builder` callback).
- **PhyloNetworks extension**: returns the root `PhyloNetworks.Node` of the
  materialized `HybridNetwork` (i.e., `net.node[net.root]`).
- **MetaGraphsNext extension**: returns the vertex label `Symbol` of the
  basenode (always `:1`), which is the key used to dereference vertex data
  and edges from the `MetaGraph` (e.g., `asset.materialized[:1]`).

Raises `ArgumentError` for tables-only assets where no construction target
was supplied and `asset.materialized === nothing`.
"""
function basenode(asset::LineageGraphAsset{MaterializedT})::MaterializedT where {MaterializedT}
    asset.materialized === nothing && throw(
        ArgumentError(
            "Cannot extract a `basenode` from a tables-only `LineageGraphAsset`. " *
            "Supply a construction target to `load` to obtain a materialized result."
        )
    )
    return asset.materialized
end

"""
    Base.iterate(asset::LineageGraphAsset[, state::Int])
    Base.length(::LineageGraphAsset)

Enable assignment and loop destructuring of a `LineageGraphAsset` in the stable
public order `(materialized, node_table, edge_table)`.

For tables-only loads, the first destructured value is `nothing`.
"""
Base.IteratorSize(::Type{<:LineageGraphAsset}) = Base.HasLength()
Base.length(::LineageGraphAsset)::Int = 3

function Base.iterate(asset::LineageGraphAsset, state::Int = 1)
    state == 1 && return asset.materialized, 2
    state == 2 && return asset.node_table, 3
    state == 3 && return asset.edge_table, 4
    return nothing
end

function has_property(table::AbstractLineageTable, propertykey::Symbol)::Bool
    return propertykey in Tables.columnnames(table)
end

function normalize_propertykey(propertykey::Symbol)::Symbol
    return propertykey
end

function normalize_propertykey(propertykey::AbstractString)::Symbol
    return Symbol(propertykey)
end

function normalize_propertykey(propertykey)::Symbol
    throw(ArgumentError("Property lookup keys must be `Symbol` or `AbstractString` values."))
end

function assert_rowkey(table::AbstractLineageTable, rowkey::StructureKeyType, rowkey_name::AbstractString)::Nothing
    nrows = lineagetable_nrows(table)
    1 <= rowkey <= nrows || throw(ArgumentError("Requested $(rowkey_name) $(rowkey) is not present in the authoritative table."))
    return nothing
end
