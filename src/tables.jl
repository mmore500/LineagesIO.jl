abstract type AbstractLineageTable <: Tables.AbstractColumns end

"""
    SourceTable

Package-owned authoritative source summary table for tranche 1 loads.
"""
struct SourceTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} <: AbstractLineageTable
    columns::ColumnsT
    schema::SchemaT
end

"""
    CollectionTable

Package-owned authoritative collection summary table for tranche 1 loads.
"""
struct CollectionTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} <: AbstractLineageTable
    columns::ColumnsT
    schema::SchemaT
end

"""
    GraphTable

Package-owned authoritative graph summary table for tranche 1 loads.
"""
struct GraphTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} <: AbstractLineageTable
    columns::ColumnsT
    schema::SchemaT
end

"""
    NodeTable

Package-owned authoritative node table for a loaded graph.
"""
struct NodeTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} <: AbstractLineageTable
    columns::ColumnsT
    schema::SchemaT
end

"""
    EdgeTable

Package-owned authoritative edge table for a loaded graph.
"""
struct EdgeTable{SchemaT <: Tables.Schema, ColumnsT <: NamedTuple} <: AbstractLineageTable
    columns::ColumnsT
    schema::SchemaT
end

Tables.istable(::Type{<:AbstractLineageTable}) = true
Tables.columnaccess(::Type{<:AbstractLineageTable}) = true
Tables.columns(table::AbstractLineageTable)::AbstractLineageTable = table
Tables.schema(table::AbstractLineageTable)::Tables.Schema = getfield(table, :schema)
Tables.columnnames(table::AbstractLineageTable)::Tuple = Tables.schema(table).names
Tables.getcolumn(table::AbstractLineageTable, i::Int)::AbstractVector = getfield(getfield(table, :columns), i)
Tables.getcolumn(table::AbstractLineageTable, nm::Symbol)::AbstractVector = getproperty(getfield(table, :columns), nm)
Tables.getcolumn(table::AbstractLineageTable, ::Type{T}, i::Int, nm::Symbol) where {T} = Tables.getcolumn(table, i)
Tables.materializer(::Type{<:AbstractLineageTable}) = Tables.columntable

function SourceTable(columns::ColumnsT) where {ColumnsT <: NamedTuple}
    lineagetable_nrows(columns)
    schema = lineage_schema(columns)
    return SourceTable{typeof(schema), ColumnsT}(columns, schema)
end

function CollectionTable(columns::ColumnsT) where {ColumnsT <: NamedTuple}
    lineagetable_nrows(columns)
    schema = lineage_schema(columns)
    return CollectionTable{typeof(schema), ColumnsT}(columns, schema)
end

function GraphTable(columns::ColumnsT) where {ColumnsT <: NamedTuple}
    lineagetable_nrows(columns)
    schema = lineage_schema(columns)
    return GraphTable{typeof(schema), ColumnsT}(columns, schema)
end

function NodeTable(columns::ColumnsT) where {ColumnsT <: NamedTuple}
    nrows = lineagetable_nrows(columns)
    expected_nodekeys = collect(StructureKeyType(1):StructureKeyType(nrows))
    columns.nodekey == expected_nodekeys || throw(ArgumentError("Node table rows must follow `nodekey` order with sequential `StructureKeyType` keys starting at 1."))
    schema = lineage_schema(columns)
    return NodeTable{typeof(schema), ColumnsT}(columns, schema)
end

function EdgeTable(columns::ColumnsT) where {ColumnsT <: NamedTuple}
    nrows = lineagetable_nrows(columns)
    expected_edgekeys = collect(StructureKeyType(1):StructureKeyType(nrows))
    columns.edgekey == expected_edgekeys || throw(ArgumentError("Edge table rows must follow `edgekey` order with sequential `StructureKeyType` keys starting at 1."))
    schema = lineage_schema(columns)
    return EdgeTable{typeof(schema), ColumnsT}(columns, schema)
end

function SourceTable(;
        source_idx::AbstractVector{<:Integer},
        source_path::AbstractVector,
        collection_count::AbstractVector{<:Integer},
        graph_count::AbstractVector{<:Integer},
    )::SourceTable
    return SourceTable(
        (
            source_idx = Int.(source_idx),
            source_path = normalize_optional_string_vector(source_path),
            collection_count = Int.(collection_count),
            graph_count = Int.(graph_count),
        )
    )
end

