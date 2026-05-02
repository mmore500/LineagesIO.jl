const ALIFE_ID_COLUMN = :id
const ALIFE_ANCESTOR_LIST_COLUMN = :ancestor_list
const ALIFE_ANCESTOR_ID_COLUMN = :ancestor_id

struct ParsedAlifeRow
    id::Int
    ancestor_ids::Vector{Int}
    annotations::Dict{Symbol, String}
    record_index::Int
end

function build_alife_store(
    text::String,
    source_path::OptionalString,
)::LineageGraphStore
    return build_alife_store(text, source_path, TablesOnlyLoadRequest())
end

function build_alife_store(
    text::String,
    source_path::OptionalString,
    request::AbstractLoadRequest,
)::LineageGraphStore
    header, rows = parse_alife_source(text, source_path)
    return build_alife_store_from_rows(header, rows, source_path, request)
end

function build_alife_store_from_table(
    table,
    source_path::OptionalString,
    request::AbstractLoadRequest,
)::LineageGraphStore
    header, rows = parse_alife_table(table, source_path)
    return build_alife_store_from_rows(header, rows, source_path, request)
end

function build_alife_store_from_rows(
    header::Vector{Symbol},
    rows::Vector{ParsedAlifeRow},
    source_path::OptionalString,
    request::AbstractLoadRequest,
)::LineageGraphStore
    annotation_names = collect_alife_annotation_names(header)
    components = partition_alife_components(rows, source_path)
    graph_assets = [
        build_alife_graph_asset(component, graph_index, source_path, annotation_names)
        for (graph_index, component) in enumerate(components)
    ]
    graph_assets = materialize_graphs(graph_assets, request)
    graph_count = length(graph_assets)
    source_table = SourceTable(
        source_idx = [1],
        source_path = [source_path],
        collection_count = [1],
        graph_count = [graph_count],
    )
    collection_table = CollectionTable(
        collection_idx = [1],
        source_idx = [1],
        collection_label = [nothing],
        graph_count = [graph_count],
    )
    graph_table = GraphTable(
        index = [graph_asset.index for graph_asset in graph_assets],
        source_idx = [graph_asset.source_idx for graph_asset in graph_assets],
        collection_idx = [graph_asset.collection_idx for graph_asset in graph_assets],
        collection_graph_idx = [graph_asset.collection_graph_idx for graph_asset in graph_assets],
        collection_label = [graph_asset.collection_label for graph_asset in graph_assets],
        graph_label = [graph_asset.graph_label for graph_asset in graph_assets],
        node_count = [lineagetable_nrows(graph_asset.node_table) for graph_asset in graph_assets],
        edge_count = [lineagetable_nrows(graph_asset.edge_table) for graph_asset in graph_assets],
    )
    graphs = GraphAssetIterator(graph_assets)
    return LineageGraphStore(
        source_table,
        collection_table,
        graph_table,
        graphs,
    )
end

