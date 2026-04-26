export LineageGraphAsset
export LineageGraphStore

import Tables

"""
    LineageGraphAsset{NodeT}

Single-graph result produced by LineagesIO. Each asset carries graph index
coordinates, Tables.jl-compliant node and edge tables, the `graph_rootnode`
returned by the entry-point `add_child` call, and the originating source path
when one exists.

`node_table` and `edge_table` must satisfy the Tables.jl interface. This tranche
stores them with concrete representation type parameters so the asset remains
fully type-stable while still allowing callers to choose any compliant table
representation.
"""
struct LineageGraphAsset{NodeT, NodeTableT, EdgeTableT}
    index::Int
    source_idx::Int
    collection_idx::Int
    collection_graph_idx::Int
    collection_label::Union{String, Nothing}
    graph_label::Union{String, Nothing}
    node_table::NodeTableT
    edge_table::EdgeTableT
    graph_rootnode::NodeT
    source_path::Union{String, Nothing}
end

"""
    LineageGraphStore{NodeT}

Top-level load result. `source_table`, `collection_table`, and `graph_table`
must satisfy the Tables.jl interface. `graphs` must be a lazy iterator that
yields `LineageGraphAsset` values rather than a materialized vector.

This tranche stores each field behind a concrete representation type parameter
to keep the result type-stable while preserving flexibility for later parsing
and view-layer tranches.
"""
struct LineageGraphStore{NodeT, SourceTableT, CollectionTableT, GraphTableT, GraphsT}
    source_table::SourceTableT
    collection_table::CollectionTableT
    graph_table::GraphTableT
    graphs::GraphsT
end

function LineageGraphAsset{NodeT}(
    index::Int,
    source_idx::Int,
    collection_idx::Int,
    collection_graph_idx::Int,
    collection_label::Union{String, Nothing},
    graph_label::Union{String, Nothing},
    node_table::NodeTableT,
    edge_table::EdgeTableT,
    graph_rootnode::NodeT,
    source_path::Union{String, Nothing},
)::LineageGraphAsset{NodeT, NodeTableT, EdgeTableT} where {NodeT, NodeTableT, EdgeTableT}
    validate_table(:node_table, node_table)
    validate_table(:edge_table, edge_table)
    return LineageGraphAsset{NodeT, NodeTableT, EdgeTableT}(
        index,
        source_idx,
        collection_idx,
        collection_graph_idx,
        collection_label,
        graph_label,
        node_table,
        edge_table,
        graph_rootnode,
        source_path,
    )
end

function LineageGraphStore{NodeT}(
    source_table::SourceTableT,
    collection_table::CollectionTableT,
    graph_table::GraphTableT,
    graphs::GraphsT,
)::LineageGraphStore{NodeT, SourceTableT, CollectionTableT, GraphTableT, GraphsT} where {
    NodeT,
    SourceTableT,
    CollectionTableT,
    GraphTableT,
    GraphsT,
}
    validate_table(:source_table, source_table)
    validate_table(:collection_table, collection_table)
    validate_table(:graph_table, graph_table)
    validate_graphs_iterator(graphs)
    return LineageGraphStore{NodeT, SourceTableT, CollectionTableT, GraphTableT, GraphsT}(
        source_table,
        collection_table,
        graph_table,
        graphs,
    )
end

function validate_table(name::Symbol, table::TableT)::Nothing where {TableT}
    Tables.istable(table) && return nothing
    throw(ArgumentError("$(name) must satisfy the Tables.jl interface"))
end

function validate_graphs_iterator(graphs::GraphsT)::Nothing where {GraphsT}
    graphs isa AbstractVector &&
        throw(ArgumentError("graphs must be a lazy iterator, not an AbstractVector"))
    return nothing
end