function CollectionTable(;
        collection_idx::AbstractVector{<:Integer},
        source_idx::AbstractVector{<:Integer},
        collection_label::AbstractVector,
        graph_count::AbstractVector{<:Integer},
    )::CollectionTable
    return CollectionTable(
        (
            collection_idx = Int.(collection_idx),
            source_idx = Int.(source_idx),
            collection_label = normalize_optional_string_vector(collection_label),
            graph_count = Int.(graph_count),
        )
    )
end

function GraphTable(;
        index::AbstractVector{<:Integer},
        source_idx::AbstractVector{<:Integer},
        collection_idx::AbstractVector{<:Integer},
        collection_graph_idx::AbstractVector{<:Integer},
        collection_label::AbstractVector,
        graph_label::AbstractVector,
        node_count::AbstractVector{<:Integer},
        edge_count::AbstractVector{<:Integer},
    )::GraphTable
    return GraphTable(
        (
            index = Int.(index),
            source_idx = Int.(source_idx),
            collection_idx = Int.(collection_idx),
            collection_graph_idx = Int.(collection_graph_idx),
            collection_label = normalize_optional_string_vector(collection_label),
            graph_label = normalize_optional_string_vector(graph_label),
            node_count = Int.(node_count),
            edge_count = Int.(edge_count),
        )
    )
end

function NodeTable(;
        nodekey::AbstractVector{<:Integer},
        label::AbstractVector{<:AbstractString},
        annotation_columns::NamedTuple = NamedTuple(),
    )::NodeTable
    structural_columns = (
        nodekey = StructureKeyType.(nodekey),
        label = String.(label),
    )
    normalized_annotations = normalize_annotation_columns(annotation_columns, "node")
    columns = merge_table_columns(structural_columns, normalized_annotations, "node")
    return NodeTable(columns)
end

function EdgeTable(;
        edgekey::AbstractVector{<:Integer},
        src_nodekey::AbstractVector{<:Integer},
        dst_nodekey::AbstractVector{<:Integer},
        edgeweight::AbstractVector,
        annotation_columns::NamedTuple = NamedTuple(),
    )::EdgeTable
    structural_columns = (
        edgekey = StructureKeyType.(edgekey),
        src_nodekey = StructureKeyType.(src_nodekey),
        dst_nodekey = StructureKeyType.(dst_nodekey),
        edgeweight = normalize_edgeweight_vector(edgeweight),
    )
    normalized_annotations = normalize_annotation_columns(annotation_columns, "edge")
    columns = merge_table_columns(structural_columns, normalized_annotations, "edge")
    return EdgeTable(columns)
end

function lineagetable_nrows(table::AbstractLineageTable)::Int
    return lineagetable_nrows(getfield(table, :columns))
end

function lineagetable_nrows(columns::NamedTuple)::Int
    lengths = map(length, values(columns))
    isempty(lengths) && return 0
    first_length = first(lengths)
    all(==(first_length), lengths) || throw(ArgumentError("All columns in a LineagesIO table must have the same length."))
    return first_length
end

function lineage_schema(columns::NamedTuple)::Tables.Schema
    return Tables.Schema(Tuple(keys(columns)), map(eltype, values(columns)))
end

function normalize_optional_string_vector(values::AbstractVector)::Vector{OptionalString}
    return OptionalString[value === nothing ? nothing : String(value) for value in values]
end

function normalize_edgeweight_vector(values::AbstractVector)::Vector{EdgeWeightType}
    normalized_values = EdgeWeightType[]
    for value in values
        if value === nothing
            push!(normalized_values, nothing)
        else
            push!(normalized_values, Float64(value))
        end
    end
    return normalized_values
end

function normalize_annotation_columns(annotation_columns::NamedTuple, scope::AbstractString)::NamedTuple
    normalized_columns = NamedTuple()
    for name in keys(annotation_columns)
        raw_column = getproperty(annotation_columns, name)
        normalized_column = OptionalString[]
        for value in raw_column
            if value === nothing
                push!(normalized_column, nothing)
            elseif value isa AbstractString
                push!(normalized_column, String(value))
            else
                throw(ArgumentError("Retained $(scope) annotation column `$(name)` must store `Union{Nothing, String}` values."))
            end
        end
        normalized_columns = merge(normalized_columns, NamedTuple{(name,)}((normalized_column,)))
    end
    return normalized_columns
end

function merge_table_columns(structural_columns::NamedTuple, annotation_columns::NamedTuple, scope::AbstractString)::NamedTuple
    conflicting_names = intersect(Tuple(keys(structural_columns)), Tuple(keys(annotation_columns)))
    isempty(conflicting_names) || throw(ArgumentError("Retained $(scope) annotation names conflict with structural $(scope) fields: $(join(string.(conflicting_names), ", "))."))
    return merge(structural_columns, annotation_columns)
end