function parse_alife_source(
    text::AbstractString,
    source_path::OptionalString,
)::Tuple{Vector{Symbol}, Vector{ParsedAlifeRow}}
    isempty(strip(text)) && throw(ArgumentError(format_alife_error(source_path, "alife sources must contain at least one header row.")))
    raw_matrix = try
        DelimitedFiles.readdlm(IOBuffer(String(text)), ',', String; quotes = true)
    catch err
        throw(ArgumentError(format_alife_error(source_path, "could not parse delimited input: $(sprint(showerror, err))")))
    end
    matrix_rows = size(raw_matrix, 1)
    matrix_rows >= 1 || throw(ArgumentError(format_alife_error(source_path, "alife sources must contain at least one header row.")))
    header = Symbol[Symbol(strip(raw_matrix[1, column_index])) for column_index in 1:size(raw_matrix, 2)]
    validate_alife_header(header, source_path)
    id_column_index = findfirst(==(ALIFE_ID_COLUMN), header)
    ancestor_list_index = findfirst(==(ALIFE_ANCESTOR_LIST_COLUMN), header)
    ancestor_id_index = findfirst(==(ALIFE_ANCESTOR_ID_COLUMN), header)

    rows = ParsedAlifeRow[]
    seen_ids = Dict{Int, Int}()
    for matrix_row_index in 2:matrix_rows
        record_index = matrix_row_index - 1
        record = @view raw_matrix[matrix_row_index, :]
        all(field -> isempty(strip(field)), record) && continue
        id = parse_alife_id(record[id_column_index], record_index, source_path)
        if haskey(seen_ids, id)
            throw(ArgumentError(format_alife_error(
                source_path,
                "duplicate `id=$(id)` at data record $(record_index); previously seen at record $(seen_ids[id]).",
            )))
        end
        seen_ids[id] = record_index
        raw_ancestor_ids = if ancestor_list_index !== nothing
            parse_alife_ancestor_list(record[ancestor_list_index], record_index, source_path)
        else
            parse_alife_ancestor_id(record[ancestor_id_index], id, record_index, source_path)
        end
        ancestor_ids = Int[ancestor_id for ancestor_id in raw_ancestor_ids if ancestor_id != id]
        annotations = Dict{Symbol, String}()
        for (column_index, column_name) in enumerate(header)
            column_index == id_column_index && continue
            ancestor_list_index !== nothing && column_index == ancestor_list_index && continue
            ancestor_id_index !== nothing && column_index == ancestor_id_index && continue
            value = strip(record[column_index])
            isempty(value) && continue
            annotations[column_name] = String(value)
        end
        push!(rows, ParsedAlifeRow(id, ancestor_ids, annotations, record_index))
    end
    isempty(rows) && throw(ArgumentError(format_alife_error(source_path, "alife sources must contain at least one data row after the header.")))

    for row in rows
        for ancestor_id in row.ancestor_ids
            haskey(seen_ids, ancestor_id) || throw(ArgumentError(format_alife_error(
                source_path,
                "data record $(row.record_index) references unknown ancestor `id=$(ancestor_id)` for `id=$(row.id)`.",
            )))
        end
    end
    return header, rows
end

function validate_alife_header(header::Vector{Symbol}, source_path::OptionalString)::Nothing
    isempty(header) && throw(ArgumentError(format_alife_error(source_path, "alife header row may not be empty.")))
    ALIFE_ID_COLUMN in header || throw(ArgumentError(format_alife_error(source_path, "alife sources must declare a required `id` header column.")))
    has_ancestor_list = ALIFE_ANCESTOR_LIST_COLUMN in header
    has_ancestor_id = ALIFE_ANCESTOR_ID_COLUMN in header
    (has_ancestor_list || has_ancestor_id) || throw(ArgumentError(format_alife_error(
        source_path,
        "alife sources must declare a required `ancestor_list` or `ancestor_id` header column.",
    )))
    (has_ancestor_list && has_ancestor_id) && throw(ArgumentError(format_alife_error(
        source_path,
        "alife sources may declare either `ancestor_list` or `ancestor_id`, but not both.",
    )))
    seen = Set{Symbol}()
    for column_name in header
        column_name in seen && throw(ArgumentError(format_alife_error(source_path, "duplicate header column `$(column_name)`.")))
        push!(seen, column_name)
    end
    return nothing
end

function collect_alife_annotation_names(header::Vector{Symbol})::Vector{Symbol}
    return Symbol[
        column_name for column_name in header
        if column_name != ALIFE_ID_COLUMN
            && column_name != ALIFE_ANCESTOR_LIST_COLUMN
            && column_name != ALIFE_ANCESTOR_ID_COLUMN
    ]
end

function parse_alife_id(field::AbstractString, record_index::Int, source_path::OptionalString)::Int
    token = strip(field)
    isempty(token) && throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) is missing the required `id` value.")))
    parsed_id = try
        parse(Int, token)
    catch
        throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) has a non-integer `id` value `$(token)`.")))
    end
    parsed_id < 0 && throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) has a negative `id` value `$(parsed_id)`; alife `id` values must be non-negative.")))
    return parsed_id
end

