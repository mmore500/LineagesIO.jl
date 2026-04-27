struct StoredGraph{NodeTableT <: NodeTable, EdgeTableT <: EdgeTable}
    index::Int
    source_idx::Int
    collection_idx::Int
    collection_graph_idx::Int
    collection_label::OptionalString
    graph_label::OptionalString
    node_table::NodeTableT
    edge_table::EdgeTableT
    source_path::OptionalString
end

"""
    LineageGraphAsset{NodeT}

Single-graph load result that carries authoritative package-owned tables and
graph/source coordinates.
"""
struct LineageGraphAsset{
    NodeT,
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
    graph_rootnode::NodeT
    source_path::OptionalString
end

struct GraphAssetIterator{StoredGraphT <: AbstractVector}
    stored_graphs::StoredGraphT
end

"""
    LineageGraphStore{NodeT}

Top-level tranche 1 load result. `graphs` is a lazy iterator of
`LineageGraphAsset{NodeT}` values.
"""
struct LineageGraphStore{
    NodeT,
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
    graphs::GraphsT,
) where {
    SourceTableT <: SourceTable,
    CollectionTableT <: CollectionTable,
    GraphTableT <: GraphTable,
    GraphsT,
}
    return LineageGraphStore{Nothing, SourceTableT, CollectionTableT, GraphTableT, GraphsT}(
        source_table,
        collection_table,
        graph_table,
        graphs,
    )
end

Base.IteratorSize(::Type{<:GraphAssetIterator}) = Base.HasLength()
Base.length(iterator::GraphAssetIterator)::Int = length(iterator.stored_graphs)

function Base.eltype(::Type{GraphAssetIterator{StoredGraphT}}) where {StoredGraphT <: AbstractVector}
    stored_graph_type = eltype(StoredGraphT)
    return LineageGraphAsset{
        Nothing,
        fieldtype(stored_graph_type, 7),
        fieldtype(stored_graph_type, 8),
    }
end

function Base.iterate(iterator::GraphAssetIterator, state::Int = 1)
    state > length(iterator) && return nothing
    stored_graph = iterator.stored_graphs[state]
    asset = LineageGraphAsset(
        stored_graph.index,
        stored_graph.source_idx,
        stored_graph.collection_idx,
        stored_graph.collection_graph_idx,
        stored_graph.collection_label,
        stored_graph.graph_label,
        stored_graph.node_table,
        stored_graph.edge_table,
        nothing,
        stored_graph.source_path,
    )
    return asset, state + 1
end

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