function parse_alife_ancestor_list(field::AbstractString, record_index::Int, source_path::OptionalString)::Vector{Int}
    token = strip(field)
    isempty(token) && return Int[]
    (startswith(token, '[') && endswith(token, ']')) || throw(ArgumentError(format_alife_error(
        source_path,
        "data record $(record_index) has a malformed `ancestor_list` `$(token)`; alife `ancestor_list` values must be bracketed `[...]`.",
    )))
    inner = strip(SubString(token, nextind(token, firstindex(token)), prevind(token, lastindex(token))))
    isempty(inner) && return Int[]
    uppercase(String(inner)) == "NONE" && return Int[]

    ancestor_ids = Int[]
    for raw_token in split(inner, ',')
        ancestor_token = strip(raw_token)
        isempty(ancestor_token) && continue
        if uppercase(String(ancestor_token)) == "NONE"
            throw(ArgumentError(format_alife_error(
                source_path,
                "data record $(record_index) lists `NONE` alongside other ancestors; `NONE` must be the sole `ancestor_list` token for basenode entries.",
            )))
        end
        parsed_ancestor_id = try
            parse(Int, ancestor_token)
        catch
            throw(ArgumentError(format_alife_error(
                source_path,
                "data record $(record_index) has a non-integer `ancestor_list` token `$(ancestor_token)`.",
            )))
        end
        parsed_ancestor_id < 0 && throw(ArgumentError(format_alife_error(
            source_path,
            "data record $(record_index) has a negative `ancestor_list` token `$(parsed_ancestor_id)`; alife `id` values must be non-negative.",
        )))
        push!(ancestor_ids, parsed_ancestor_id)
    end
    return ancestor_ids
end

function parse_alife_ancestor_id(field::AbstractString, self_id::Int, record_index::Int, source_path::OptionalString)::Vector{Int}
    token = strip(field)
    isempty(token) && throw(ArgumentError(format_alife_error(
        source_path,
        "data record $(record_index) is missing the required `ancestor_id` value; basenode entries must set `ancestor_id` equal to their own `id`.",
    )))
    parsed_ancestor_id = try
        parse(Int, token)
    catch
        throw(ArgumentError(format_alife_error(
            source_path,
            "data record $(record_index) has a non-integer `ancestor_id` value `$(token)`.",
        )))
    end
    parsed_ancestor_id < 0 && throw(ArgumentError(format_alife_error(
        source_path,
        "data record $(record_index) has a negative `ancestor_id` value `$(parsed_ancestor_id)`; alife `id` values must be non-negative.",
    )))
    return Int[parsed_ancestor_id]
end

function partition_alife_components(rows::Vector{ParsedAlifeRow}, source_path::OptionalString)::Vector{Vector{ParsedAlifeRow}}
    nrows = length(rows)
    nrows == 0 && return Vector{ParsedAlifeRow}[]
    index_by_id = Dict{Int, Int}()
    for (i, row) in enumerate(rows)
        index_by_id[row.id] = i
    end
    representative_for = collect(1:nrows)
    for (i, row) in enumerate(rows)
        for ancestor_id in row.ancestor_ids
            union_find_union!(representative_for, i, index_by_id[ancestor_id])
        end
    end
    grouped = Dict{Int, Vector{Int}}()
    for i in 1:nrows
        representative = union_find_representative!(representative_for, i)
        push!(get!(grouped, representative, Int[]), i)
    end
    component_keys = sort(collect(keys(grouped)); by = key -> minimum(grouped[key]))
    return [ParsedAlifeRow[rows[i] for i in grouped[key]] for key in component_keys]
end

function union_find_representative!(representative_for::Vector{Int}, x::Int)::Int
    while representative_for[x] != x
        representative_for[x] = representative_for[representative_for[x]]
        x = representative_for[x]
    end
    return x
end

function union_find_union!(representative_for::Vector{Int}, a::Int, b::Int)::Nothing
    representative_a = union_find_representative!(representative_for, a)
    representative_b = union_find_representative!(representative_for, b)
    representative_a == representative_b && return nothing
    representative_for[representative_a] = representative_b
    return nothing
end

function build_alife_graph_asset(
    component::Vector{ParsedAlifeRow},
    graph_index::Int,
    source_path::OptionalString,
    annotation_names::Vector{Symbol},
)::LineageGraphAsset
    basenode_rows = ParsedAlifeRow[row for row in component if isempty(row.ancestor_ids)]
    length(basenode_rows) == 1 || throw(ArgumentError(format_alife_error(
        source_path,
        "each connected alife component must declare exactly one basenode entry (with `[NONE]` `ancestor_list` or self-referencing `ancestor_id`); graph $(graph_index) yielded $(length(basenode_rows)) candidate basenodes.",
    )))
    basenode_row = first(basenode_rows)

    rows_by_id = Dict{Int, ParsedAlifeRow}(row.id => row for row in component)
    children_by_id = Dict{Int, Vector{Int}}()
    for row in component
        for ancestor_id in row.ancestor_ids
            push!(get!(children_by_id, ancestor_id, Int[]), row.id)
        end
    end

    nodekey_by_id = Dict{Int, StructureKeyType}()
    bfs_ordered_ids = Int[]
    nodekey_by_id[basenode_row.id] = StructureKeyType(1)
    push!(bfs_ordered_ids, basenode_row.id)
    queue_index = 1
    while queue_index <= length(bfs_ordered_ids)
        current_id = bfs_ordered_ids[queue_index]
        queue_index += 1
        child_ids = sort(get(children_by_id, current_id, Int[]))
        for child_id in child_ids
            haskey(nodekey_by_id, child_id) && continue
            nodekey_by_id[child_id] = StructureKeyType(length(bfs_ordered_ids) + 1)
            push!(bfs_ordered_ids, child_id)
        end
    end
    if length(bfs_ordered_ids) != length(component)
        throw(ArgumentError(format_alife_error(
            source_path,
            "alife graph $(graph_index) has $(length(component) - length(bfs_ordered_ids)) entries unreachable from its basenode; this typically indicates an ancestor cycle.",
        )))
    end

    nodekeys = StructureKeyType[]
    labels = String[]
    node_annotation_rows = Dict{Symbol, String}[]
    for id in bfs_ordered_ids
        push!(nodekeys, nodekey_by_id[id])
        push!(labels, string(id))
        push!(node_annotation_rows, copy(rows_by_id[id].annotations))
    end
    annotation_columns = build_annotation_columns(node_annotation_rows, copy(annotation_names))
    node_table = NodeTable(nodekey = nodekeys, label = labels, annotation_columns = annotation_columns)

    edgekeys = StructureKeyType[]
    src_nodekeys = StructureKeyType[]
    dst_nodekeys = StructureKeyType[]
    edgeweights = EdgeWeightType[]
    for id in bfs_ordered_ids
        row = rows_by_id[id]
        for ancestor_id in row.ancestor_ids
            push!(edgekeys, StructureKeyType(length(edgekeys) + 1))
            push!(src_nodekeys, nodekey_by_id[ancestor_id])
            push!(dst_nodekeys, nodekey_by_id[id])
            push!(edgeweights, nothing)
        end
    end
    edge_table = EdgeTable(
        edgekey = edgekeys,
        src_nodekey = src_nodekeys,
        dst_nodekey = dst_nodekeys,
        edgeweight = edgeweights,
    )
    return LineageGraphAsset(
        graph_index,
        1,
        1,
        graph_index,
        nothing,
        nothing,
        node_table,
        edge_table,
        nothing,
        nothing,
        source_path,
    )
end

function format_alife_error(source_path::OptionalString, message::AbstractString)::String
    source_label = source_path === nothing ? "<input>" : source_path
    return "Alife standard parse error in $(source_label): $(message)"
end

"""
    load_alife_table(table; source_path = nothing) -> LineageGraphStore
    load_alife_table(table, NodeT; source_path = nothing) -> LineageGraphStore
    load_alife_table(table, basenode; source_path = nothing) -> LineageGraphStore
    load_alife_table(table; builder = fn, source_path = nothing) -> LineageGraphStore

Load a Tables.jl-compatible columnar object whose schema follows the alife
phylogeny data standard. The table must declare an `id` column and exactly
one of `ancestor_list` or `ancestor_id`. Root entries are identified by
`[NONE]`/empty `ancestor_list` or by `ancestor_id` equal to the row's own
`id`. All other columns are retained as node annotations.
"""
function load_alife_table(
    table,
    args...;
    builder = nothing,
    source_path::Union{Nothing, AbstractString} = nothing,
)::LineageGraphStore
    Tables.istable(typeof(table)) || throw(ArgumentError("`load_alife_table` requires a Tables.jl-compatible input, but received `$(typeof(table))`. Pass a `NamedTuple` of vectors, a `DataFrame`, or any other value satisfying the Tables.jl interface."))
    request = build_load_request(args, builder)
    return build_alife_store_from_table(table, normalize_source_path(source_path), request)
end

function parse_alife_table(
    table,
    source_path::OptionalString,
)::Tuple{Vector{Symbol}, Vector{ParsedAlifeRow}}
    column_table = Tables.columns(table)
    column_name_tuple = Tables.columnnames(column_table)
    header = Symbol[Symbol(name) for name in column_name_tuple]
    validate_alife_header(header, source_path)
    id_column_index = findfirst(==(ALIFE_ID_COLUMN), header)
    ancestor_list_index = findfirst(==(ALIFE_ANCESTOR_LIST_COLUMN), header)
    ancestor_id_index = findfirst(==(ALIFE_ANCESTOR_ID_COLUMN), header)

    id_column = Tables.getcolumn(column_table, header[id_column_index])
    ancestor_list_column = ancestor_list_index === nothing ? nothing : Tables.getcolumn(column_table, header[ancestor_list_index])
    ancestor_id_column = ancestor_id_index === nothing ? nothing : Tables.getcolumn(column_table, header[ancestor_id_index])
    nrows = length(id_column)
    nrows >= 1 || throw(ArgumentError(format_alife_error(source_path, "alife sources must contain at least one data row.")))

    rows = ParsedAlifeRow[]
    seen_ids = Dict{Int, Int}()
    for record_index in 1:nrows
        id = coerce_alife_id(id_column[record_index], record_index, source_path)
        if haskey(seen_ids, id)
            throw(ArgumentError(format_alife_error(
                source_path,
                "duplicate `id=$(id)` at data record $(record_index); previously seen at record $(seen_ids[id]).",
            )))
        end
        seen_ids[id] = record_index
        raw_ancestor_ids = if ancestor_list_column !== nothing
            coerce_alife_ancestor_list(ancestor_list_column[record_index], record_index, source_path)
        else
            coerce_alife_ancestor_id(ancestor_id_column[record_index], id, record_index, source_path)
        end
        ancestor_ids = Int[ancestor_id for ancestor_id in raw_ancestor_ids if ancestor_id != id]
        annotations = Dict{Symbol, String}()
        for (column_index, column_name) in enumerate(header)
            column_index == id_column_index && continue
            ancestor_list_index !== nothing && column_index == ancestor_list_index && continue
            ancestor_id_index !== nothing && column_index == ancestor_id_index && continue
            cell = Tables.getcolumn(column_table, column_name)[record_index]
            cell === missing && continue
            cell === nothing && continue
            value_str = strip(string(cell))
            isempty(value_str) && continue
            annotations[column_name] = String(value_str)
        end
        push!(rows, ParsedAlifeRow(id, ancestor_ids, annotations, record_index))
    end
    isempty(rows) && throw(ArgumentError(format_alife_error(source_path, "alife sources must contain at least one data row.")))

    for row in rows
        for ancestor_id in row.ancestor_ids
            haskey(seen_ids, ancestor_id) || throw(ArgumentError(format_alife_error(
                source_path,
                "data record $(row.record_index) references unknown ancestor `id=$(ancestor_id)` for `id=$(row.id)`.",
            )))
        end
    end
    return header, rows
end

function coerce_alife_id(value, record_index::Int, source_path::OptionalString)::Int
    value === missing && throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) is missing the required `id` value.")))
    value === nothing && throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) is missing the required `id` value.")))
    if value isa Integer
        value < 0 && throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) has a negative `id` value `$(value)`; alife `id` values must be non-negative.")))
        return Int(value)
    end
    if value isa AbstractString
        return parse_alife_id(value, record_index, source_path)
    end
    throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) `id` value `$(value)` of type `$(typeof(value))` is not coercible to an integer.")))
end

function coerce_alife_ancestor_list(value, record_index::Int, source_path::OptionalString)::Vector{Int}
    (value === missing || value === nothing) && return Int[]
    value isa AbstractString && return parse_alife_ancestor_list(value, record_index, source_path)
    if value isa AbstractVector
        ancestor_ids = Int[]
        for element in value
            push!(ancestor_ids, coerce_alife_id(element, record_index, source_path))
        end
        return ancestor_ids
    end
    throw(ArgumentError(format_alife_error(
        source_path,
        "data record $(record_index) `ancestor_list` value `$(value)` of type `$(typeof(value))` is not coercible to a list of integers.",
    )))
end

function coerce_alife_ancestor_id(value, self_id::Int, record_index::Int, source_path::OptionalString)::Vector{Int}
    (value === missing || value === nothing) && throw(ArgumentError(format_alife_error(
        source_path,
        "data record $(record_index) is missing the required `ancestor_id` value; basenode entries must set `ancestor_id` equal to their own `id`.",
    )))
    if value isa Integer
        value < 0 && throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) has a negative `ancestor_id` value `$(value)`; alife `id` values must be non-negative.")))
        return Int[Int(value)]
    end
    value isa AbstractString && return parse_alife_ancestor_id(value, self_id, record_index, source_path)
    throw(ArgumentError(format_alife_error(
        source_path,
        "data record $(record_index) `ancestor_id` value `$(value)` of type `$(typeof(value))` is not coercible to an integer.",
    )))
end
